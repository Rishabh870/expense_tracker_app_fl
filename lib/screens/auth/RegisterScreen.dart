import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constant/colors.dart';
import '../../components/shared/AuthButtton.dart';
import '../../components/shared/MyInputField.dart';
import 'dart:async';

import '../../models/Register.dart';



final registrationProvider = StateProvider<RegistrationData>((ref) => RegistrationData());

class MultiStepRegisterScreen extends ConsumerStatefulWidget {
  const MultiStepRegisterScreen({super.key});

  @override
  ConsumerState<MultiStepRegisterScreen> createState() => _MultiStepRegisterScreenState();
}

class _MultiStepRegisterScreenState extends ConsumerState<MultiStepRegisterScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int currentStep = 0;
  final int totalSteps = 5;

  // Controllers for each step
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final budgetController = TextEditingController();

  // OTP controllers
  final List<TextEditingController> emailOtpControllers = List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> phoneOtpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> emailOtpFocusNodes = List.generate(4, (index) => FocusNode());
  final List<FocusNode> phoneOtpFocusNodes = List.generate(4, (index) => FocusNode());

  // Timer for OTP
  Timer? emailOtpTimer;
  Timer? phoneOtpTimer;
  int emailOtpSeconds = 60;
  int phoneOtpSeconds = 60;
  bool canResendEmailOtp = false;
  bool canResendPhoneOtp = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    budgetController.dispose();

    for (var controller in emailOtpControllers) {
      controller.dispose();
    }
    for (var controller in phoneOtpControllers) {
      controller.dispose();
    }
    for (var node in emailOtpFocusNodes) {
      node.dispose();
    }
    for (var node in phoneOtpFocusNodes) {
      node.dispose();
    }

    emailOtpTimer?.cancel();
    phoneOtpTimer?.cancel();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Start OTP timer when reaching email OTP step
      if (currentStep == 1) {
        _startEmailOtpTimer();
      }
      // Start phone OTP timer when reaching phone OTP step
      else if (currentStep == 3) {
        _startPhoneOtpTimer();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startEmailOtpTimer() {
    emailOtpSeconds = 60;
    canResendEmailOtp = false;
    emailOtpTimer?.cancel();
    emailOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (emailOtpSeconds > 0) {
          emailOtpSeconds--;
        } else {
          canResendEmailOtp = true;
          timer.cancel();
        }
      });
    });
  }

  void _startPhoneOtpTimer() {
    phoneOtpSeconds = 60;
    canResendPhoneOtp = false;
    phoneOtpTimer?.cancel();
    phoneOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (phoneOtpSeconds > 0) {
          phoneOtpSeconds--;
        } else {
          canResendPhoneOtp = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleOtpChange(String value, int index, List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    if (value.isNotEmpty && value.length == 1) {
      if (index < 3) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
              Text(
                '${((currentStep + 1) / totalSteps * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: previousStep,
        )
            : IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => context.go('/login'),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1BasicInfo(),
                _buildStep2EmailVerification(),
                _buildStep3PhoneNumber(),
                _buildStep4PhoneVerification(),
                _buildStep5BudgetSetup(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    final regData = ref.watch(registrationProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s start with your basic details',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            InputField(
              label: 'Email Address',
              icon: Icons.email_outlined,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            InputField(
              label: 'Username',
              icon: Icons.person_outline,
              controller: usernameController,
            ),

            InputField(
              label: 'Password',
              icon: Icons.lock_outline,
              controller: passwordController,
              isPassword: true,
            ),

            InputField(
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              controller: confirmPasswordController,
              isPassword: true,
            ),

            const SizedBox(height: 20),

            // Password requirements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password Requirements:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordRequirement('At least 6 characters', passwordController.text.length >= 6),
                  _buildPasswordRequirement('Passwords match', passwordController.text == confirmPasswordController.text && passwordController.text.isNotEmpty),
                ],
              ),
            ),

            const SizedBox(height: 32),

            AuthButoon(
              label: 'Continue',
              onTap: () {
                ref.read(registrationProvider.notifier).update((state) => state
                  ..email = emailController.text.trim()
                  ..username = usernameController.text.trim()
                  ..password = passwordController.text
                  ..confirmPassword = confirmPasswordController.text);

                if (regData.isStep1Valid) {
                  // TODO: Send email OTP
                  nextStep();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? AppColors.success : AppColors.muted,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              fontSize: 14,
              color: isValid ? AppColors.success : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2EmailVerification() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verify Email',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 4-digit code sent to ${emailController.text}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // OTP Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 60,
                height: 60,
                child: TextField(
                  controller: emailOtpControllers[index],
                  focusNode: emailOtpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _handleOtpChange(value, index, emailOtpControllers, emailOtpFocusNodes);

                    // Update registration data
                    final otp = emailOtpControllers.map((c) => c.text).join();
                    ref.read(registrationProvider.notifier).update((state) => state..emailOtp = otp);
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Resend OTP
          Center(
            child: canResendEmailOtp
                ? TextButton(
              onPressed: () {
                // TODO: Resend email OTP
                _startEmailOtpTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP sent successfully')),
                );
              },
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : Text(
              'Resend OTP in ${_formatTime(emailOtpSeconds)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 32),

          AuthButoon(
            label: 'Verify & Continue',
            onTap: () {
              final regData = ref.read(registrationProvider);
              if (regData.isStep2Valid) {
                // TODO: Verify email OTP
                nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter the complete OTP')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3PhoneNumber() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your phone number for better security (Optional)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          InputField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),

          // Skip option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can skip this step and add your phone number later from settings.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(registrationProvider.notifier).update((state) => state
                      ..phoneRequired = false
                      ..phoneNumber = '');
                    // Skip phone verification step
                    setState(() {
                      currentStep = 4; // Jump to budget setup
                    });
                    _pageController.animateToPage(
                      4,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthButoon(
                  label: 'Continue',
                  onTap: () {
                    if (phoneController.text.trim().isNotEmpty) {
                      ref.read(registrationProvider.notifier).update((state) => state
                        ..phoneRequired = true
                        ..phoneNumber = phoneController.text.trim());
                      // TODO: Send phone OTP
                      nextStep();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your phone number')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4PhoneVerification() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verify Phone',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 4-digit code sent to ${phoneController.text}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // OTP Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 60,
                height: 60,
                child: TextField(
                  controller: phoneOtpControllers[index],
                  focusNode: phoneOtpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _handleOtpChange(value, index, phoneOtpControllers, phoneOtpFocusNodes);

                    // Update registration data
                    final otp = phoneOtpControllers.map((c) => c.text).join();
                    ref.read(registrationProvider.notifier).update((state) => state..phoneOtp = otp);
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Resend OTP
          Center(
            child: canResendPhoneOtp
                ? TextButton(
              onPressed: () {
                // TODO: Resend phone OTP
                _startPhoneOtpTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP sent successfully')),
                );
              },
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : Text(
              'Resend OTP in ${_formatTime(phoneOtpSeconds)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 32),

          AuthButoon(
            label: 'Verify & Continue',
            onTap: () {
              final regData = ref.read(registrationProvider);
              if (regData.isStep4Valid) {
                // TODO: Verify phone OTP
                nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter the complete OTP')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5BudgetSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Setup',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your monthly budget and cycle start date',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Month Start Date
          const Text(
            'Cycle Start Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which day of the month your budget cycle starts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: ref.watch(registrationProvider).monthStartDate,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: List.generate(28, (index) {
                  final day = index + 1;
                  String suffix = 'th';
                  if (day == 1 || day == 21) suffix = 'st';
                  else if (day == 2 || day == 22) suffix = 'nd';
                  else if (day == 3 || day == 23) suffix = 'rd';

                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text('$day$suffix of every month'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(registrationProvider.notifier).update((state) => state..monthStartDate = value);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Budget Per Cycle
          const Text(
            'Monthly Budget',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your monthly expense budget limit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary),
              suffixText: 'INR',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              final budget = double.tryParse(value) ?? 0.0;
              ref.read(registrationProvider.notifier).update((state) => state..budgetPerCycle = budget);
            },
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          ),

          const SizedBox(height: 20),

          // Budget suggestions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5000, 10000, 15000, 20000, 30000].map((amount) {
              return InkWell(
                onTap: () {
                  budgetController.text = amount.toString();
                  ref.read(registrationProvider.notifier).update((state) => state..budgetPerCycle = amount.toDouble());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '₹${amount}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          AuthButoon(
            label: isLoading ? 'Creating Account...' : 'Create Account',
            onTap: isLoading ? null : () async {
              final regData = ref.read(registrationProvider);
              if (regData.isStep5Valid) {
                setState(() {
                  isLoading = true;
                });

                try {
                  // TODO: Submit registration data to server
                  await Future.delayed(const Duration(seconds: 2)); // Simulate API call

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account created successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.go('/login');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create account: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid budget amount')),
                );
              }
            },
          ),

          const SizedBox(height: 20),

          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryItem('Email', ref.watch(registrationProvider).email),
                _buildSummaryItem('Username', ref.watch(registrationProvider).username),
                if (ref.watch(registrationProvider).phoneRequired)
                  _buildSummaryItem('Phone', ref.watch(registrationProvider).phoneNumber),
                _buildSummaryItem('Cycle Starts', '${ref.watch(registrationProvider).monthStartDate}${_getDaySuffix(ref.watch(registrationProvider).monthStartDate)} of every month'),
                _buildSummaryItem('Monthly Budget', '₹${ref.watch(registrationProvider).budgetPerCycle.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}