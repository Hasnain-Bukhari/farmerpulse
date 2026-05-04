import '../../data/repositories/season_repository.dart';

/// Use case for deleting a season.
///
/// Can include validation for cascade deletes or constraints.
class DeleteSeasonUseCase {
  final SeasonRepository _repository;

  DeleteSeasonUseCase(this._repository);

  /// Execute the use case.
  ///
  /// Throws [ArgumentError] if validation fails.
  Future<void> call(String seasonId) async {
    // Validate: Season must exist
    final season = _repository.getSeasonById(seasonId);
    if (season == null) {
      throw ArgumentError('Season not found');
    }

    // TODO: Add validation to check if season has associated plots
    // If plots exist, either prevent deletion or implement cascade delete

    await _repository.deleteSeason(seasonId);
  }
}
