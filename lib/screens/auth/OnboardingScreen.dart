import 'package:expense_tracker_app_fl/components/shared/AuthButtton.dart';
import 'package:expense_tracker_app_fl/providers/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker_app_fl/constant/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndRedirect();
  }

  Future<void> _checkTokenAndRedirect() async {
    final accessToken = await TokenManager.getAccessToken();

    if (!mounted) return; // ✅ Check before using context

    if (accessToken != null && accessToken.isNotEmpty) {
      context.go('/main'); // ✅ Safe now
    }
  }

  void _goToLogin(BuildContext context) {
    context.go('/login');
  }

  void _goToSignUp(BuildContext context) {
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Lottie.asset(
                'lib/assets/animations/banner.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AuthButoon(
                    label: 'Login',
                    onTap: () => _goToLogin(context),
                  ),
                  const SizedBox(height: 14),
                  AuthButoon(
                    label: 'Sign Up',
                    onTap: () => _goToSignUp(context),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
