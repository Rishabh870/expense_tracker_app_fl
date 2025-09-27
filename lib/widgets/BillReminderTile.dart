import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/BillReminder.dart';
import '../providers/bill_reminder_provider.dart';

class BillReminderTile extends ConsumerWidget {
  final BillReminder reminder;
  final VoidCallback? onTap;

  const BillReminderTile({
    Key? key,
    required this.reminder,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: 2,
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: reminder.isPaid ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reminder.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${reminder.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: reminder.isPaid ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusChip(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (!reminder.isPaid) ...[
                      _buildTogglePaidButton(ref),
                      const SizedBox(width: 8),
                    ],
                    _buildMenuButton(ref),
                  ],
                ),
                if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: double.infinity,
                    child: Text(
                      reminder.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String text;

    if (reminder.isPaid) {
      chipColor = Colors.green;
      text = 'Paid';
    } else if (reminder.isOverdue) {
      chipColor = Colors.red;
      text = 'Overdue';
    } else if (reminder.daysUntilDue <= 3) {
      chipColor = Colors.orange;
      text = '${reminder.daysUntilDue}d left';
    } else {
      chipColor = Colors.blue;
      text = '${reminder.daysUntilDue}d left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTogglePaidButton(WidgetRef ref) {
    return InkWell(
      onTap: () async {
        try {
          await ref.read(billReminderProvider.notifier).togglePaidStatus(reminder.id);
        } catch (e) {
          // Handle error - could show snackbar
          print('Error toggling paid status: $e');
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              'Mark Paid',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
          // TODO: Implement edit functionality
            break;
          case 'delete':
            try {
              await ref.read(billReminderProvider.notifier).deleteBillReminder(reminder.id);
            } catch (e) {
              print('Error deleting reminder: $e');
            }
            break;
          case 'toggle_paid':
            try {
              await ref.read(billReminderProvider.notifier).togglePaidStatus(reminder.id);
            } catch (e) {
              print('Error toggling paid status: $e');
            }
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_paid',
          child: Row(
            children: [
              Icon(
                reminder.isPaid ? Icons.undo : Icons.check_circle,
                color: reminder.isPaid ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(reminder.isPaid ? 'Mark Unpaid' : 'Mark Paid'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  Color _getBorderColor() {
    if (reminder.isPaid) {
      return Colors.green.withOpacity(0.3);
    } else if (reminder.isOverdue) {
      return Colors.red.withOpacity(0.5);
    } else if (reminder.daysUntilDue <= 3) {
      return Colors.orange.withOpacity(0.5);
    }
    return Colors.blue.withOpacity(0.3);
  }

  String _formatDueDate() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final dueDate = reminder.dueDate;
    final formattedDate = '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';

    if (reminder.isPaid) {
      return 'Due: $formattedDate';
    } else if (reminder.isOverdue) {
      return 'Overdue: $formattedDate';
    } else {
      return 'Due: $formattedDate';
    }
  }
}