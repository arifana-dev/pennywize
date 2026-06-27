import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/datasources/anthropic_datasource.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();
  @override
  List<Object?> get props => [];
}

class StartScan extends ScannerEvent {
  const StartScan(this.imageFile);
  final File imageFile;
  @override
  List<Object?> get props => [imageFile.path];
}

class ResetScanner extends ScannerEvent {
  const ResetScanner();
}

enum ScannerStatus { initial, scanning, success, error }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStatus.initial,
    this.scanned,
    this.error,
  });

  final ScannerStatus status;
  final ScanResult? scanned;
  final String? error;

  ScannerState copyWith({
    ScannerStatus? status,
    ScanResult? scanned,
    String? error,
  }) {
    return ScannerState(
      status: status ?? this.status,
      scanned: scanned ?? this.scanned,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, scanned, error];
}
