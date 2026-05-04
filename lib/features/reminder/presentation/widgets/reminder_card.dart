import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reminder.dart';

/// Widget displaying a reminder card.
class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getBorderColor(theme, isOverdue, isDueToday),
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Icon(
                      _getTypeIcon(reminder.type),
                      size: 20,
                      color: _getBorderColor(theme, isOverdue, isDueToday),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (reminder.isRepeating)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'REPEAT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),

                // Description
                if (reminder.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    reminder.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Time and status
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(reminder.scheduledTime),
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    _StatusChip(
                      isOverdue: isOverdue,
                      isDueToday: isDueToday,
                      daysUntilDue: reminder.daysUntilDue,
                    ),
                  ],
                ),

                // Repeat info
                if (reminder.isRepeating && reminder.repeatIntervalDays != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRepeatText(reminder.repeatIntervalDays!),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],

                // Actions
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onComplete != null && reminder.isActive)
                        TextButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Complete'),
                        ),
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(ThemeData theme, bool isOverdue, bool isDueToday) {
    if (isOverdue) return theme.colorScheme.error;
    if (isDueToday) return Colors.orange;
    return theme.colorScheme.primary;
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.activity:
        return Icons.event;
      case ReminderType.irrigation:
        return Icons.water_drop;
      case ReminderType.fertilizer:
        return Icons.eco;
      case ReminderType.harvest:
        return Icons.agriculture;
      case ReminderType.planting:
        return Icons.grass;
      case ReminderType.inspection:
        return Icons.visibility;
      case ReminderType.maintenance:
        return Icons.build;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');

    if (reminderDate.isAtSameMomentAs(today)) {
      return 'Today at ${timeFormat.format(dateTime)}';
    } else if (reminderDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow at ${timeFormat.format(dateTime)}';
    } else {
      return '${dateFormat.format(dateTime)} at ${timeFormat.format(dateTime)}';
    }
  }

  String _getRepeatText(int intervalDays) {
    switch (intervalDays) {
      case 1:
        return 'Daily';
      case 2:
        return 'Every 2 days';
      case 3:
        return 'Every 3 days';
      case 7:
        return 'Weekly';
      case 14:
        return 'Every 2 weeks';
      case 30:
        return 'Monthly';
      default:
        return 'Every $intervalDays days';
    }
  }
}

/// Widget showing reminder status chip.
class _StatusChip extends StatelessWidget {
  final bool isOverdue;
  final bool isDueToday;
  final int daysUntilDue;

  const _StatusChip({
    required this.isOverdue,
    required this.isDueToday,
    required this.daysUntilDue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String text;

    if (isOverdue) {
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.onErrorContainer;
      text = 'Overdue';
    } else if (isDueToday) {
      backgroundColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange.shade700;
      text = 'Due Today';
    } else if (daysUntilDue <= 1) {
      backgroundColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange.shade700;
      text = 'Due Tomorrow';
    } else if (daysUntilDue <= 7) {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      text = 'Due in $daysUntilDue days';
    } else {
      backgroundColor = theme.colorScheme.surfaceVariant;
      textColor = theme.colorScheme.onSurfaceVariant;
      text = 'Due in $daysUntilDue days';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}