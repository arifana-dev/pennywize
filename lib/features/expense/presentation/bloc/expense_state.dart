import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

enum ExpenseStatus { initial, loading, loaded, error }

class ExpenseState extends Equatable {
  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.todayTotal = 0,
    this.monthTotal = 0,
    this.error,
  });

  final ExpenseStatus status;
  final List<Expense> expenses;
  final int todayTotal;
  final int monthTotal;
  final String? error;

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    int? todayTotal,
    int? monthTotal,
    String? error,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      todayTotal: todayTotal ?? this.todayTotal,
      monthTotal: monthTotal ?? this.monthTotal,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, expenses, todayTotal, monthTotal, error];
}
