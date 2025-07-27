import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>(
  (ref) => LoginController(),
);

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController() : super(const AsyncData(null));

  Future<void> signIn(String username, String password) async {
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
