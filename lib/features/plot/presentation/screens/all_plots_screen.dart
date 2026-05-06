import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../domain/entities/plot.dart';
import '../providers/plot_providers.dart';
import '../widgets/plot_card.dart';
import '../../domain/entities/plot.dart';
import '../../../season/presentation/providers/season_providers.dart';

/// Screen showing all plots across all seasons.
class AllPlotsScreen extends ConsumerStatefulWidget {
  const AllPlotsScreen({super.key});

  @override
  ConsumerState<AllPlotsScreen> createState() => _AllPlotsScreenState();
}

class _AllPlotsScreenState extends ConsumerState<AllPlotsScreen> {
  String? selectedSeasonFilter;

  @override
  Widget build(BuildContext context) {
    final plotsAsync = ref.watch(plotsStreamProvider);
    final plotsFallback = ref.watch(plotsListProvider);
    final seasons = ref.watch(seasonsListProvider);

    // Debug: Add logging to understand the loading issue
    debugPrint('All Plots screen build - AsyncValue state: ${plotsAsync.runtimeType}');
    debugPrint('Fallback plots: ${plotsFallback.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Plots'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by Season',
            onSelected: (seasonId) {
              setState(() {
                selectedSeasonFilter = seasonId == 'all' ? null : seasonId;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'all',
                child: Text('All Seasons'),
              ),
              ...seasons.map((season) => PopupMenuItem<String>(
                value: season.id,
                child: Text(season.name),
              )),
            ],
          ),
        ],
      ),
      body: plotsAsync.when(
        data: (plots) => _buildPlotsList(context, plots, seasons),
        loading: () {
          // Use fallback data if available while loading
          if (plotsFallback.isNotEmpty) {
            return _buildPlotsList(context, plotsFallback, seasons);
          }
          return const Center(child: AppLoadingIndicator());
        },
        error: (error, stack) {
          debugPrint('Plots loading error: $error');
          // Use fallback data if available on error
          if (plotsFallback.isNotEmpty) {
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
                  child: _buildPlotsList(context, plotsFallback, seasons),
                ),
              ],
            );
          }
          return AppErrorWidget(
            message: 'Failed to load plots: $error',
            onRetry: () => ref.refresh(plotsStreamProvider),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to seasons to add a plot (requires selecting a season first)
          context.push(AppRouter.seasons);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlotsList(BuildContext context, List<Plot> plots, List<dynamic> seasons) {
    // Apply season filter if selected
    var filteredPlots = plots;
    if (selectedSeasonFilter != null) {
      filteredPlots = plots.where((plot) => plot.seasonId == selectedSeasonFilter).toList();
    }

    if (filteredPlots.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group plots by season for better organization
    final plotsBySeasonMap = <String, List<Plot>>{};
    for (final plot in filteredPlots) {
      plotsBySeasonMap.putIfAbsent(plot.seasonId, () => []).add(plot);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plotsBySeasonMap.keys.length,
      itemBuilder: (context, index) {
        final seasonId = plotsBySeasonMap.keys.elementAt(index);
        final seasonPlots = plotsBySeasonMap[seasonId]!;
        // Find season safely with null handling
        dynamic season;
        try {
          season = seasons.firstWhere((s) => s.id == seasonId);
        } catch (e) {
          // If season not found, use first available season or null
          season = seasons.isNotEmpty ? seasons.first : null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season header
            if (selectedSeasonFilter == null && season != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        season.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (season.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // Plots for this season
            ...seasonPlots.map((plot) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlotCard(
                    plot: plot,
                    onTap: () {
                      context.push('/plots/${plot.id}/activities');
                    },
                    onEdit: () {
                      context.push(AppRouter.plotEdit(plot.seasonId, plot.id));
                    },
                    onStatusChange: () => _changePlotStatus(context, ref, plot),
                  ),
                )),
            
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
              Icons.map_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              selectedSeasonFilter != null ? 'No plots in selected season' : 'No plots yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedSeasonFilter != null 
                  ? 'Try selecting a different season or add plots to this season'
                  : 'Create a season and add some plots to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRouter.seasons),
              icon: const Icon(Icons.add),
              label: Text(selectedSeasonFilter != null ? 'Manage Seasons' : 'Create Season'),
            ),
          ],
        ),
      ),
    );
  }

  /// Change plot status with confirmation
  Future<void> _changePlotStatus(BuildContext context, WidgetRef ref, Plot plot) async {
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