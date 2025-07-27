import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final int length = 4;
  final String email = 'example@email.com';
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _hiddenController = TextEditingController();
  List<String> otpArray = List.generate(4, (index) => '');
  int activeIndex = 0;
  bool autoSubmitted = false;

  int timer = 60;
  bool resendEnabled = false;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _hiddenController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    timer = 60;
    resendEnabled = false;
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timerObj) {
      if (timer <= 1) {
        timerObj.cancel();
        setState(() => resendEnabled = true);
      } else {
        setState(() => timer--);
      }
    });
  }

  void resetInput() {
    setState(() {
      otpArray = List.generate(length, (index) => '');
      activeIndex = 0;
      autoSubmitted = false;
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void handleChange(String text) {
    if (text.isEmpty) return;
    final char = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (char.isEmpty) return;

    setState(() {
      otpArray[activeIndex] = char[0];
      if (activeIndex < length - 1) {
        activeIndex++;
      } else {
        final otp = otpArray.join();
        if (!autoSubmitted && !otpArray.contains('')) {
          autoSubmitted = true;
          FocusScope.of(context).unfocus();
          handleAutoSubmit(otp);
        }
      }
    });
    _hiddenController.clear();
  }

  void handleAutoSubmit(String otp) {
    debugPrint('Auto-Submitted OTP: $otp');
    Future.delayed(const Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void onSubmit() {
    final otp = otpArray.join();
    debugPrint('Manual Submit OTP: $otp');
  }

  void handleBackspace() {
    setState(() {
      if (otpArray[activeIndex].isNotEmpty) {
        otpArray[activeIndex] = '';
      } else if (activeIndex > 0) {
        activeIndex--;
        otpArray[activeIndex] = '';
      }
      autoSubmitted = false;
    });
  }

  String formatTime(int sec) => '00:${sec < 10 ? '0$sec' : sec}';

  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final visible = parts[0].substring(0, 2);
    final masked = '*' * (parts[0].length - 2);
    return '$visible$masked@${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              Column(
                children: [
                  const Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'OTP has been sent to ${maskEmail(email)}',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Image.asset(
                    'lib/images/otp2.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // Hidden input
                  SizedBox(
                    height: 0,
                    width: 0,
                    child: TextField(
                      controller: _hiddenController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      onChanged: handleChange,
                      onSubmitted: (_) => onSubmit(),
                      onEditingComplete: () {},
                      maxLength: 1,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(counterText: ''),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(length, (index) {
                      final isFocused = index == activeIndex;
                      return GestureDetector(
                        onTap: () => setState(() => activeIndex = index),
                        child: Container(
                          width: 50,
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isFocused ? Colors.blue.shade50 : Colors.white,
                            border: Border.all(
                              color: isFocused ? Colors.blue : Colors.grey,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            otpArray[index],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),
                  resendEnabled
                      ? TextButton(
                          onPressed: () {
                            debugPrint('Resending OTP...');
                            resetInput();
                            startTimer();
                          },
                          child: const Text('Didn\'t receive OTP? Resend OTP'),
                        )
                      : Text(
                          "Didn't receive OTP? Resend in ${formatTime(timer)}",
                          style: const TextStyle(color: Colors.grey),
                        )
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onSubmit,
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 40),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
