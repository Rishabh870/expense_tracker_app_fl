import 'Category.dart';       // create this based on CategoryOut

class SplitUserAmount {
  final int person;
  final double amount;
  final double paid;

  SplitUserAmount({
    required this.person,
    this.amount =0,
    this.paid = 0,
  });

  factory SplitUserAmount.fromJson(Map<String, dynamic> json) {
    return SplitUserAmount(
      person: json['person'],
      amount: (json['amount'] ?? 0).toDouble(),
      paid: (json['paid'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person,
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
  final List<SplitUserAmount> splitUsers;
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
    required this.splitUsers,
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
      splitUsers: (json['split_users'] as List<dynamic>?)
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
}
