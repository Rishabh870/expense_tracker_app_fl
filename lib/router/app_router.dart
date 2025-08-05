import 'package:expense_tracker_app_fl/screens/auth/LoginScreen.dart';
import 'package:expense_tracker_app_fl/screens/auth/OnboardingScreen.dart';
import 'package:expense_tracker_app_fl/screens/auth/OtpScreen.dart';
import 'package:expense_tracker_app_fl/screens/auth/RegisterScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/MainScreen.dart';
import 'package:go_router/go_router.dart';

import '../screens/main/ExpenseScreens/ExpenseItemsPage.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboardingscreen',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) => const OTPScreen(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/expense/:id/items',
        name: 'expense_items',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ExpenseItemsPage(expenseId: id);
        },
      ),

    ],
  );
}
