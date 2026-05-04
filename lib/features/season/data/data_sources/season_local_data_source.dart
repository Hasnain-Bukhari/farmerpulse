import 'package:hive_flutter/hive_flutter.dart';
import '../models/season_model.dart';

/// Local data source for Season CRUD operations.
///
/// Handles direct interaction with Hive box for seasons.
/// This is the lowest level of data access.
class SeasonLocalDataSource {
  static const String boxName = 'seasons';

  Box<SeasonModel> get _box => Hive.box<SeasonModel>(boxName);

  /// Create a new season.
  Future<void> createSeason(SeasonModel season) async {
    await _box.put(season.id, season);
  }

  /// Get all seasons from the database.
  List<SeasonModel> getAllSeasons() {
    return _box.values.toList();
  }

  /// Get a specific season by ID.
  SeasonModel? getSeasonById(String id) {
    return _box.get(id);
  }

  /// Get the currently active season.
  SeasonModel? getActiveSeason() {
    return _box.values.firstWhere(
      (season) => season.isActive,
      orElse: () => throw StateError('No active season found'),
    );
  }

  /// Update an existing season.
  Future<void> updateSeason(SeasonModel season) async {
    await _box.put(season.id, season);
  }

  /// Delete a season by ID.
  Future<void> deleteSeason(String id) async {
    await _box.delete(id);
  }

  /// Watch for changes to all seasons.
  Stream<List<SeasonModel>> watchSeasons() {
    return _box.watch().map((_) => getAllSeasons());
  }

  /// Check if a season with the given name exists.
  bool seasonNameExists(String name) {
    return _box.values.any(
      (season) => season.name.toLowerCase() == name.toLowerCase(),
    );
  }

  /// Get seasons within a date range.
  List<SeasonModel> getSeasonsByDateRange(DateTime start, DateTime end) {
    return _box.values.where((season) {
      return season.startDate.isBefore(end) && season.endDate.isAfter(start);
    }).toList();
  }

  /// Clear all seasons (use with caution).
  Future<void> clearAll() async {
    await _box.clear();
  }
}
