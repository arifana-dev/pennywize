import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/categories.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/domain/repositories/expense_repository.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repo) : super(const DashboardState()) {
    on<LoadDashboard>((event, emit) => _load(emit, state.period));
    on<ChangePeriod>((event, emit) => _load(emit, event.period));
  }

  final ExpenseRepository _repo;

  Future<void> _load(
    Emitter<DashboardState> emit,
    DashboardPeriod period,
  ) async {
    emit(state.copyWith(loading: true, period: period));
    final now = DateTime.now();

    DateTime start;
    DateTime end;
    switch (period) {
      case DashboardPeriod.today:
        start = DateUtilsX.startOfDay(now);
        end = DateUtilsX.endOfDay(now);
        break;
      case DashboardPeriod.week:
        start = DateUtilsX.startOfWeek(now);
        end = DateUtilsX.endOfDay(now);
        break;
      case DashboardPeriod.month:
        start = DateUtilsX.startOfMonth(now);
        end = DateUtilsX.endOfMonth(now);
        break;
    }

    final expenses = await _repo.getInRange(start, end);
    final weeklyExpenses = await _repo.getInRange(
      DateUtilsX.startOfWeek(now),
      DateUtilsX.endOfDay(now),
    );

    emit(state.copyWith(
      loading: false,
      expenses: expenses,
      weeklyComment: _weeklyComment(weeklyExpenses),
    ));
  }

  String _weeklyComment(List<Expense> weekly) {
    if (weekly.isEmpty) {
      return 'Minggu ini masih bersih nih ✨ Penny ikut bangga!';
    }
    final byCat = <ExpenseCategory, int>{};
    for (final e in weekly) {
      byCat[e.category] = (byCat[e.category] ?? 0) + e.amount;
    }
    final top = byCat.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final c = top.key;
    return 'Minggu ini kamu paling boros di ${c.label} ${c.emoji}';
  }
}
