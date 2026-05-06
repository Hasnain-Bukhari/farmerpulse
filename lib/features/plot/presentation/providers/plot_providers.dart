import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/plot_local_data_source.dart';
import '../../data/repositories/plot_repository.dart';
import '../../domain/entities/plot.dart';
import '../../domain/use_cases/create_plot_use_case.dart';
import '../../domain/use_cases/update_plot_use_case.dart';
import '../../domain/use_cases/delete_plot_use_case.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Data Source Provider
// ══════════════════════════════════════════════════════════════════════════════

final plotDataSourceProvider = Provider<PlotLocalDataSource>((ref) {
  return PlotLocalDataSource();
});

// ══════════════════════════════════════════════════════════════════════════════
// Repository Provider
// ══════════════════════════════════════════════════════════════════════════════

final plotRepositoryProvider = Provider<PlotRepository>((ref) {
  final dataSource = ref.watch(plotDataSourceProvider);
  return PlotRepository(dataSource);
});

// ══════════════════════════════════════════════════════════════════════════════
// Use Case Providers
// ══════════════════════════════════════════════════════════════════════════════

final createPlotUseCaseProvider = Provider<CreatePlotUseCase>((ref) {
  final repository = ref.watch(plotRepositoryProvider);
  return CreatePlotUseCase(repository);
});

final updatePlotUseCaseProvider = Provider<UpdatePlotUseCase>((ref) {
  final repository = ref.watch(plotRepositoryProvider);
  return UpdatePlotUseCase(repository);
});

final deletePlotUseCaseProvider = Provider<DeletePlotUseCase>((ref) {
  final repository = ref.watch(plotRepositoryProvider);
  return DeletePlotUseCase(repository);
});

// ══════════════════════════════════════════════════════════════════════════════
// State Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider that watches all plots as a stream.
final plotsStreamProvider = StreamProvider<List<Plot>>((ref) {
  try {
    final repository = ref.watch(plotRepositoryProvider);
    return repository.watchPlots().handleError((error, stackTrace) {
      debugPrint('Error in plotsStreamProvider: $error');
      debugPrint('Stack trace: $stackTrace');
      throw error; // Re-throw to let Riverpod handle it
    });
  } catch (e) {
    debugPrint('Error creating plotsStreamProvider: $e');
    // Return a stream with the synchronous data as fallback
    final repository = ref.read(plotRepositoryProvider);
    return Stream.value(repository.getAllPlots());
  }
});

/// Provider that watches plots for a specific season.
final plotsBySeasonStreamProvider =
    StreamProvider.family<List<Plot>, String>((ref, seasonId) {
  final repository = ref.watch(plotRepositoryProvider);
  return repository.watchPlotsBySeasonId(seasonId);
});

/// Provider that returns all plots as a list (synchronous).
final plotsListProvider = Provider<List<Plot>>((ref) {
  try {
    final repository = ref.watch(plotRepositoryProvider);
    return repository.getAllPlots();
  } catch (e) {
    debugPrint('Error in plotsListProvider: $e');
    return <Plot>[];
  }
});

/// Provider that returns plots for a specific season (synchronous).
final plotsBySeasonProvider = Provider.family<List<Plot>, String>((ref, seasonId) {
  final repository = ref.watch(plotRepositoryProvider);
  return repository.getPlotsBySeasonId(seasonId);
});

/// Provider for a specific plot by ID.
final plotByIdProvider = Provider.family<Plot?, String>((ref, id) {
  final repository = ref.watch(plotRepositoryProvider);
  return repository.getPlotById(id);
});
