import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../../plot/presentation/providers/plot_providers.dart';
import '../../../activity/presentation/providers/activity_providers.dart';
import '../../../reminder/presentation/providers/reminder_providers.dart';
import '../../../analytics/presentation/providers/analytics_providers.dart';
import '../../../analytics/presentation/widgets/dashboard_widgets.dart';

/// Home / dashboard screen.
///
/// This is the main landing screen after the splash.
/// Shows quick access to main features and summary statistics.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsListProvider);
    final activeSeason = ref.watch(activeSeasonProvider);
    final plotsAsync = ref.watch(plotsStreamProvider);
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final dueRemindersCount = ref.watch(dueRemindersCountProvider);
    final dashboardSummary = ref.watch(dashboardSummaryProvider);

    final seasonCount = seasonsAsync.length;
    final plotCount = plotsAsync.when(
      data: (plots) => plots.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final activityCount = activitiesAsync.when(
      data: (activities) => activities.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    // Calculate total expenses for active season
    final activeSeasonExpense = activeSeason != null
        ? ref.watch(seasonTotalExpenseProvider(activeSeason.id))
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmerPulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.goNamed(AppRouter.settingsName),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active Season Banner
          if (activeSeason != null)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active Season',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeSeason.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activeSeason.getDurationInDays()} days',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No active season. Create one to get started.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Dashboard Summary Card
          FarmSummaryCard(
            summary: dashboardSummary,
            onTap: () => context.push('/analytics/profit-loss'),
          ),
          const SizedBox(height: 24),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  label: 'Seasons',
                  value: seasonCount.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.map,
                  label: 'Plots',
                  value: plotCount.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timeline,
                  label: 'Activities',
                  value: activityCount.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  label: 'Expenses',
                  value: '\$${activeSeasonExpense.toStringAsFixed(0)}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Large Action Buttons
          _LargeActionButton(
            icon: Icons.calendar_today,
            title: 'Manage Seasons',
            subtitle: 'View and organize farming seasons',
            onTap: () => context.push(AppRouter.seasons),
          ),
          const SizedBox(height: 12),
          _LargeActionButton(
            icon: Icons.add_circle_outline,
            title: 'Create New Season',
            subtitle: 'Start a new farming season',
            onTap: () => context.push(AppRouter.seasonsCreate),
          ),
          const SizedBox(height: 12),
          _LargeActionButton(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App settings and data management',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

/// Stat card showing a metric.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large action button with icon and description.
class _LargeActionButton extends StatelessWidget {
  const _LargeActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
