import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._local);

  final ExpenseLocalDataSource _local;

  @override
  Future<int> add(Expense expense) => _local.insert(expense);

  @override
  Future<void> delete(int id) => _local.delete(id);

  @override
  Future<List<Expense>> getAll() => _local.getAll();

  @override
  Future<List<Expense>> getInRange(DateTime start, DateTime end) =>
      _local.getInRange(start, end);

  @override
  Future<int> totalInRange(DateTime start, DateTime end) =>
      _local.totalInRange(start, end);

  @override
  Future<void> update(Expense expense) => _local.update(expense);
}
