import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../services/widget_service.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc(this._repo) : super(const ExpenseState()) {
    on<LoadExpenses>(_onLoad);
    on<AddExpense>(_onAdd);
    on<UpdateExpense>(_onUpdate);
    on<DeleteExpense>(_onDelete);
    on<RestoreExpense>(_onRestore);
  }

  final ExpenseRepository _repo;

  Future<void> _refreshTotals(Emitter<ExpenseState> emit,
      {List<Expense>? expenses}) async {
    final now = DateTime.now();
    final todayTotal = await _repo.totalInRange(
      DateUtilsX.startOfDay(now),
      DateUtilsX.endOfDay(now),
    );
    final monthTotal = await _repo.totalInRange(
      DateUtilsX.startOfMonth(now),
      DateUtilsX.endOfMonth(now),
    );
    final list = expenses ?? await _repo.getAll();
    emit(state.copyWith(
      status: ExpenseStatus.loaded,
      expenses: list,
      todayTotal: todayTotal,
      monthTotal: monthTotal,
    ));
    await WidgetService.instance.refresh(
      todayTotal: todayTotal,
      transactionCount: list
          .where((e) =>
              !e.date.isBefore(DateUtilsX.startOfDay(now)) &&
              !e.date.isAfter(DateUtilsX.endOfDay(now)))
          .length,
    );
  }

  Future<void> _onLoad(LoadExpenses _, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      await _refreshTotals(emit);
    } catch (err) {
      emit(state.copyWith(status: ExpenseStatus.error, error: err.toString()));
    }
  }

  Future<void> _onAdd(AddExpense e, Emitter<ExpenseState> emit) async {
    await _repo.add(e.expense);
    await _refreshTotals(emit);
  }

  Future<void> _onUpdate(UpdateExpense e, Emitter<ExpenseState> emit) async {
    await _repo.update(e.expense);
    await _refreshTotals(emit);
  }

  Future<void> _onDelete(DeleteExpense e, Emitter<ExpenseState> emit) async {
    if (e.expense.id == null) return;
    await _repo.delete(e.expense.id!);
    await _refreshTotals(emit);
  }

  Future<void> _onRestore(RestoreExpense e, Emitter<ExpenseState> emit) async {
    await _repo.add(e.expense.copyWith(id: null));
    await _refreshTotals(emit);
  }
}
