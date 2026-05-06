import '../../data/repositories/activity_repository.dart';
import '../../../plot/data/repositories/plot_repository.dart';

/// Service for calculating expense totals and statistics.
class ExpenseCalculationService {
  final ActivityRepository _activityRepository;
  final PlotRepository _plotRepository;

  ExpenseCalculationService(
    this._activityRepository,
    this._plotRepository,
  );

  /// Calculate total expenses for a specific plot.
  double calculatePlotTotal(String plotId) {
    final activities = _activityRepository.getActivitiesByPlotId(plotId);
    return activities.fold(0.0, (sum, activity) {
      return sum + (activity.cost ?? 0.0);
    });
  }

  /// Calculate total expenses for a season (all plots).
  double calculateSeasonTotal(String seasonId) {
    final plots = _plotRepository.getPlotsBySeasonId(seasonId);
    double total = 0.0;

    for (final plot in plots) {
      total += calculatePlotTotal(plot.id);
    }

    return total;
  }

  /// Get expense breakdown by plot for a season.
  Map<String, PlotExpenseSummary> getSeasonExpenseBreakdown(String seasonId) {
    final plots = _plotRepository.getPlotsBySeasonId(seasonId);
    final Map<String, PlotExpenseSummary> breakdown = {};

    for (final plot in plots) {
      final activities = _activityRepository.getActivitiesByPlotId(plot.id);
      final total = activities.fold(0.0, (sum, activity) {
        return sum + (activity.cost ?? 0.0);
      });

      breakdown[plot.id] = PlotExpenseSummary(
        plotId: plot.id,
        plotName: plot.name,
        totalCost: total,
        activityCount: activities.length,
      );
    }

    return breakdown;
  }

  /// Get expense breakdown by activity type for a plot.
  Map<String, double> getPlotExpenseByType(String plotId) {
    final activities = _activityRepository.getActivitiesByPlotId(plotId);
    final Map<String, double> breakdown = {};

    for (final activity in activities) {
      final type = activity.type.label;
      breakdown[type] = (breakdown[type] ?? 0.0) + (activity.cost ?? 0.0);
    }

    return breakdown;
  }

  /// Calculate average cost per activity for a plot.
  double calculateAverageCostPerActivity(String plotId) {
    final activities = _activityRepository.getActivitiesByPlotId(plotId);
    if (activities.isEmpty) return 0.0;

    final total = calculatePlotTotal(plotId);
    return total / activities.length;
  }

  /// Get most expensive activities for a plot.
  List<ActivityExpense> getMostExpensiveActivities(
    String plotId, {
    int limit = 5,
  }) {
    final activities = _activityRepository.getActivitiesByPlotId(plotId);

    final expensiveActivities = activities
        .where((activity) => activity.cost != null && activity.cost! > 0)
        .map((activity) => ActivityExpense(
              activityId: activity.id,
              title: activity.title,
              type: activity.type.label,
              cost: activity.cost!,
              date: activity.date,
            ))
        .toList()
      ..sort((a, b) => b.cost.compareTo(a.cost));

    return expensiveActivities.take(limit).toList();
  }

  /// Calculate total expenses for a date range.
  double calculateExpensesByDateRange(
    String plotId,
    DateTime start,
    DateTime end,
  ) {
    final activities = _activityRepository.getActivitiesByDateRange(start, end);
    final plotActivities = activities.where((a) => a.plotId == plotId);

    return plotActivities.fold(0.0, (sum, activity) {
      return sum + (activity.cost ?? 0.0);
    });
  }
}

/// Summary of plot expenses.
class PlotExpenseSummary {
  final String plotId;
  final String plotName;
  final double totalCost;
  final int activityCount;

  PlotExpenseSummary({
    required this.plotId,
    required this.plotName,
    required this.totalCost,
    required this.activityCount,
  });

  double get averageCostPerActivity =>
      activityCount > 0 ? totalCost / activityCount : 0.0;
}

/// Individual activity expense record.
class ActivityExpense {
  final String activityId;
  final String title;
  final String type;
  final double cost;
  final DateTime date;

  ActivityExpense({
    required this.activityId,
    required this.title,
    required this.type,
    required this.cost,
    required this.date,
  });
}
