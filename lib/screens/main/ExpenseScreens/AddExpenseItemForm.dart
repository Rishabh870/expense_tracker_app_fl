import 'package:expense_tracker_app_fl/models/ExpenseItem.dart';
import 'package:expense_tracker_app_fl/models/SplitUser.dart';
import 'package:expense_tracker_app_fl/providers/expense_item_provider.dart';
import 'package:expense_tracker_app_fl/providers/split_users_provider.dart';
import 'package:expense_tracker_app_fl/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../widgets/CustomDropdown.dart';
import '../../../widgets/CustomeInput.dart';

class AddExpenseItemForm extends ConsumerStatefulWidget {
  final int expenseId;

  const AddExpenseItemForm({super.key, required this.expenseId});

  @override
  ConsumerState<AddExpenseItemForm> createState() => _AddExpenseItemFormState( );
}

class _AddExpenseItemFormState extends ConsumerState<AddExpenseItemForm> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(splitUsersProvider.notifier).loadUsers();
    });
  }

  void addExpenseItem() async {
    try {
      final itemName = itemNameController.text.trim();
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final quantity = int.tryParse(quantityController.text) ?? 1;
      final measurement = measurementController.text.trim();
      final payerId = int.tryParse(selectedPayer ?? '');

      if (itemName.isEmpty || amount <= 0 || quantity <= 0 || payerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
        return;
      }


      // Create the expense item data structure
      final expenseItemData = {

        'item_name': itemName,
        'amount': amount,
        'item_size': quantity,
        'item_measurement': measurement.isEmpty ? 'pc' : measurement,
        'payer_id': payerId,
        'expense_id': widget.expenseId,
        'is_split': selectedPeople.isNotEmpty,
        'splits': selectedPeople.map((personId) => {
          'person_id': int.parse(personId),
          'amount': amount / selectedPeople.length, // Equal split for now
          'paid': 0,
        }).toList(),
      };

      // TODO: Call your API service to create the expense item
      await ref.read(expenseItemProvider.notifier).addExpenseItem(expenseItemData, widget.expenseId);

      print("Expense Item Data: $expenseItemData");

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added successfully!")),
      );

      // Refresh the expense items list

    } catch (e) {
      print("Failed to add expense item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item: $e")),
      );
    }
  }

  final itemNameController = TextEditingController();
  final amountController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final measurementController = TextEditingController();

  String? selectedPayer;
  final List<String> selectedPeople = [];

  // Common measurements
  final List<DropdownOption> measurementOptions = [
    DropdownOption(value: 'pc', label: 'Piece'),
    DropdownOption(value: 'kg', label: 'Kilogram'),
    DropdownOption(value: 'g', label: 'Gram'),
    DropdownOption(value: 'l', label: 'Liter'),
    DropdownOption(value: 'ml', label: 'Milliliter'),
    DropdownOption(value: 'box', label: 'Box'),
    DropdownOption(value: 'pack', label: 'Pack'),
  ];


  @override
  void dispose() {
    itemNameController.dispose();
    amountController.dispose();
    quantityController.dispose();
    measurementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splitUsersState = ref.watch(splitUsersProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Item",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Item Name
                    CustomInputField(
                      label: "Item Name *",
                      hintText: "Enter item name",
                      controller: itemNameController,
                    ),

                    // Item Amount
                    CustomInputField(
                      label: "Item Amount *",
                      hintText: "0",
                      controller: amountController,
                    ),

                    // Quantity and Measurement Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomInputField(
                            label: "Quantity *",
                            hintText: "1",
                            controller: quantityController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CustomDropdownField<String>(
                            label: "Measurement *",
                            hintText: "Select measurement",
                            value: measurementController.text.isEmpty
                                ? null
                                : measurementController.text,
                            items: measurementOptions,
                            onChanged: (val) {
                              setState(() {
                                measurementController.text = val ?? '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Payer Selection
                    splitUsersState.when(
                      data: (users) => CustomDropdownField<String>(
                        label: "Payer *",
                        hintText: "Select payer",
                        icon: Icons.person,
                        value: selectedPayer,
                        items: users
                            .map((c) => DropdownOption(
                          value: c.id.toString(),
                          label: c.name ?? 'Unknown User',
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedPayer = val;
                          });
                        },
                      ),
                      loading: () => const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Payer *",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          SizedBox(height: 6),
                          LinearProgressIndicator(),
                          SizedBox(height: 16),
                        ],
                      ),
                      error: (e, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Payer *",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Error loading users: $e'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Split With Section
                    const Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Split With"),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Split Among Users
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: splitUsersState.when(
                        data: (users) => MultiSelectDialogField(
                          items: users
                              .map((e) => MultiSelectItem(e.id, e.name ?? "Unknown User"))
                              .toList(),
                          title: const Text("Split Among Users"),
                          buttonText: const Text("Select users"),
                          buttonIcon: const Icon(Icons.group),
                          listType: MultiSelectListType.CHIP,
                          decoration: const BoxDecoration(),
                          onConfirm: (values) {
                            setState(() {
                              selectedPeople.clear();
                              selectedPeople.addAll(values.map((e) => e.toString()));
                            });
                          },
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Container(
                          padding: const EdgeInsets.all(12),
                          child: Text('Error loading users: $e'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Submit Button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addExpenseItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6EF5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Add Item",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

void showAddExpenseItemModal(BuildContext context, int expenseId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => AddExpenseItemForm(expenseId: expenseId),
  );
}