import 'package:expense_tracker_app_fl/models/Dashboard.dart';
import 'package:expense_tracker_app_fl/services/dashboard_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardNotifier extends StateNotifier<AsyncValue<BalanceOverview>> {
  DashboardNotifier() : super(const AsyncValue.loading()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final balance = await DashboardService.fetchOverview();
      state = AsyncValue.data(balance);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dashboardProvider =
StateNotifierProvider<DashboardNotifier, AsyncValue<BalanceOverview>>(
        (ref) => DashboardNotifier());
