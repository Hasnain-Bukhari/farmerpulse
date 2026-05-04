import '../../domain/entities/season.dart';
import '../data_sources/season_local_data_source.dart';
import '../models/season_model.dart';

/// Repository for Season data operations.
///
/// Abstracts data access and handles mapping between
/// domain entities and data models.
class SeasonRepository {
  final SeasonLocalDataSource _dataSource;

  SeasonRepository(this._dataSource);

  /// Create a new season.
  Future<void> createSeason(Season season) async {
    final model = SeasonModel.fromEntity(season);
    await _dataSource.createSeason(model);
  }

  /// Get all seasons.
  List<Season> getAllSeasons() {
    return _dataSource.getAllSeasons().map((model) => model.toEntity()).toList();
  }

  /// Get a specific season by ID.
  Season? getSeasonById(String id) {
    final model = _dataSource.getSeasonById(id);
    return model?.toEntity();
  }

  /// Get the currently active season.
  Season? getActiveSeason() {
    try {
      final model = _dataSource.getActiveSeason();
      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  /// Update an existing season.
  Future<void> updateSeason(Season season) async {
    final model = SeasonModel.fromEntity(season);
    await _dataSource.updateSeason(model);
  }

  /// Delete a season by ID.
  Future<void> deleteSeason(String id) async {
    await _dataSource.deleteSeason(id);
  }

  /// Watch for changes to all seasons.
  Stream<List<Season>> watchSeasons() {
    return _dataSource.watchSeasons().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  /// Check if a season name already exists.
  bool seasonNameExists(String name) {
    return _dataSource.seasonNameExists(name);
  }

  /// Get seasons within a date range.
  List<Season> getSeasonsByDateRange(DateTime start, DateTime end) {
    return _dataSource
        .getSeasonsByDateRange(start, end)
        .map((model) => model.toEntity())
        .toList();
  }
}
