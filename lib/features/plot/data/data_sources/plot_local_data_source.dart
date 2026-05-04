import 'package:hive_flutter/hive_flutter.dart';
import '../models/plot_model.dart';

/// Local data source for Plot CRUD operations.
class PlotLocalDataSource {
  static const String boxName = 'plots';

  Box<PlotModel> get _box => Hive.box<PlotModel>(boxName);

  /// Create a new plot.
  Future<void> createPlot(PlotModel plot) async {
    await _box.put(plot.id, plot);
  }

  /// Get all plots.
  List<PlotModel> getAllPlots() {
    return _box.values.toList();
  }

  /// Get plots by season ID.
  List<PlotModel> getPlotsBySeasonId(String seasonId) {
    return _box.values.where((plot) => plot.seasonId == seasonId).toList();
  }

  /// Get a specific plot by ID.
  PlotModel? getPlotById(String id) {
    return _box.get(id);
  }

  /// Update an existing plot.
  Future<void> updatePlot(PlotModel plot) async {
    await _box.put(plot.id, plot);
  }

  /// Delete a plot by ID.
  Future<void> deletePlot(String id) async {
    await _box.delete(id);
  }

  /// Watch for changes to plots.
  Stream<List<PlotModel>> watchPlots() {
    return _box.watch().map((_) => getAllPlots());
  }

  /// Watch plots for a specific season.
  Stream<List<PlotModel>> watchPlotsBySeasonId(String seasonId) {
    return _box.watch().map((_) => getPlotsBySeasonId(seasonId));
  }

  /// Check if a plot name exists within a season.
  bool plotNameExistsInSeason(String name, String seasonId) {
    return _box.values.any(
      (plot) =>
          plot.seasonId == seasonId &&
          plot.name.toLowerCase() == name.toLowerCase(),
    );
  }

  /// Clear all plots.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
