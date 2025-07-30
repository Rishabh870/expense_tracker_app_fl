import 'package:expense_tracker_app_fl/models/Expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/expense_service.dart';

final expenseProvider = FutureProvider<List<Expense>>((ref) async {
  return await ExpenseService.fetchExpenses();
});
