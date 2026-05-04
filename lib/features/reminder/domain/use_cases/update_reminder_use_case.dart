import '../../data/repositories/reminder_repository.dart';
import '../entities/reminder.dart';
import '../../../../core/services/notification_service.dart';

/// Use case for updating reminders with notification rescheduling.
class UpdateReminderUseCase {
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  const UpdateReminderUseCase(
    this._repository,
    this._notificationService,
  );

  /// Update a reminder and reschedule notifications.
  Future<void> call(Reminder updatedReminder) async {
    // Validation
    if (!_repository.reminderExists(updatedReminder.id)) {
      throw Exception('Reminder not found');
    }

    if (updatedReminder.title.trim().isEmpty) {
      throw Exception('Reminder title cannot be empty');
    }

    if (updatedReminder.scheduledTime.isBefore(DateTime.now()) && updatedReminder.isActive) {
      throw Exception('Active reminder cannot be scheduled in the past');
    }

    if (updatedReminder.isRepeating && 
        (updatedReminder.repeatIntervalDays == null || updatedReminder.repeatIntervalDays! <= 0)) {
      throw Exception('Repeating reminders must have a valid interval');
    }

    // Get old reminder to cancel its notifications
    final oldReminder = _repository.getReminderById(updatedReminder.id);
    if (oldReminder != null) {
      await _cancelOldNotifications(oldReminder);
    }

    // Update in database
    await _repository.updateReminder(updatedReminder);

    // Schedule new notifications if active
    if (updatedReminder.isActive) {
      await _scheduleNotifications(updatedReminder);
    }
  }

  /// Cancel old notifications.
  Future<void> _cancelOldNotifications(Reminder reminder) async {
    final notificationId = reminder.id.hashCode;
    
    if (reminder.isRepeating && reminder.repeatIntervalDays != null) {
      // Cancel repeating notifications range
      await _notificationService.cancelNotificationRange(notificationId, 100);
    } else {
      // Cancel single notification
      await _notificationService.cancelNotification(notificationId);
    }
  }

  /// Schedule new notifications for the updated reminder.
  Future<void> _scheduleNotifications(Reminder reminder) async {
    final notificationId = reminder.id.hashCode;

    if (reminder.isRepeating && reminder.repeatIntervalDays != null) {
      // Schedule custom repeating notifications
      await _notificationService.scheduleCustomRepeatingNotification(
        baseId: notificationId,
        title: reminder.title,
        body: reminder.description,
        firstTime: reminder.scheduledTime,
        intervalDays: reminder.repeatIntervalDays!,
        totalNotifications: 100,
        payload: _createPayload(reminder),
      );
    } else {
      // Schedule single notification
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: reminder.title,
        body: reminder.description,
        scheduledTime: reminder.scheduledTime,
        payload: _createPayload(reminder),
      );
    }
  }

  /// Create notification payload for navigation.
  String _createPayload(Reminder reminder) {
    return 'reminder:${reminder.id}:${reminder.linkedActivityId ?? ''}:${reminder.linkedPlotId ?? ''}';
  }
}