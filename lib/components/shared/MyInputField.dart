import 'package:flutter/material.dart';

import '../../constant/colors.dart';

class InputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? fieldButtonLabel;
  final VoidCallback? fieldButtonFunction;
  final TextEditingController controller;

  const InputField({
    super.key,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.fieldButtonLabel,
    this.fieldButtonFunction,
    required this.controller,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = isFocused ? AppColors.primary : Colors.black;
    final iconColor = isFocused ? AppColors.primary : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: isFocused ? 2 : 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(widget.icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Focus(
              onFocusChange: (focus) => setState(() => isFocused = focus),
              child: TextField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.isPassword,
                decoration: InputDecoration(
                  hintText: widget.label,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          if (widget.fieldButtonLabel != null &&
              widget.fieldButtonFunction != null)
            GestureDetector(
              onTap: widget.fieldButtonFunction,
              child: Text(
                widget.fieldButtonLabel!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
