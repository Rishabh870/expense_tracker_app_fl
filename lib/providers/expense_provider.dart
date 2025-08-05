import 'dart:ffi';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Expense.dart';
import '../services/expense_service.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    loadExpenses(); // Initial fetch
  }

  Future<void> loadExpenses() async {
    final expenses = await ExpenseService.fetchExpenses();
    state = expenses;
  }

  Future<List<Expense>> getExpenseItems(Int id) async{
    final expenseItems = await ExpenseService.fetchExpenses();

    return expenseItems;
  }
  void addExpense(CreateExpense expense) async{
    final resExpense = await ExpenseService.addExpense(expense);

    state = [resExpense,...state];
  }

  void deleteExpense(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  void updateExpense(Expense updated) {
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e
    ];
  }

// Optionally: add methods to sync with backend after each mutation
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
      (ref) => ExpenseNotifier(),
);
