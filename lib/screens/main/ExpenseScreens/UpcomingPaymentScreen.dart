import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/BillReminder.dart';
import '../../../providers/bill_reminder_provider.dart';
import '../../../widgets/BillReminderTile.dart';
import 'AddBillReminderForm.dart';

class UpcomingPaymentScreen extends ConsumerStatefulWidget {
  const UpcomingPaymentScreen({super.key});

  @override
  ConsumerState<UpcomingPaymentScreen> createState() =>
      _UpcomingPaymentScreenState();
}

class _UpcomingPaymentScreenState extends ConsumerState<UpcomingPaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load bill reminders when screen initializes
    Future.microtask(() {
      ref.read(billReminderProvider.notifier).loadBillReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billRemindersState = ref.watch(billReminderProvider);

    return Scaffold(
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child:TabBar(
              controller: _tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Color(0xFF4C6EF5),
                  width: 3,
                ),
                insets: EdgeInsets.symmetric(horizontal: 0), // horizontal padding for the line
              ),
              labelColor: const Color(0xFF4C6EF5), // color of selected tab text
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Overdue'),
                Tab(text: 'Paid'),
              ],
            )
            ,
          ),

          // Summary Cards
          _buildSummaryCards(billRemindersState),

          // Tab Content
          Expanded(
            child: billRemindersState.when(
              data: (reminders) => TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(reminders),
                  _buildOverdueTab(reminders),
                  _buildPaidTab(reminders),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4C6EF5),
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load bill reminders',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(billReminderProvider.notifier)
                            .loadBillReminders();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildSummaryCards(AsyncValue<List<BillReminder>> billRemindersState) {
    return billRemindersState.when(
      data: (reminders) {
        final upcoming =
            reminders.where((r) => !r.isPaid && !r.isOverdue).toList();
        final overdue = reminders.where((r) => r.isOverdue).toList();
        final paid = reminders.where((r) => r.isPaid).toList();

        final upcomingTotal =
            upcoming.fold<double>(0, (sum, r) => sum + r.amount);
        final overdueTotal =
            overdue.fold<double>(0, (sum, r) => sum + r.amount);
        final paidTotal = paid.fold<double>(0, (sum, r) => sum + r.amount);

        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Upcoming',
                  upcoming.length,
                  upcomingTotal,
                  Colors.blue,
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Overdue',
                  overdue.length,
                  overdueTotal,
                  Colors.red,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Paid',
                  paid.length,
                  paidTotal,
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildSummaryCard(
      String title, int count, double total, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$count bills',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${total.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab(List<BillReminder> allReminders) {
    final upcomingReminders =
        allReminders.where((r) => !r.isPaid && !r.isOverdue).toList();

    // Sort by due date
    upcomingReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (upcomingReminders.isEmpty) {
      return _buildEmptyState(
        'No upcoming bills',
        'All your bills are up to date!',
        Icons.check_circle_outline,
        Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billReminderProvider.notifier).loadBillReminders();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: upcomingReminders.length,
        itemBuilder: (context, index) {
          final reminder = upcomingReminders[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: BillReminderTile(reminder: reminder),
          );
        },
      ),
    );
  }

  Widget _buildOverdueTab(List<BillReminder> allReminders) {
    final overdueReminders = allReminders.where((r) => r.isOverdue).toList();

    // Sort by due date (most overdue first)
    overdueReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (overdueReminders.isEmpty) {
      return _buildEmptyState(
        'No overdue bills',
        'Great! You\'re on top of all your payments.',
        Icons.thumb_up_outlined,
        Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billReminderProvider.notifier).loadBillReminders();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: overdueReminders.length,
        itemBuilder: (context, index) {
          final reminder = overdueReminders[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: BillReminderTile(reminder: reminder),
          );
        },
      ),
    );
  }

  Widget _buildPaidTab(List<BillReminder> allReminders) {
    final paidReminders = allReminders.where((r) => r.isPaid).toList();

    // Sort by paid date (most recent first)
    paidReminders.sort((a, b) {
      if (a.paidOn != null && b.paidOn != null) {
        return b.paidOn!.compareTo(a.paidOn!);
      }
      return b.dueDate.compareTo(a.dueDate);
    });

    if (paidReminders.isEmpty) {
      return _buildEmptyState(
        'No paid bills',
        'Paid bills will appear here.',
        Icons.receipt_outlined,
        Colors.grey,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(billReminderProvider.notifier).loadBillReminders();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: paidReminders.length,
        itemBuilder: (context, index) {
          final reminder = paidReminders[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: BillReminderTile(reminder: reminder),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
      String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: color.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
