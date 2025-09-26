import 'package:expense_tracker_app_fl/models/Settlement.dart';
import 'package:expense_tracker_app_fl/services/settlement_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettlementNotifer extends StateNotifier<AsyncValue<List<SettlementSummary>>> {
  SettlementNotifer() : super(const AsyncValue.loading()) {
    loadSettlements();
  }

  Future<void> loadSettlements() async {
    try {
      final settlements = await SettlementService.fetchSettlements();
      state = AsyncValue.data(settlements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final settlementProvider =
StateNotifierProvider<SettlementNotifer, AsyncValue<List<SettlementSummary>>>(
        (ref) => SettlementNotifer());
