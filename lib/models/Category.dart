import 'Budget.dart'; // Create this model based on your BudgetOut class

class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? bgColor;
  final Budget? budgets;
  final bool isNet;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.bgColor,
    this.budgets,
    this.isNet = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      bgColor: json['bgColor'],
      budgets: json['budgets'] != null
          ? Budget.fromJson(json['budgets'])
          : null,
      isNet: json['is_net'] ?? false,
    );
  }
}
