import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminder_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';

/// Screen for creating or editing reminders.
class ReminderFormScreen extends ConsumerStatefulWidget {
  final String? reminderId;
  final String? plotId;
  final String? activityId;

  const ReminderFormScreen({
    super.key,
    this.reminderId,
    this.plotId,
    this.activityId,
  });

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay.now();
  ReminderType _selectedType = ReminderType.custom;
  bool _isRepeating = false;
  CustomRepeatInterval _repeatInterval = CustomRepeatInterval.daily;
  bool _isLoading = false;

  bool get _isEditing => widget.reminderId != null;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  void _loadReminder() {
    if (_isEditing) {
      final reminder = ref.read(reminderByIdProvider(widget.reminderId!));
      if (reminder != null) {
        _titleController.text = reminder.title;
        _descriptionController.text = reminder.description;
        _scheduledDate = reminder.scheduledTime;
        _scheduledTime = TimeOfDay.fromDateTime(reminder.scheduledTime);
        _selectedType = reminder.type;
        _isRepeating = reminder.isRepeating;
        if (reminder.repeatIntervalDays != null) {
          _repeatInterval = CustomRepeatInterval.values.firstWhere(
            (interval) => interval.days == reminder.repeatIntervalDays,
            orElse: () => CustomRepeatInterval.daily,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reminder' : 'Create Reminder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveReminder,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter reminder title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Type
            DropdownButtonFormField<ReminderType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: ReminderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getTypeIcon(type), size: 20),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_scheduledDate)),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 12),

            // Time
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(_scheduledTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),

            // Repeat toggle
            SwitchListTile(
              title: const Text('Repeat'),
              subtitle: Text(_isRepeating ? 'This reminder will repeat' : 'One-time reminder'),
              value: _isRepeating,
              onChanged: (value) {
                setState(() {
                  _isRepeating = value;
                });
              },
            ),

            // Repeat interval (if repeating)
            if (_isRepeating) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<CustomRepeatInterval>(
                value: _repeatInterval,
                decoration: const InputDecoration(
                  labelText: 'Repeat Every',
                  border: OutlineInputBorder(),
                ),
                items: CustomRepeatInterval.values.map((interval) {
                  return DropdownMenuItem(
                    value: interval,
                    child: Text(interval.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _repeatInterval = value;
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notification Info',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getNotificationInfo(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getNotificationInfo() {
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    final formattedDateTime = DateFormat('MMM d, yyyy \'at\' h:mm a').format(scheduledDateTime);

    if (_isRepeating) {
      return 'You will receive notifications starting $formattedDateTime and then ${_repeatInterval.label.toLowerCase()}.';
    } else {
      return 'You will receive a notification on $formattedDateTime.';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );

    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final scheduledDateTime = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      final reminder = Reminder(
        id: widget.reminderId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledTime: scheduledDateTime,
        isRepeating: _isRepeating,
        repeatIntervalDays: _isRepeating ? _repeatInterval.days : null,
        isActive: true,
        linkedActivityId: widget.activityId,
        linkedPlotId: widget.plotId,
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(updateReminderUseCaseProvider).call(reminder);
      } else {
        await ref.read(createReminderUseCaseProvider).call(reminder);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Reminder updated!' : 'Reminder created!'),
          ),
        );
        context.pop();
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}