import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../providers/split_users_provider.dart';
import 'CustomDropdown.dart';

class AssignToModal extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final Function(List<int> personIds) onConfirm;

  const AssignToModal({
    super.key,
    required this.selectedItems,
    required this.onConfirm,
  });

  @override
  State<AssignToModal> createState() => _AssignToModalState();
}

class _AssignToModalState extends State<AssignToModal> {
  List<String> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assign selected items to users:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// ✅ Use your splitUsersState here
          Consumer(
            builder: (context, ref, _) {
              final splitUsersState = ref.watch(splitUsersProvider); // your provider

              return splitUsersState.when(
                data: (users) => Container(
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
                          selectedUsers.clear();
                          selectedUsers
                              .addAll(values.map((e) => e.toString()));
                        });
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              );
            },
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(selectedUsers.map(int.parse).toList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C6EF5),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Assign", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
