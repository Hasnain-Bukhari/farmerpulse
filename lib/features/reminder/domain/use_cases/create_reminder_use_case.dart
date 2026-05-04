import '../../data/repositories/reminder_repository.dart';
import '../entities/reminder.dart';
import '../../../../core/services/notification_service.dart';

/// Use case for creating reminders with notification scheduling.
class CreateReminderUseCase {
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  const CreateReminderUseCase(
    this._repository,
    this._notificationService,
  );

  /// Create a reminder and schedule notifications.
  Future<void> call(Reminder reminder) async {
    // Validation
    if (reminder.title.trim().isEmpty) {
      throw Exception('Reminder title cannot be empty');
    }

    if (reminder.scheduledTime.isBefore(DateTime.now())) {
      throw Exception('Reminder cannot be scheduled in the past');
    }

    if (reminder.isRepeating && 
        (reminder.repeatIntervalDays == null || reminder.repeatIntervalDays! <= 0)) {
      throw Exception('Repeating reminders must have a valid interval');
    }

    // Save to database
    await _repository.createReminder(reminder);

    // Schedule notifications
    await _scheduleNotifications(reminder);
  }

  /// Schedule notification(s) for the reminder.
  Future<void> _scheduleNotifications(Reminder reminder) async {
    final notificationId = reminder.id.hashCode;

    if (reminder.isRepeating && reminder.repeatIntervalDays != null) {
      // Schedule custom repeating notifications (max 100 occurrences)
      const maxNotifications = 100;
      await _notificationService.scheduleCustomRepeatingNotification(
        baseId: notificationId,
        title: reminder.title,
        body: reminder.description,
        firstTime: reminder.scheduledTime,
        intervalDays: reminder.repeatIntervalDays!,
        totalNotifications: maxNotifications,
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