import '../../../season/domain/entities/season.dart';
import '../../../plot/domain/entities/plot.dart';
import '../../../activity/domain/entities/activity.dart';

/// Dashboard summary containing key farm metrics.
class DashboardSummary {
  final Season? activeSeason;
  final int totalSeasons;
  final int totalPlots;
  final int totalActivities;
  final double totalExpenses;
  final double activeSeasonExpenses;
  final int dueReminders;
  final int upcomingReminders;
  final int recentActivities;
  final DateTime lastUpdated;

  const DashboardSummary({
    this.activeSeason,
    required this.totalSeasons,
    required this.totalPlots,
    required this.totalActivities,
    required this.totalExpenses,
    required this.activeSeasonExpenses,
    required this.dueReminders,
    required this.upcomingReminders,
    required this.recentActivities,
    required this.lastUpdated,
  });

  /// Get productivity score (0-100) based on recent activity.
  double get productivityScore {
    if (activeSeason == null || totalPlots == 0) return 0.0;
    
    // Calculate based on activities per plot in the last 7 days
    final activitiesPerPlot = recentActivities / totalPlots;
    
    // Scale to 0-100 (assuming 1 activity per plot per week = 100%)
    return (activitiesPerPlot * 100).clamp(0.0, 100.0);
  }

  /// Get expense efficiency (lower is better).
  double get expenseEfficiency {
    if (totalActivities == 0) return 0.0;
    return activeSeasonExpenses / totalActivities;
  }

  /// Check if farm is active (has recent activity).
  bool get isActive {
    return recentActivities > 0;
  }

  /// Get urgency level based on due reminders.
  UrgencyLevel get urgencyLevel {
    if (dueReminders >= 5) return UrgencyLevel.high;
    if (dueReminders >= 2) return UrgencyLevel.medium;
    if (dueReminders > 0) return UrgencyLevel.low;
    return UrgencyLevel.none;
  }
}

/// Analytics for a specific season.
class SeasonAnalytics {
  final Season season;
  final int totalPlots;
  final int totalActivities;
  final double totalExpenses;
  final double averageCostPerActivity;
  final Map<String, double> expensesByType;
  final List<PlotAnalytics> plotAnalytics;
  final Map<DateTime, int> activityTrends;
  final DateTime calculatedAt;

  const SeasonAnalytics({
    required this.season,
    required this.totalPlots,
    required this.totalActivities,
    required this.totalExpenses,
    required this.averageCostPerActivity,
    required this.expensesByType,
    required this.plotAnalytics,
    required this.activityTrends,
    required this.calculatedAt,
  });

  /// Get the most expensive activity type.
  String? get mostExpensiveType {
    if (expensesByType.isEmpty) return null;
    
    return expensesByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get the most productive plot.
  PlotAnalytics? get mostProductivePlot {
    if (plotAnalytics.isEmpty) return null;
    
    return plotAnalytics
        .reduce((a, b) => a.totalActivities > b.totalActivities ? a : b);
  }

  /// Get average expenses per plot.
  double get averageExpensesPerPlot {
    if (totalPlots == 0) return 0.0;
    return totalExpenses / totalPlots;
  }

  /// Get daily average activities.
  double get dailyAverageActivities {
    if (activityTrends.isEmpty) return 0.0;
    
    final totalDays = activityTrends.length;
    final totalActivitiesInPeriod = activityTrends.values.fold(0, (sum, count) => sum + count);
    
    return totalActivitiesInPeriod / totalDays;
  }
}

/// Analytics for a specific plot.
class PlotAnalytics {
  final Plot plot;
  final int totalActivities;
  final double totalExpenses;
  final double averageCostPerActivity;
  final DateTime? lastActivityDate;

  const PlotAnalytics({
    required this.plot,
    required this.totalActivities,
    required this.totalExpenses,
    required this.averageCostPerActivity,
    this.lastActivityDate,
  });

  /// Check if plot is active (has recent activity).
  bool get isActive {
    if (lastActivityDate == null) return false;
    
    final daysSinceLastActivity = DateTime.now().difference(lastActivityDate!).inDays;
    return daysSinceLastActivity <= 14; // Active if activity within 2 weeks
  }

  /// Get activity frequency (activities per day).
  double getActivityFrequency(int days) {
    return totalActivities / days;
  }

  /// Get cost efficiency per unit area.
  double get costPerUnitArea {
    return totalExpenses / plot.area;
  }
}

/// Season comparison data.
class SeasonComparison {
  final Season season;
  final double totalExpenses;
  final int totalActivities;
  final int totalPlots;
  final double averageExpensePerPlot;

  const SeasonComparison({
    required this.season,
    required this.totalExpenses,
    required this.totalActivities,
    required this.totalPlots,
    required this.averageExpensePerPlot,
  });

  /// Calculate efficiency score (activities per dollar spent).
  double get efficiencyScore {
    if (totalExpenses == 0) return 0.0;
    return totalActivities / totalExpenses;
  }

  /// Get season duration in days.
  int get durationInDays {
    return season.getDurationInDays();
  }

  /// Calculate cost per day.
  double get costPerDay {
    final days = durationInDays;
    return days > 0 ? totalExpenses / days : 0.0;
  }
}

/// Urgency levels for dashboard alerts.
enum UrgencyLevel {
  none('No urgent tasks', 'All caught up!'),
  low('Low priority', 'A few tasks need attention'),
  medium('Medium priority', 'Several tasks are due'),
  high('High priority', 'Many overdue tasks!');

  const UrgencyLevel(this.label, this.description);

  final String label;
  final String description;
}