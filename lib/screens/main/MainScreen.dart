import 'package:expense_tracker_app_fl/screens/main/ExpenseScreens/AddExpenseSheet.dart';
import 'package:expense_tracker_app_fl/screens/main/SettlementScreen.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:expense_tracker_app_fl/screens/main/ExpenseScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/HomeScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/SettingScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExpenseScreen(),
    SettlementScreen(),
    SettingScreen(),
  ];

  final List<String> _icons = [
    'lib/assets/icons/IconLayoutDashboard.svg',
    'lib/assets/icons/IconReceipt.svg',
    'lib/assets/icons/IconCurrencyRupee.svg',
    'lib/assets/icons/IconSettings.svg',
  ];

  final List<String> _labels = [
    'Home',
    'Expense',
    'Settlement',
    'Setting',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _labels[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF4C6EF5),
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: List.generate(_icons.length, (index) {
          final isSelected = index == _selectedIndex;
          return CurvedNavigationBarItem(
            child: SvgPicture.asset(
              _icons[index],
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: _labels[index],
            labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10),
          );
        }),
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        color: Colors.white,
        buttonBackgroundColor: const Color(0xFF4C6EF5),
        animationDuration: const Duration(milliseconds: 400),
        height: 60,
        index: _selectedIndex,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCustomFormModal(context),
        backgroundColor: const Color(0xFF4C6EF5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
