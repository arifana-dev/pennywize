import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/currency_formatter.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _appGroupId = 'group.id.arifana.penny';
  static const _packageName = 'id.arifana.penny';
  static const _androidWidgetSmall = 'PennyWidgetSmall';
  static const _androidWidgetMedium = 'PennyWidgetMedium';

  static const keyTodayTotal = 'today_total';
  static const keyTodayTotalText = 'today_total_text';
  static const keyTransactionCount = 'transaction_count';
  static const keyTransactionLabel = 'transaction_label';
  static const keyPennyMessage = 'penny_message';
  static const keyBgImagePath = 'bg_image_path';
  static const keyBgAssetName = 'bg_asset_name';

  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  Future<void> refresh({
    required int todayTotal,
    required int transactionCount,
  }) async {
    if (!_supportedPlatform()) return;

    final message = AppStrings.widgetMessageOfDay(DateTime.now());
    await HomeWidget.saveWidgetData<int>(keyTodayTotal, todayTotal);
    await HomeWidget.saveWidgetData<String>(
      keyTodayTotalText,
      CurrencyFormatter.format(todayTotal),
    );
    await HomeWidget.saveWidgetData<int>(keyTransactionCount, transactionCount);
    await HomeWidget.saveWidgetData<String>(
      keyTransactionLabel,
      'dari $transactionCount transaksi',
    );
    await HomeWidget.saveWidgetData<String>(keyPennyMessage, message);

    try {
      await HomeWidget.updateWidget(
        name: _androidWidgetSmall,
        androidName: _androidWidgetSmall,
      );
      await HomeWidget.updateWidget(
        name: _androidWidgetMedium,
        androidName: _androidWidgetMedium,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Widget update skipped: $e');
      }
    }
  }

  /// Asks the launcher to pin the Penny widget. Android 8.0+ (API 26) only;
  /// older versions / unsupported launchers silently do nothing.
  Future<bool> requestPinWidget() async {
    if (!_supportedPlatform()) return false;
    try {
      await HomeWidget.requestPinWidget(
        name: _androidWidgetSmall,
        androidName: _androidWidgetSmall,
        qualifiedAndroidName: '$_packageName.$_androidWidgetSmall',
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Pin widget failed: $e');
      return false;
    }
  }

  Future<void> setBuiltInBackground(String assetName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBgAssetName, assetName);
    await prefs.remove(keyBgImagePath);
    await HomeWidget.saveWidgetData<String>(keyBgAssetName, assetName);
    await HomeWidget.saveWidgetData<String>(keyBgImagePath, '');
    await _pingWidget();
  }

  Future<void> setCustomBackground(File file) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBgImagePath, file.path);
    await prefs.remove(keyBgAssetName);

    final bytes = await file.readAsBytes();
    final base64Img = base64Encode(bytes);
    await HomeWidget.saveWidgetData<String>(keyBgImagePath, file.path);
    await HomeWidget.saveWidgetData<String>('bg_image_b64', base64Img);
    await HomeWidget.saveWidgetData<String>(keyBgAssetName, '');
    await _pingWidget();
  }

  Future<({String? assetName, String? imagePath})> currentBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      assetName: prefs.getString(keyBgAssetName),
      imagePath: prefs.getString(keyBgImagePath),
    );
  }

  Future<void> _pingWidget() async {
    if (!_supportedPlatform()) return;
    try {
      await HomeWidget.updateWidget(
        name: _androidWidgetSmall,
        androidName: _androidWidgetSmall,
      );
      await HomeWidget.updateWidget(
        name: _androidWidgetMedium,
        androidName: _androidWidgetMedium,
      );
    } catch (_) {}
  }

  bool _supportedPlatform() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
