class BillReminder {
  final int id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String? repeatCycle;
  final int reminderDaysBefore;
  final String? notes;
  final bool isPaid;
  final DateTime? paidOn;

  BillReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.repeatCycle,
    this.reminderDaysBefore = 1,
    this.notes,
    this.isPaid = false,
    this.paidOn,
  });

  factory BillReminder.fromJson(Map<String, dynamic> json) {
    return BillReminder(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      category: json['category'],
      repeatCycle: json['repeat_cycle'],
      reminderDaysBefore: json['reminder_days_before'] ?? 1,
      notes: json['notes'],
      isPaid: json['is_paid'] ?? false,
      paidOn: json['paid_on'] != null ? DateTime.parse(json['paid_on']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'category': category,
      'repeat_cycle': repeatCycle,
      'reminder_days_before': reminderDaysBefore,
      'notes': notes,
      'is_paid': isPaid,
      'paid_on': paidOn?.toIso8601String().split('T')[0],
    };
  }

  // Helper method to check if bill is overdue
  bool get isOverdue {
    return !isPaid && DateTime.now().isAfter(dueDate);
  }

  // Helper method to get days until due
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  // Helper method to check if reminder should be shown
  bool get shouldShowReminder {
    return !isPaid && daysUntilDue <= reminderDaysBefore && daysUntilDue >= 0;
  }
}

class CreateBillReminder {
  final String title;
  final double amount;
  final String dueDate; // YYYY-MM-DD format
  final String category;
  final String? repeatCycle;
  final int? reminderDaysBefore;
  final String? notes;
  final bool? isPaid;

  CreateBillReminder({
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.repeatCycle,
    this.reminderDaysBefore,
    this.notes,
    this.isPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'due_date': dueDate,
      'category': category,
      'repeat_cycle': repeatCycle,
      'reminder_days_before': reminderDaysBefore,
      'notes': notes,
      'is_paid': isPaid,
    };
  }
}

class UpdateBillReminder {
  final String? title;
  final double? amount;
  final String? dueDate; // YYYY-MM-DD format
  final String? category;
  final String? repeatCycle;
  final int? reminderDaysBefore;
  final String? notes;
  final bool? isPaid;

  UpdateBillReminder({
    this.title,
    this.amount,
    this.dueDate,
    this.category,
    this.repeatCycle,
    this.reminderDaysBefore,
    this.notes,
    this.isPaid,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (amount != null) data['amount'] = amount;
    if (dueDate != null) data['due_date'] = dueDate;
    if (category != null) data['category'] = category;
    if (repeatCycle != null) data['repeat_cycle'] = repeatCycle;
    if (reminderDaysBefore != null) data['reminder_days_before'] = reminderDaysBefore;
    if (notes != null) data['notes'] = notes;
    if (isPaid != null) data['is_paid'] = isPaid;
    return data;
  }
}