

import '../models/Expense.dart';
import '../utils/RequestMethod.dart';

class ExpenseService {
  static Future<List<Expense>> fetchExpenses() async {
    final res = await publicDio.get('/expenses');
    return (res.data as List)
        .map((e) => Expense.fromJson(e))
        .toList();
  }

}
