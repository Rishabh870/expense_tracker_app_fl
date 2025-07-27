import 'package:expense_tracker_app_fl/components/shared/AuthButtton.dart';
import 'package:expense_tracker_app_fl/components/shared/MyIconButton.dart';
import 'package:expense_tracker_app_fl/components/shared/MyInputField.dart';
import 'package:expense_tracker_app_fl/core/statemanager/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  void signUserIn() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final email = emailController.text.trim();
    ref
        .read(registerControllerProvider.notifier)
        .signUp(username, email, password);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(registerControllerProvider);

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
                MyInputField(
                  controller: usernameController,
                  hintText: 'Username',
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),
                MyInputField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  icon: Icons.mail,
                ),
                const SizedBox(height: 10),
                MyInputField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 25),
                loginState.when(
                  data: (_) => MyButton(onTap: signUserIn, label: "Register"),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Column(
                    children: [
                      Text('⚠️ $e', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      MyButton(onTap: signUserIn, label: "Register"),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
                      icon: Image.asset('lib/images/google.png', height: 20),
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
                      'Already a member?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
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
    emailController.dispose();
    super.dispose();
  }
}
