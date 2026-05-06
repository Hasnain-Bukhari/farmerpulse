import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_providers.dart';
import '../widgets/dashboard_widgets.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../domain/entities/revenue.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen for managing profit/loss and financial analytics.
class ProfitLossScreen extends ConsumerStatefulWidget {
  final String? seasonId;

  const ProfitLossScreen({
    super.key,
    this.seasonId,
  });

  @override
  ConsumerState<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends ConsumerState<ProfitLossScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSeasonId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedSeasonId = widget.seasonId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Revenue', icon: Icon(Icons.trending_up)),
            Tab(text: 'Analysis', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => _showAddRevenueDialog(),
            tooltip: 'Add Revenue',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildRevenueTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final profitLossResult = _selectedSeasonId != null
        ? ref.watch(seasonProfitLossProvider(_selectedSeasonId!))
        : ref.watch(totalProfitLossProvider);
    
    final profitLossAsync = AsyncValue.data(profitLossResult);

    return profitLossAsync.when(
      data: (result) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Season Selection
          _buildSeasonSelector(),
          const SizedBox(height: 16),

          // Financial Summary
          FinancialSummaryCard(
            totalRevenue: result.totalRevenue,
            totalExpenses: result.totalExpenses,
            netProfit: result.netProfit,
          ),
          const SizedBox(height: 16),

          // Key Metrics
          _buildKeyMetrics(result),
          const SizedBox(height: 16),

          // Breakdown Charts
          _buildBreakdownSection(result),
        ],
      ),
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, stack) => AppErrorWidget(
        message: 'Failed to load profit/loss data: $error',
        onRetry: () => ref.refresh(
          _selectedSeasonId != null
              ? seasonProfitLossProvider(_selectedSeasonId!)
              : totalProfitLossProvider,
        ),
      ),
    );
  }

  Widget _buildRevenueTab() {
    final revenues = _selectedSeasonId != null
        ? ref.watch(seasonRevenuesProvider(_selectedSeasonId!))
        : ref.watch(allRevenuesProvider);
    
    final revenuesAsync = AsyncValue.data(revenues);

    return revenuesAsync.when(
      data: (revenues) => Column(
        children: [
          // Add Revenue Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showAddRevenueDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Revenue'),
              ),
            ),
          ),

          // Revenue List
          Expanded(
            child: revenues.isEmpty
                ? _buildEmptyRevenueState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: revenues.length,
                    itemBuilder: (context, index) {
                      final revenue = revenues[index];
                      return _RevenueCard(
                        revenue: revenue,
                        onEdit: () => _showEditRevenueDialog(revenue),
                        onDelete: () => _confirmDeleteRevenue(revenue),
                      );
                    },
                  ),
          ),
        ],
      ),
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, stack) => AppErrorWidget(
        message: 'Failed to load revenues: $error',
        onRetry: () => ref.refresh(
          _selectedSeasonId != null
              ? seasonRevenuesProvider(_selectedSeasonId!)
              : allRevenuesProvider,
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    final profitLossResult = _selectedSeasonId != null
        ? ref.watch(seasonProfitLossProvider(_selectedSeasonId!))
        : ref.watch(totalProfitLossProvider);
    
    final profitLossAsync = AsyncValue.data(profitLossResult);

    return profitLossAsync.when(
      data: (result) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Break-Even Analysis
          _buildBreakEvenCard(result),
          const SizedBox(height: 16),

          // ROI Analysis
          _buildROICard(result),
          const SizedBox(height: 16),

          // Recommendations
          _buildRecommendationsCard(result),
        ],
      ),
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (error, stack) => AppErrorWidget(
        message: 'Failed to load analysis: $error',
        onRetry: () => ref.refresh(
          _selectedSeasonId != null
              ? seasonProfitLossProvider(_selectedSeasonId!)
              : totalProfitLossProvider,
        ),
      ),
    );
  }

  Widget _buildSeasonSelector() {
        final seasonsAsync = ref.watch(seasonsListProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: _selectedSeasonId,
                decoration: const InputDecoration(
                  labelText: 'Select Season',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Seasons'),
                  ),
                  ...seasonsAsync.map((season) {
                    return DropdownMenuItem(
                      value: season.id,
                      child: Text(season.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSeasonId = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(ProfitLossResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    label: 'Profit Margin',
                    value: result.formattedProfitMargin,
                    color: result.isProfit ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricChip(
                    label: 'ROI',
                    value: result.formattedROI,
                    color: result.roi > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownSection(ProfitLossResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...result.expensesByType.entries.map((entry) {
              final percentage = result.totalExpenses > 0
                  ? (entry.value / result.totalExpenses) * 100
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${entry.value.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakEvenCard(ProfitLossResult result) {
    final breakEven = result.getBreakEvenAnalysis();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Break-Even Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (breakEven.isBreakEvenOrProfit) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'You are ${result.isProfit ? "profitable" : "at break-even"}!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Need ${breakEven.formattedRevenueNeeded} more revenue',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildROICard(ProfitLossResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Return on Investment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('ROI: ${result.formattedROI}'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: result.roi > 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    result.roi > 0 ? 'Good' : 'Needs Improvement',
                    style: TextStyle(
                      color: result.roi > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(ProfitLossResult result) {
    final recommendations = _getRecommendations(result);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((recommendation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(recommendation)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRevenueState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No revenue recorded yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add revenue entries to calculate profit/loss',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getRecommendations(ProfitLossResult result) {
    final recommendations = <String>[];

    if (result.isLoss) {
      recommendations.add('Focus on reducing expenses or increasing revenue');
      recommendations.add('Consider optimizing your most expensive activity types');
    } else if (result.profitMargin < 10) {
      recommendations.add('Profit margin is low - consider cost optimization');
    }

    if (result.roi < 10) {
      recommendations.add('Return on investment is below 10% - review efficiency');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Good financial performance! Consider expansion opportunities');
    }

    return recommendations;
  }

  Future<void> _showAddRevenueDialog() async {
    // Navigate to revenue form
    context.push('/analytics/revenue/add?seasonId=$_selectedSeasonId');
  }

  Future<void> _showEditRevenueDialog(Revenue revenue) async {
    // Navigate to revenue form for editing
    context.push('/analytics/revenue/${revenue.id}/edit');
  }

  Future<void> _confirmDeleteRevenue(Revenue revenue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Revenue'),
        content: Text('Are you sure you want to delete "${revenue.description}"?'),
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
        await ref.read(deleteRevenueUseCaseProvider).call(revenue.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revenue deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
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

/// Widget displaying a revenue card.
class _RevenueCard extends StatelessWidget {
  final Revenue revenue;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _RevenueCard({
    required this.revenue,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(revenue.type),
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        revenue.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        revenue.type.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  revenue.formattedAmount,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(revenue.recordedDate),
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(RevenueType type) {
    switch (type) {
      case RevenueType.harvest:
        return Icons.agriculture;
      case RevenueType.livestock:
        return Icons.pets;
      case RevenueType.produce:
        return Icons.local_grocery_store;
      case RevenueType.equipment:
        return Icons.handyman;
      case RevenueType.services:
        return Icons.build;
      case RevenueType.subsidies:
        return Icons.account_balance;
      case RevenueType.insurance:
        return Icons.security;
      case RevenueType.other:
        return Icons.monetization_on;
    }
  }
}

/// Widget showing a metric chip.
class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}