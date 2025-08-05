import 'package:flutter/foundation.dart';

import '../models/Expense.dart';
import '../models/ExpenseItem.dart';
import '../utils/RequestMethod.dart';

class ExpenseService {
  static Future<List<Expense>> fetchExpenses() async {
    try {
      final res = await privateDio.get('/expense/');

      return (res.data as List).map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }

      throw Exception('Failed to load expenses');
    }
  }

  static Future<Expense> addExpense(CreateExpense expense) async {
    try {
      final res = await privateDio.post('/expense/', data: expense.toJson());

      return Expense.fromJson(res.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error Adding expenses: $e');
      }

      throw Exception('Failed to add expenses');
    }

  }
  static Future<List<ExpenseItem>> fetchExpenseById(int id) async {
    try {
      final res = await privateDio.get('/expense-item/$id');
  print(res.toString());
      return (res.data as List).map((e) => ExpenseItem.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }

      throw Exception('Failed to load expenses');
    }
  }

}
