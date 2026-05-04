import '../entities/season.dart';
import '../../data/repositories/season_repository.dart';

/// Use case for creating a new season.
///
/// Validates business rules before persisting the season.
class CreateSeasonUseCase {
  final SeasonRepository _repository;

  CreateSeasonUseCase(this._repository);

  /// Execute the use case.
  ///
  /// Throws [ArgumentError] if validation fails.
  Future<void> call(Season season) async {
    // Validate: End date must be after start date
    if (season.endDate.isBefore(season.startDate) ||
        season.endDate.isAtSameMomentAs(season.startDate)) {
      throw ArgumentError('End date must be after start date');
    }

    // Validate: Minimum duration of 1 day
    if (season.getDurationInDays() < 1) {
      throw ArgumentError('Season must be at least 1 day long');
    }

    // Validate: Season name must be unique
    if (_repository.seasonNameExists(season.name)) {
      throw ArgumentError('A season with this name already exists');
    }

    // Validate: Check for overlapping active seasons
    if (season.isActive) {
      final existingSeasons = _repository.getAllSeasons();
      final hasOverlap = existingSeasons.any(
        (existing) =>
            existing.isActive &&
            existing.id != season.id &&
            _isOverlapping(season, existing),
      );

      if (hasOverlap) {
        throw ArgumentError('Season overlaps with an existing active season');
      }
    }

    await _repository.createSeason(season);
  }

  /// Check if two seasons overlap in dates.
  bool _isOverlapping(Season s1, Season s2) {
    return s1.startDate.isBefore(s2.endDate) &&
        s2.startDate.isBefore(s1.endDate);
  }
}
