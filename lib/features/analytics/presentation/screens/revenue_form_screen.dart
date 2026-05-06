import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_providers.dart';
import '../../domain/entities/revenue.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../../plot/presentation/providers/plot_providers.dart';
import '../../../plot/domain/entities/plot.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';

/// Screen for adding or editing revenue records.
class RevenueFormScreen extends ConsumerStatefulWidget {
  final String? revenueId;
  final String? seasonId;
  final String? plotId;

  const RevenueFormScreen({
    super.key,
    this.revenueId,
    this.seasonId,
    this.plotId,
  });

  @override
  ConsumerState<RevenueFormScreen> createState() => _RevenueFormScreenState();
}

class _RevenueFormScreenState extends ConsumerState<RevenueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _recordedDate = DateTime.now();
  RevenueType _selectedType = RevenueType.harvest;
  String? _selectedSeasonId;
  String? _selectedPlotId;
  bool _isLoading = false;

  bool get _isEditing => widget.revenueId != null;

  @override
  void initState() {
    super.initState();
    _selectedSeasonId = widget.seasonId;
    _selectedPlotId = widget.plotId;
    _loadRevenue();
    
    // Add a post frame callback to validate the season ID after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seasons = ref.read(seasonsListProvider);
      if (_selectedSeasonId != null && seasons.isNotEmpty && !seasons.any((s) => s.id == _selectedSeasonId)) {
        setState(() {
          _selectedSeasonId = seasons.first.id;
          _selectedPlotId = null; // Reset plot selection
        });
      }
    });
  }

  void _loadRevenue() {
    if (_isEditing) {
      final revenue = ref.read(revenueByIdProvider(widget.revenueId!));
      if (revenue != null) {
        _descriptionController.text = revenue.description;
        _amountController.text = revenue.amount.toString();
        _notesController.text = revenue.notes ?? '';
        _recordedDate = revenue.recordedDate;
        _selectedType = revenue.type;
        _selectedSeasonId = revenue.seasonId;
        _selectedPlotId = revenue.plotId;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seasons = ref.watch(seasonsListProvider);
    
    // Ensure _selectedSeasonId is valid - if it's not in the list, reset it
    if (_selectedSeasonId != null && !seasons.any((s) => s.id == _selectedSeasonId)) {
      _selectedSeasonId = seasons.isNotEmpty ? seasons.first.id : null;
    }
    
    final plots = _selectedSeasonId != null
        ? ref.watch(plotsBySeasonProvider(_selectedSeasonId!))
            : <Plot>[];
            
    // Ensure _selectedPlotId is valid - if it's not in the list, reset it
    if (_selectedPlotId != null && !plots.any((p) => p.id == _selectedPlotId)) {
      _selectedPlotId = null; // Reset to season-wide
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Revenue' : 'Add Revenue'),
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
              onPressed: _saveRevenue,
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (seasons.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Seasons Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please create a season first before adding revenue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'e.g., Wheat harvest sales',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                hintText: '0.00',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final amount = double.tryParse(value.trim());
                if (amount == null || amount <= 0) {
                  return 'Enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Revenue Type
            DropdownButtonFormField<RevenueType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Revenue Type',
                border: OutlineInputBorder(),
              ),
              items: RevenueType.values.map((type) {
                return DropdownMenuItem(
                  key: ValueKey(type),
                  value: type,
                  child: Text(type.label),
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

            // Season Selection
            DropdownButtonFormField<String?>(
              value: _selectedSeasonId,
              decoration: const InputDecoration(
                labelText: 'Season *',
                border: OutlineInputBorder(),
              ),
              items: seasons.isEmpty ? [] : seasons.map((season) {
                return DropdownMenuItem<String?>(
                  key: ValueKey(season.id),
                  value: season.id,
                  child: Text(season.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeasonId = value;
                  _selectedPlotId = null; // Reset plot selection
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a season';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Plot Selection (Optional)
            DropdownButtonFormField<String?>(
              value: _selectedPlotId,
              decoration: const InputDecoration(
                labelText: 'Plot (Optional)',
                hintText: 'Select specific plot or leave empty for season-wide',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  key: ValueKey('season-wide'),
                  value: null,
                  child: Text('Season-wide revenue'),
                ),
                ...plots.map((plot) {
                  return DropdownMenuItem<String?>(
                    key: ValueKey(plot.id),
                    value: plot.id,
                    child: Text(plot.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPlotId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_recordedDate)),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Additional details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Type Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedType.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedType.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            ], // Close the else block
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _recordedDate = picked;
      });
    }
  }

  Future<void> _saveRevenue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final revenue = Revenue(
        id: widget.revenueId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        seasonId: _selectedSeasonId!,
        plotId: _selectedPlotId,
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        description: _descriptionController.text.trim(),
        recordedDate: _recordedDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: DateTime.now(),
        updatedAt: _isEditing ? DateTime.now() : null,
      );

      if (_isEditing) {
        await ref.read(updateRevenueUseCaseProvider).call(revenue);
      } else {
        await ref.read(createRevenueUseCaseProvider).call(revenue);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Revenue updated!' : 'Revenue added!'),
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