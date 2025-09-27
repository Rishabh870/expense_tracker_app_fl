import 'dart:ffi';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ExpenseItem.dart';
import '../services/expense_service.dart';

class ExpenseItemNotifier extends StateNotifier<List<ExpenseItem>> {
  ExpenseItemNotifier() : super([]);

  Future<void> loadExpensesItems(int id) async {
    final expenses = await ExpenseService.fetchExpenseById(id);
    state = expenses;
  }

  Future<void> importExpenseBill(int id,PlatformFile file) async {
    await ExpenseService.importBill(id,file);
  }
  Future<void> addExpenseItem(Map<String, dynamic> item, int expenseId) async {
    try {
      final newItem = await ExpenseService.addItem(item, expenseId);

      state = [...state, newItem];
    } catch (e) {
      throw Exception('Failed to add expense item: $e');
    }
  }
  Future<void> recalculateExpense(int expenseId) async {
    try {
      final newItem = await ExpenseService.recalculate(expenseId);

      state = newItem;
    } catch (e) {
      throw Exception('Failed to add expense item: $e');
    }
  }

}

final expenseItemProvider =
    StateNotifierProvider<ExpenseItemNotifier, List<ExpenseItem>>(
  (ref) => ExpenseItemNotifier(),
);
