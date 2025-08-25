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
// Optionally: add methods to sync with backend after each mutation
}

final expenseItemProvider =
    StateNotifierProvider<ExpenseItemNotifier, List<ExpenseItem>>(
  (ref) => ExpenseItemNotifier(),
);
