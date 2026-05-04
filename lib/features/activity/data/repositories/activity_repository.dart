import '../../domain/entities/activity.dart';
import '../data_sources/activity_local_data_source.dart';
import '../models/activity_model.dart';

/// Repository for Activity data operations.
class ActivityRepository {
  final ActivityLocalDataSource _dataSource;

  ActivityRepository(this._dataSource);

  /// Create a new activity.
  Future<void> createActivity(Activity activity) async {
    final model = ActivityModel.fromEntity(activity);
    await _dataSource.createActivity(model);
  }

  /// Get all activities.
  List<Activity> getAllActivities() {
    return _dataSource
        .getAllActivities()
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get activities by plot ID.
  List<Activity> getActivitiesByPlotId(String plotId) {
    return _dataSource
        .getActivitiesByPlotId(plotId)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get activities by date range.
  List<Activity> getActivitiesByDateRange(DateTime start, DateTime end) {
    return _dataSource
        .getActivitiesByDateRange(start, end)
        .map((model) => model.toEntity())
        .toList();
  }

  /// Get a specific activity by ID.
  Activity? getActivityById(String id) {
    final model = _dataSource.getActivityById(id);
    return model?.toEntity();
  }

  /// Update an existing activity.
  Future<void> updateActivity(Activity activity) async {
    final model = ActivityModel.fromEntity(activity);
    await _dataSource.updateActivity(model);
  }

  /// Delete an activity by ID.
  Future<void> deleteActivity(String id) async {
    await _dataSource.deleteActivity(id);
  }

  /// Watch for changes to all activities.
  Stream<List<Activity>> watchActivities() {
    return _dataSource.watchActivities().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  /// Watch activities for a specific plot.
  Stream<List<Activity>> watchActivitiesByPlotId(String plotId) {
    return _dataSource.watchActivitiesByPlotId(plotId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }

  /// Get recent activities (last N days).
  List<Activity> getRecentActivities(int days) {
    return _dataSource
        .getRecentActivities(days)
        .map((model) => model.toEntity())
        .toList();
  }
}
