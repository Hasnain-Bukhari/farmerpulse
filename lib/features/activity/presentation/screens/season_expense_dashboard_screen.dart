import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../../activity/presentation/providers/activity_providers.dart';
import '../../../activity/presentation/widgets/expense_widgets.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';

/// Screen showing expense dashboard for a season.
class SeasonExpenseDashboardScreen extends ConsumerWidget {
  final String seasonId;

  const SeasonExpenseDashboardScreen({
    super.key,
    required this.seasonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final season = ref.watch(seasonByIdProvider(seasonId));
    final seasonExpense = ref.watch(seasonTotalExpenseProvider(seasonId));
    final expenseBreakdown = ref.watch(seasonExpenseBreakdownProvider(seasonId));

    if (season == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expenses')),
        body: const Center(child: Text('Season not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${season.name} - Expenses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Season Expense
          ExpenseSummaryCard(
            totalCost: seasonExpense,
            activityCount: _getTotalActivities(expenseBreakdown),
            label: 'Total Season Expenses',
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 24),

          // Plot Breakdown Section
          Text(
            'Expenses by Plot',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Plot Expense Cards
          if (expenseBreakdown.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses recorded yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...expenseBreakdown.entries.map((entry) {
              final plotSummary = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlotExpenseCard(
                  plotSummary: plotSummary,
                  onTap: () => context.push('/plots/${plotSummary.plotId}/activities'),
                ),
              );
            }),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/seasons/$seasonId'),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Season'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement data export
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTotalActivities(Map<String, PlotExpenseSummary> breakdown) {
    return breakdown.values.fold(0, (sum, plot) => sum + plot.activityCount);
  }
}

/// Card showing plot expense summary.
class _PlotExpenseCard extends StatelessWidget {
  final PlotExpenseSummary plotSummary;
  final VoidCallback onTap;

  const _PlotExpenseCard({
    required this.plotSummary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plotSummary.plotName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ExpenseIndicator(amount: plotSummary.totalCost),
                ],
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${plotSummary.activityCount} ${plotSummary.activityCount == 1 ? "activity" : "activities"}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calculate,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Avg: \$${plotSummary.averageCostPerActivity.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}