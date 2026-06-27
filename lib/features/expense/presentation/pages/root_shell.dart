import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/penny_mascot.dart';
import '../../../../core/widgets/penny_nav_bar.dart';
import '../../../../core/widgets/slide_route.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../scanner/data/datasources/anthropic_datasource.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../scanner/presentation/pages/scanner_page.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import 'add_expense_page.dart';
import 'home_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(const LoadExpenses());
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.charcoal.withValues(alpha: 0.45),
      builder: (_) => _AiQuickSheet(
        onParsed: (expense) {
          context.read<ExpenseBloc>().add(AddExpense(expense));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${expense.merchantName} dicatat!')),
          );
        },
        onScan: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(SlideRoute(page: const ScannerPage()));
        },
        onManual: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(SlideRoute(page: const AddExpensePage()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pages = [HomePage(), DashboardPage()];
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: PennyFloatingNavBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          if (i == 1) {
            context.read<DashboardBloc>().add(const LoadDashboard());
          }
        },
        onCenterAction: _showAddSheet,
        tabs: const [
          PennyNavTab(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Catatan',
          ),
          PennyNavTab(
            icon: Icons.donut_small_outlined,
            activeIcon: Icons.donut_small_rounded,
            label: 'Ringkasan',
          ),
        ],
      ),
    );
  }
}

class _AiQuickSheet extends StatefulWidget {
  const _AiQuickSheet({
    required this.onParsed,
    required this.onScan,
    required this.onManual,
  });

  final ValueChanged<Expense> onParsed;
  final VoidCallback onScan;
  final VoidCallback onManual;

  @override
  State<_AiQuickSheet> createState() => _AiQuickSheetState();
}

class _AiQuickSheetState extends State<_AiQuickSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final expense = await sl<AnthropicReceiptDataSource>().parseText(text);
      widget.onParsed(expense);
    } on ScannerException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Terjadi kesalahan, coba lagi.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'CATAT PENGELUARAN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cerita ke Penny',
                  style: GoogleFonts.fraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _error != null
                          ? AppColors.error
                          : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          autofocus: true,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            if (!_loading) _submit();
                          },
                          decoration: InputDecoration(
                            hintText: 'mis. 10000 makan di warteg',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 15,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _loading
                            ? const SizedBox(
                                width: 36,
                                height: 36,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send_rounded),
                                color: AppColors.charcoal,
                                onPressed: _submit,
                              ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // ponytail: scan foto dimatikan — endpoint tak punya model vision
                // gratis (deepseek-v4-flash-free text-only). Aktifkan lagi tombol
                // Scan struk + onScan setelah ada model vision (mis. claude-haiku-4-5).
                Row(
                  children: [
                    _SheetOption(
                      icon: Icons.edit_note_rounded,
                      label: 'Tulis manual',
                      onTap: widget.onManual,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onDone});

  final VoidCallback onDone;

  static const _key = 'penny.onboarding.done';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'v0.1',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Center(child: PennyMascot(size: 140)),
              const SizedBox(height: 28),
              Text(
                'Halo, aku\nPenny.',
                style: GoogleFonts.fraunces(
                  fontSize: 48,
                  fontWeight: FontWeight.w500,
                  height: 1.05,
                  letterSpacing: -1.4,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Aku bantu kamu nyatet pengeluaran tanpa drama. Foto struk, biar aku yang baca. Atau ketik manual juga oke.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await markDone();
                  onDone();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Mulai bareng Penny'),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.tagline,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
