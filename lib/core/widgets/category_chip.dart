import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/categories.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.compact = false,
  });

  final ExpenseCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = category.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: TextStyle(fontSize: compact ? 12 : 14)),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: GoogleFonts.nunito(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 44});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        category.emoji,
        style: TextStyle(fontSize: size * 0.45),
      ),
    );
  }
}
