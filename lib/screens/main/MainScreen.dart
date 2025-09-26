import 'package:expense_tracker_app_fl/providers/token_manager.dart';
import 'package:expense_tracker_app_fl/screens/main/ExpenseScreens/AddExpenseSheet.dart';
import 'package:expense_tracker_app_fl/screens/main/SettlementScreen.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:expense_tracker_app_fl/screens/main/ExpenseScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/HomeScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/SettingScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
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

  // Logout function
  Future<void> _logout() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging out..."),
            ],
          ),
        ),
      );


      await TokenManager.clearTokens();


      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                Row(
                  children: [
                    // User Avatar

                    const SizedBox(width: 8),
                    // Logout Button
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutDialog();
                        }
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 20,
                      ),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
              fontSize: 10,
            ),
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
        onPressed: () => showAddExpenseModal(context),
        backgroundColor: const Color(0xFF4C6EF5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}