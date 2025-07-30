import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/expense_provider.dart';
class BilledExpensesScreen extends StatefulWidget {
  const BilledExpensesScreen({super.key});

  @override
  State<BilledExpensesScreen> createState() => _BilledExpensesScreenState();
}

class _BilledExpensesScreenState extends State<BilledExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, _) {
          final expensesAsync = ref.watch(expenseProvider);

          return expensesAsync.when(
            data: (expenses) => ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  title: Text(expense.title ?? 'No title'),
                  subtitle: Text('₹${expense.amount.toString()}'),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
      ),
    );
  }
}
