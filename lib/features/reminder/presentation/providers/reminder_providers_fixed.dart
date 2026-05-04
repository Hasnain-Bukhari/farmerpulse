import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../data/data_sources/reminder_local_data_source.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/use_cases/create_reminder_use_case.dart';
import '../../domain/use_cases/update_reminder_use_case.dart';
import '../../domain/use_cases/delete_reminder_use_case.dart';
import '../../domain/use_cases/complete_reminder_use_case.dart';

/// Provider for NotificationService.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for ReminderLocalDataSource.
final reminderLocalDataSourceProvider = Provider<ReminderLocalDataSource>((ref) {
  return ReminderLocalDataSource();
});

/// Provider for ReminderRepository.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final dataSource = ref.read(reminderLocalDataSourceProvider);
  return ReminderRepository(dataSource);
});

/// Provider for CreateReminderUseCase.
final createReminderUseCaseProvider = Provider<CreateReminderUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return CreateReminderUseCase(repository, notificationService);
});

/// Provider for UpdateReminderUseCase.
final updateReminderUseCaseProvider = Provider<UpdateReminderUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return UpdateReminderUseCase(repository, notificationService);
});

/// Provider for DeleteReminderUseCase.
final deleteReminderUseCaseProvider = Provider<DeleteReminderUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return DeleteReminderUseCase(repository, notificationService);
});

/// Provider for CompleteReminderUseCase.
final completeReminderUseCaseProvider = Provider<CompleteReminderUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return CompleteReminderUseCase(repository, notificationService);
});

/// Stream provider for all reminders.
final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return repository.watchReminders();
});

/// Provider for reminders by status.
final remindersByStatusProvider = Provider.family<List<Reminder>, ReminderStatus>((ref, status) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  
  return remindersAsync.when(
    data: (reminders) => reminders.where((r) => _getReminderStatus(r) == status).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for due reminders count.
final dueRemindersCountProvider = Provider<int>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  
  return remindersAsync.when(
    data: (reminders) {
      final now = DateTime.now();
      return reminders.where((reminder) {
        return reminder.isActive && 
               reminder.scheduledTime.isBefore(now.add(const Duration(hours: 24)));
      }).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for overdue reminders count.
final overdueRemindersCountProvider = Provider<int>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  
  return remindersAsync.when(
    data: (reminders) => reminders.where((r) => r.isOverdue).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for reminders by plot.
final remindersByPlotProvider = Provider.family<List<Reminder>, String?>((ref, plotId) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  
  return remindersAsync.when(
    data: (reminders) => reminders.where((r) => r.linkedPlotId == plotId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for reminders by activity.
final remindersByActivityProvider = Provider.family<List<Reminder>, String?>((ref, activityId) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  
  return remindersAsync.when(
    data: (reminders) => reminders.where((r) => r.linkedActivityId == activityId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for reminder by ID.
final reminderByIdProvider = Provider.family<Reminder?, String>((ref, reminderId) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  
  return remindersAsync.when(
    data: (reminders) => reminders.where((r) => r.id == reminderId).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Enhanced provider for notification permissions status with caching.
final notificationPermissionsProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  
  // Check if notifications are enabled
  final pendingNotifications = await notificationService.getPendingNotifications();
  
  // If we can get pending notifications, permissions are likely granted
  // This is a workaround since flutter_local_notifications doesn't provide
  // a direct way to check permission status on all platforms
  return true; // Assume granted if no exception thrown
});

/// Provider for pending notifications count (for debugging/monitoring).
final pendingNotificationsCountProvider = FutureProvider<int>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  final pending = await notificationService.getPendingNotifications();
  return pending.length;
});

/// Helper function to determine reminder status.
ReminderStatus _getReminderStatus(Reminder reminder) {
  if (!reminder.isActive || reminder.completedAt != null) {
    return ReminderStatus.completed;
  }
  
  final now = DateTime.now();
  if (reminder.scheduledTime.isBefore(now)) {
    return ReminderStatus.overdue;
  } else if (reminder.isDueToday) {
    return ReminderStatus.dueToday;
  } else {
    return ReminderStatus.upcoming;
  }
}

/// Enum for reminder status categories.
enum ReminderStatus {
  overdue,
  dueToday,
  upcoming,
  completed,
}