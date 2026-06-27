import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<int> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(int id);
  Future<List<Expense>> getAll();
  Future<List<Expense>> getInRange(DateTime start, DateTime end);
  Future<int> totalInRange(DateTime start, DateTime end);
}
