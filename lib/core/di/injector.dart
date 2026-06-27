import 'package:get_it/get_it.dart';

import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/expense/data/datasources/expense_local_datasource.dart';
import '../../features/expense/data/repositories/expense_repository_impl.dart';
import '../../features/expense/domain/repositories/expense_repository.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/scanner/data/datasources/anthropic_datasource.dart';
import '../../features/scanner/data/repositories/scanner_repository_impl.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDi() async {
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSource(),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<AnthropicReceiptDataSource>(
    () => AnthropicReceiptDataSource(),
  );
  sl.registerLazySingleton<ScannerRepository>(
    () => ScannerRepositoryImpl(sl()),
  );

  sl.registerFactory<ExpenseBloc>(() => ExpenseBloc(sl()));
  sl.registerFactory<DashboardBloc>(() => DashboardBloc(sl()));
  sl.registerFactory<ScannerBloc>(() => ScannerBloc(sl()));
}
