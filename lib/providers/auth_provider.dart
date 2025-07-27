import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart'; // import your AuthService

final loginControllerProvider =
StateNotifierProvider<LoginController, AsyncValue<void>>(
      (ref) => LoginController(ref),
);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class LoginController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LoginController(this.ref) : super(const AsyncData(null));

  Future<void> signIn(String username, String password) async {
    state = const AsyncLoading();

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(username, password);
      log(response.data.toString());
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}

final registerControllerProvider =
    StateNotifierProvider<RegisterController, AsyncValue<void>>(
  (ref) => RegisterController(),
);

class RegisterController extends StateNotifier<AsyncValue<void>> {
  RegisterController() : super(const AsyncData(null));

  Future<void> signUp(String username, String email, String password) async {
    state = const AsyncLoading();

    await Future.delayed(const Duration(seconds: 2)); // simulate API call

    if (username == 'admin' && password == '1234') {
      state = const AsyncData(null);
      // navigate from outside here if needed
    } else {
      state = AsyncError('Invalid credentials', StackTrace.current);
    }
  }
}
