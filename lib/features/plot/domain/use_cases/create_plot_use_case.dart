import '../entities/plot.dart';
import '../../data/repositories/plot_repository.dart';

/// Use case for creating a new plot.
class CreatePlotUseCase {
  final PlotRepository _repository;

  CreatePlotUseCase(this._repository);

  /// Execute the use case.
  Future<void> call(Plot plot) async {
    // Validate: Area must be greater than 0
    if (plot.area <= 0) {
      throw ArgumentError('Plot area must be greater than 0');
    }

    // Validate: Plot name must be unique within the season
    if (_repository.plotNameExistsInSeason(plot.name, plot.seasonId)) {
      throw ArgumentError('A plot with this name already exists in this season');
    }

    await _repository.createPlot(plot);
  }
}
