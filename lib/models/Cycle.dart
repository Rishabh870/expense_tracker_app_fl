import 'package:flutter/foundation.dart';

class Cycle {
  final int id;
  final int userId;
  final String? name;
  final DateTime periodStart;
  final DateTime? periodEnd;
  final bool isNew;

  Cycle({
    required this.id,
    required this.userId,
    this.name,
    required this.periodStart,
    this.periodEnd,
    this.isNew = false,
  });

  factory Cycle.fromJson(Map<String, dynamic> json) {
    return Cycle(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: json['period_end'] != null ? DateTime.parse(json['period_end']) : null,
      isNew: json['is_new'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'period_start': periodStart.toIso8601String(),
    'period_end': periodEnd?.toIso8601String(),
    'is_new': isNew,
  };
}
