import 'package:expense_tracker_app_fl/screens/auth/LoginScreen.dart';
import 'package:expense_tracker_app_fl/screens/auth/OtpScreen.dart';
import 'package:expense_tracker_app_fl/screens/auth/RegisterScreen.dart';
import 'package:expense_tracker_app_fl/screens/main/MainScreen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/main',
    routes: [
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
    ],
  );
}
