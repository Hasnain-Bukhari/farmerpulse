import '../../domain/entities/plot.dart';
import '../data_sources/plot_local_data_source.dart';
import '../models/plot_model.dart';

/// Repository for Plot data operations.
class PlotRepository {
  final PlotLocalDataSource _dataSource;

  PlotRepository(this._dataSource);

  /// Create a new plot.
  Future<void> createPlot(Plot plot) async {
    final model = PlotModel.fromEntity(plot);
    await _dataSource.createPlot(model);
  }

  /// Get all plots.
  List<Plot> getAllPlots() {
    return _dataSource.getAllPlots().map((model) => model.toEntity()).toList();
  }

  /// Get plots by season ID.
  List<Plot> getPlotsBySeasonId(String seasonId) {
    return _dataSource
        .getPlotsBySeasonId(seasonId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get a specific plot by ID.
  Plot? getPlotById(String id) {
    final model = _dataSource.getPlotById(id);
    return model?.toEntity();
  }

  /// Update an existing plot.
  Future<void> updatePlot(Plot plot) async {
    final model = PlotModel.fromEntity(plot);
    await _dataSource.updatePlot(model);
  }

  /// Delete a plot by ID.
  Future<void> deletePlot(String id) async {
    await _dataSource.deletePlot(id);
  }

  /// Watch for changes to all plots.
  Stream<List<Plot>> watchPlots() {
    return _dataSource.watchPlots().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  /// Watch plots for a specific season.
  Stream<List<Plot>> watchPlotsBySeasonId(String seasonId) {
    return _dataSource.watchPlotsBySeasonId(seasonId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  /// Check if a plot name exists within a season.
  bool plotNameExistsInSeason(String name, String seasonId) {
    return _dataSource.plotNameExistsInSeason(name, seasonId);
  }
}
