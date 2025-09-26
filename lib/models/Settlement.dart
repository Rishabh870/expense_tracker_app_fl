import 'SplitUser.dart';

enum DirectionEnum { PAY, RECEIVE }

DirectionEnum directionEnumFromString(String value) {
  return value.toUpperCase() == "PAY" ? DirectionEnum.PAY : DirectionEnum.RECEIVE;
}

String directionEnumToString(DirectionEnum direction) {
  return direction == DirectionEnum.PAY ? "PAY" : "RECEIVE";
}

class SettlementOut {
  final int id;
  final int userId;
  final int otherPersonId;
  final int expenseId;
  final DirectionEnum direction;
  final double amount;
  final DateTime? settledOn;

  SettlementOut({
    required this.id,
    required this.userId,
    required this.otherPersonId,
    required this.expenseId,
    required this.direction,
    required this.amount,
    this.settledOn,
  });

  factory SettlementOut.fromJson(Map<String, dynamic> json) {
    return SettlementOut(
      id: json['id'],
      userId: json['user_id'],
      otherPersonId: json['other_person_id'],
      expenseId: json['expense_id'],
      direction: directionEnumFromString(json['direction']),
      amount: (json['amount'] as num).toDouble(),
      settledOn: json['settled_on'] != null ? DateTime.parse(json['settled_on']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'other_person_id': otherPersonId,
    'expense_id': expenseId,
    'direction': directionEnumToString(direction),
    'amount': amount,
    'settled_on': settledOn?.toIso8601String(),
  };
}

// SettlementSummary model
class SettlementSummary {
  final SplitUser person;
  final double amount;
  final DirectionEnum direction;

  SettlementSummary({
    required this.person,
    required this.amount,
    required this.direction,
  });

  factory SettlementSummary.fromJson(Map<String, dynamic> json) {
    return SettlementSummary(
      person: SplitUser.fromJson(json['person']),
      amount: (json['amount'] as num).toDouble(),
      direction: directionEnumFromString(json['direction']),
    );
  }

  Map<String, dynamic> toJson() => {
    'person': person.toJson(),
    'amount': amount,
    'direction': directionEnumToString(direction),
  };
}