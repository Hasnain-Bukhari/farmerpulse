import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/farm_analytics_service.dart';
import '../../domain/services/profit_loss_calculation_service.dart';
import '../../data/data_sources/revenue_local_data_source.dart';
import '../../data/repositories/revenue_repository.dart';
import '../../domain/use_cases/create_revenue_use_case.dart';
import '../../domain/use_cases/update_revenue_use_case.dart';
import '../../domain/use_cases/delete_revenue_use_case.dart';
import '../../domain/entities/revenue.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../season/presentation/providers/season_providers.dart';
import '../../../plot/presentation/providers/plot_providers.dart';
import '../../../activity/presentation/providers/activity_providers.dart';
import '../../../reminder/presentation/providers/reminder_providers.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Core Infrastructure Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Revenue data source provider.
final revenueLocalDataSourceProvider = Provider<RevenueLocalDataSource>((ref) {
  return RevenueLocalDataSource();
});

/// Revenue repository provider.
final revenueRepositoryProvider = Provider<RevenueRepository>((ref) {
  final dataSource = ref.watch(revenueLocalDataSourceProvider);
  return RevenueRepository(dataSource);
});

/// Farm analytics service provider.
final farmAnalyticsServiceProvider = Provider<FarmAnalyticsService>((ref) {
  final seasonRepository = ref.watch(seasonRepositoryProvider);
  final plotRepository = ref.watch(plotRepositoryProvider);
  final activityRepository = ref.watch(activityRepositoryProvider);
  final reminderRepository = ref.watch(reminderRepositoryProvider);
  
  return FarmAnalyticsService(
    seasonRepository,
    plotRepository,
    activityRepository,
    reminderRepository,
  );
});

/// Profit/Loss calculation service provider.
final profitLossCalculationServiceProvider = Provider<ProfitLossCalculationService>((ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  final revenueRepository = ref.watch(revenueRepositoryProvider);
  final plotRepository = ref.watch(plotRepositoryProvider);
  
  return ProfitLossCalculationService(activityRepository, revenueRepository, plotRepository);
});

// ══════════════════════════════════════════════════════════════════════════════
// Use Case Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Create revenue use case provider.
final createRevenueUseCaseProvider = Provider<CreateRevenueUseCase>((ref) {
  final repository = ref.watch(revenueRepositoryProvider);
  return CreateRevenueUseCase(repository);
});

/// Update revenue use case provider.
final updateRevenueUseCaseProvider = Provider<UpdateRevenueUseCase>((ref) {
  final repository = ref.watch(revenueRepositoryProvider);
  return UpdateRevenueUseCase(repository);
});

/// Delete revenue use case provider.
final deleteRevenueUseCaseProvider = Provider<DeleteRevenueUseCase>((ref) {
  final repository = ref.watch(revenueRepositoryProvider);
  return DeleteRevenueUseCase(repository);
});

// ══════════════════════════════════════════════════════════════════════════════
// Data Stream Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Stream provider for all revenues.
final revenuesStreamProvider = StreamProvider<List<Revenue>>((ref) {
  final repository = ref.watch(revenueRepositoryProvider);
  return repository.watchRevenues();
});

/// Stream provider for revenues by season.
final revenuesBySeasonStreamProvider = 
    StreamProvider.family<List<Revenue>, String>((ref, seasonId) {
  final repository = ref.watch(revenueRepositoryProvider);
  return repository.watchRevenuesBySeasonId(seasonId);
});

/// Stream provider for revenues by plot.
final revenuesByPlotStreamProvider = 
    StreamProvider.family<List<Revenue>, String>((ref, plotId) {
  final repository = ref.watch(revenueRepositoryProvider);
  return repository.watchRevenuesByPlotId(plotId);
});

// ══════════════════════════════════════════════════════════════════════════════
// State Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider for all revenues list.
final allRevenuesProvider = Provider<List<Revenue>>((ref) {
  final revenuesAsync = ref.watch(revenuesStreamProvider);
  return revenuesAsync.when(
    data: (revenues) => revenues,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for revenues by season.
final seasonRevenuesProvider = Provider.family<List<Revenue>, String>((ref, seasonId) {
  final revenuesAsync = ref.watch(revenuesBySeasonStreamProvider(seasonId));
  return revenuesAsync.when(
    data: (revenues) => revenues,
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for revenue by ID.
final revenueByIdProvider = Provider.family<Revenue?, String>((ref, id) {
  final revenues = ref.watch(allRevenuesProvider);
  try {
    return revenues.firstWhere((revenue) => revenue.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider for total revenue count.
final totalRevenuesCountProvider = Provider<int>((ref) {
  final revenues = ref.watch(allRevenuesProvider);
  return revenues.length;
});

// ══════════════════════════════════════════════════════════════════════════════
// Analytics Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider for dashboard summary.
final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getDashboardSummary();
});

/// Provider for season analytics.
final seasonAnalyticsProvider = Provider.family<SeasonAnalytics, String>((ref, seasonId) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getSeasonAnalytics(seasonId);
});

/// Provider for profit/loss calculation for a season.
final seasonProfitLossProvider = Provider.family<ProfitLossResult, String>((ref, seasonId) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.calculateSeasonProfitLoss(seasonId);
});

/// Provider for profit/loss calculation for a plot.
final plotProfitLossProvider = 
    Provider.family<ProfitLossResult, ({String plotId, String seasonId})>((ref, params) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.calculatePlotProfitLoss(params.plotId, params.seasonId);
});

/// Provider for total profit/loss calculation.
final totalProfitLossProvider = Provider<ProfitLossResult>((ref) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.calculateTotalProfitLoss();
});

/// Provider for season revenue breakdown.
final seasonRevenueBreakdownProvider = 
    Provider.family<Map<String, double>, String>((ref, seasonId) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.getSeasonRevenueBreakdown(seasonId);
});

/// Provider for season expense breakdown.
final seasonExpenseBreakdownProvider = 
    Provider.family<Map<String, double>, String>((ref, seasonId) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.getSeasonExpenseBreakdown(seasonId);
});

/// Provider for top expensive activities.
final topExpensiveActivitiesProvider = Provider<List<Activity>>((ref) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getTopExpensiveActivities();
});

/// Provider for activity distribution by type.
final activityDistributionProvider = Provider<Map<String, int>>((ref) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getActivityDistribution();
});

/// Provider for average expenses per plot.
final averageExpensesPerPlotProvider = Provider<double>((ref) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getAverageExpensesPerPlot();
});

/// Provider for average activities per plot.
final averageActivitiesPerPlotProvider = Provider<double>((ref) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getAverageActivitiesPerPlot();
});

/// Provider for season comparisons.
final seasonComparisonsProvider = Provider<List<SeasonComparison>>((ref) {
  final service = ref.watch(farmAnalyticsServiceProvider);
  return service.getSeasonComparisons();
});

/// Provider for most profitable season.
final mostProfitableSeasonProvider = Provider<String?>((ref) {
  final seasons = ref.watch(seasonsListProvider);
  final seasonIds = seasons.map((s) => s.id).toList();
  
  if (seasonIds.isEmpty) return null;
  
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.getMostProfitableSeason(seasonIds);
});

/// Provider for break-even analysis for a season.
final breakEvenAnalysisProvider = Provider.family<double, String>((ref, seasonId) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.calculateBreakEvenPoint(seasonId);
});

/// Provider for ROI calculation for a season.
final roiProvider = Provider.family<double, String>((ref, seasonId) {
  final service = ref.watch(profitLossCalculationServiceProvider);
  return service.calculateROI(seasonId);
});

// ══════════════════════════════════════════════════════════════════════════════
// Filter and Sort Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider for revenues by type.
final revenuesByTypeProvider = 
    Provider.family<List<Revenue>, RevenueType>((ref, type) {
  final revenues = ref.watch(allRevenuesProvider);
  return revenues.where((revenue) => revenue.type == type).toList();
});

/// Provider for revenues sorted by amount.
final revenuesSortedByAmountProvider = Provider<List<Revenue>>((ref) {
  final revenues = ref.watch(allRevenuesProvider);
  final sortedRevenues = List<Revenue>.from(revenues);
  sortedRevenues.sort((a, b) => b.amount.compareTo(a.amount));
  return sortedRevenues;
});

/// Provider for recent revenues (last 30 days).
final recentRevenuesProvider = Provider<List<Revenue>>((ref) {
  final revenues = ref.watch(allRevenuesProvider);
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  
  return revenues.where((revenue) => 
    revenue.recordedDate.isAfter(thirtyDaysAgo)
  ).toList();
});

/// Provider for revenue totals by month.
final monthlyRevenueTotalsProvider = Provider<Map<String, double>>((ref) {
  final revenues = ref.watch(allRevenuesProvider);
  final monthlyTotals = <String, double>{};

  for (final revenue in revenues) {
    final monthKey = '${revenue.recordedDate.year}-${revenue.recordedDate.month.toString().padLeft(2, '0')}';
    monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + revenue.amount;
  }

  return monthlyTotals;
});