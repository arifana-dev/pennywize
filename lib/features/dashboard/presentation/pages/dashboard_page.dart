import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../../../expense/presentation/bloc/expense_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import '../services/pdf_export_service.dart';
import '../widgets/category_breakdown_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
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
                    'RINGKASAN',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  _ExportButton(
                    expenses: state.expenses,
                    period: state.period,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Lihat ke mana\nuangmu pergi.',
                style: GoogleFonts.fraunces(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  letterSpacing: -0.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _PeriodToggle(period: state.period),
              const SizedBox(height: 16),
              const _TotalsRow(),
              const SizedBox(height: 16),
              if (state.weeklyComment.isNotEmpty)
                _PennyComment(state.weeklyComment),
              const SizedBox(height: 16),
              CategoryBreakdownChart(expenses: state.expenses),
              const SizedBox(height: 16),
              _RecentList(state: state),
            ],
          ),
        );
      },
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.expenses.isEmpty) return const SizedBox.shrink();
    final preview = state.expenses.take(5).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transaksi teratas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${state.expenses.length} entri',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...preview.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: e.category.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.merchantName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(e.amount),
                      style: GoogleFonts.fraunces(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PennyComment extends StatelessWidget {
  const _PennyComment(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATATAN PENNY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: AppColors.textPrimary,
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

class _TotalsRow extends StatelessWidget {
  const _TotalsRow();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'HARI INI',
                amount: state.todayTotal,
                onLight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'BULAN INI',
                amount: state.monthTotal,
                onLight: false,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.onLight,
  });

  final String label;
  final int amount;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final bg = onLight ? AppColors.card : AppColors.charcoal;
    final fg = onLight ? AppColors.textPrimary : Colors.white;
    final sub = onLight
        ? AppColors.textMuted
        : Colors.white.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: onLight
            ? Border.all(color: AppColors.divider)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: sub,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            CurrencyFormatter.format(amount),
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatefulWidget {
  const _ExportButton({required this.expenses, required this.period});

  final List<Expense> expenses;
  final DashboardPeriod period;

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _loading = false;

  Future<void> _export() async {
    if (_loading || widget.expenses.isEmpty) return;
    setState(() => _loading = true);
    try {
      await PdfExportService.export(
        expenses: widget.expenses,
        period: widget.period,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal export PDF, coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textMuted,
              ),
            )
          : IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              color: widget.expenses.isEmpty
                  ? AppColors.outline
                  : AppColors.textMuted,
              tooltip: 'Export PDF',
              onPressed: _export,
            ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period});
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: DashboardPeriod.values.map((p) {
          final selected = p == period;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.read<DashboardBloc>().add(ChangePeriod(p)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.charcoal : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  p.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
