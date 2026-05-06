import 'package:hive_flutter/hive_flutter.dart';
import '../models/reminder_model.dart';

/// Local data source for Reminder operations using Hive.
class ReminderLocalDataSource {
  static const String _boxName = 'reminders';
  
  Box<ReminderModel> get _box {
    try {
      return Hive.box<ReminderModel>(_boxName);
    } catch (e) {
      // If box is not open, try to open it
      throw Exception('Reminders box not initialized: $e');
    }
  }

  /// Create a new reminder.
  Future<void> createReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);
  }

  /// Get all reminders.
  List<ReminderModel> getAllReminders() {
    return _box.values.toList();
  }

  /// Get reminder by ID.
  ReminderModel? getReminderById(String id) {
    return _box.get(id);
  }

  /// Get active reminders.
  List<ReminderModel> getActiveReminders() {
    return _box.values.where((reminder) => reminder.isActive).toList();
  }

  /// Get reminders by plot ID.
  List<ReminderModel> getRemindersByPlotId(String plotId) {
    return _box.values
        .where((reminder) => reminder.linkedPlotId == plotId)
        .toList();
  }

  /// Get reminders by activity ID.
  List<ReminderModel> getRemindersByActivityId(String activityId) {
    return _box.values
        .where((reminder) => reminder.linkedActivityId == activityId)
        .toList();
  }

  /// Get due reminders (overdue or due today).
  List<ReminderModel> getDueReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _box.values.where((reminder) {
      if (!reminder.isActive) return false;
      
      final reminderDate = DateTime(
        reminder.scheduledTime.year,
        reminder.scheduledTime.month,
        reminder.scheduledTime.day,
      );
      
      return reminderDate.isBefore(today) || reminderDate.isAtSameMomentAs(today);
    }).toList();
  }

  /// Get upcoming reminders (next 7 days).
  List<ReminderModel> getUpcomingReminders() {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    
    return _box.values.where((reminder) {
      return reminder.isActive &&
             reminder.scheduledTime.isAfter(now) &&
             reminder.scheduledTime.isBefore(sevenDaysFromNow);
    }).toList();
  }

  /// Update a reminder.
  Future<void> updateReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);
  }

  /// Delete a reminder.
  Future<void> deleteReminder(String id) async {
    await _box.delete(id);
  }

  /// Delete reminders by plot ID.
  Future<void> deleteRemindersByPlotId(String plotId) async {
    final reminders = getRemindersByPlotId(plotId);
    for (final reminder in reminders) {
      await _box.delete(reminder.id);
    }
  }

  /// Delete reminders by activity ID.
  Future<void> deleteRemindersByActivityId(String activityId) async {
    final reminders = getRemindersByActivityId(activityId);
    for (final reminder in reminders) {
      await _box.delete(reminder.id);
    }
  }

  /// Watch all reminders stream.
  Stream<List<ReminderModel>> watchReminders() {
    return _box.watch().map((_) => getAllReminders());
  }

  /// Watch active reminders stream.
  Stream<List<ReminderModel>> watchActiveReminders() {
    return _box.watch().map((_) => getActiveReminders());
  }

  /// Watch reminders by plot ID stream.
  Stream<List<ReminderModel>> watchRemindersByPlotId(String plotId) {
    return _box.watch().map((_) => getRemindersByPlotId(plotId));
  }

  /// Check if reminder exists.
  bool reminderExists(String id) {
    return _box.containsKey(id);
  }

  /// Get reminders count.
  int getRemindersCount() {
    return _box.length;
  }

  /// Get active reminders count.
  int getActiveRemindersCount() {
    return getActiveReminders().length;
  }
}