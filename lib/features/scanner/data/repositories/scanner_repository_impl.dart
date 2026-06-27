import 'dart:io';
import '../datasources/anthropic_datasource.dart';

abstract class ScannerRepository {
  Future<ScanResult> scan(File imageFile);
}

class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl(this._datasource);

  final AnthropicReceiptDataSource _datasource;

  @override
  Future<ScanResult> scan(File imageFile) => _datasource.scan(imageFile);
}
