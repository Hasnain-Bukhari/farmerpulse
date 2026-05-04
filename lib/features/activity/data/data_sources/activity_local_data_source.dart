import 'package:hive_flutter/hive_flutter.dart';
import '../models/activity_model.dart';

/// Local data source for Activity CRUD operations.
class ActivityLocalDataSource {
  static const String boxName = 'activities';

  Box<ActivityModel> get _box => Hive.box<ActivityModel>(boxName);

  /// Create a new activity.
  Future<void> createActivity(ActivityModel activity) async {
    await _box.put(activity.id, activity);
  }

  /// Get all activities.
  List<ActivityModel> getAllActivities() {
    return _box.values.toList();
  }

  /// Get activities by plot ID.
  List<ActivityModel> getActivitiesByPlotId(String plotId) {
    return _box.values.where((activity) => activity.plotId == plotId).toList();
  }

  /// Get activities by date range.
  List<ActivityModel> getActivitiesByDateRange(DateTime start, DateTime end) {
    return _box.values.where((activity) {
      return activity.date.isAfter(start.subtract(const Duration(days: 1))) &&
          activity.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get a specific activity by ID.
  ActivityModel? getActivityById(String id) {
    return _box.get(id);
  }

  /// Update an existing activity.
  Future<void> updateActivity(ActivityModel activity) async {
    await _box.put(activity.id, activity);
  }

  /// Delete an activity by ID.
  Future<void> deleteActivity(String id) async {
    await _box.delete(id);
  }

  /// Watch for changes to activities.
  Stream<List<ActivityModel>> watchActivities() {
    return _box.watch().map((_) => getAllActivities());
  }

  /// Watch activities for a specific plot.
  Stream<List<ActivityModel>> watchActivitiesByPlotId(String plotId) {
    return _box.watch().map((_) => getActivitiesByPlotId(plotId));
  }

  /// Get recent activities (last N days).
  List<ActivityModel> getRecentActivities(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _box.values.where((activity) {
      return activity.date.isAfter(cutoffDate);
    }).toList();
  }

  /// Clear all activities.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
