/// Domain entity representing a reminder.
class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isRepeating;
  final int? repeatIntervalDays;
  final bool isActive;
  final String? linkedActivityId;
  final String? linkedPlotId;
  final ReminderType type;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isRepeating = false,
    this.repeatIntervalDays,
    this.isActive = true,
    this.linkedActivityId,
    this.linkedPlotId,
    required this.type,
    required this.createdAt,
    this.completedAt,
  });

  /// Create a copy with modified properties.
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isRepeating,
    int? repeatIntervalDays,
    bool? isActive,
    String? linkedActivityId,
    String? linkedPlotId,
    ReminderType? type,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatIntervalDays: repeatIntervalDays ?? this.repeatIntervalDays,
      isActive: isActive ?? this.isActive,
      linkedActivityId: linkedActivityId ?? this.linkedActivityId,
      linkedPlotId: linkedPlotId ?? this.linkedPlotId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if the reminder is overdue.
  bool get isOverdue {
    return DateTime.now().isAfter(scheduledTime) && isActive && completedAt == null;
  }

  /// Check if the reminder is due today.
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
    );
    return reminderDate.isAtSameMomentAs(today) && isActive;
  }

  /// Check if the reminder is due within the next 7 days.
  bool get isDueSoon {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    return scheduledTime.isAfter(now) && 
           scheduledTime.isBefore(sevenDaysFromNow) && 
           isActive;
  }

  /// Get days until the reminder is due.
  int get daysUntilDue {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    return difference.inDays;
  }

  /// Get the next occurrence time for repeating reminders.
  DateTime? getNextOccurrence() {
    if (!isRepeating || repeatIntervalDays == null) return null;
    
    final now = DateTime.now();
    DateTime nextTime = scheduledTime;
    
    while (nextTime.isBefore(now)) {
      nextTime = nextTime.add(Duration(days: repeatIntervalDays!));
    }
    
    return nextTime;
  }

  /// Mark reminder as completed.
  Reminder markCompleted() {
    return copyWith(
      completedAt: DateTime.now(),
      isActive: false,
    );
  }

  /// Reactivate the reminder (for repeating reminders).
  Reminder reactivate({DateTime? newScheduledTime}) {
    return copyWith(
      scheduledTime: newScheduledTime ?? getNextOccurrence(),
      isActive: true,
      completedAt: null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reminder{id: $id, title: $title, scheduledTime: $scheduledTime, '
           'isRepeating: $isRepeating, isActive: $isActive}';
  }
}

/// Types of reminders.
enum ReminderType {
  activity('Activity Reminder', 'Reminder for a specific farm activity'),
  irrigation('Irrigation', 'Time to water the crops'),
  fertilizer('Fertilizer', 'Time to apply fertilizer'),
  harvest('Harvest', 'Time to harvest the crops'),
  planting('Planting', 'Time to plant seeds'),
  inspection('Inspection', 'Time to inspect the crops'),
  maintenance('Maintenance', 'Equipment or farm maintenance'),
  custom('Custom', 'Custom reminder');

  const ReminderType(this.label, this.description);

  final String label;
  final String description;
}