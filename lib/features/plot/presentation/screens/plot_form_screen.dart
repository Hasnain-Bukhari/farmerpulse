import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/plot.dart';
import '../providers/plot_providers.dart';

/// Screen for creating or editing a plot.
class PlotFormScreen extends ConsumerStatefulWidget {
  final String seasonId;
  final String? plotId;

  const PlotFormScreen({
    super.key,
    required this.seasonId,
    this.plotId,
  });

  @override
  ConsumerState<PlotFormScreen> createState() => _PlotFormScreenState();
}

class _PlotFormScreenState extends ConsumerState<PlotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _notesController = TextEditingController();

  String _areaUnit = 'acres';
  PlotStatus _status = PlotStatus.active;
  bool _isLoading = false;

  final List<String> _areaUnits = ['acres', 'hectares', 'sq meters', 'sq feet'];

  @override
  void initState() {
    super.initState();
    if (widget.plotId != null) {
      _loadExistingPlot();
    }
  }

  void _loadExistingPlot() {
    final plot = ref.read(plotByIdProvider(widget.plotId!));
    if (plot != null) {
      _nameController.text = plot.name;
      _locationController.text = plot.location ?? '';
      _areaController.text = plot.area.toString();
      _areaUnit = plot.areaUnit;
      _soilTypeController.text = plot.soilType ?? '';
      _notesController.text = plot.notes ?? '';
      _status = plot.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _soilTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plotId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Plot' : 'Add Plot'),
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
            // Plot Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plot Name *',
                hintText: 'e.g., Plot A1, North Field',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a plot name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _areaController,
                    decoration: const InputDecoration(
                      labelText: 'Area *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.square_foot),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final area = double.tryParse(value);
                      if (area == null || area <= 0) {
                        return 'Invalid area';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _areaUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: _areaUnits.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _areaUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g., North section, GPS coordinates',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Soil Type
            TextFormField(
              controller: _soilTypeController,
              decoration: const InputDecoration(
                labelText: 'Soil Type (Optional)',
                hintText: 'e.g., Loamy clay, Sandy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.terrain),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<PlotStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items: PlotStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional information',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Save Button
            FilledButton.icon(
              onPressed: _isLoading ? null : _savePlot,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(isEditing ? 'Update Plot' : 'Add Plot'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePlot() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final plot = Plot(
        id: widget.plotId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        seasonId: widget.seasonId,
        name: _nameController.text.trim(),
        area: double.parse(_areaController.text.trim()),
        areaUnit: _areaUnit,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        soilType: _soilTypeController.text.trim().isEmpty
            ? null
            : _soilTypeController.text.trim(),
        status: _status,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (widget.plotId != null) {
        await ref.read(updatePlotUseCaseProvider).call(plot);
      } else {
        await ref.read(createPlotUseCaseProvider).call(plot);
      }

      // Refresh the plots data
      ref.invalidate(plotsBySeasonProvider(widget.seasonId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                content: Text(widget.plotId != null ? 'Plot updated!' : 'Plot added!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
