import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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

      return (res.data as List).map((e) => ExpenseItem.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }

      throw Exception('Failed to load expenses');
    }
  }

  static Future<void> updateBulkItems(final data) async {
    try {
      final res = await privateDio.put('/expense-item/bulk-update',data: data);


    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }

      throw Exception('Failed to load expenses');
    }
  }

  static Future<void> importBill(int id, PlatformFile file) async {
    try {
      // Convert PlatformFile to MultipartFile
      final multipartFile = await MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      );

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      // Make POST request to your backend
      final res = await privateDio.post(
        '/expense-item/extract-bill/pdf/$id',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (kDebugMode) {
        print('Upload successful: ${res.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      throw Exception('Failed to upload file');
    }
  }
  
  static Future<ExpenseItem> addItem(var item,int expenseId) async {
    try {
      final res = await privateDio.post('/expense-item/', data: item);

      return ExpenseItem.fromJson(res.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error Adding expenses: $e');
      }

      throw Exception('Failed to add expenses');
    }
  }

  static Future<List<ExpenseItem>> recalculate(int expenseId) async {
    try {
      final res = await privateDio.post('/expense/recalculate/$expenseId');

      return (res.data as List).map((e) => ExpenseItem.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error Adding expenses: $e');
      }

      throw Exception('Failed to add expenses');
    }
  }

  static Future<Expense> expenseSummary(int expenseId) async {
    try {
      final res = await privateDio.get('/expense/summary/$expenseId');

      return  Expense.fromJson(res.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error Adding expenses: $e');
      }

      throw Exception('Failed to add expenses');
    }
  }
}
