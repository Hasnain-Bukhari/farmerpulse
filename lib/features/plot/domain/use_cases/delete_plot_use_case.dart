import '../../data/repositories/plot_repository.dart';

/// Use case for deleting a plot.
class DeletePlotUseCase {
  final PlotRepository _repository;

  DeletePlotUseCase(this._repository);

  /// Execute the use case.
  Future<void> call(String plotId) async {
    // Validate: Plot must exist
    final plot = _repository.getPlotById(plotId);
    if (plot == null) {
      throw ArgumentError('Plot not found');
    }

    // TODO: Add validation to check if plot has associated activities
    // If activities exist, either prevent deletion or implement cascade delete

    await _repository.deletePlot(plotId);
  }
}
