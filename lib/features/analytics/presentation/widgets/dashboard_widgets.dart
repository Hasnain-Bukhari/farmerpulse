import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Widget displaying overall farm summary card.
class FarmSummaryCard extends StatelessWidget {
  final DashboardSummary summary;
  final VoidCallback? onTap;

  const FarmSummaryCard({
    super.key,
    required this.summary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.dashboard,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Farm Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          summary.activeSeason?.name ?? 'No active season',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ProductivityIndicator(score: summary.productivityScore),
                ],
              ),
              
              const SizedBox(height: 20),

              // Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: 'Plots',
                      value: summary.totalPlots.toString(),
                      icon: Icons.map,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricItem(
                      label: 'Activities',
                      value: summary.recentActivities.toString(),
                      sublabel: 'last 7 days',
                      icon: Icons.timeline,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      label: 'Total Expenses',
                      value: '\$${summary.activeSeasonExpenses.toStringAsFixed(0)}',
                      sublabel: 'current season',
                      icon: Icons.monetization_on,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricItem(
                      label: 'Reminders',
                      value: summary.dueReminders.toString(),
                      sublabel: 'due now',
                      icon: Icons.notifications,
                      color: summary.dueReminders > 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),

              // Urgency Alert
              if (summary.urgencyLevel != UrgencyLevel.none) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(summary.urgencyLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getUrgencyColor(summary.urgencyLevel).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: _getUrgencyColor(summary.urgencyLevel),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary.urgencyLevel.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getUrgencyColor(summary.urgencyLevel),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.high:
        return Colors.red;
      case UrgencyLevel.medium:
        return Colors.orange;
      case UrgencyLevel.low:
        return Colors.yellow.shade700;
      case UrgencyLevel.none:
        return Colors.grey;
    }
  }
}

/// Widget showing a single metric item.
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    this.sublabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(
              sublabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget showing productivity score indicator.
class _ProductivityIndicator extends StatelessWidget {
  final double score;

  const _ProductivityIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${score.toInt()}%',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'Active',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow.shade700;
    return Colors.red;
  }
}

/// Widget displaying financial summary.
class FinancialSummaryCard extends StatelessWidget {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final VoidCallback? onTap;

  const FinancialSummaryCard({
    super.key,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProfit = netProfit >= 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isProfit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: isProfit ? Colors.green : Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Summary',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isProfit ? 'Profitable' : 'Loss',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isProfit ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Financial Metrics
              Row(
                children: [
                  Expanded(
                    child: _FinancialMetric(
                      label: 'Revenue',
                      value: '\$${totalRevenue.toStringAsFixed(2)}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _FinancialMetric(
                      label: 'Expenses',
                      value: '\$${totalExpenses.toStringAsFixed(2)}',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Net Profit/Loss
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isProfit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isProfit ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net ${isProfit ? "Profit" : "Loss"}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${isProfit ? "+" : "-"}\$${netProfit.abs().toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isProfit ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget showing a single financial metric.
class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinancialMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Widget displaying quick action cards.
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onViewProfitLoss;
  final VoidCallback? onAddRevenue;
  final VoidCallback? onViewReports;
  final VoidCallback? onManageSeasons;

  const QuickActionsGrid({
    super.key,
    this.onViewProfitLoss,
    this.onAddRevenue,
    this.onViewReports,
    this.onManageSeasons,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _QuickActionCard(
          icon: Icons.analytics,
          label: 'Profit/Loss',
          description: 'View financial analytics',
          color: Colors.green,
          onTap: onViewProfitLoss,
        ),
        _QuickActionCard(
          icon: Icons.add_business,
          label: 'Add Revenue',
          description: 'Record income',
          color: Colors.blue,
          onTap: onAddRevenue,
        ),
        _QuickActionCard(
          icon: Icons.bar_chart,
          label: 'Reports',
          description: 'View detailed reports',
          color: Colors.purple,
          onTap: onViewReports,
        ),
        _QuickActionCard(
          icon: Icons.calendar_view_month,
          label: 'Seasons',
          description: 'Manage seasons',
          color: Colors.orange,
          onTap: onManageSeasons,
        ),
      ],
    );
  }
}

/// Individual quick action card.
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    this.onTap,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}