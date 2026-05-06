import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/season/data/models/season_model.dart';
import '../../features/plot/data/models/plot_model.dart';
import '../../features/activity/data/models/activity_model.dart';
import '../../features/reminder/data/models/reminder_model.dart';
import '../../features/analytics/data/models/revenue_model.dart';

/// Service for backup and restore operations using JSON format.
class BackupService {
  static const String _backupVersion = '1.0.0';

  /// Create a complete backup of all app data.
  Future<BackupResult> createBackup() async {
    try {
      final backupData = await _exportAllData();
      final fileName = 'farmerpulse_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = await _saveBackupToFile(backupData, fileName);
      
      return BackupResult.success(
        filePath: file.path,
        fileName: fileName,
        dataSize: backupData.length,
      );
    } catch (e) {
      return BackupResult.error('Failed to create backup: ${e.toString()}');
    }
  }

  /// Export backup data and share it.
  Future<BackupResult> exportAndShare() async {
    try {
      final backupData = await _exportAllData();
      final fileName = 'farmerpulse_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = await _saveBackupToFile(backupData, fileName);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'FarmerPulse Backup - ${DateTime.now().toLocal().toString().split(' ')[0]}',
      );
      
      return BackupResult.success(
        filePath: file.path,
        fileName: fileName,
        dataSize: backupData.length,
      );
    } catch (e) {
      return BackupResult.error('Failed to export backup: ${e.toString()}');
    }
  }

  /// Restore data from a backup file.
  Future<RestoreResult> restoreFromFile() async {
    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult.cancelled();
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      
      return await _restoreFromJsonContent(content);
    } catch (e) {
      return RestoreResult.error('Failed to restore from file: ${e.toString()}');
    }
  }

  /// Restore data from JSON content.
  Future<RestoreResult> restoreFromJson(String jsonContent) async {
    return await _restoreFromJsonContent(jsonContent);
  }

  /// Get backup statistics.
  Future<BackupStats> getBackupStats() async {
    try {
      final seasons = Hive.box<SeasonModel>('seasons');
      final plots = Hive.box<PlotModel>('plots');
      final activities = Hive.box<ActivityModel>('activities');
      final reminders = Hive.box<ReminderModel>('reminders');
      final revenues = Hive.box<RevenueModel>('revenues');

      return BackupStats(
        totalSeasons: seasons.length,
        totalPlots: plots.length,
        totalActivities: activities.length,
        totalReminders: reminders.length,
        totalRevenues: revenues.length,
        lastBackupDate: await _getLastBackupDate(),
        estimatedSize: await _estimateBackupSize(),
      );
    } catch (e) {
      return BackupStats.empty();
    }
  }

  /// Clear all app data (use with caution).
  Future<void> clearAllData() async {
    await Hive.box<SeasonModel>('seasons').clear();
    await Hive.box<PlotModel>('plots').clear();
    await Hive.box<ActivityModel>('activities').clear();
    await Hive.box<ReminderModel>('reminders').clear();
    await Hive.box<RevenueModel>('revenues').clear();
  }

  /// Export all data to JSON format.
  Future<String> _exportAllData() async {
    final seasonsBox = Hive.box<SeasonModel>('seasons');
    final plotsBox = Hive.box<PlotModel>('plots');
    final activitiesBox = Hive.box<ActivityModel>('activities');
    final remindersBox = Hive.box<ReminderModel>('reminders');
    final revenuesBox = Hive.box<RevenueModel>('revenues');

    final backupData = {
      'version': _backupVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'appInfo': {
        'name': 'FarmerPulse',
        'version': '1.0.0',
      },
      'data': {
        'seasons': seasonsBox.values.map((s) => _seasonToJson(s)).toList(),
        'plots': plotsBox.values.map((p) => _plotToJson(p)).toList(),
        'activities': activitiesBox.values.map((a) => _activityToJson(a)).toList(),
        'reminders': remindersBox.values.map((r) => _reminderToJson(r)).toList(),
        'revenues': revenuesBox.values.map((r) => _revenueToJson(r)).toList(),
      },
      'stats': {
        'totalSeasons': seasonsBox.length,
        'totalPlots': plotsBox.length,
        'totalActivities': activitiesBox.length,
        'totalReminders': remindersBox.length,
        'totalRevenues': revenuesBox.length,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  /// Restore data from JSON content.
  Future<RestoreResult> _restoreFromJsonContent(String jsonContent) async {
    try {
      final backupData = json.decode(jsonContent) as Map<String, dynamic>;
      
      // Validate backup format
      if (!backupData.containsKey('version') || !backupData.containsKey('data')) {
        return RestoreResult.error('Invalid backup file format');
      }

      final version = backupData['version'] as String;
      if (version != _backupVersion) {
        return RestoreResult.error('Unsupported backup version: $version');
      }

      final data = backupData['data'] as Map<String, dynamic>;
      
      // Clear existing data
      await clearAllData();
      
      // Restore data
      int totalRestored = 0;
      
      // Restore seasons
      if (data.containsKey('seasons')) {
        final seasons = (data['seasons'] as List).cast<Map<String, dynamic>>();
        for (final seasonJson in seasons) {
          final season = _seasonFromJson(seasonJson);
          await Hive.box<SeasonModel>('seasons').put(season.id, season);
          totalRestored++;
        }
      }
      
      // Restore plots
      if (data.containsKey('plots')) {
        final plots = (data['plots'] as List).cast<Map<String, dynamic>>();
        for (final plotJson in plots) {
          final plot = _plotFromJson(plotJson);
          await Hive.box<PlotModel>('plots').put(plot.id, plot);
          totalRestored++;
        }
      }
      
      // Restore activities
      if (data.containsKey('activities')) {
        final activities = (data['activities'] as List).cast<Map<String, dynamic>>();
        for (final activityJson in activities) {
          final activity = _activityFromJson(activityJson);
          await Hive.box<ActivityModel>('activities').put(activity.id, activity);
          totalRestored++;
        }
      }
      
      // Restore reminders
      if (data.containsKey('reminders')) {
        final reminders = (data['reminders'] as List).cast<Map<String, dynamic>>();
        for (final reminderJson in reminders) {
          final reminder = _reminderFromJson(reminderJson);
          await Hive.box<ReminderModel>('reminders').put(reminder.id, reminder);
          totalRestored++;
        }
      }
      
      // Restore revenues
      if (data.containsKey('revenues')) {
        final revenues = (data['revenues'] as List).cast<Map<String, dynamic>>();
        for (final revenueJson in revenues) {
          final revenue = _revenueFromJson(revenueJson);
          await Hive.box<RevenueModel>('revenues').put(revenue.id, revenue);
          totalRestored++;
        }
      }

      await _saveLastBackupDate(DateTime.now());
      
      return RestoreResult.success(
        itemsRestored: totalRestored,
        backupDate: DateTime.parse(backupData['timestamp'] as String),
      );
    } catch (e) {
      return RestoreResult.error('Failed to restore data: ${e.toString()}');
    }
  }

  /// Save backup to file.
  Future<File> _saveBackupToFile(String backupData, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    final file = File('${backupDir.path}/$fileName');
    await file.writeAsString(backupData);
    
    return file;
  }

  /// Convert SeasonModel to JSON.
  Map<String, dynamic> _seasonToJson(SeasonModel season) {
    return {
      'id': season.id,
      'name': season.name,
      'startDate': season.startDate.toIso8601String(),
      'endDate': season.endDate.toIso8601String(),
      'isActive': season.isActive,
      'cropType': season.cropType,
      'notes': season.notes,
      'createdAt': season.createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to SeasonModel.
  SeasonModel _seasonFromJson(Map<String, dynamic> json) {
    return SeasonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      cropType: json['cropType'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert PlotModel to JSON.
  Map<String, dynamic> _plotToJson(PlotModel plot) {
    return {
      'id': plot.id,
      'seasonId': plot.seasonId,
      'name': plot.name,
      'location': plot.location,
      'area': plot.area,
      'areaUnit': plot.areaUnit,
      'soilType': plot.soilType,
          'status': plot.status,
      'notes': plot.notes,
      'createdAt': plot.createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to PlotModel.
  PlotModel _plotFromJson(Map<String, dynamic> json) {
    return PlotModel(
      id: json['id'] as String,
      seasonId: json['seasonId'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      area: json['area'] as double,
      areaUnit: json['areaUnit'] as String,
      soilType: json['soilType'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert ActivityModel to JSON.
  Map<String, dynamic> _activityToJson(ActivityModel activity) {
    return {
      'id': activity.id,
      'plotId': activity.plotId,
          'type': activity.type,
      'title': activity.title,
      'description': activity.description,
      'date': activity.date.toIso8601String(),
      'durationMinutes': activity.durationMinutes,
      'cost': activity.cost,
      'quantity': activity.quantity,
      'unit': activity.unit,
          'status': activity.status,
      'photos': activity.photos,
      'createdAt': activity.createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to ActivityModel.
  ActivityModel _activityFromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      plotId: json['plotId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int?,
      cost: json['cost'] as double?,
      quantity: json['quantity'] as double?,
      unit: json['unit'] as String?,
      status: json['status'] as String,
      photos: (json['photos'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert ReminderModel to JSON.
  Map<String, dynamic> _reminderToJson(ReminderModel reminder) {
    return {
      'id': reminder.id,
      'title': reminder.title,
      'description': reminder.description,
      'scheduledTime': reminder.scheduledTime.toIso8601String(),
      'isRepeating': reminder.isRepeating,
      'repeatIntervalDays': reminder.repeatIntervalDays,
      'isActive': reminder.isActive,
      'linkedActivityId': reminder.linkedActivityId,
      'linkedPlotId': reminder.linkedPlotId,
      'typeIndex': reminder.typeIndex,
      'createdAt': reminder.createdAt.toIso8601String(),
      'completedAt': reminder.completedAt?.toIso8601String(),
    };
  }

  /// Convert JSON to ReminderModel.
  ReminderModel _reminderFromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isRepeating: json['isRepeating'] as bool,
      repeatIntervalDays: json['repeatIntervalDays'] as int?,
      isActive: json['isActive'] as bool,
      linkedActivityId: json['linkedActivityId'] as String?,
      linkedPlotId: json['linkedPlotId'] as String?,
      typeIndex: json['typeIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
    );
  }

  /// Convert RevenueModel to JSON.
  Map<String, dynamic> _revenueToJson(RevenueModel revenue) {
    return {
      'id': revenue.id,
      'seasonId': revenue.seasonId,
      'plotId': revenue.plotId,
      'amount': revenue.amount,
      'typeIndex': revenue.typeIndex,
      'description': revenue.description,
      'recordedDate': revenue.recordedDate.toIso8601String(),
      'notes': revenue.notes,
      'createdAt': revenue.createdAt.toIso8601String(),
      'updatedAt': revenue.updatedAt?.toIso8601String(),
    };
  }

  /// Convert JSON to RevenueModel.
  RevenueModel _revenueFromJson(Map<String, dynamic> json) {
    return RevenueModel(
      id: json['id'] as String,
      seasonId: json['seasonId'] as String,
      plotId: json['plotId'] as String?,
      amount: json['amount'] as double,
      typeIndex: json['typeIndex'] as int,
      description: json['description'] as String,
      recordedDate: DateTime.parse(json['recordedDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  /// Get last backup date from preferences.
  Future<DateTime?> _getLastBackupDate() async {
    try {
      final prefs = Hive.box('preferences');
      final timestamp = prefs.get('last_backup_date') as String?;
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      return null;
    }
  }

  /// Save last backup date to preferences.
  Future<void> _saveLastBackupDate(DateTime date) async {
    try {
      final prefs = Hive.box('preferences');
      await prefs.put('last_backup_date', date.toIso8601String());
    } catch (e) {
      // Ignore errors
    }
  }

  /// Estimate backup size in bytes.
  Future<int> _estimateBackupSize() async {
    try {
      final data = await _exportAllData();
      return data.length;
    } catch (e) {
      return 0;
    }
  }
}

/// Result of backup operation.
class BackupResult {
  final bool isSuccess;
  final String? filePath;
  final String? fileName;
  final int? dataSize;
  final String? errorMessage;

  const BackupResult._({
    required this.isSuccess,
    this.filePath,
    this.fileName,
    this.dataSize,
    this.errorMessage,
  });

  factory BackupResult.success({
    required String filePath,
    required String fileName,
    required int dataSize,
  }) {
    return BackupResult._(
      isSuccess: true,
      filePath: filePath,
      fileName: fileName,
      dataSize: dataSize,
    );
  }

  factory BackupResult.error(String message) {
    return BackupResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Result of restore operation.
class RestoreResult {
  final bool isSuccess;
  final bool isCancelled;
  final int? itemsRestored;
  final DateTime? backupDate;
  final String? errorMessage;

  const RestoreResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.itemsRestored,
    this.backupDate,
    this.errorMessage,
  });

  factory RestoreResult.success({
    required int itemsRestored,
    required DateTime backupDate,
  }) {
    return RestoreResult._(
      isSuccess: true,
      isCancelled: false,
      itemsRestored: itemsRestored,
      backupDate: backupDate,
    );
  }

  factory RestoreResult.error(String message) {
    return RestoreResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: message,
    );
  }

  factory RestoreResult.cancelled() {
    return const RestoreResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }
}

/// Backup statistics.
class BackupStats {
  final int totalSeasons;
  final int totalPlots;
  final int totalActivities;
  final int totalReminders;
  final int totalRevenues;
  final DateTime? lastBackupDate;
  final int estimatedSize;

  const BackupStats({
    required this.totalSeasons,
    required this.totalPlots,
    required this.totalActivities,
    required this.totalReminders,
    required this.totalRevenues,
    this.lastBackupDate,
    required this.estimatedSize,
  });

  factory BackupStats.empty() {
    return const BackupStats(
      totalSeasons: 0,
      totalPlots: 0,
      totalActivities: 0,
      totalReminders: 0,
      totalRevenues: 0,
      estimatedSize: 0,
    );
  }

  int get totalItems => totalSeasons + totalPlots + totalActivities + totalReminders + totalRevenues;

  String get formattedSize {
    if (estimatedSize < 1024) return '${estimatedSize}B';
    if (estimatedSize < 1024 * 1024) return '${(estimatedSize / 1024).toStringAsFixed(1)}KB';
    return '${(estimatedSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}