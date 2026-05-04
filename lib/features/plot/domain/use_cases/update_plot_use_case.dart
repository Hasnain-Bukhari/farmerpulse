import '../entities/plot.dart';
import '../../data/repositories/plot_repository.dart';

/// Use case for updating an existing plot.
class UpdatePlotUseCase {
  final PlotRepository _repository;

  UpdatePlotUseCase(this._repository);

  /// Execute the use case.
  Future<void> call(Plot plot) async {
    // Validate: Plot must exist
    final existing = _repository.getPlotById(plot.id);
    if (existing == null) {
      throw ArgumentError('Plot not found');
    }

    // Validate: Area must be greater than 0
    if (plot.area <= 0) {
      throw ArgumentError('Plot area must be greater than 0');
    }

    // Validate: If name changed, check uniqueness
    if (existing.name != plot.name) {
      if (_repository.plotNameExistsInSeason(plot.name, plot.seasonId)) {
        throw ArgumentError('A plot with this name already exists in this season');
      }
    }

    await _repository.updatePlot(plot);
  }
}
