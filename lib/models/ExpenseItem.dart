import 'package:expense_tracker_app_fl/models/Expense.dart';

import 'SplitUser.dart';

class ExpenseItem {
  final int id;
  final String itemName;
  final int itemSize;
  final String itemMeasurement;
  final double amount;
  final int? userId;
  final int? payerId;
  final SplitUser? payer;
  final int? expenseId;
  final bool isSplit;
  final List<SplitUserAmount>? splits;
  final DateTime createdAt;

  ExpenseItem({
    required this.id,
    required this.itemName,
    required this.itemSize,
    required this.itemMeasurement,
    required this.amount,
    this.userId,
    this.payerId,
    this.payer,
    this.expenseId,
    required this.isSplit,
    this.splits,
    required this.createdAt,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'],
      itemName: json['item_name'],
      itemSize: json['item_size'],
      itemMeasurement: json['item_measurement'],
      amount: (json['amount'] ?? 0).toDouble(),
      userId: json['user_id'],
      payerId: json['payer_id'],
      payer: json['payer'] != null ? SplitUser.fromJson(json['payer']) : null,
      expenseId: json['expense_id'],
      isSplit: json['is_split'] ?? false,
      splits: json['splits'] != null
          ? (json['splits'] as List).map((e) => SplitUserAmount.fromJson(e)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'item_size': itemSize,
      'item_measurement': itemMeasurement,
      'amount': amount,
      'user_id': userId,
      'payer_id': payerId,
      'payer': payer?.toJson(),
      'expense_id': expenseId,
      'is_split': isSplit,
      'splits': splits?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
