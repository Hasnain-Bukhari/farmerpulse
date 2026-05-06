import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/season_providers.dart';
import '../widgets/season_card.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen displaying a list of all seasons.
///
/// Uses Riverpod to watch the seasons stream and automatically
/// rebuilds when seasons are added, updated, or deleted.
class SeasonListScreen extends ConsumerWidget {
  const SeasonListScreen({super.key});

  static const routeName = 'seasons';
  static const routePath = '/seasons';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasons = ref.watch(seasonsListProvider);
    // Convert to AsyncValue for compatibility with existing UI
    final seasonsAsync = AsyncValue.data(seasons);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seasons'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showSeasonInfo(context),
            tooltip: 'Season Info',
          ),
        ],
      ),
      body: seasonsAsync.when(
        data: (seasons) {
          if (seasons.isEmpty) {
            return _buildEmptyState(context);
          }

          // Sort seasons: active first, then by start date descending
          final sortedSeasons = List.of(seasons)
            ..sort((a, b) {
              if (a.isActive && !b.isActive) return -1;
              if (!a.isActive && b.isActive) return 1;
              return b.startDate.compareTo(a.startDate);
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedSeasons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return SeasonCard(
                season: sortedSeasons[index],
                onTap: () => _navigateToSeasonDetail(context, sortedSeasons[index].id),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stack) => AppErrorWidget(
          message: 'Failed to load seasons: $error',
          onRetry: () => ref.refresh(seasonsListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateSeason(context),
        icon: const Icon(Icons.add),
        label: const Text('New Season'),
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
              Icons.calendar_today_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Seasons Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first farming season to start tracking plots and activities.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToCreateSeason(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Season'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateSeason(BuildContext context) {
    context.push('/seasons/create');
  }

  void _navigateToSeasonDetail(BuildContext context, String seasonId) {
    // Navigate to plots for this season
    context.push('/seasons/$seasonId/plots');
  }

  void _showSeasonInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Seasons'),
        content: const Text(
          'Seasons help you organize your farming activities by time periods. '
          'Each season can contain multiple plots, and each plot tracks its own activities.\n\n'
          'Only one season can be active at a time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
