import 'package:expense_tracker_app_fl/providers/token_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker_app_fl/services/cycle_service.dart';

import '../models/Cycle.dart';

class CycleNotifier extends StateNotifier<AsyncValue<List<Cycle>>> {
  CycleNotifier() : super(const AsyncValue.loading()) {
    loadCycle();
  }

  Future<void> loadCycle() async {
    try {
      final cycle = await CycleService.fetchCycles(); // your API call or local check
      state = AsyncValue.data(cycle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setCycle(int cycle) async {
    try {
     TokenManager.setCycleId(cycle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> checkOrCreateCycle()async{
    try {
      final cycle = await CycleService.checkOrCreateCycle(); // your API call or local check

      final currentCycleId =await TokenManager.getCycleId();

      if(currentCycleId == 0 || cycle.isNew){
        await TokenManager.setCycleId(cycle.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }

  }

}
final cycleProvider =
StateNotifierProvider<CycleNotifier, AsyncValue<List<Cycle>?>>(
      (ref) => CycleNotifier(),
);
