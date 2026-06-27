import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc(this._repo) : super(const ScannerState()) {
    on<StartScan>(_onStart);
    on<ResetScanner>(
      (event, emit) => emit(const ScannerState()),
    );
  }

  final ScannerRepository _repo;

  Future<void> _onStart(StartScan event, Emitter<ScannerState> emit) async {
    emit(state.copyWith(status: ScannerStatus.scanning));
    try {
      final result = await _repo.scan(event.imageFile);
      emit(state.copyWith(
        status: ScannerStatus.success,
        scanned: result,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: ScannerStatus.error,
        error: err.toString(),
      ));
    }
  }
}
