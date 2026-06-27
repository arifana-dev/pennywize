import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/penny_empty_state.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/penny_greeting.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<ExpenseBloc>().add(const LoadExpenses());
                await Future<void>.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: PennyGreeting(todayTotal: state.todayTotal),
                  ),
                  if (state.status == ExpenseStatus.loading)
                    const _ShimmerList()
                  else if (state.expenses.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: PennyEmptyState(
                        title: 'Catatan masih kosong',
                        message: AppStrings.emptyExpenses,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 130),
                      sliver: SliverList.separated(
                        itemCount: state.expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final expense = state.expenses[i];
                          return Dismissible(
                            key: ValueKey('exp-${expense.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 22),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) {
                              final bloc = context.read<ExpenseBloc>();
                              final messenger = ScaffoldMessenger.of(context);
                              bloc.add(DeleteExpense(expense));
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${expense.merchantName} dihapus'),
                                  action: SnackBarAction(
                                    label: 'URUNGKAN',
                                    onPressed: () =>
                                        bloc.add(RestoreExpense(expense)),
                                  ),
                                ),
                              );
                            },
                            child: ExpenseListItem(expense: expense),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
      sliver: SliverList.separated(
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppColors.divider,
          highlightColor: AppColors.surface,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}
