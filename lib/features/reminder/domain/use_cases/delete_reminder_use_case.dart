import '../../data/repositories/reminder_repository.dart';
import '../../../../core/services/notification_service.dart';

/// Use case for deleting reminders and canceling notifications.
class DeleteReminderUseCase {
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  const DeleteReminderUseCase(
    this._repository,
    this._notificationService,
  );

  /// Delete a reminder and cancel its notifications.
  Future<void> call(String reminderId) async {
    // Validation
    final reminder = _repository.getReminderById(reminderId);
    if (reminder == null) {
      throw Exception('Reminder not found');
    }

    // Cancel notifications
    final notificationId = reminder.id.hashCode;
    if (reminder.isRepeating && reminder.repeatIntervalDays != null) {
      // Cancel repeating notifications range
      await _notificationService.cancelNotificationRange(notificationId, 100);
    } else {
      // Cancel single notification
      await _notificationService.cancelNotification(notificationId);
    }

    // Delete from database
    await _repository.deleteReminder(reminderId);
  }
}