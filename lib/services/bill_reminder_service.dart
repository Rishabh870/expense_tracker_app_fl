import 'package:flutter/foundation.dart';
import '../utils/RequestMethod.dart';
import '../models/BillReminder.dart';

class BillReminderService {
  static Future<List<BillReminder>> fetchBillReminders() async {
    try {
      final res = await privateDio.get('/reminder-bills/');
      return (res.data as List).map((e) => BillReminder.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching bill reminders: $e');
      }
      throw Exception('Failed to load bill reminders');
    }
  }

  static Future<BillReminder> createBillReminder(CreateBillReminder reminder) async {
    try {
      final res = await privateDio.post('/reminder-bills/', data: reminder.toJson());
      return BillReminder.fromJson(res.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating bill reminder: $e');
      }
      throw Exception('Failed to create bill reminder');
    }
  }

  static Future<BillReminder> updateBillReminder(int id, UpdateBillReminder reminder) async {
    try {
      final res = await privateDio.put('/reminder-bills/$id', data: reminder.toJson());
      return BillReminder.fromJson(res.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating bill reminder: $e');
      }
      throw Exception('Failed to update bill reminder');
    }
  }

  static Future<void> deleteBillReminder(int id) async {
    try {
      await privateDio.delete('/reminder-bills/$id');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting bill reminder: $e');
      }
      throw Exception('Failed to delete bill reminder');
    }
  }

  static Future<BillReminder> togglePaidStatus(int id) async {
    try {
      final res = await privateDio.patch('/reminder-bills/$id/toggle-paid');
      return BillReminder.fromJson(res.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling paid status: $e');
      }
      throw Exception('Failed to toggle paid status');
    }
  }
}