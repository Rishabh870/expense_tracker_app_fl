import 'package:expense_tracker_app_fl/models/SplitUser.dart';
import 'package:expense_tracker_app_fl/services/split_users_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Category.dart';


class SplitUserNotifier extends StateNotifier<AsyncValue<List<SplitUser>>> {
  SplitUserNotifier() : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final users = await SplitUsersService.fetchSplitUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final splitUsersProvider =
StateNotifierProvider<SplitUserNotifier, AsyncValue<List<SplitUser>>>(
        (ref) => SplitUserNotifier());
