import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double textSize;

  const CustomAvatar({
    super.key,
    required this.name,
    this.size = 12,
    this.textSize = 24,
  });

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  static final List<Color> defaultColors = [
    Colors.blue.shade100,     // blue
    Colors.cyan.shade100,     // cyan
    Colors.purple.shade100,   // grape (closest match)
    Colors.green.shade100,    // green
    Colors.indigo.shade100,   // indigo
    Colors.lime.shade100,     // lime
    Colors.orange.shade100,   // orange
    Colors.pink.shade100,     // pink
    Colors.red.shade100,      // red
    Colors.teal.shade100,     // teal
    Colors.deepPurple.shade100, // violet (approximation)
  ];

  static final List<Color> textColors = [
    Colors.blue.shade700,        // blue
    Colors.cyan.shade700,        // cyan
    Colors.purple.shade700,      // grape (approximation)
    Colors.green.shade700,       // green
    Colors.indigo.shade700,      // indigo
    Colors.lime.shade700,        // lime
    Colors.orange.shade700,      // orange
    Colors.pink.shade700,        // pink
    Colors.red.shade700,         // red
    Colors.teal.shade700,        // teal
    Colors.deepPurple.shade700,  // violet (approximation)
  ];


  int getHashCode(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      final char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash + char) & 0xFFFFFFFF;
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(name);

    final hash = getHashCode(initials);
    final index = hash.abs() % defaultColors.length;
    final bgColor = defaultColors[index];
    final textColor = textColors[index];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: textSize,
        ),
      ),

    );
  }
}
