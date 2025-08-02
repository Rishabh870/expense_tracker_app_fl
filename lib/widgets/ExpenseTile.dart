import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/Expense.dart';
import 'CustomAvatar.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
  });

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12.0, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _hexToColor(
                    expense.category?.bgColor ?? "#FCD3E3"),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                'lib/assets/icons/${expense.category?.icon}.svg',
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text("Paid by: ",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(
                        "Priyanshu",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Splitted with: ',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 28,
                        width:
                        (expense.splits.length - 1) * 20.0 + 24,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: List.generate(
                              expense.splits.length, (index) {
                            final user = expense.splits[index];
                            return Positioned(
                              left: index * 16.0,
                              child: CustomAvatar(
                                name: user.person.name ?? '',
                                size: 20,
                                textSize: 8,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) {
    buffer.write('ff'); // Add full opacity if not provided
  }
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
