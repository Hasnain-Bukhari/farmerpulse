import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/activity_local_data_source.dart';
import '../../data/repositories/activity_repository.dart';
import '../../domain/entities/activity.dart';
import '../../domain/use_cases/create_activity_use_case.dart';
import '../../domain/use_cases/update_activity_use_case.dart';
import '../../domain/use_cases/delete_activity_use_case.dart';
import '../../domain/services/expense_calculation_service.dart';
import '../../../plot/presentation/providers/plot_providers.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Data Source Provider
// ══════════════════════════════════════════════════════════════════════════════

final activityDataSourceProvider = Provider<ActivityLocalDataSource>((ref) {
  return ActivityLocalDataSource();
});

// ══════════════════════════════════════════════════════════════════════════════
// Repository Provider
// ══════════════════════════════════════════════════════════════════════════════

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dataSource = ref.watch(activityDataSourceProvider);
  return ActivityRepository(dataSource);
});

// ══════════════════════════════════════════════════════════════════════════════
// Use Case Providers
// ══════════════════════════════════════════════════════════════════════════════

final createActivityUseCaseProvider = Provider<CreateActivityUseCase>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return CreateActivityUseCase(repository);
});

final updateActivityUseCaseProvider = Provider<UpdateActivityUseCase>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return UpdateActivityUseCase(repository);
});

final deleteActivityUseCaseProvider = Provider<DeleteActivityUseCase>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  return DeleteActivityUseCase(repository);
});

// ══════════════════════════════════════════════════════════════════════════════
// State Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider that watches all activities as a stream.
final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  try {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.watchActivities().handleError((error, stackTrace) {
      debugPrint('Error in activitiesStreamProvider: $error');
      debugPrint('Stack trace: $stackTrace');
      throw error; // Re-throw to let Riverpod handle it
    });
  } catch (e) {
    debugPrint('Error creating activitiesStreamProvider: $e');
    // Return a stream with the synchronous data as fallback
    final repository = ref.read(activityRepositoryProvider);
    return Stream.value(repository.getAllActivities());
  }
});

/// Provider that watches activities for a specific plot.
final activitiesByPlotStreamProvider =
    StreamProvider.family<List<Activity>, String>((ref, plotId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.watchActivitiesByPlotId(plotId);
});

/// Provider that returns all activities as a list (synchronous).
final activitiesListProvider = Provider<List<Activity>>((ref) {
  try {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.getAllActivities();
  } catch (e) {
    debugPrint('Error in activitiesListProvider: $e');
    return <Activity>[];
  }
});

/// Provider that returns activities for a specific plot (synchronous).
final activitiesByPlotProvider = Provider.family<List<Activity>, String>((ref, plotId) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivitiesByPlotId(plotId);
});

/// Provider for a specific activity by ID.
final activityByIdProvider = Provider.family<Activity?, String>((ref, id) {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getActivityById(id);
});

/// Provider for recent activities (last 7 days).
final recentActivitiesProvider = Provider<List<Activity>>((ref) {
  try {
    final repository = ref.watch(activityRepositoryProvider);
    return repository.getRecentActivities(7);
  } catch (e) {
    debugPrint('Error in recentActivitiesProvider: $e');
    return <Activity>[];
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// Expense Calculation Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Service provider for expense calculations.
final expenseCalculationServiceProvider =
    Provider<ExpenseCalculationService>((ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  final plotRepository = ref.watch(plotRepositoryProvider);
  return ExpenseCalculationService(activityRepository, plotRepository);
});

/// Calculate total expenses for a plot.
final plotTotalExpenseProvider = Provider.family<double, String>((ref, plotId) {
  final service = ref.watch(expenseCalculationServiceProvider);
  // Watch activities to trigger recalculation when they change
  ref.watch(activitiesByPlotStreamProvider(plotId));
  return service.calculatePlotTotal(plotId);
});

/// Calculate total expenses for a season.
final seasonTotalExpenseProvider =
    Provider.family<double, String>((ref, seasonId) {
  final service = ref.watch(expenseCalculationServiceProvider);
  // Watch activities to trigger recalculation
  ref.watch(activitiesStreamProvider);
  return service.calculateSeasonTotal(seasonId);
});

/// Get expense breakdown by plot for a season.
final seasonExpenseBreakdownProvider =
    Provider.family<Map<String, PlotExpenseSummary>, String>((ref, seasonId) {
  final service = ref.watch(expenseCalculationServiceProvider);
  ref.watch(activitiesStreamProvider);
  return service.getSeasonExpenseBreakdown(seasonId);
});

/// Get expense breakdown by activity type for a plot.
final plotExpenseByTypeProvider =
    Provider.family<Map<String, double>, String>((ref, plotId) {
  final service = ref.watch(expenseCalculationServiceProvider);
  ref.watch(activitiesByPlotStreamProvider(plotId));
  return service.getPlotExpenseByType(plotId);
});
