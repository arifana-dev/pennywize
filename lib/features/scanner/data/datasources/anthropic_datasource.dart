import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../expense/domain/entities/expense.dart';

class AnthropicReceiptDataSource {
  AnthropicReceiptDataSource({Dio? dio, FirebaseFirestore? firestore})
      : _dio = dio ?? Dio(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final Dio _dio;
  final FirebaseFirestore _firestore;

  static const _defaultEndpoint = 'https://opencode.ai/zen/v1/chat/completions';
  static const _defaultModel = 'deepseek-v4-flash-free';
  static const _defaultScanModel = 'deepseek-v4-flash-free';

  static const _systemPrompt =
      "You are Penny's receipt reading assistant. Extract info from receipt images and return ONLY valid JSON with keys: merchant_name (string), total_amount (number, no formatting), date (YYYY-MM-DD), category (one of: Makanan, Transport, Belanja, Kesehatan, Hiburan, Tagihan, Lainnya), items (array of {name: string, price: number} for each line item, empty array if none). If a field cannot be determined, use null. Return nothing else.";

  static const _textSystemPrompt =
      "You are Penny's expense parser. Parse natural language expense descriptions (in Indonesian or English) and return ONLY valid JSON with keys: merchant_name (string), total_amount (number, no formatting), date (YYYY-MM-DD or null if not mentioned), category (one of: Makanan, Transport, Belanja, Kesehatan, Hiburan, Tagihan, Lainnya). Infer category from context. For merchant_name: use the merchant/place name if mentioned, otherwise use the item or activity as the name (e.g. 'beli bh' → 'Beli BH', 'makan warteg' → 'Warteg'). Never return null for merchant_name. Return nothing else.";

  Future<ScanResult> scan(File imageFile) async {
    final config = await _loadConfig();
    final bytes = await imageFile.readAsBytes();
    final mediaType = _detectMediaType(imageFile.path);
    final base64Image = base64Encode(bytes);

    try {
      final response = await _dio.post(
        config.endpoint,
        options: Options(
          headers: {
            'authorization': 'Bearer ${config.apiKey}',
            'content-type': 'application/json',
            'http-referer': 'https://penny-expense-ai.firebaseapp.com',
            'x-title': 'Penny',
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': _defaultScanModel,
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      'Extract receipt fields and return JSON only. No prose.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mediaType;base64,$base64Image',
                  },
                },
              ],
            },
          ],
        },
      );

      final text = _extractText(response.data);
      final jsonStr = _extractJson(text);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _toScanResult(map);
    } on DioException catch (err) {
      if (kDebugMode) debugPrint('OpenRouter API error: ${err.message}');
      throw ScannerException(
        'Penny gak bisa baca strukmu: ${err.response?.statusCode ?? err.message}',
      );
    } on FormatException catch (_) {
      throw const ScannerException(
        'Penny bingung baca hasilnya. Coba foto yang lebih jelas ya.',
      );
    }
  }

  Future<Expense> parseText(String text) async {
    final config = await _loadConfig();
    try {
      final response = await _dio.post(
        config.endpoint,
        options: Options(
          headers: {
            'authorization': 'Bearer ${config.apiKey}',
            'content-type': 'application/json',
            'http-referer': 'https://penny-expense-ai.firebaseapp.com',
            'x-title': 'Penny',
          },
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': config.model,
          'messages': [
            {'role': 'system', 'content': _textSystemPrompt},
            {'role': 'user', 'content': text},
          ],
        },
      );
      if (kDebugMode) debugPrint('[AI] request: $text');
      if (kDebugMode) debugPrint('[AI] response: ${response.data}');
      final raw = _extractText(response.data);
      final jsonStr = _extractJson(raw);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _toScanResult(map).expense;
    } on DioException catch (err) {
      if (kDebugMode)
        debugPrint('[AI] error: ${err.response?.data ?? err.message}');
      throw ScannerException(
        'Penny gagal parsing teksmu: ${err.response?.statusCode ?? err.message}',
      );
    } on FormatException catch (_) {
      throw const ScannerException(
        'Penny bingung parsing hasilnya. Coba tulis ulang.',
      );
    }
  }

  Future<_AiConfig> _loadConfig() async {
    return const _AiConfig(
      apiKey: String.fromEnvironment('OPENCODE_API_KEY'),
      model: _defaultModel,
      endpoint: _defaultEndpoint,
    );
  }

  String _detectMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  String _extractText(dynamic data) {
    if (data is Map<String, dynamic>) {
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final message = choices.first['message'];
        if (message is Map<String, dynamic>) {
          final content = message['content'];
          if (content is String) return content;
        }
      }
    }
    throw const FormatException('No text content in response');
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end < 0 || end <= start) {
      throw const FormatException('No JSON object in response');
    }
    return text.substring(start, end + 1);
  }

  ScanResult _toScanResult(Map<String, dynamic> map) {
    final merchant = (map['merchant_name'] as String?)?.trim();
    final totalRaw = map['total_amount'];
    int amount = 0;
    if (totalRaw is num) {
      amount = totalRaw.toInt();
    } else if (totalRaw is String) {
      amount = int.tryParse(totalRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    final dateStr = map['date'] as String?;
    final parsed = DateUtilsX.tryParseIso(dateStr) ?? DateTime.now();
    final category = ExpenseCategory.fromString(map['category'] as String?);

    final rawItems = map['items'];
    final items = <ReceiptItem>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          final name = (item['name'] as String?)?.trim() ?? '';
          final priceRaw = item['price'];
          final price = priceRaw is num
              ? priceRaw.toInt()
              : int.tryParse(
                      priceRaw?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
                          '') ??
                  0;
          if (name.isNotEmpty) items.add(ReceiptItem(name: name, price: price));
        }
      }
    }

    return ScanResult(
      expense: Expense(
        merchantName: merchant?.isNotEmpty == true ? merchant! : 'Tanpa nama',
        amount: amount,
        date: parsed,
        category: category,
      ),
      items: items,
    );
  }
}

class _AiConfig {
  const _AiConfig({
    required this.apiKey,
    required this.model,
    required this.endpoint,
  });

  final String apiKey;
  final String model;
  final String endpoint;
}

class ReceiptItem {
  const ReceiptItem({required this.name, required this.price});
  final String name;
  final int price;
}

class ScanResult {
  const ScanResult({required this.expense, this.items = const []});
  final Expense expense;
  final List<ReceiptItem> items;
}

class ScannerException implements Exception {
  const ScannerException(this.message);
  final String message;
  @override
  String toString() => message;
}
