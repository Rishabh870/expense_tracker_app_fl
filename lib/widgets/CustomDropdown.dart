import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownOption> items;
  final String hintText;
  final IconData? icon;
  final void Function(T?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          isExpanded: true,
          icon: icon != null ? Icon(icon) : null,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.deepPurple.shade50,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: items.map((DropdownOption item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: Text(item.label.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


class DropdownOption<T> {
  final T value;
  final String label;

  DropdownOption({required this.value, required this.label});
}