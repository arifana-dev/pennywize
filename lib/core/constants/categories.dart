import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ExpenseCategory {
  makanan,
  transport,
  belanja,
  kesehatan,
  hiburan,
  tagihan,
  lainnya;

  String get label {
    switch (this) {
      case ExpenseCategory.makanan:
        return 'Makanan';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.belanja:
        return 'Belanja';
      case ExpenseCategory.kesehatan:
        return 'Kesehatan';
      case ExpenseCategory.hiburan:
        return 'Hiburan';
      case ExpenseCategory.tagihan:
        return 'Tagihan';
      case ExpenseCategory.lainnya:
        return 'Lainnya';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.makanan:
        return '🍜';
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.belanja:
        return '🛍️';
      case ExpenseCategory.kesehatan:
        return '💊';
      case ExpenseCategory.hiburan:
        return '🎮';
      case ExpenseCategory.tagihan:
        return '📱';
      case ExpenseCategory.lainnya:
        return '📦';
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.makanan:
        return AppColors.primary;
      case ExpenseCategory.transport:
        return const Color(0xFF6E8B9E);
      case ExpenseCategory.belanja:
        return const Color(0xFFB8593B);
      case ExpenseCategory.kesehatan:
        return const Color(0xFF7A9B6E);
      case ExpenseCategory.hiburan:
        return const Color(0xFF9B6B8E);
      case ExpenseCategory.tagihan:
        return AppColors.accent;
      case ExpenseCategory.lainnya:
        return const Color(0xFF8C7A6B);
    }
  }

  static ExpenseCategory fromString(String? value) {
    if (value == null) return ExpenseCategory.lainnya;
    final lower = value.toLowerCase().trim();
    for (final c in ExpenseCategory.values) {
      if (c.label.toLowerCase() == lower || c.name == lower) return c;
    }
    return ExpenseCategory.lainnya;
  }
}
