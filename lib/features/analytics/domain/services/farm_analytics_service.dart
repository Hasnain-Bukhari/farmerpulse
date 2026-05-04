import '../../season/data/repositories/season_repository.dart';
import '../../plot/data/repositories/plot_repository.dart';
import '../../activity/data/repositories/activity_repository.dart';
import '../../reminder/data/repositories/reminder_repository.dart';
import '../entities/dashboard_summary.dart';
import '../entities/season_analytics.dart';

/// Service for calculating farm analytics and dashboard data.
class FarmAnalyticsService {
  final SeasonRepository _seasonRepository;
  final PlotRepository _plotRepository;
  final ActivityRepository _activityRepository;
  final ReminderRepository _reminderRepository;

  const FarmAnalyticsService(
    this._seasonRepository,
    this._plotRepository,
    this._activityRepository,
    this._reminderRepository,
  );

  /// Get complete dashboard summary.
  DashboardSummary getDashboardSummary() {
    final seasons = _seasonRepository.getAllSeasons();
    final plots = _plotRepository.getAllPlots();
    final activities = _activityRepository.getAllActivities();
    final reminders = _reminderRepository.getActiveReminders();

    // Find active season
    final activeSeason = seasons.where((s) => s.isActive).firstOrNull;
    
    // Calculate totals
    final totalSeasons = seasons.length;
    final totalPlots = plots.length;
    final totalActivities = activities.length;
    
    // Calculate expenses
    final totalExpenses = activities.fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));
    final activeSeasonExpenses = activeSeason != null 
        ? _calculateSeasonExpenses(activeSeason.id) 
        : 0.0;

    // Calculate reminders
    final dueReminders = reminders.where((r) => r.isOverdue || r.isDueToday).length;
    final upcomingReminders = reminders.where((r) => r.isDueSoon).length;

    // Recent activity (last 7 days)
    final recentActivities = _getRecentActivitiesCount(7);

    return DashboardSummary(
      activeSeason: activeSeason,
      totalSeasons: totalSeasons,
      totalPlots: totalPlots,
      totalActivities: totalActivities,
      totalExpenses: totalExpenses,
      activeSeasonExpenses: activeSeasonExpenses,
      dueReminders: dueReminders,
      upcomingReminders: upcomingReminders,
      recentActivities: recentActivities,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get analytics for a specific season.
  SeasonAnalytics getSeasonAnalytics(String seasonId) {
    final season = _seasonRepository.getSeasonById(seasonId);
    if (season == null) {
      throw Exception('Season not found');
    }

    final plots = _plotRepository.getPlotsBySeasonId(seasonId);
    final activities = <Activity>[];
    
    // Collect all activities for this season
    for (final plot in plots) {
      activities.addAll(_activityRepository.getActivitiesByPlotId(plot.id));
    }

    // Calculate expenses by type
    final expensesByType = <String, double>{};
    for (final activity in activities) {
      final type = activity.type.label;
      expensesByType[type] = (expensesByType[type] ?? 0.0) + (activity.cost ?? 0.0);
    }

    // Calculate plot performance
    final plotAnalytics = plots.map((plot) {
      final plotActivities = activities.where((a) => a.plotId == plot.id).toList();
      final plotExpenses = plotActivities.fold(0.0, (sum, a) => sum + (a.cost ?? 0.0));
      
      return PlotAnalytics(
        plot: plot,
        totalActivities: plotActivities.length,
        totalExpenses: plotExpenses,
        averageCostPerActivity: plotActivities.isNotEmpty ? plotExpenses / plotActivities.length : 0.0,
        lastActivityDate: plotActivities.isNotEmpty 
            ? plotActivities.map((a) => a.date).reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      );
    }).toList();

    // Calculate totals
    final totalExpenses = activities.fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));
    final totalActivities = activities.length;
    final averageCostPerActivity = totalActivities > 0 ? totalExpenses / totalActivities : 0.0;

    // Activity trends (last 30 days)
    final activityTrends = _calculateActivityTrends(activities, 30);

    return SeasonAnalytics(
      season: season,
      totalPlots: plots.length,
      totalActivities: totalActivities,
      totalExpenses: totalExpenses,
      averageCostPerActivity: averageCostPerActivity,
      expensesByType: expensesByType,
      plotAnalytics: plotAnalytics,
      activityTrends: activityTrends,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate expenses for a specific season.
  double _calculateSeasonExpenses(String seasonId) {
    final plots = _plotRepository.getPlotsBySeasonId(seasonId);
    double total = 0.0;

    for (final plot in plots) {
      final activities = _activityRepository.getActivitiesByPlotId(plot.id);
      total += activities.fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));
    }

    return total;
  }

  /// Get count of recent activities.
  int _getRecentActivitiesCount(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final activities = _activityRepository.getAllActivities();
    
    return activities.where((activity) => activity.date.isAfter(cutoffDate)).length;
  }

  /// Calculate activity trends over time.
  Map<DateTime, int> _calculateActivityTrends(List<Activity> activities, int days) {
    final trends = <DateTime, int>{};
    final now = DateTime.now();
    
    // Initialize with zeros
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      trends[date] = 0;
    }

    // Count activities by date
    for (final activity in activities) {
      final activityDate = DateTime(activity.date.year, activity.date.month, activity.date.day);
      if (trends.containsKey(activityDate)) {
        trends[activityDate] = trends[activityDate]! + 1;
      }
    }

    return trends;
  }

  /// Get top expensive activities across all seasons.
  List<Activity> getTopExpensiveActivities({int limit = 10}) {
    final activities = _activityRepository.getAllActivities();
    
    // Filter activities with costs and sort by cost descending
    final expensiveActivities = activities
        .where((activity) => activity.cost != null && activity.cost! > 0)
        .toList();
    
    expensiveActivities.sort((a, b) => (b.cost ?? 0.0).compareTo(a.cost ?? 0.0));
    
    return expensiveActivities.take(limit).toList();
  }

  /// Get activity distribution by type.
  Map<String, int> getActivityDistribution() {
    final activities = _activityRepository.getAllActivities();
    final distribution = <String, int>{};

    for (final activity in activities) {
      final type = activity.type.label;
      distribution[type] = (distribution[type] ?? 0) + 1;
    }

    return distribution;
  }

  /// Calculate average expenses per plot.
  double getAverageExpensesPerPlot() {
    final plots = _plotRepository.getAllPlots();
    if (plots.isEmpty) return 0.0;

    final totalExpenses = _activityRepository.getAllActivities()
        .fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));

    return totalExpenses / plots.length;
  }

  /// Get productivity metrics (activities per plot).
  double getAverageActivitiesPerPlot() {
    final plots = _plotRepository.getAllPlots();
    if (plots.isEmpty) return 0.0;

    final totalActivities = _activityRepository.getAllActivities().length;
    return totalActivities / plots.length;
  }

  /// Get seasonal comparison data.
  List<SeasonComparison> getSeasonComparisons() {
    final seasons = _seasonRepository.getAllSeasons();
    
    return seasons.map((season) {
      final seasonExpenses = _calculateSeasonExpenses(season.id);
      final plots = _plotRepository.getPlotsBySeasonId(season.id);
      final totalActivities = plots.fold(0, (sum, plot) {
        return sum + _activityRepository.getActivitiesByPlotId(plot.id).length;
      });

      return SeasonComparison(
        season: season,
        totalExpenses: seasonExpenses,
        totalActivities: totalActivities,
        totalPlots: plots.length,
        averageExpensePerPlot: plots.isNotEmpty ? seasonExpenses / plots.length : 0.0,
      );
    }).toList();
  }
}