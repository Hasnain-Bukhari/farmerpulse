import '../../../reminder/domain/entities/reminder.dart';
import '../data_sources/reminder_local_data_source.dart';
import '../models/reminder_model.dart';

/// Repository for Reminder data operations.
class ReminderRepository {
  final ReminderLocalDataSource _dataSource;

  const ReminderRepository(this._dataSource);

  /// Create a new reminder.
  Future<void> createReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _dataSource.createReminder(model);
  }

  /// Get all reminders.
  List<Reminder> getAllReminders() {
    return _dataSource.getAllReminders()
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get reminder by ID.
  Reminder? getReminderById(String id) {
    final model = _dataSource.getReminderById(id);
    return model?.toEntity();
  }

  /// Get active reminders.
  List<Reminder> getActiveReminders() {
    return _dataSource.getActiveReminders()
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get reminders by plot ID.
  List<Reminder> getRemindersByPlotId(String plotId) {
    return _dataSource.getRemindersByPlotId(plotId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get reminders by activity ID.
  List<Reminder> getRemindersByActivityId(String activityId) {
    return _dataSource.getRemindersByActivityId(activityId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get due reminders (overdue or due today).
  List<Reminder> getDueReminders() {
    return _dataSource.getDueReminders()
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get upcoming reminders (next 7 days).
  List<Reminder> getUpcomingReminders() {
    return _dataSource.getUpcomingReminders()
        .map((model) => model.toEntity())
        .toList();
  }

  /// Update a reminder.
  Future<void> updateReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _dataSource.updateReminder(model);
  }

  /// Delete a reminder.
  Future<void> deleteReminder(String id) async {
    await _dataSource.deleteReminder(id);
  }

  /// Delete reminders by plot ID.
  Future<void> deleteRemindersByPlotId(String plotId) async {
    await _dataSource.deleteRemindersByPlotId(plotId);
  }

  /// Delete reminders by activity ID.
  Future<void> deleteRemindersByActivityId(String activityId) async {
    await _dataSource.deleteRemindersByActivityId(activityId);
  }

  /// Watch all reminders stream.
  Stream<List<Reminder>> watchReminders() {
    return _dataSource.watchReminders()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  /// Watch active reminders stream.
  Stream<List<Reminder>> watchActiveReminders() {
    return _dataSource.watchActiveReminders()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  /// Watch reminders by plot ID stream.
  Stream<List<Reminder>> watchRemindersByPlotId(String plotId) {
    return _dataSource.watchRemindersByPlotId(plotId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  /// Check if reminder exists.
  bool reminderExists(String id) {
    return _dataSource.reminderExists(id);
  }

  /// Get reminders count.
  int getRemindersCount() {
    return _dataSource.getRemindersCount();
  }

  /// Get active reminders count.
  int getActiveRemindersCount() {
    return _dataSource.getActiveRemindersCount();
  }
}