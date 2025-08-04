import 'package:expense_tracker_app_fl/models/Category.dart';
import 'package:expense_tracker_app_fl/providers/category_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../providers/split_users_provider.dart';
import '../../../widgets/CustomDropdown.dart';
import '../../../widgets/CustomeInput.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  const AddExpenseForm({super.key});

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(splitUsersProvider.notifier).loadUsers();
      //ref.read(fetchPeopleProvider.notifier).fetchPeople();
    });
  }

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final categoryController = TextEditingController();

  String? selectedCategory;
  String? selectedPayer;

  final List<String> payers = ["Alice", "Bob", "Charlie", "Daisy"];
  final List<String> splitPeople = ["Alice", "Bob", "Charlie", "Daisy"];
  final List<String> selectedPeople = [];

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("Add Expense",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    CustomInputField(
                        label: "Expense Title",
                        hintText: "John",
                        controller: titleController),
                    CustomInputField(
                        label: "Amount",
                        hintText: "100",
                        controller: amountController),
                    CustomInputField(
                      label: "Date",
                      hintText: "Pick date",
                      controller: dateController,
                      readOnly: true,
                      icon: Icons.calendar_today,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          dateController.text =
                              "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                    categoryState.when(
                      data: (categories) => CustomDropdownField(
                        label: "Category",
                        hintText: "Select Category",
                        icon: Icons.category,
                        value: selectedCategory,
                        items: categories
                            .map((c) => DropdownOption(
                                  value: c.id.toString(),
                                  label: c.name.toString(),
                                ))
                            .toList(), // Use your categories here
                        onChanged: (val) {
                          setState(() {
                            selectedCategory = val;
                          });
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    splitUsersState.when(
                      data: (users) => CustomDropdownField(
                        label: "Payer",
                        hintText: "Select Payer",
                        icon: Icons.category,
                        value: selectedCategory,
                        items: users
                            .map((c) => DropdownOption(
                                  value: c.id.toString(),
                                  label: c.name.toString(),
                                ))
                            .toList(), // Use your categories here
                        onChanged: (val) {
                          setState(() {
                            selectedPayer = val;
                          });
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    // CustomDropdownField<String>(
                    //   label: "Payer",
                    //   hintText: "Select payer",
                    //   icon: Icons.person,
                    //   value: selectedPayer,
                    //   items: payers,
                    //   onChanged: (val) {
                    //     setState(() {
                    //       selectedPayer = val;
                    //     });
                    //   },
                    // ),
                    const Row(
                      children: [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("Split Among"),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: splitUsersState.when(
                        data: (users) => MultiSelectDialogField(
                          items: users
                              .map((e) => MultiSelectItem(e.id, e.name ?? ""))
                              .toList(),
                          title: const Text("Split Among"),
                          buttonText: const Text("Select People"),
                          buttonIcon: const Icon(Icons.group),
                          listType: MultiSelectListType.CHIP,
                          decoration: const BoxDecoration(),
                          onConfirm: (values) {
                            setState(() {
                              selectedPeople.clear();
                              selectedPeople
                                  .addAll(values.map((e) => e.toString()));
                            });
                          },
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6EF5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text("Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
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

void showAddExpenseModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const AddExpenseForm(),
  );
}
