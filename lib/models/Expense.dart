import 'package:expense_tracker_app_fl/models/SplitUser.dart';
import 'Category.dart'; // Based on CategoryOut

class SplitUserAmount {
  final SplitUser person;
  final double amount;
  final double paid;

  SplitUserAmount({
    required this.person,
    this.amount = 0,
    this.paid = 0,
  });

  factory SplitUserAmount.fromJson(Map<String, dynamic> json) {
    return SplitUserAmount(
      person: SplitUser.fromJson(json['person']),
      amount: (json['amount'] ?? 0).toDouble(),
      paid: (json['paid'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person.toJson(),
      'amount': amount,
      'paid': paid,
    };
  }
}

class Expense {
  final int id;
  final int? userId;
  final int? payerId;
  final String title;
  final double amount;
  final int? categoryId;
  final DateTime date;
  final List<SplitUserAmount> splits;
  final bool isSplit;
  final DateTime createdAt;
  final Category? category;

  Expense({
    required this.id,
    this.userId,
    this.payerId,
    required this.title,
    required this.amount,
    this.categoryId,
    required this.date,
    required this.splits,
    required this.isSplit,
    required this.createdAt,
    this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['user_id'],
      payerId: json['payer_id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'],
      date: DateTime.parse(json['date']),
      splits: (json['splits'] as List<dynamic>?)
          ?.map((e) => SplitUserAmount.fromJson(e))
          .toList() ??
          [],
      isSplit: json['is_split'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payer_id': payerId,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'is_split': isSplit,
      'created_at': createdAt.toIso8601String(),
      'category': category,
    };
  }
}
