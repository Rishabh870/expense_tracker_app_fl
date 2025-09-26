import '../models/Settlement.dart';
import '../utils/RequestMethod.dart';

class SettlementService {
  static Future<List<SettlementSummary>> fetchSettlements() async {
    try {
      final res = await privateDio.get('/settlement/summary/');

      return (res.data as List).map((e) => SettlementSummary.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching SettlementSummary: $e');

      throw Exception('Failed to load SettlementSummary');
    }
  }
}
