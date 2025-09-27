class BalanceOverview {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double netBudget;
  final double spendingPercentage;
  final double emis;
  final double pendingSettlements;
  final double actualRemaining;

  BalanceOverview({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.netBudget,
    required this.spendingPercentage,
    this.emis = 0,
    this.pendingSettlements = 0,
    this.actualRemaining = 0
  });

  // Optional: factory to create from JSON
  factory BalanceOverview.fromJson(Map<String, dynamic> json) {
    return BalanceOverview(
      totalBudget: (json['total_budget'] ?? 0).toDouble(),
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      netBudget: (json['net_budget'] ?? 0).toDouble(),
      spendingPercentage: (json['spending_percentage'] ?? 0).toDouble(),
      emis: (json['emis'] ?? 0).toDouble(),
      pendingSettlements: (json['pending_settlements'] ?? 0).toDouble(),
      actualRemaining: (json['actual_remaining'] ?? 0).toDouble(),
    );
  }

  // Optional: convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_budget': totalBudget,
      'total_spent': totalSpent,
      'remaining': remaining,
      'net_budget': netBudget,
      'spending_percentage': spendingPercentage,
      'emis': emis,
      'pending_settlements': pendingSettlements,
      'actual_remaining': actualRemaining,
    };
  }
}
