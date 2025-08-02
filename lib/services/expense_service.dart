import 'package:flutter/foundation.dart';

import '../models/Expense.dart';
import '../utils/RequestMethod.dart';

class ExpenseService {
  static Future<List<Expense>> fetchExpenses() async {
    try {
      final res = await privateDio.get('/expense/');

      return (res.data as List)
          .map((e) => Expense.fromJson(e))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }

      throw Exception('Failed to load expenses');
    }
  }
}
