import '../entities/season.dart';
import '../../data/repositories/season_repository.dart';

/// Use case for updating an existing season.
///
/// Validates business rules before persisting the changes.
class UpdateSeasonUseCase {
  final SeasonRepository _repository;

  UpdateSeasonUseCase(this._repository);

  /// Execute the use case.
  ///
  /// Throws [ArgumentError] if validation fails.
  Future<void> call(Season season) async {
    // Validate: Season must exist
    final existing = _repository.getSeasonById(season.id);
    if (existing == null) {
      throw ArgumentError('Season not found');
    }

    // Validate: End date must be after start date
    if (season.endDate.isBefore(season.startDate) ||
        season.endDate.isAtSameMomentAs(season.startDate)) {
      throw ArgumentError('End date must be after start date');
    }

    // Validate: Minimum duration of 1 day
    if (season.getDurationInDays() < 1) {
      throw ArgumentError('Season must be at least 1 day long');
    }

    // Validate: Check for overlapping active seasons
    if (season.isActive) {
      final allSeasons = _repository.getAllSeasons();
      final hasOverlap = allSeasons.any(
        (other) =>
            other.isActive &&
            other.id != season.id &&
            _isOverlapping(season, other),
      );

      if (hasOverlap) {
        throw ArgumentError('Season overlaps with an existing active season');
      }
    }

    await _repository.updateSeason(season);
  }

  /// Check if two seasons overlap in dates.
  bool _isOverlapping(Season s1, Season s2) {
    return s1.startDate.isBefore(s2.endDate) &&
        s2.startDate.isBefore(s1.endDate);
  }
}
