import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/BillReminder.dart';
import '../../../providers/bill_reminder_provider.dart';
import '../../../widgets/CustomDropdown.dart';
import '../../../widgets/CustomeInput.dart';


class AddBillReminderForm extends ConsumerStatefulWidget {
  const AddBillReminderForm({super.key});

  @override
  ConsumerState<AddBillReminderForm> createState() => _AddBillReminderFormState();
}

class _AddBillReminderFormState extends ConsumerState<AddBillReminderForm> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final notesController = TextEditingController();

  String? selectedCategory;
  String? selectedRepeatCycle;
  int reminderDaysBefore = 1;

  final List<String> categories = [
    'Electricity', 'Water', 'Gas', 'Internet', 'Mobile', 'Insurance',
    'Rent', 'Mortgage', 'Credit Card', 'Loan', 'Subscription', 'Other'
  ];

  final List<String> repeatCycles = [
    'monthly', 'quarterly', 'yearly', 'weekly', 'bi-weekly'
  ];

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    dateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> addBillReminder() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final title = titleController.text.trim();
      final dueDate = dateController.text.trim();
      final category = selectedCategory!;
      final notes = notesController.text.trim();

      final reminder = CreateBillReminder(
        title: title,
        amount: amount,
        dueDate: dueDate,
        category: category,
        repeatCycle: selectedRepeatCycle,
        reminderDaysBefore: reminderDaysBefore,
        notes: notes.isEmpty ? null : notes,
        isPaid: false,
      );

      await ref.read(billReminderProvider.notifier).createBillReminder(reminder);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill reminder added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add bill reminder: $e'),
            backgroundColor: Colors.red,
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
  }

  bool _validateForm() {
    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final dueDate = dateController.text.trim();

    if (title.isEmpty) {
      _showError('Please enter a title');
      return false;
    }

    if (amount <= 0) {
      _showError('Please enter a valid amount');
      return false;
    }

    if (dueDate.isEmpty) {
      _showError('Please select a due date');
      return false;
    }

    if (selectedCategory == null) {
      _showError('Please select a category');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Add Bill Reminder",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomInputField(
                      label: "Bill Title",
                      hintText: "e.g., Electricity Bill",
                      controller: titleController,
                      icon: Icons.receipt_long,
                    ),

                    CustomInputField(
                      label: "Amount (₹)",
                      hintText: "0.00",
                      controller: amountController,
                      icon: Icons.currency_rupee,
                    ),

                    CustomInputField(
                      label: "Due Date",
                      hintText: "Select date",
                      controller: dateController,
                      readOnly: true,
                      icon: Icons.calendar_today,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (pickedDate != null) {
                          dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),

                    CustomDropdownField<String>(
                      label: "Category",
                      hintText: "Select category",
                      icon: Icons.category,
                      value: selectedCategory,
                      items: categories
                          .map((category) => DropdownOption(
                        value: category,
                        label: category,
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                        });
                      },
                    ),

                    CustomDropdownField<String>(
                      label: "Repeat Cycle (Optional)",
                      hintText: "Select repeat cycle",
                      icon: Icons.repeat,
                      value: selectedRepeatCycle,
                      items: repeatCycles
                          .map((cycle) => DropdownOption(
                        value: cycle,
                        label: cycle.capitalize(),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedRepeatCycle = val;
                        });
                      },
                    ),

                    // Reminder Days Before
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Remind me before",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Slider(
                                  value: reminderDaysBefore.toDouble(),
                                  min: 0,
                                  max: 30,
                                  divisions: 30,
                                  label: reminderDaysBefore == 0
                                      ? 'Same day'
                                      : '$reminderDaysBefore ${reminderDaysBefore == 1 ? 'day' : 'days'}',
                                  onChanged: (value) {
                                    setState(() {
                                      reminderDaysBefore = value.round();
                                    });
                                  },
                                ),
                              ),
                              Text(
                                reminderDaysBefore == 0
                                    ? 'Same day'
                                    : '$reminderDaysBefore ${reminderDaysBefore == 1 ? 'day' : 'days'}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    CustomInputField(
                      label: "Notes (Optional)",
                      hintText: "Add any notes...",
                      controller: notesController,
                      icon: Icons.notes,
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : addBillReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6EF5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Add Bill Reminder",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

void showAddBillReminderModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const AddBillReminderForm(),
  );
}