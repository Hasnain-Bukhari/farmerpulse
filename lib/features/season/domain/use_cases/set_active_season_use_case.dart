import '../entities/season.dart';
import '../../data/repositories/season_repository.dart';

/// Use case for setting a season as active.
///
/// Ensures only one season is active at a time.
class SetActiveSeasonUseCase {
  final SeasonRepository _repository;

  SetActiveSeasonUseCase(this._repository);

  /// Execute the use case.
  ///
  /// Deactivates all other seasons and activates the specified one.
  Future<void> call(String seasonId) async {
    // Validate: Season must exist
    final season = _repository.getSeasonById(seasonId);
    if (season == null) {
      throw ArgumentError('Season not found');
    }

    // Deactivate all seasons
    final allSeasons = _repository.getAllSeasons();
    for (final s in allSeasons) {
      if (s.isActive) {
        await _repository.updateSeason(s.copyWith(isActive: false));
      }
    }

    // Activate the selected season
    await _repository.updateSeason(season.copyWith(isActive: true));
  }
}
