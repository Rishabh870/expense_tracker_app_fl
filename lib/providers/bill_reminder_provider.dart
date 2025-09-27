import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/BillReminder.dart';
import '../services/bill_reminder_service.dart';

class BillReminderNotifier extends StateNotifier<AsyncValue<List<BillReminder>>> {
  BillReminderNotifier() : super(const AsyncValue.loading()) {
    loadBillReminders();
  }

  Future<void> loadBillReminders() async {
    try {
      state = const AsyncValue.loading();
      final reminders = await BillReminderService.fetchBillReminders();
      state = AsyncValue.data(reminders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBillReminder(CreateBillReminder reminder) async {
    try {
      final newReminder = await BillReminderService.createBillReminder(reminder);

      // Add to current list if we have data
      state.whenData((currentReminders) {
        final updatedList = [newReminder, ...currentReminders];
        // Sort by due date
        updatedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        state = AsyncValue.data(updatedList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBillReminder(int id, UpdateBillReminder reminder) async {
    try {
      final updatedReminder = await BillReminderService.updateBillReminder(id, reminder);

      state.whenData((currentReminders) {
        final updatedList = currentReminders.map((r) {
          return r.id == id ? updatedReminder : r;
        }).toList();
        // Sort by due date
        updatedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        state = AsyncValue.data(updatedList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBillReminder(int id) async {
    try {
      await BillReminderService.deleteBillReminder(id);

      state.whenData((currentReminders) {
        final updatedList = currentReminders.where((r) => r.id != id).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePaidStatus(int id) async {
    try {
      final updatedReminder = await BillReminderService.togglePaidStatus(id);

      state.whenData((currentReminders) {
        final updatedList = currentReminders.map((r) {
          return r.id == id ? updatedReminder : r;
        }).toList();
        // Sort by due date
        updatedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        state = AsyncValue.data(updatedList);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Helper methods to get filtered lists
  List<BillReminder> getUpcomingBills() {
    return state.maybeWhen(
      data: (reminders) => reminders.where((r) => !r.isPaid && !r.isOverdue).toList(),
      orElse: () => [],
    );
  }

  List<BillReminder> getOverdueBills() {
    return state.maybeWhen(
      data: (reminders) => reminders.where((r) => r.isOverdue).toList(),
      orElse: () => [],
    );
  }

  List<BillReminder> getPaidBills() {
    return state.maybeWhen(
      data: (reminders) => reminders.where((r) => r.isPaid).toList(),
      orElse: () => [],
    );
  }

  List<BillReminder> getRemindersToShow() {
    return state.maybeWhen(
      data: (reminders) => reminders.where((r) => r.shouldShowReminder).toList(),
      orElse: () => [],
    );
  }
}

final billReminderProvider = StateNotifierProvider<BillReminderNotifier, AsyncValue<List<BillReminder>>>(
      (ref) => BillReminderNotifier(),
);