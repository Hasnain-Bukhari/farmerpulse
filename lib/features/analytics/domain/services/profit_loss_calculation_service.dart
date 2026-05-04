import '../../activity/data/repositories/activity_repository.dart';
import '../../plot/data/repositories/plot_repository.dart';
import '../data/repositories/revenue_repository.dart';
import '../domain/entities/revenue.dart';

/// Service for calculating profit/loss and financial metrics.
class ProfitLossCalculationService {
  final ActivityRepository _activityRepository;
  final RevenueRepository _revenueRepository;
  final PlotRepository _plotRepository;

  const ProfitLossCalculationService(
    this._activityRepository,
    this._revenueRepository,
    this._plotRepository,
  );

  /// Calculate profit/loss for a specific season.
  ProfitLossResult calculateSeasonProfitLoss(String seasonId) {
    final revenues = _revenueRepository.getRevenuesBySeasonId(seasonId);
    final activities = _getSeasonActivities(seasonId);

    return _calculateProfitLoss(
      seasonId: seasonId,
      revenues: revenues,
      activities: activities,
    );
  }

  /// Calculate profit/loss for a specific plot.
  ProfitLossResult calculatePlotProfitLoss(String plotId, String seasonId) {
    final revenues = _revenueRepository.getRevenuesByPlotId(plotId);
    final activities = _activityRepository.getActivitiesByPlotId(plotId);

    return _calculateProfitLoss(
      seasonId: seasonId,
      plotId: plotId,
      revenues: revenues,
      activities: activities,
    );
  }

  /// Calculate combined profit/loss for all seasons.
  ProfitLossResult calculateTotalProfitLoss() {
    final allRevenues = _revenueRepository.getAllRevenues();
    final allActivities = _activityRepository.getAllActivities();

    return _calculateProfitLoss(
      seasonId: 'all-seasons',
      revenues: allRevenues,
      activities: allActivities,
    );
  }

  /// Get revenue breakdown by type for a season.
  Map<String, double> getSeasonRevenueBreakdown(String seasonId) {
    final revenues = _revenueRepository.getRevenuesBySeasonId(seasonId);
    return _getRevenueBreakdown(revenues);
  }

  /// Get expense breakdown by type for a season.
  Map<String, double> getSeasonExpenseBreakdown(String seasonId) {
    final activities = _getSeasonActivities(seasonId);
    return _getExpenseBreakdown(activities);
  }

  /// Calculate profit margin for a season.
  double calculateProfitMargin(String seasonId) {
    final result = calculateSeasonProfitLoss(seasonId);
    return result.profitMargin;
  }

  /// Calculate return on investment (ROI) for a season.
  double calculateROI(String seasonId) {
    final result = calculateSeasonProfitLoss(seasonId);
    return result.roi;
  }

  /// Get most profitable season.
  String? getMostProfitableSeason(List<String> seasonIds) {
    double maxProfit = double.negativeInfinity;
    String? mostProfitableSeasonId;

    for (final seasonId in seasonIds) {
      final result = calculateSeasonProfitLoss(seasonId);
      if (result.netProfit > maxProfit) {
        maxProfit = result.netProfit;
        mostProfitableSeasonId = seasonId;
      }
    }

    return mostProfitableSeasonId;
  }

  /// Get most profitable plot in a season.
  String? getMostProfitablePlot(String seasonId, List<String> plotIds) {
    double maxProfit = double.negativeInfinity;
    String? mostProfitablePlotId;

    for (final plotId in plotIds) {
      final result = calculatePlotProfitLoss(plotId, seasonId);
      if (result.netProfit > maxProfit) {
        maxProfit = result.netProfit;
        mostProfitablePlotId = plotId;
      }
    }

    return mostProfitablePlotId;
  }

  /// Calculate break-even point for a season.
  double calculateBreakEvenPoint(String seasonId) {
    final activities = _getSeasonActivities(seasonId);
    final totalExpenses = activities.fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));
    return totalExpenses;
  }

  /// Calculate cost per unit area for a plot.
  double calculateCostPerUnitArea(String plotId) {
    // This would need plot area information
    // For now, return cost per activity as a proxy
    final activities = _activityRepository.getActivitiesByPlotId(plotId);
    final totalCost = activities.fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));
    return activities.isNotEmpty ? totalCost / activities.length : 0.0;
  }

  /// Calculate revenue per unit area for a plot.
  double calculateRevenuePerUnitArea(String plotId) {
    final revenues = _revenueRepository.getRevenuesByPlotId(plotId);
    final totalRevenue = revenues.fold(0.0, (sum, revenue) => sum + revenue.amount);
    // Would need plot area for accurate calculation
    return totalRevenue;
  }

  /// Core profit/loss calculation logic.
  ProfitLossResult _calculateProfitLoss({
    required String seasonId,
    String? plotId,
    required List<Revenue> revenues,
    required List<Activity> activities,
  }) {
    // Calculate total revenue
    final totalRevenue = revenues.fold(0.0, (sum, revenue) => sum + revenue.amount);

    // Calculate total expenses
    final totalExpenses = activities.fold(0.0, (sum, activity) => sum + (activity.cost ?? 0.0));

    // Calculate net profit
    final netProfit = totalRevenue - totalExpenses;

    // Calculate profit margin (profit as percentage of revenue)
    final profitMargin = totalRevenue != 0 ? (netProfit / totalRevenue) * 100 : 0.0;

    // Get expense breakdown
    final expensesByType = _getExpenseBreakdown(activities);

    return ProfitLossResult(
      seasonId: seasonId,
      plotId: plotId,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      profitMargin: profitMargin,
      revenues: revenues,
      expensesByType: expensesByType,
      calculatedAt: DateTime.now(),
    );
  }

  /// Get all activities for a season.
  List<Activity> _getSeasonActivities(String seasonId) {
    // Get all plots for the season
    final plots = _plotRepository.getPlotsBySeasonId(seasonId);
    final plotIds = plots.map((plot) => plot.id).toSet();
    
    // Get all activities and filter by plot IDs
    final allActivities = _activityRepository.getAllActivities();
    return allActivities.where((activity) => plotIds.contains(activity.plotId)).toList();
  }

  /// Calculate revenue breakdown by type.
  Map<String, double> _getRevenueBreakdown(List<Revenue> revenues) {
    final breakdown = <String, double>{};

    for (final revenue in revenues) {
      final type = revenue.type.label;
      breakdown[type] = (breakdown[type] ?? 0.0) + revenue.amount;
    }

    return breakdown;
  }

  /// Calculate expense breakdown by activity type.
  Map<String, double> _getExpenseBreakdown(List<Activity> activities) {
    final breakdown = <String, double>{};

    for (final activity in activities) {
      final type = activity.type.label;
      breakdown[type] = (breakdown[type] ?? 0.0) + (activity.cost ?? 0.0);
    }

    return breakdown;
  }
}