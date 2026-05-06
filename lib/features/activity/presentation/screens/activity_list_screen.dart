import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/activity_providers.dart';
import '../widgets/activity_card.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen displaying a list of activities for a specific plot.
class ActivityListScreen extends ConsumerWidget {
  final String plotId;

  const ActivityListScreen({
    super.key,
    required this.plotId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesByPlotProvider(plotId));
    // Convert to AsyncValue for compatibility with existing UI
    final activitiesAsync = AsyncValue.data(activities);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () => context.push('/plots/$plotId/activities/timeline'),
            tooltip: 'Timeline View',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/plots/$plotId/activities/add'),
            tooltip: 'Add Activity',
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No activities yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start tracking your farming activities',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/plots/$plotId/activities/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Activity'),
                  ),
                ],
              ),
            );
          }

          // Sort activities by date (most recent first)
          final sortedActivities = List.from(activities)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedActivities.length,
            itemBuilder: (context, index) {
              final activity = sortedActivities[index];
              return ActivityCard(
                activity: activity,
                onEdit: () => context.push('/plots/$plotId/activities/${activity.id}/edit'),
                onDelete: () async {
                  final confirmed = await _showDeleteConfirmation(context, activity.type.name);
                  if (confirmed && context.mounted) {
                    await ref.read(deleteActivityUseCaseProvider).call(activity.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Activity "${activity.type.name}" deleted'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (error, stack) => AppErrorWidget(
          message: 'Error loading activities: $error',
          onRetry: () => ref.invalidate(activitiesByPlotProvider(plotId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plots/$plotId/activities/add'),
        tooltip: 'Add Activity',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String activityType) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete this $activityType activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}