import 'package:hive_flutter/hive_flutter.dart';
import '../models/revenue_model.dart';

/// Local data source for Revenue operations using Hive.
class RevenueLocalDataSource {
  static const String _boxName = 'revenues';
  
  Box<RevenueModel> get _box => Hive.box<RevenueModel>(_boxName);

  /// Create a new revenue record.
  Future<void> createRevenue(RevenueModel revenue) async {
    await _box.put(revenue.id, revenue);
  }

  /// Get all revenue records.
  List<RevenueModel> getAllRevenues() {
    return _box.values.toList();
  }

  /// Get revenue by ID.
  RevenueModel? getRevenueById(String id) {
    return _box.get(id);
  }

  /// Get revenues by season ID.
  List<RevenueModel> getRevenuesBySeasonId(String seasonId) {
    return _box.values
        .where((revenue) => revenue.seasonId == seasonId)
        .toList();
  }

  /// Get revenues by plot ID.
  List<RevenueModel> getRevenuesByPlotId(String plotId) {
    return _box.values
        .where((revenue) => revenue.plotId == plotId)
        .toList();
  }

  /// Get season-wide revenues (not plot-specific).
  List<RevenueModel> getSeasonWideRevenues(String seasonId) {
    return _box.values
        .where((revenue) => revenue.seasonId == seasonId && revenue.plotId == null)
        .toList();
  }

  /// Get revenues by date range.
  List<RevenueModel> getRevenuesByDateRange(DateTime startDate, DateTime endDate) {
    return _box.values.where((revenue) {
      return revenue.recordedDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             revenue.recordedDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get revenues by type.
  List<RevenueModel> getRevenuesByType(int typeIndex) {
    return _box.values
        .where((revenue) => revenue.typeIndex == typeIndex)
        .toList();
  }

  /// Get total revenue for a season.
  double getTotalSeasonRevenue(String seasonId) {
    return getRevenuesBySeasonId(seasonId)
        .fold(0.0, (sum, revenue) => sum + revenue.amount);
  }

  /// Get total revenue for a plot.
  double getTotalPlotRevenue(String plotId) {
    return getRevenuesByPlotId(plotId)
        .fold(0.0, (sum, revenue) => sum + revenue.amount);
  }

  /// Update a revenue record.
  Future<void> updateRevenue(RevenueModel revenue) async {
    await _box.put(revenue.id, revenue);
  }

  /// Delete a revenue record.
  Future<void> deleteRevenue(String id) async {
    await _box.delete(id);
  }

  /// Delete revenues by season ID.
  Future<void> deleteRevenuesBySeasonId(String seasonId) async {
    final revenues = getRevenuesBySeasonId(seasonId);
    for (final revenue in revenues) {
      await _box.delete(revenue.id);
    }
  }

  /// Delete revenues by plot ID.
  Future<void> deleteRevenuesByPlotId(String plotId) async {
    final revenues = getRevenuesByPlotId(plotId);
    for (final revenue in revenues) {
      await _box.delete(revenue.id);
    }
  }

  /// Watch all revenues stream.
  Stream<List<RevenueModel>> watchRevenues() {
    return _box.watch().map((_) => getAllRevenues());
  }

  /// Watch revenues by season ID stream.
  Stream<List<RevenueModel>> watchRevenuesBySeasonId(String seasonId) {
    return _box.watch().map((_) => getRevenuesBySeasonId(seasonId));
  }

  /// Watch revenues by plot ID stream.
  Stream<List<RevenueModel>> watchRevenuesByPlotId(String plotId) {
    return _box.watch().map((_) => getRevenuesByPlotId(plotId));
  }

  /// Check if revenue exists.
  bool revenueExists(String id) {
    return _box.containsKey(id);
  }

  /// Get revenues count.
  int getRevenuesCount() {
    return _box.length;
  }

  /// Get revenues count for season.
  int getSeasonRevenuesCount(String seasonId) {
    return getRevenuesBySeasonId(seasonId).length;
  }
}