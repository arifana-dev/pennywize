import 'package:equatable/equatable.dart';
import '../../../expense/domain/entities/expense.dart';

enum DashboardPeriod { today, week, month }

extension DashboardPeriodX on DashboardPeriod {
  String get label {
    switch (this) {
      case DashboardPeriod.today:
        return 'Hari ini';
      case DashboardPeriod.week:
        return 'Minggu ini';
      case DashboardPeriod.month:
        return 'Bulan ini';
    }
  }
}

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class ChangePeriod extends DashboardEvent {
  const ChangePeriod(this.period);
  final DashboardPeriod period;
  @override
  List<Object?> get props => [period];
}

class DashboardState extends Equatable {
  const DashboardState({
    this.loading = false,
    this.period = DashboardPeriod.month,
    this.expenses = const [],
    this.weeklyComment = '',
  });

  final bool loading;
  final DashboardPeriod period;
  final List<Expense> expenses;
  final String weeklyComment;

  int get total =>
      expenses.fold<int>(0, (sum, e) => sum + e.amount);

  DashboardState copyWith({
    bool? loading,
    DashboardPeriod? period,
    List<Expense>? expenses,
    String? weeklyComment,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      period: period ?? this.period,
      expenses: expenses ?? this.expenses,
      weeklyComment: weeklyComment ?? this.weeklyComment,
    );
  }

  @override
  List<Object?> get props => [loading, period, expenses, weeklyComment];
}
