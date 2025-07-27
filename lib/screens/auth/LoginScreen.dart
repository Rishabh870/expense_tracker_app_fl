import 'package:expense_tracker_app_fl/components/shared/AuthButtton.dart';
import 'package:expense_tracker_app_fl/components/shared/MyIconButton.dart';
import 'package:expense_tracker_app_fl/components/shared/MyInputField.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker_app_fl/statemanager/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constant/colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    ref.read(loginControllerProvider.notifier).signIn(username, password);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                InputField(
                  label: 'Username',
                  icon: Icons.person,
                  controller: usernameController,
                ),
                const SizedBox(height: 10),
                InputField(
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  controller: passwordController,
                  fieldButtonLabel: 'Forgot?',
                  fieldButtonFunction: () => {},
                ),
                const SizedBox(height: 25),
                loginState.when(
                  data: (_) => AuthButoon(onTap: signUserIn, label: "Login"),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Column(
                    children: [
                      Text('⚠️ $e', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      AuthButoon(onTap: signUserIn, label: "Login"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 0.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Or continue with',
                          style: TextStyle(color: Colors.grey[700])),
                    ),
                    const Expanded(child: Divider(thickness: 0.5)),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyIconButton(
                      label: 'Google',
                      icon: Image.asset('lib/assets/images/google.png', height: 20),
                      onTap: () {
                        // TODO: Google Sign In
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        context.go('/register');
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
