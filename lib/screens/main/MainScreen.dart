import 'package:expense_tracker_app_fl/screens/main/ExpenseScreens/AddExpenseSheet.dart';
import 'package:expense_tracker_app_fl/screens/main/SettlementScreen.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:expense_tracker_app_fl/screens/main/ExpenseScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/HomeScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/SettingScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExpenseScreen(),
    SettlementScreen(),
    SettingScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.list_alt_outlined,
    Icons.money_outlined,
    Icons.settings_outlined,
  ];

  final List<String> _labels = [
    'Home',
    'Expense',
    'Settlement',
    'Setting',
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: CurvedNavigationBar(
        items: List.generate(_icons.length, (index) {
          final isSelected = index == _selectedIndex;
          return CurvedNavigationBarItem(
            child: Icon(
              _icons[index],
              color: isSelected ? Colors.white : Colors.black87,
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: _selectedIndex,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCustomFormModal(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
