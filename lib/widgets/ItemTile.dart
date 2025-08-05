import 'package:flutter/material.dart';
import '../models/ExpenseItem.dart';
import 'CustomAvatar.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.expense,
    this.isSelected,
    this.onChanged,
  });

  final ExpenseItem expense;
  final bool? isSelected;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        elevation: 0.5,
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged?.call(!(isSelected ?? false)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected ?? false,
                  onChanged: onChanged,
                  activeColor:  const Color(0xFF4C6EF5),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.itemName.length > 23
                            ? '${expense.itemName.substring(0, 23)}...'
                            : expense.itemName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Split with: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (expense.splits?.isNotEmpty == true)
                            SizedBox(
                              height: 28,
                              width: (expense.splits!.length - 1) * 20.0 + 28,
                              child: Stack(
                                children: List.generate(
                                  expense.splits!.length,
                                  (index) {
                                    final user = expense.splits![index];
                                    return Positioned(
                                      left: index * 18.0,
                                      child: CustomAvatar(
                                        name: user.person.name ?? "",
                                        size: 24,
                                        textSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            const Text(
                              'No one',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    if (expense.itemSize > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${expense.itemSize} ${expense.itemMeasurement}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
}
