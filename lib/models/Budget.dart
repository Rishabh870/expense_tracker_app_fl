class Budget {
  final int id;
  final double amount;
  final double spent;

  Budget({
    required this.id,
    this.amount = 0,
    this.spent = 0,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      spent: (json['spent'] ?? 0).toDouble(),
    );
  }
}
