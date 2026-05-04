import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../../plot/presentation/providers/plot_providers.dart';
import '../../../plot/presentation/widgets/plot_card.dart';
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
                      if (season.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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
              'Add plots to this season to track farming activities.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
}
