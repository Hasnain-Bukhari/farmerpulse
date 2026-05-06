import 'package:flutter/material.dart';
import '../../domain/entities/plot.dart';

/// Card widget displaying plot information.
class PlotCard extends StatelessWidget {
  final Plot plot;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusChange;

  const PlotCard({
    super.key,
    required this.plot,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
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
              // Header: Name and Status Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plot.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(plot.status, theme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plot.status.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Area
              Row(
                children: [
                  Icon(
                    Icons.square_foot,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${plot.area} ${plot.areaUnit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Location (if available)
              if (plot.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plot.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Soil Type (if available)
              if (plot.soilType != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.terrain,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      plot.soilType!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Action buttons (if provided)
              if (onEdit != null || onDelete != null || onStatusChange != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status change button
                    if (onStatusChange != null)
                      OutlinedButton.icon(
                        onPressed: onStatusChange,
                        icon: Icon(_getStatusIcon(plot.status), size: 16),
                        label: Text(_getNextStatusAction(plot.status)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _getStatusColor(plot.status, theme),
                          side: BorderSide(color: _getStatusColor(plot.status, theme)),
                        ),
                      ),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: Colors.red,
                            onPressed: onDelete,
                            tooltip: 'Delete',
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PlotStatus status, ThemeData theme) {
    switch (status) {
      case PlotStatus.active:
        return Colors.green;
      case PlotStatus.fallow:
        return Colors.orange;
      case PlotStatus.retired:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PlotStatus status) {
    switch (status) {
      case PlotStatus.active:
        return Icons.pause_circle_outline;
      case PlotStatus.fallow:
        return Icons.play_circle_outline;
      case PlotStatus.retired:
        return Icons.refresh;
    }
  }

  String _getNextStatusAction(PlotStatus status) {
    switch (status) {
      case PlotStatus.active:
        return 'Set Fallow';
      case PlotStatus.fallow:
        return 'Reactivate';
      case PlotStatus.retired:
        return 'Reactivate';
    }
  }

  /// Add a more comprehensive status menu option
  void showStatusMenu(BuildContext context, VoidCallback? onStatusChange) {
    if (onStatusChange == null) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Plot Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Colors.green),
              title: const Text('Set Active'),
              subtitle: const Text('Plot is ready for new activities'),
              onTap: () {
                Navigator.pop(context);
                onStatusChange();
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle, color: Colors.orange),
              title: const Text('Set Fallow'),
              subtitle: const Text('Plot is resting between seasons'),
              onTap: () {
                Navigator.pop(context);
                onStatusChange();
              },
            ),
            ListTile(
              leading: const Icon(Icons.stop_circle, color: Colors.grey),
              title: const Text('Retire Plot'),
              subtitle: const Text('Plot is no longer in use'),
              onTap: () {
                Navigator.pop(context);
                onStatusChange();
              },
            ),
          ],
        ),
      ),
    );
  }
}
