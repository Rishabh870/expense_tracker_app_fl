import 'package:expense_tracker_app_fl/constant/colors.dart';
import 'package:expense_tracker_app_fl/models/Expense.dart';
import 'package:expense_tracker_app_fl/providers/category_providers.dart';
import 'package:expense_tracker_app_fl/providers/expense_provider.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:go_router/go_router.dart';

import '../../models/Category.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when the screen initializes
    Future.microtask(() {
      try {
        ref.read(expenseProvider.notifier).loadExpenses();
        ref.read(categoryProvider.notifier).loadCategories();
      } catch (e) {
        if (kDebugMode) {
          print('Error loading initial data: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);
    final categoriesState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expenseProvider.notifier).loadExpenses();
          await ref.read(categoryProvider.notifier).loadCategories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 20),

              // Financial Overview Cards
              _buildFinancialOverview(expenses),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Recent Expenses
              _buildRecentExpenses(expenses),
              const SizedBox(height: 24),

              // Category Spending
              categoriesState.when(
                data: (categories) => _buildCategorySpending(expenses, categories),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget('Failed to load categories'),
              ),
              const SizedBox(height: 24),

              // Settlement Overview
              _buildSettlementOverview(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getTimeOfDay()}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your expenses and stay on budget',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(List<Expense> expenses) {
    final totalSpent = _calculateTotalSpent(expenses);
    final monthlyExpenses = _calculateMonthlyExpenses(expenses);
    final avgDaily = monthlyExpenses / DateTime.now().day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Total Spent',
                '₹${totalSpent.toStringAsFixed(2)}',
                Icons.trending_up,
                AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                'This Month',
                '₹${monthlyExpenses.toStringAsFixed(2)}',
                Icons.calendar_today,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Daily Average',
                '₹${avgDaily.toStringAsFixed(2)}',
                Icons.today,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                'Pending',
                '₹${_calculatePendingAmount(expenses).toStringAsFixed(2)}',
                Icons.pending_actions,
                AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Expense',
                Icons.add_circle_outline,
                AppColors.primary,
                    () {
                  // Navigate to add expense
                  // This would trigger the floating action button functionality
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'View Reports',
                Icons.analytics_outlined,
                AppColors.secondary,
                    () {
                  // Navigate to reports
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Settle Up',
                Icons.handshake_outlined,
                AppColors.success,
                    () {
                  // Navigate to settlement
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(List<Expense> expenses) {
    final recentExpenses = expenses.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full expenses list
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentExpenses.isEmpty)
          _buildEmptyState('No recent expenses', Icons.receipt_outlined)
        else
          ...recentExpenses.map((expense) => _buildRecentExpenseItem(expense)),
      ],
    );
  }

  Widget _buildRecentExpenseItem(Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to expense details
          context.pushNamed(
            'expense_items',
            pathParameters: {'id': expense.id.toString()},
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _hexToColor(expense.category?.bgColor ?? "#6366F1"),
                borderRadius: BorderRadius.circular(8),
              ),
              child: expense.category?.icon != null
                  ? SvgPicture.asset(
                'lib/assets/icons/${expense.category!.icon}.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )
                  : const Icon(Icons.receipt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(expense.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpending(List<Expense> expenses, List<Category> categories) {
    try {
      final categorySpending = _calculateCategorySpending(expenses, categories);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Spending',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          if (categorySpending.isEmpty)
            _buildEmptyState('No category data', Icons.category_outlined)
          else
            ...categorySpending.entries.take(5).map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percentage = _calculateCategoryPercentage(amount, expenses);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _hexToColor(category.bgColor ?? "#6366F1"),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: category.icon != null
                          ? SvgPicture.asset(
                        'lib/assets/icons/${category.icon}.svg',
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      )
                          : const Icon(Icons.category, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              _hexToColor(category.bgColor ?? "#6366F1"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in _buildCategorySpending: $e');
      }
      return _buildErrorWidget('Failed to load category spending');
    }
  }

  Widget _buildSettlementOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Settlement Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSettlementItem('You Owe', '₹1,250.00', AppColors.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSettlementItem('You\'re Owed', '₹850.00', AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementItem(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  double _calculateTotalSpent(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateMonthlyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses
        .where((expense) =>
    expense.date.year == now.year && expense.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculatePendingAmount(List<Expense> expenses) {
    // Calculate based on split expenses where user hasn't paid
    return expenses
        .where((expense) => expense.isSplit && expense.splits.isNotEmpty)
        .fold(0.0, (sum, expense) {
      try {
        final userSplit = expense.splits.firstWhere(
              (split) => split.person.isSelf == true,
          orElse: () =>  expense.splits.first,
        );
        if (userSplit != null) {
          return sum + (userSplit.amount - userSplit.paid);
        }
        return sum;
      } catch (e) {
        return sum;
      }
    });
  }

  Map<Category, double> _calculateCategorySpending(List<Expense> expenses, List<Category> categories) {
    final Map<Category, double> categorySpending = {};

    if (categories.isEmpty) return categorySpending;

    for (final expense in expenses) {
      Category? category;
      try {
        category = categories.firstWhere(
              (cat) => cat.id == expense.categoryId,
        );
      } catch (e) {
        // If no matching category found, skip this expense or use a default
        continue;
      }

      if (category != null) {
        categorySpending[category] = (categorySpending[category] ?? 0) + expense.amount;
      }
    }

    // Sort by amount descending
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  double _calculateCategoryPercentage(double amount, List<Expense> expenses) {
    final total = _calculateTotalSpent(expenses);
    if (total == 0) return 0;
    return (amount / total) * 100;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}