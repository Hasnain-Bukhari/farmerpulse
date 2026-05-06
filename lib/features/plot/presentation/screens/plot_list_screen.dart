import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/plot_providers.dart';
import '../widgets/plot_card.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';

/// Screen displaying a list of plots for a specific season.
class PlotListScreen extends ConsumerWidget {
  final String seasonId;

  const PlotListScreen({
    super.key,
    required this.seasonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plots = ref.watch(plotsBySeasonProvider(seasonId));
    // Convert to AsyncValue for compatibility with existing UI
    final plotsAsync = AsyncValue.data(plots);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plots'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/seasons/$seasonId/plots/add'),
            tooltip: 'Add Plot',
          ),
        ],
      ),
      body: plotsAsync.when(
        data: (plots) {
          if (plots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.landscape_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No plots yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your first plot to start tracking activities',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/seasons/$seasonId/plots/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Plot'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plots.length,
            itemBuilder: (context, index) {
              final plot = plots[index];
              return PlotCard(
                plot: plot,
                onTap: () => context.push('/plots/${plot.id}/activities'),
                onEdit: () => context.push('/seasons/$seasonId/plots/${plot.id}/edit'),
                onDelete: () async {
                  final confirmed = await _showDeleteConfirmation(context, plot.name);
                  if (confirmed && context.mounted) {
                    await ref.read(deletePlotUseCaseProvider).call(plot.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Plot "${plot.name}" deleted'),
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
          message: 'Error loading plots: $error',
          onRetry: () => ref.invalidate(plotsBySeasonProvider(seasonId)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/seasons/$seasonId/plots/add'),
        tooltip: 'Add Plot',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String plotName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plot'),
        content: Text('Are you sure you want to delete "$plotName"?'),
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