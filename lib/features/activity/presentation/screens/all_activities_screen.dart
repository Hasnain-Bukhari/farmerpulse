import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_providers.dart';
import '../widgets/activity_card.dart';
import '../../../plot/presentation/providers/plot_providers.dart';
import '../../../season/presentation/providers/season_providers.dart';

/// Screen showing all activities across all plots and seasons.
class AllActivitiesScreen extends ConsumerStatefulWidget {
  const AllActivitiesScreen({super.key});

  @override
  ConsumerState<AllActivitiesScreen> createState() => _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends ConsumerState<AllActivitiesScreen> {
  bool showOnlyRecent = false;

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final activitiesFallback = ref.watch(activitiesListProvider);
    final recentActivities = ref.watch(recentActivitiesProvider);
    final plots = ref.watch(plotsListProvider);
    final seasons = ref.watch(seasonsListProvider);

    // Debug: Add logging to understand the loading issue
    debugPrint('All Activities screen build - AsyncValue state: ${activitiesAsync.runtimeType}');
    debugPrint('Fallback activities: ${activitiesFallback.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Activities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(showOnlyRecent ? Icons.date_range : Icons.history),
            tooltip: showOnlyRecent ? 'Show All Activities' : 'Show Recent (7 days)',
            onPressed: () {
              setState(() {
                showOnlyRecent = !showOnlyRecent;
              });
            },
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (allActivities) => _buildActivitiesList(context, allActivities, plots, seasons),
        loading: () {
          // Use fallback data if available while loading
          if (activitiesFallback.isNotEmpty) {
            return _buildActivitiesList(context, activitiesFallback, plots, seasons);
          }
          return const Center(child: AppLoadingIndicator());
        },
        error: (error, stack) {
          debugPrint('Activities loading error: $error');
          // Use fallback data if available on error
          if (activitiesFallback.isNotEmpty) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange.withOpacity(0.1),
                  child: Text(
                    'Using cached data (sync issue detected)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                  ),
                ),
                Expanded(
                  child: _buildActivitiesList(context, activitiesFallback, plots, seasons),
                ),
              ],
            );
          }
          return AppErrorWidget(
            message: 'Failed to load activities: $error',
            onRetry: () => ref.refresh(activitiesStreamProvider),
          );
        },
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, List<Activity> allActivities, List<dynamic> plots, List<dynamic> seasons) {
    final recentActivitiesData = ref.watch(recentActivitiesProvider);
    final activities = showOnlyRecent ? recentActivitiesData : allActivities;

    if (activities.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group activities by date for better organization
    final activitiesByDate = <String, List<Activity>>{};
    for (final activity in activities) {
      final dateKey = _formatDate(activity.createdAt);
      activitiesByDate.putIfAbsent(dateKey, () => []).add(activity);
    }

    // Sort date keys (most recent first)
    final sortedDateKeys = activitiesByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDateKeys[index];
        final dateActivities = activitiesByDate[dateKey]!;
        
        // Sort activities within the date (most recent first)
        dateActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateHeader(dateKey),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dateActivities.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Activities for this date
            ...dateActivities.map((activity) {
              // Find plot and season info with safer fallbacks
              dynamic plot;
              try {
                plot = plots.isNotEmpty 
                    ? plots.firstWhere((p) => p.id == activity.plotId)
                    : null;
              } catch (e) {
                plot = plots.isNotEmpty ? plots.first : null;
              }
              
              dynamic season;
              try {
                season = plot != null && seasons.isNotEmpty
                    ? seasons.firstWhere((s) => s.id == plot.seasonId)
                    : null;
              } catch (e) {
                season = seasons.isNotEmpty ? seasons.first : null;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: Column(
                    children: [
                      ActivityCard(
                        activity: activity,
                        onTap: () {
                          if (plot != null) {
                            context.push(AppRouter.activityEdit(plot.id, activity.id));
                          }
                        },
                      ),
                      // Additional context info
                      if (plot != null && season != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${plot.name} • ${season.name}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (season.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
          ],
        );
      },
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              showOnlyRecent ? 'No recent activities' : 'No activities yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              showOnlyRecent 
                  ? 'No activities in the last 7 days. Try viewing all activities.'
                  : 'Add some plots and start recording your farm activities',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRouter.seasons),
              icon: const Icon(Icons.add),
              label: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateHeader(String dateKey) {
    final parts = dateKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final date = DateTime(year, month, day);
    final now = DateTime.now();

    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${monthNames[month - 1]} $day, $year';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}