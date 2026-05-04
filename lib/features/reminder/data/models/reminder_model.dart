import 'package:hive/hive.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_model.g.dart';

/// Hive model for Reminder entity.
@HiveType(typeId: 3)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime scheduledTime;

  @HiveField(4)
  bool isRepeating;

  @HiveField(5)
  int? repeatIntervalDays;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  String? linkedActivityId;

  @HiveField(8)
  String? linkedPlotId;

  @HiveField(9)
  int typeIndex; // Store enum index

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime? completedAt;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isRepeating = false,
    this.repeatIntervalDays,
    this.isActive = true,
    this.linkedActivityId,
    this.linkedPlotId,
    required this.typeIndex,
    required this.createdAt,
    this.completedAt,
  });

  /// Convert from domain entity to Hive model.
  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      scheduledTime: reminder.scheduledTime,
      isRepeating: reminder.isRepeating,
      repeatIntervalDays: reminder.repeatIntervalDays,
      isActive: reminder.isActive,
      linkedActivityId: reminder.linkedActivityId,
      linkedPlotId: reminder.linkedPlotId,
      typeIndex: reminder.type.index,
      createdAt: reminder.createdAt,
      completedAt: reminder.completedAt,
    );
  }

  /// Convert from Hive model to domain entity.
  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      isRepeating: isRepeating,
      repeatIntervalDays: repeatIntervalDays,
      isActive: isActive,
      linkedActivityId: linkedActivityId,
      linkedPlotId: linkedPlotId,
      type: ReminderType.values[typeIndex],
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}