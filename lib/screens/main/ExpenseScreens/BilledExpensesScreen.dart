import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BilledExpensesScreen extends StatefulWidget {
  const BilledExpensesScreen({super.key});

  @override
  State<BilledExpensesScreen> createState() => _BilledExpensesScreenState();
}

class _BilledExpensesScreenState extends State<BilledExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: const [],
      ),
    );
  }
}
