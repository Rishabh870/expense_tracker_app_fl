import 'package:expense_tracker_app_fl/models/SplitUser.dart';

import '../utils/RequestMethod.dart';
import '../models/Category.dart';

class SplitUsersService {
  static Future<List<SplitUser>> fetchSplitUsers() async {
    try {
      final res = await privateDio.get('/split-user/');

      return (res.data as List).map((e) => SplitUser.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching expenses: $e');

      throw Exception('Failed to load expenses');
    }
  }
}
