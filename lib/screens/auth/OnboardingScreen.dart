import 'package:expense_tracker_app_fl/components/shared/AuthButtton.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker_app_fl/core/constant/colors.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
            // 🎞️ Lottie Banner
            Expanded(
              child: Lottie.asset(
                'assets/animations/banner.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // 🔘 Buttons
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
