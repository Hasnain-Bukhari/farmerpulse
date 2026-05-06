import '../../domain/entities/revenue.dart';
import '../data_sources/revenue_local_data_source.dart';
import '../models/revenue_model.dart';

/// Repository for Revenue data operations.
class RevenueRepository {
  final RevenueLocalDataSource _dataSource;

  const RevenueRepository(this._dataSource);

  /// Create a new revenue record.
  Future<void> createRevenue(Revenue revenue) async {
    final model = RevenueModel.fromEntity(revenue);
    await _dataSource.createRevenue(model);
  }

  /// Get all revenue records.
  List<Revenue> getAllRevenues() {
    return _dataSource.getAllRevenues()
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get revenue by ID.
  Revenue? getRevenueById(String id) {
    final model = _dataSource.getRevenueById(id);
    return model?.toEntity();
  }

  /// Get revenues by season ID.
  List<Revenue> getRevenuesBySeasonId(String seasonId) {
    return _dataSource.getRevenuesBySeasonId(seasonId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get revenues by plot ID.
  List<Revenue> getRevenuesByPlotId(String plotId) {
    return _dataSource.getRevenuesByPlotId(plotId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get season-wide revenues (not plot-specific).
  List<Revenue> getSeasonWideRevenues(String seasonId) {
    return _dataSource.getSeasonWideRevenues(seasonId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get revenues by date range.
  List<Revenue> getRevenuesByDateRange(DateTime startDate, DateTime endDate) {
    return _dataSource.getRevenuesByDateRange(startDate, endDate)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get revenues by type.
  List<Revenue> getRevenuesByType(RevenueType type) {
    return _dataSource.getRevenuesByType(type.index)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get total revenue for a season.
  double getTotalSeasonRevenue(String seasonId) {
    return _dataSource.getTotalSeasonRevenue(seasonId);
  }

  /// Get total revenue for a plot.
  double getTotalPlotRevenue(String plotId) {
    return _dataSource.getTotalPlotRevenue(plotId);
  }

  /// Update a revenue record.
  Future<void> updateRevenue(Revenue revenue) async {
    final model = RevenueModel.fromEntity(revenue);
    await _dataSource.updateRevenue(model);
  }

  /// Delete a revenue record.
  Future<void> deleteRevenue(String id) async {
    await _dataSource.deleteRevenue(id);
  }

  /// Delete revenues by season ID.
  Future<void> deleteRevenuesBySeasonId(String seasonId) async {
    await _dataSource.deleteRevenuesBySeasonId(seasonId);
  }

  /// Delete revenues by plot ID.
  Future<void> deleteRevenuesByPlotId(String plotId) async {
    await _dataSource.deleteRevenuesByPlotId(plotId);
  }

  /// Watch all revenues stream.
  Stream<List<Revenue>> watchRevenues() {
    return _dataSource.watchRevenues()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  /// Watch revenues by season ID stream.
  Stream<List<Revenue>> watchRevenuesBySeasonId(String seasonId) {
    return _dataSource.watchRevenuesBySeasonId(seasonId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  /// Watch revenues by plot ID stream.
  Stream<List<Revenue>> watchRevenuesByPlotId(String plotId) {
    return _dataSource.watchRevenuesByPlotId(plotId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  /// Check if revenue exists.
  bool revenueExists(String id) {
    return _dataSource.revenueExists(id);
  }

  /// Get revenues count.
  int getRevenuesCount() {
    return _dataSource.getRevenuesCount();
  }

  /// Get revenues count for season.
  int getSeasonRevenuesCount(String seasonId) {
    return _dataSource.getSeasonRevenuesCount(seasonId);
  }
}