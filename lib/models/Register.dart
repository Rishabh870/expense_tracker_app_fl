class RegistrationData {
  String email = '';
  String username = '';
  String password = '';
  String confirmPassword = '';
  String phoneNumber = '';
  String emailOtp = '';
  String phoneOtp = '';
  int monthStartDate = 1;
  double budgetPerCycle = 0.0;
  bool phoneRequired = false;

  bool get isStep1Valid =>
      email.isNotEmpty &&
          username.isNotEmpty &&
          password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          password == confirmPassword &&
          _isValidEmail(email) &&
          password.length >= 6;

  bool get isStep2Valid => emailOtp.length == 4;

  bool get isStep3Valid => !phoneRequired || phoneNumber.isNotEmpty;

  bool get isStep4Valid => !phoneRequired || phoneOtp.length == 4;

  bool get isStep5Valid => budgetPerCycle > 0;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}