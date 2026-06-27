import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class AddExpense extends ExpenseEvent {
  const AddExpense(this.expense);
  final Expense expense;
  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  const UpdateExpense(this.expense);
  final Expense expense;
  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  const DeleteExpense(this.expense);
  final Expense expense;
  @override
  List<Object?> get props => [expense];
}

class RestoreExpense extends ExpenseEvent {
  const RestoreExpense(this.expense);
  final Expense expense;
  @override
  List<Object?> get props => [expense];
}
