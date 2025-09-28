import 'package:dio/dio.dart';
import 'package:expense_tracker_app_fl/utils/RequestMethod.dart';
import '../models/Cycle.dart';

class CycleService {

 static Future<List<Cycle>> fetchCycles() async {
    try {
      final response = await privateDio.get('/cycle/');
      final data = response.data as List;
      return data.map((json) => Cycle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch cycles: $e');
    }
  }

 static Future<Cycle> createCycle(DateTime periodStart, {String? name}) async {
    try {
      final response = await privateDio.post(
        '/cycle/',
        data: {
          'period_start': periodStart.toIso8601String(),
          if (name != null) 'name': name,
        },
      );
      return Cycle.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create cycle: $e');
    }
  }

 static Future<Cycle> checkOrCreateCycle() async {
   try {
     final response = await privateDio.get('/cycle/check-or-create-cycle');
     final data = response.data;
     return  Cycle.fromJson(data);
   } catch (e) {
     throw Exception('Failed to fetch cycles: $e');
   }
 }
}
