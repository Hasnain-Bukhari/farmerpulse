import 'package:flutter/material.dart';
import '../../domain/entities/activity.dart';
import 'package:intl/intl.dart';

/// Card widget displaying activity information.
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type icon, Title, Status, Delete button
              Row(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(activity.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(activity.type),
                      color: _getTypeColor(activity.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activity.type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getTypeColor(activity.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(activity.status, theme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.status.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  
                  // Delete button
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: theme.colorScheme.error,
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Date and Time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(activity.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeFormat.format(activity.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  if (activity.isToday()) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TODAY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.blue,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Description (if available)
              if (activity.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  activity.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Details row (duration, cost, quantity)
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (activity.durationMinutes != null)
                    _DetailChip(
                      icon: Icons.timer,
                      label: activity.getFormattedDuration()!,
                    ),
                  if (activity.cost != null)
                    _DetailChip(
                      icon: Icons.attach_money,
                      label: '\$${activity.cost!.toStringAsFixed(2)}',
                    ),
                  if (activity.quantity != null)
                    _DetailChip(
                      icon: Icons.inventory_2_outlined,
                      label: '${activity.quantity} ${activity.unit ?? ""}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.landPreparation:
        return Icons.agriculture;
      case ActivityType.seeding:
        return Icons.spa;
      case ActivityType.watering:
        return Icons.water_drop;
      case ActivityType.spray:
        return Icons.spray;
      case ActivityType.harvest:
        return Icons.grass;
      case ActivityType.fertilizer:
        return Icons.eco;
      case ActivityType.cleaning:
        return Icons.cleaning_services;
    }
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.landPreparation:
        return Colors.brown;
      case ActivityType.seeding:
        return Colors.green;
      case ActivityType.watering:
        return Colors.blue;
      case ActivityType.spray:
        return Colors.purple;
      case ActivityType.harvest:
        return Colors.orange;
      case ActivityType.fertilizer:
        return Colors.teal;
      case ActivityType.cleaning:
        return Colors.indigo;
    }
  }

  Color _getStatusColor(ActivityStatus status, ThemeData theme) {
    switch (status) {
      case ActivityStatus.planned:
        return Colors.blue;
      case ActivityStatus.completed:
        return Colors.green;
      case ActivityStatus.cancelled:
        return Colors.grey;
    }
  }
}

/// Small detail chip used in activity card.
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
