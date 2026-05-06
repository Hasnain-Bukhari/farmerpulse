import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/data_sources/reminder_local_data_source.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../domain/use_cases/create_reminder_use_case.dart';
import '../../domain/use_cases/update_reminder_use_case.dart';
import '../../domain/use_cases/delete_reminder_use_case.dart';
import '../../domain/use_cases/complete_reminder_use_case.dart';
import '../../domain/entities/reminder.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Core Infrastructure Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Notification service provider.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Reminder data source provider.
final reminderLocalDataSourceProvider = Provider<ReminderLocalDataSource>((ref) {
  return ReminderLocalDataSource();
});

/// Reminder repository provider.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final dataSource = ref.watch(reminderLocalDataSourceProvider);
  return ReminderRepository(dataSource);
});

// ══════════════════════════════════════════════════════════════════════════════
// Use Case Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Create reminder use case provider.
final createReminderUseCaseProvider = Provider<CreateReminderUseCase>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return CreateReminderUseCase(repository, notificationService);
});

/// Update reminder use case provider.
final updateReminderUseCaseProvider = Provider<UpdateReminderUseCase>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return UpdateReminderUseCase(repository, notificationService);
});

/// Delete reminder use case provider.
final deleteReminderUseCaseProvider = Provider<DeleteReminderUseCase>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return DeleteReminderUseCase(repository, notificationService);
});

/// Complete reminder use case provider.
final completeReminderUseCaseProvider = Provider<CompleteReminderUseCase>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return CompleteReminderUseCase(repository, notificationService);
});

// ══════════════════════════════════════════════════════════════════════════════
// Data Stream Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Stream provider for all reminders.
final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchReminders();
});

/// Stream provider for active reminders.
final activeRemindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  try {
    final repository = ref.watch(reminderRepositoryProvider);
    return repository.watchActiveReminders().handleError((error, stackTrace) {
      // Log the error for debugging
      debugPrint('Error in activeRemindersStreamProvider: $error');
      debugPrint('Stack trace: $stackTrace');
      throw error; // Re-throw to let Riverpod handle it
    });
  } catch (e) {
    debugPrint('Error creating activeRemindersStreamProvider: $e');
    // Return a stream with an empty list as fallback
    return Stream.value(<Reminder>[]);
  }
});

/// Stream provider for reminders by plot ID.
final remindersByPlotStreamProvider = 
    StreamProvider.family<List<Reminder>, String>((ref, plotId) {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.watchRemindersByPlotId(plotId);
});

// ══════════════════════════════════════════════════════════════════════════════
// State Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider for all reminders list.
final remindersListProvider = Provider<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  return remindersAsync.when(
    data: (reminders) => reminders,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for active reminders list.
final activeRemindersListProvider = Provider<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(activeRemindersStreamProvider);
  return remindersAsync.when(
    data: (reminders) => reminders,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Fallback provider for active reminders (synchronous).
final activeRemindersFallbackProvider = Provider<List<Reminder>>((ref) {
  try {
    final repository = ref.watch(reminderRepositoryProvider);
    return repository.getActiveReminders();
  } catch (e) {
    debugPrint('Error in activeRemindersFallbackProvider: $e');
    return <Reminder>[];
  }
});

/// Provider for due reminders (overdue and due today).
final dueRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(activeRemindersListProvider);
  return reminders.where((reminder) => reminder.isOverdue || reminder.isDueToday).toList();
});

/// Provider for upcoming reminders (next 7 days).
final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(activeRemindersListProvider);
  return reminders.where((reminder) => reminder.isDueSoon).toList();
});

/// Provider for reminder by ID.
final reminderByIdProvider = Provider.family<Reminder?, String>((ref, id) {
  final reminders = ref.watch(remindersListProvider);
  try {
    return reminders.firstWhere((reminder) => reminder.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider for reminders count.
final remindersCountProvider = Provider<int>((ref) {
  final reminders = ref.watch(remindersListProvider);
  return reminders.length;
});

/// Provider for active reminders count.
final activeRemindersCountProvider = Provider<int>((ref) {
  final reminders = ref.watch(activeRemindersListProvider);
  return reminders.length;
});

/// Provider for due reminders count.
final dueRemindersCountProvider = Provider<int>((ref) {
  final dueReminders = ref.watch(dueRemindersProvider);
  return dueReminders.length;
});

// ══════════════════════════════════════════════════════════════════════════════
// Filter and Sort Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider for reminders filtered by type.
final remindersByTypeProvider = 
    Provider.family<List<Reminder>, ReminderType>((ref, type) {
  final reminders = ref.watch(activeRemindersListProvider);
  return reminders.where((reminder) => reminder.type == type).toList();
});

/// Provider for reminders sorted by scheduled time.
final remindersSortedByTimeProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(activeRemindersListProvider);
  final sortedReminders = List<Reminder>.from(reminders);
  sortedReminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  return sortedReminders;
});

/// Provider for overdue reminders.
final overdueRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(activeRemindersListProvider);
  return reminders.where((reminder) => reminder.isOverdue).toList();
});

/// Provider for today's reminders.
final todaysRemindersProvider = Provider<List<Reminder>>((ref) {
  final reminders = ref.watch(activeRemindersListProvider);
  return reminders.where((reminder) => reminder.isDueToday).toList();
});

// ══════════════════════════════════════════════════════════════════════════════
// Notification Status Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider for notification permissions status.
final notificationPermissionsProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.requestPermissions();
});

/// Provider for pending notification requests.
final pendingNotificationsProvider = FutureProvider((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getPendingNotifications();
});