import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/season.dart';
import '../providers/season_providers.dart';

/// Screen for creating or editing a season.
class SeasonFormScreen extends ConsumerStatefulWidget {
  final String? seasonId;

  const SeasonFormScreen({super.key, this.seasonId});

  static const routeName = 'season-form';
  static const createRoutePath = '/seasons/create';
  static String editRoutePath(String id) => '/seasons/$id/edit';

  @override
  ConsumerState<SeasonFormScreen> createState() => _SeasonFormScreenState();
}

class _SeasonFormScreenState extends ConsumerState<SeasonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.seasonId != null) {
      _loadExistingSeason();
    }
  }

  void _loadExistingSeason() {
    final season = ref.read(seasonByIdProvider(widget.seasonId!));
    if (season != null) {
      _nameController.text = season.name;
      _cropTypeController.text = season.cropType ?? '';
      _notesController.text = season.notes ?? '';
      _startDate = season.startDate;
      _endDate = season.endDate;
      _isActive = season.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cropTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.seasonId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Season' : 'Create Season'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Season Name *',
                hintText: 'e.g., Winter 2026',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a season name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cropTypeController,
              decoration: const InputDecoration(
                labelText: 'Main Crop (Optional)',
                hintText: 'e.g., Wheat, Rice, Corn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Start Date *',
              selectedDate: _startDate,
              onTap: () => _selectDate(context, isStartDate: true),
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'End Date *',
              selectedDate: _endDate,
              onTap: () => _selectDate(context, isStartDate: false),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set as Active Season'),
              subtitle: const Text('Only one season can be active at a time'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional information',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _saveSeason,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Season' : 'Create Season'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate == null
              ? 'Select date'
              : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(pickedDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _saveSeason() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final season = Season(
        id: widget.seasonId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        isActive: _isActive,
        cropType: _cropTypeController.text.trim().isEmpty
            ? null
            : _cropTypeController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.seasonId != null) {
        await ref.read(updateSeasonUseCaseProvider).call(season);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Season updated successfully')),
          );
        }
      } else {
        await ref.read(createSeasonUseCaseProvider).call(season);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Season created successfully')),
          );
        }
      }

      if (mounted) {
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
