import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../domain/entities/season.dart';
import '../../../plot/presentation/providers/plot_providers.dart';
import '../../../plot/presentation/widgets/plot_card.dart';
import '../../../plot/domain/entities/plot.dart';
import '../../../activity/presentation/providers/activity_providers.dart';
import '../../../activity/presentation/widgets/expense_widgets.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen showing details of a specific season and its plots.
class SeasonDetailScreen extends ConsumerWidget {
  final String seasonId;

  const SeasonDetailScreen({
    super.key,
    required this.seasonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = ref.watch(seasonByIdProvider(seasonId));
    final plotsAsync = ref.watch(plotsBySeasonStreamProvider(seasonId));
    final seasonExpense = ref.watch(seasonTotalExpenseProvider(seasonId));

    if (seasonAsync == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Season')),
        body: const Center(
          child: Text('Season not found'),
        ),
      );
    }

    final season = seasonAsync;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(season.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => context.push('/analytics/profit-loss?seasonId=$seasonId'),
            tooltip: 'View Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => context.push('/analytics/revenue/add?seasonId=$seasonId'),
            tooltip: 'Add Revenue',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/seasons/$seasonId/edit'),
            tooltip: 'Edit Season',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              if (season.isActive)
                const PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text('Complete Season'),
                    ],
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'reactivate',
                  child: Row(
                    children: [
                      Icon(Icons.play_circle_outline),
                      SizedBox(width: 8),
                      Text('Reactivate Season'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              if (value == 'complete') {
                _completeSeason(context, ref, season);
              } else if (value == 'reactivate') {
                _reactivateSeason(context, ref, season);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Season Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Season Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: season.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              season.isActive ? Icons.play_circle : Icons.check_circle,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              season.isActive ? 'ACTIVE' : 'COMPLETED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Duration',
                    '${dateFormat.format(season.startDate)} - ${dateFormat.format(season.endDate)}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.timelapse,
                    'Days',
                    '${season.getDurationInDays()} days',
                  ),
                  if (season.cropType != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.grass,
                      'Crop',
                      season.cropType!,
                    ),
                  ],
                  // Total Expense
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.attach_money,
                    'Total Expenses',
                    '\$${seasonExpense.toStringAsFixed(2)}',
                    valueColor: seasonExpense > 0 ? Colors.green : null,
                  ),
                  if (season.notes != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      season.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Season Management Section
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.manage_accounts,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Season Management',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Season completion status and actions
                  Consumer(
                    builder: (context, ref, _) {
                      final plots = ref.watch(plotsBySeasonProvider(season.id));
                      final activePlots = plots.where((plot) => plot.status == PlotStatus.active).toList();
                      final canComplete = season.isActive && activePlots.isEmpty;
                      
                      return Column(
                        children: [
                          // Status indicator
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: canComplete 
                                  ? Colors.green.withOpacity(0.1)
                                  : season.isActive 
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: canComplete 
                                    ? Colors.green
                                    : season.isActive 
                                      ? Colors.orange
                                      : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  canComplete 
                                      ? Icons.check_circle
                                      : season.isActive 
                                        ? Icons.pending
                                        : Icons.done_all,
                                  color: canComplete 
                                      ? Colors.green
                                      : season.isActive 
                                        ? Colors.orange
                                        : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        canComplete 
                                            ? 'Ready to Complete'
                                            : season.isActive 
                                              ? 'Season Active (${activePlots.length} plots active)'
                                              : 'Season Completed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getDarkerColor(canComplete 
                                              ? Colors.green
                                              : season.isActive 
                                                ? Colors.orange
                                                : Colors.grey),
                                        ),
                                      ),
                                      if (season.isActive && activePlots.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Complete all plots to finish this season',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getDarkerColor(Colors.orange),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            children: [
                              if (season.isActive) ...[
                                if (canComplete)
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _completeSeason(context, ref, season),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('Complete Season'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showPlotCompletionHelp(
                                        context,
                                        ref,
                                        season,
                                        activePlots,
                                      ),
                                      icon: const Icon(Icons.help_outline),
                                      label: Text('Complete ${activePlots.length} Plots'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange,
                                        side: const BorderSide(color: Colors.orange),
                                      ),
                                    ),
                                  ),
                              ] else ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _reactivateSeason(context, ref, season),
                                    icon: const Icon(Icons.play_circle_outline),
                                    label: const Text('Reactivate Season'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      side: const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Financial Tracking Section
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Financial Tracking',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/analytics/revenue/add?seasonId=${season.id}'
                          ),
                          icon: const Icon(Icons.add_business, color: Colors.green),
                          label: const Text('Add Season Revenue'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/analytics/profit-loss?seasonId=${season.id}'
                          ),
                          icon: const Icon(Icons.analytics, color: Colors.blue),
                          label: const Text('View Analytics'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your earnings and expenses for this season',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Plots Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plots',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/seasons/$seasonId/plots/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Plot'),
                ),
              ],
            ),
          ),

          // Plots List
          Expanded(
            child: plotsAsync.when(
              data: (plots) {
                if (plots.isEmpty) {
                  return _buildEmptyPlots(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: plots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final plot = plots[index];
                    final plotExpense =
                        ref.watch(plotTotalExpenseProvider(plot.id));

                    return Column(
                      children: [
                        PlotCard(
                          plot: plot,
                          onTap: () {
                            context.push('/plots/${plot.id}/activities');
                          },
                          onStatusChange: () => _changePlotStatus(context, ref, plot, season),
                        ),
                        // Revenue and Expense Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push(
                                    '/analytics/revenue/add?seasonId=${season.id}&plotId=${plot.id}'
                                  ),
                                  icon: const Icon(Icons.add_business, size: 16),
                                  label: const Text('Add Earnings'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.green),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/plots/${plot.id}/activities/add'),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Activity'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Additional Actions Row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/plots/${plot.id}/activities/timeline'),
                                  icon: const Icon(Icons.timeline, size: 16),
                                  label: const Text('Timeline'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.purple,
                                    side: const BorderSide(color: Colors.purple),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/plots/${plot.id}/activities'),
                                  icon: const Icon(Icons.list, size: 16),
                                  label: const Text('Activities'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.indigo,
                                    side: const BorderSide(color: Colors.indigo),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expense indicator below plot card
                        if (plotExpense > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ExpenseIndicator(amount: plotExpense),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (error, stack) => AppErrorWidget(
                message: 'Failed to load plots: $error',
                onRetry: () => ref.refresh(plotsBySeasonStreamProvider(seasonId)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seasons/$seasonId/plots/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Plot'),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: valueColor != null ? FontWeight.w600 : null,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlots(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Plots Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add plots to this season to track farming activities and plot-specific earnings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tip: Start by adding your first plot!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can track earnings for the entire season or by individual plots. Use the Financial Tracking section above to add season-wide revenue.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/seasons/$seasonId/plots/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add First Plot'),
            ),
          ],
        ),
      ),
    );
  }

  /// Complete the current season
  Future<void> _completeSeason(BuildContext context, WidgetRef ref, Season season) async {
    // Check if all plots are completed (fallow or retired)
    final plots = ref.read(plotsBySeasonProvider(season.id));
    final activePlots = plots.where((plot) => plot.status == PlotStatus.active).toList();
    
    if (activePlots.isNotEmpty) {
      // Show warning that there are still active plots
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Complete Season'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have ${activePlots.length} active plots that need to be completed first:'),
              const SizedBox(height: 12),
              ...activePlots.map((plot) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(plot.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              const Text(
                'To complete the season:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Go to each plot and change status to "Fallow" or "Retired"'),
              const Text('2. Complete all farming activities'),
              const Text('3. Add final revenue/earnings'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Season'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to complete "${season.name}"?'),
            const SizedBox(height: 16),
            const Text(
              'All plots are properly completed ✓',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Mark the season as inactive'),
            const Text('• Calculate final earnings and expenses'),
            const Text('• Generate season summary report'),
            const SizedBox(height: 16),
            const Text(
              'You can still view analytics and data, but cannot add new activities.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Complete Season'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Deactivate the season
        final completedSeason = season.copyWith(isActive: false);
        await ref.read(updateSeasonUseCaseProvider).call(completedSeason);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Season "${season.name}" completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to analytics to show final results
          context.push('/analytics/profit-loss?seasonId=${season.id}');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing season: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Reactivate a completed season
  Future<void> _reactivateSeason(BuildContext context, WidgetRef ref, Season season) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivate Season'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to reactivate "${season.name}"?'),
            const SizedBox(height: 16),
            const Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Mark the season as active again'),
            const Text('• Allow adding new activities and revenue'),
            const Text('• Deactivate any other currently active seasons'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // First, deactivate all other seasons
        final allSeasons = ref.read(seasonsListProvider);
        for (final existingSeason in allSeasons) {
          if (existingSeason.isActive && existingSeason.id != season.id) {
            final deactivatedSeason = existingSeason.copyWith(isActive: false);
            await ref.read(updateSeasonUseCaseProvider).call(deactivatedSeason);
          }
        }
        
        // Then activate this season
        final activatedSeason = season.copyWith(isActive: true);
        await ref.read(updateSeasonUseCaseProvider).call(activatedSeason);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Season "${season.name}" reactivated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reactivating season: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Show help for completing active plots
  void _showPlotCompletionHelp(
    BuildContext context,
    WidgetRef ref,
    Season season,
    List<Plot> activePlots,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Active Plots'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have ${activePlots.length} active plots that need to be completed:'),
            const SizedBox(height: 12),
            ...activePlots.take(5).map((plot) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plot.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _changePlotStatus(context, ref, plot, season);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Complete', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            )),
            if (activePlots.length > 5) ...[
              Text('... and ${activePlots.length - 5} more plots'),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Click "Set Fallow" on each plot to mark them as complete for this season.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  /// Change plot status with confirmation
  Future<void> _changePlotStatus(BuildContext context, WidgetRef ref, Plot plot, Season season) async {
    final nextStatus = _getNextPlotStatus(plot.status);
    final actionText = _getStatusActionText(plot.status);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText Plot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to $actionText "${plot.name}"?'),
            const SizedBox(height: 12),
            _buildStatusExplanation(plot.status, nextStatus),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final updatedPlot = plot.copyWith(status: nextStatus);
        await ref.read(updatePlotUseCaseProvider).call(updatedPlot);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plot "${plot.name}" status updated to ${nextStatus.label}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update plot status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  PlotStatus _getNextPlotStatus(PlotStatus currentStatus) {
    switch (currentStatus) {
      case PlotStatus.active:
        return PlotStatus.fallow;
      case PlotStatus.fallow:
        return PlotStatus.active;
      case PlotStatus.retired:
        return PlotStatus.active;
    }
  }

  String _getStatusActionText(PlotStatus currentStatus) {
    switch (currentStatus) {
      case PlotStatus.active:
        return 'Set Fallow';
      case PlotStatus.fallow:
        return 'Reactivate';
      case PlotStatus.retired:
        return 'Reactivate';
    }
  }

  Widget _buildStatusExplanation(PlotStatus currentStatus, PlotStatus nextStatus) {
    String explanation;
    IconData icon;
    Color color;

    switch (nextStatus) {
      case PlotStatus.active:
        explanation = 'The plot will be marked as active and ready for new activities.';
        icon = Icons.play_circle;
        color = Colors.green;
        break;
      case PlotStatus.fallow:
        explanation = 'The plot will be set to fallow (resting) and won\'t accept new activities until reactivated.';
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      case PlotStatus.retired:
        explanation = 'The plot will be retired and removed from active use.';
        icon = Icons.stop_circle;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: TextStyle(
                color: _getDarkerColor(color),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get a darker version of the color for better text contrast
  Color _getDarkerColor(Color color) {
    if (color == Colors.green) return Colors.green.shade700;
    if (color == Colors.orange) return Colors.orange.shade700;
    if (color == Colors.grey) return Colors.grey.shade700;
    // For any other color, darken it manually
    return Color.fromARGB(
      color.alpha,
      (color.red * 0.7).round(),
      (color.green * 0.7).round(),
      (color.blue * 0.7).round(),
    );
  }
}
