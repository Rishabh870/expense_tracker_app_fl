import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/expense_provider.dart';
import '../../../widgets/ExpenseTile.dart';
import 'ExpenseItemsPage.dart';

class BilledExpensesScreen extends ConsumerWidget {
  const BilledExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    return Scaffold(
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses found'))
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: InkWell(
              onTap: () {
                context.pushNamed(
                  'expense_items',
                  pathParameters: {'id': expense.id.toString()},
                );
              },
              child: ExpenseTile(expense: expense),
            )

            ,
          );
        },
      ),
    );

  }
}
