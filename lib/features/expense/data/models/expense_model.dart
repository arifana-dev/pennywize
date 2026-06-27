import '../../../../core/constants/categories.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel {
  ExpenseModel._();

  static Map<String, dynamic> toMap(Expense e) {
    return {
      if (e.id != null) 'id': e.id,
      'merchant_name': e.merchantName,
      'amount': e.amount,
      'date': e.date.millisecondsSinceEpoch,
      'category': e.category.name,
      'notes': e.notes,
      'created_at': (e.createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      merchantName: map['merchant_name'] as String,
      amount: (map['amount'] as num).toInt(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: ExpenseCategory.fromString(map['category'] as String?),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }
}
