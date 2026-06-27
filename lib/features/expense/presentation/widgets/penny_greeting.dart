import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/slide_route.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class PennyGreeting extends StatelessWidget {
  const PennyGreeting({super.key, required this.todayTotal});

  final int todayTotal;

  String _message() {
    if (todayTotal < 50000) return AppStrings.pennyUnder50k;
    if (todayTotal < 200000) return AppStrings.pennyMid;
    return AppStrings.pennyOver200k;
  }

  String _greetingByHour() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateUtilsX.formatFull(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            formatter.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _greetingByHour(),
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _CircleIcon(
                  icon: Icons.tune_rounded,
                  tooltip: 'Pengaturan',
                  onTap: () => Navigator.of(context)
                      .push(SlideRoute(page: const SettingsPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Semantics(
              label:
                  'Pengeluaran hari ini ${CurrencyFormatter.format(todayTotal)}. ${_message()}',
              container: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PENGELUARAN HARI INI',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      CurrencyFormatter.format(todayTotal),
                      style: GoogleFonts.fraunces(
                        fontSize: 42,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1.2,
                        height: 1.05,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                        height: 1, color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 14),
                    Text(
                      _message(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Text(
                  'Riwayat',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Terbaru',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.tune_rounded,
                size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
