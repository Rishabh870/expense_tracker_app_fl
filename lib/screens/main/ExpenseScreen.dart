import 'package:expense_tracker_app_fl/screens/main/ExpenseScreens/BilledExpensesScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/ExpenseScreens/UnbilledExpensesScreen.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Unbilled Expenses'),
              Tab(text: 'Expenses'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                BilledExpensesScreen(),
                UnbilledExpensesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
