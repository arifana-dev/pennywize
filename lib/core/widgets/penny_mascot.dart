import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class PennyMascot extends StatelessWidget {
  const PennyMascot({
    super.key,
    this.size = 120,
    this.withBackground = false,
  });

  final double size;
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    final mascot = SvgPicture.asset(
      'assets/svg/penny_mascot.svg',
      width: size,
      height: size,
    );

    if (!withBackground) return mascot;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: mascot,
    );
  }
}
