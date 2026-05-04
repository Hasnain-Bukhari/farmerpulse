import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen showing all reminders with filtering options.
class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(activeRemindersStreamProvider);
    final dueCount = ref.watch(dueRemindersCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          if (dueCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$dueCount due',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/reminders/add'),
            tooltip: 'Add Reminder',
          ),
        ],
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildRemindersList(context, ref, reminders);
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stack) => AppErrorWidget(
          message: 'Failed to load reminders: $error',
          onRetry: () => ref.refresh(activeRemindersStreamProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/reminders/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create reminders to stay on top of your farm activities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/reminders/add'),
              icon: const Icon(Icons.add),
              label: const Text('Create Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(
    BuildContext context,
    WidgetRef ref,
    List<reminder.Reminder> reminders,
  ) {
    // Group reminders by status
    final overdue = reminders.where((r) => r.isOverdue).toList();
    final dueToday = reminders.where((r) => r.isDueToday && !r.isOverdue).toList();
    final upcoming = reminders.where((r) => !r.isOverdue && !r.isDueToday).toList();

    // Sort each group
    overdue.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    dueToday.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    upcoming.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overdue section
        if (overdue.isNotEmpty) ...[
          _SectionHeader(
            title: 'Overdue',
            count: overdue.length,
            color: Theme.of(context).colorScheme.error,
          ),
          ...overdue.map((reminder) => _buildReminderCard(context, ref, reminder)),
          const SizedBox(height: 16),
        ],

        // Due today section
        if (dueToday.isNotEmpty) ...[
          _SectionHeader(
            title: 'Due Today',
            count: dueToday.length,
            color: Colors.orange,
          ),
          ...dueToday.map((reminder) => _buildReminderCard(context, ref, reminder)),
          const SizedBox(height: 16),
        ],

        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(
            title: 'Upcoming',
            count: upcoming.length,
            color: Theme.of(context).colorScheme.primary,
          ),
          ...upcoming.map((reminder) => _buildReminderCard(context, ref, reminder)),
        ],
      ],
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    WidgetRef ref,
    reminder.Reminder reminder,
  ) {
    return ReminderCard(
      reminder: reminder,
      onTap: () => _showReminderDetails(context, reminder),
      onComplete: () => _completeReminder(context, ref, reminder),
      onEdit: () => context.push('/reminders/${reminder.id}/edit'),
      onDelete: () => _confirmDelete(context, ref, reminder),
    );
  }

  void _showReminderDetails(BuildContext context, reminder.Reminder reminder) {
    // TODO: Navigate to reminder detail screen or show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReminderDetailsSheet(reminder: reminder),
    );
  }

  Future<void> _completeReminder(
    BuildContext context,
    WidgetRef ref,
    reminder.Reminder reminder,
  ) async {
    try {
      await ref.read(completeReminderUseCaseProvider).call(reminder.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder completed!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    reminder.Reminder reminder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteReminderUseCaseProvider).call(reminder.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing reminder details.
class _ReminderDetailsSheet extends StatelessWidget {
  final reminder.Reminder reminder;

  const _ReminderDetailsSheet({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, controller) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              reminder.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Details
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reminder.description.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(reminder.description),
                      const SizedBox(height: 16),
                    ],
                    // Add more details as needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}