import 'package:expense_tracker_app_fl/models/Dashboard.dart';

import '../models/Settlement.dart';
import '../utils/RequestMethod.dart';

class DashboardService {
  static Future<BalanceOverview> fetchOverview() async {
    try {
      final res = await privateDio.get('/overview/balance');

      return BalanceOverview.fromJson(res.data);
    } catch (e) {
      print('Error fetching BalanceOverview: $e');

      throw Exception('Failed to load BalanceOverview');
    }
  }
}
