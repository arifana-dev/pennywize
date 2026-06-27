import 'package:equatable/equatable.dart';
import '../../../../core/constants/categories.dart';

class Expense extends Equatable {
  const Expense({
    this.id,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.createdAt,
  });

  final int? id;
  final String merchantName;
  final int amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? notes;
  final DateTime? createdAt;

  Expense copyWith({
    int? id,
    String? merchantName,
    int? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, merchantName, amount, date, category, notes, createdAt];
}
