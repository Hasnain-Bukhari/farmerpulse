import '../../data/repositories/reminder_repository.dart';
import '../entities/reminder.dart';
import '../../../../core/services/notification_service.dart';

/// Use case for completing reminders and handling repeat logic.
class CompleteReminderUseCase {
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  const CompleteReminderUseCase(
    this._repository,
    this._notificationService,
  );

  /// Complete a reminder and handle repeat scheduling.
  Future<void> call(String reminderId) async {
    // Get the reminder
    final reminder = _repository.getReminderById(reminderId);
    if (reminder == null) {
      throw Exception('Reminder not found');
    }

    if (!reminder.isActive) {
      throw Exception('Reminder is already inactive');
    }

    // Mark as completed
    final completedReminder = reminder.markCompleted();
    await _repository.updateReminder(completedReminder);

    // Handle repeating reminders
    if (reminder.isRepeating && reminder.repeatIntervalDays != null) {
      await _handleRepeatingReminder(reminder);
    } else {
      // Cancel notifications for non-repeating reminder
      final notificationId = reminder.id.hashCode;
      await _notificationService.cancelNotification(notificationId);
    }
  }

  /// Handle scheduling of next occurrence for repeating reminders.
  Future<void> _handleRepeatingReminder(Reminder reminder) async {
    final nextOccurrence = reminder.getNextOccurrence();
    if (nextOccurrence == null) return;

    // Create new reminder for next occurrence
    final nextReminder = Reminder(
      id: '${reminder.id}_${nextOccurrence.millisecondsSinceEpoch}',
      title: reminder.title,
      description: reminder.description,
      scheduledTime: nextOccurrence,
      isRepeating: reminder.isRepeating,
      repeatIntervalDays: reminder.repeatIntervalDays,
      isActive: true,
      linkedActivityId: reminder.linkedActivityId,
      linkedPlotId: reminder.linkedPlotId,
      type: reminder.type,
      createdAt: DateTime.now(),
    );

    // Save new reminder
    await _repository.createReminder(nextReminder);

    // Schedule notification for new reminder
    final notificationId = nextReminder.id.hashCode;
    await _notificationService.scheduleNotification(
      id: notificationId,
      title: nextReminder.title,
      body: nextReminder.description,
      scheduledTime: nextReminder.scheduledTime,
      payload: _createPayload(nextReminder),
    );
  }

  /// Create notification payload for navigation.
  String _createPayload(Reminder reminder) {
    return 'reminder:${reminder.id}:${reminder.linkedActivityId ?? ''}:${reminder.linkedPlotId ?? ''}';
  }
}