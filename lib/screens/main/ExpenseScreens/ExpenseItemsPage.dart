import 'dart:ffi';
import 'package:expense_tracker_app_fl/models/Expense.dart';
import 'package:expense_tracker_app_fl/providers/expense_item_provider.dart';
import 'package:expense_tracker_app_fl/providers/expense_provider.dart';
import 'package:expense_tracker_app_fl/services/expense_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../widgets/AssignToModal.dart';
import '../../../widgets/FilePickerWidget.dart';
import '../../../widgets/ItemTile.dart';
import 'AddExpenseItemForm.dart';

class ExpenseItemsPage extends ConsumerStatefulWidget {
  final int expenseId;

  const ExpenseItemsPage({super.key, required this.expenseId});

  @override
  ConsumerState<ExpenseItemsPage> createState() => _ExpenseItemsPageState();
}

class _ExpenseItemsPageState extends ConsumerState<ExpenseItemsPage> {
  bool loading = true;
  Set<int> selectedIndexes = {};
  bool isDialOpen = false;

  Expense? currentExpenseData;


  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(expenseItemProvider.notifier)
          .loadExpensesItems(widget.expenseId);
      setState(() {
        loading = false;
      });
      _getExpenseSummary();
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void handleRecalculate() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Recalculating...")));
    await ref.read(expenseItemProvider.notifier).recalculateExpense(widget.expenseId);

    ref.invalidate(expenseProvider);
    _getExpenseSummary();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Calculated")));
  }


  void uploadFile(PlatformFile file) async {
    try {
      await ref
          .read(expenseItemProvider.notifier)
          .importExpenseBill(widget.expenseId, file);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded successfully: ${file.name}')),
      );

      // Optionally, refresh the expense items after upload
      await ref
          .read(expenseItemProvider.notifier)
          .loadExpensesItems(widget.expenseId);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }


  void handleImportBill() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7, // 70% of screen
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilePickerWidget(
              onUpload: uploadFile,
            ),
          ),
        );
      },
    );
  }

  void handleAddItem() {
    showAddExpenseItemModal(context, widget.expenseId);

  }

  void handleAssignTo() {
    final items = ref.read(expenseItemProvider);

    final selectedItems = selectedIndexes.map((i) => {
      "id": items[i].id,
      "expense_id": items[i].expenseId,
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AssignToModal(
          selectedItems: selectedItems,
          onConfirm: (personId) async {
            try {


              // Attach chosen personId to each selected item
              final payload = {
                'items': selectedItems,
                "splits": personId.map((i) => {
                  "person_id": i,
                  "amount": 0,
                }).toList(),  // ✅ force to list
              };


              await ExpenseService.updateBulkItems(payload);

              ref.refresh(expenseItemProvider);

              Navigator.pop(context); // close modal

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Items assigned successfully")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
        );
      },
    );
  }


  void _getExpenseSummary() async {
    try {
      final summary = await ExpenseService.expenseSummary(widget.expenseId);
      setState(() {
        currentExpenseData = summary;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch summary: $e")),
      );
    }
  }

  String _calculateTotal(List<Expense> items) {
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.amount ?? 0),
    );
    return total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final expenseItems = ref.watch(expenseItemProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C6EF5),
        title: const Text(
          "Expense Items",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 18, color: Color(0xFF4C6EF5)),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔷 Total Summary Bar
                Container(
                  width: double.infinity,
                  color: const Color(0xFFEDF2FF),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₹${currentExpenseData?.amount ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: handleRecalculate,
                        borderRadius: BorderRadius.circular(20),
                        child: const Row(
                          children: [
                            Icon(Icons.refresh,
                                size: 20, color: Color(0xFF4C6EF5)),
                            SizedBox(width: 6),
                            Text(
                              'Recalculate',
                              style: TextStyle(
                                color: Color(0xFF4C6EF5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔽 List of Items
                Expanded(
                  child: expenseItems.isEmpty
                      ? const Center(child: Text('No items found'))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 2),
                          itemCount: expenseItems.length,
                          itemBuilder: (context, index) {
                            final expense = expenseItems[index];
                            return TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween(begin: 0, end: 1),
                              builder: (context, value, child) {
                                return Opacity(opacity: value, child: child);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: ItemTile(
                                  expense: expense,
                                  isSelected: selectedIndexes.contains(index),
                                  onChanged: (_) => toggleSelection(index),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      /// ✅ Dual Floating Buttons
      floatingActionButton: Stack(
        children: [
          // Main SpeedDial - Bottom Right
          Positioned(
            bottom: 16,
            right: 16,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: const Color(0xFF4C6EF5),
              animatedIconTheme: const IconThemeData(color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
              overlayOpacity: 0.1,
              onOpen: () => setState(() => isDialOpen = true),
              onClose: () => setState(() => isDialOpen = false),
              children: [
                SpeedDialChild(
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                  ),
                  label: 'Import Bill',
                  onTap: handleImportBill,
                  backgroundColor: const Color(0xFF4C6EF5),
                  labelBackgroundColor: Colors.white,
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                SpeedDialChild(
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: 'Add Item',
                  onTap: handleAddItem,
                  backgroundColor: const Color(0xFF4C6EF5),
                  labelBackgroundColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          // Conditional FAB - Bottom Left (Assign To)
          if (selectedIndexes.isNotEmpty)
            Positioned(
              bottom: isDialOpen ? 190 : 90,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Assign To',
                      style: TextStyle(
                        color: Color(0xFF4C6EF5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'assignToFAB',
                    onPressed: handleAssignTo,
                    backgroundColor: const Color(0xFF4C6EF5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child:
                        const Icon(Icons.assignment_ind, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
