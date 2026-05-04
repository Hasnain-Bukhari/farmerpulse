import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_providers.dart';
import '../widgets/activity_card.dart';
import '../widgets/expense_widgets.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen displaying activities in timeline format sorted by date.
class ActivityTimelineScreen extends ConsumerWidget {
  final String plotId;

  const ActivityTimelineScreen({
    super.key,
    required this.plotId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesByPlotStreamProvider(plotId));
    final plotExpense = ref.watch(plotTotalExpenseProvider(plotId));
    final expenseByType = ref.watch(plotExpenseByTypeProvider(plotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showExpenseBreakdown(context, ref),
            tooltip: 'View Expenses',
          ),
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: () => context.push('/reminders/add?plotId=$plotId'),
            tooltip: 'Add Reminder',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/plots/$plotId/activities/add'),
            tooltip: 'Add Activity',
          ),
        ],
      ),
      body: Column(
        children: [
          // Expense Summary Card
          if (plotExpense > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: activitiesAsync.when(
                data: (activities) => ExpenseSummaryCard(
                  totalCost: plotExpense,
                  activityCount: activities.length,
                  label: 'Plot Total Expenses',
                  icon: Icons.analytics,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // Activities Timeline
          Expanded(
            child: activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Sort activities by date (newest first)
                final sortedActivities = List<Activity>.from(activities)
                  ..sort((a, b) => b.date.compareTo(a.date));

                // Group activities by date
                final grouped = _groupActivitiesByDate(sortedActivities);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    return _DateGroup(
                      date: entry.key,
                      activities: entry.value,
                      onActivityTap: (activity) =>
                          _navigateToEditActivity(context, activity),
                      onActivityDelete: (activity) =>
                          _confirmDelete(context, ref, activity),
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (error, stack) => AppErrorWidget(
                message: 'Failed to load activities: $error',
                onRetry: () => ref.refresh(activitiesByPlotStreamProvider(plotId)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/plots/$plotId/activities/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
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
              Icons.timeline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Activities Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking activities for this plot to see your farming timeline.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/plots/$plotId/activities/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add First Activity'),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<Activity>> _groupActivitiesByDate(
    List<Activity> activities,
  ) {
    final Map<DateTime, List<Activity>> grouped = {};

    for (final activity in activities) {
      // Create date without time for grouping
      final dateKey = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(activity);
    }

    return grouped;
  }

  void _navigateToEditActivity(BuildContext context, Activity activity) {
    context.push('/plots/${activity.plotId}/activities/${activity.id}/edit');
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Delete "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(deleteActivityUseCaseProvider).call(activity.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _showExpenseBreakdown(BuildContext context, WidgetRef ref) {
    final expenseByType = ref.read(plotExpenseByTypeProvider(plotId));
    final totalExpense = ref.read(plotTotalExpenseProvider(plotId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
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
              
              // Header
              Text(
                'Expense Breakdown',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${totalExpense.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Breakdown
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: expenseByType.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses recorded yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        )
                      : ExpenseBreakdownList(
                          breakdown: expenseByType,
                          total: totalExpense,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget displaying a group of activities for a specific date.
class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<Activity> activities;
  final Function(Activity) onActivityTap;
  final Function(Activity) onActivityDelete;

  const _DateGroup({
    required this.date,
    required this.activities,
    required this.onActivityTap,
    required this.onActivityDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: isToday ? Colors.blue : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isToday ? 'Today' : dateFormat.format(date),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.blue : null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activities.length} ${activities.length == 1 ? "activity" : "activities"}',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),

        // Activities for this date
        ...activities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(
                activity: activity,
                onTap: () => onActivityTap(activity),
                onDelete: () => onActivityDelete(activity),
              ),
            )),
      ],
    );
  }
}
