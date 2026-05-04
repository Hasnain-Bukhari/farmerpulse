import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/season_local_data_source.dart';
import '../../data/repositories/season_repository.dart';
import '../../domain/entities/season.dart';
import '../../domain/use_cases/create_season_use_case.dart';
import '../../domain/use_cases/update_season_use_case.dart';
import '../../domain/use_cases/delete_season_use_case.dart';
import '../../domain/use_cases/set_active_season_use_case.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Data Source Provider
// ══════════════════════════════════════════════════════════════════════════════

final seasonDataSourceProvider = Provider<SeasonLocalDataSource>((ref) {
  return SeasonLocalDataSource();
});

// ══════════════════════════════════════════════════════════════════════════════
// Repository Provider
// ══════════════════════════════════════════════════════════════════════════════

final seasonRepositoryProvider = Provider<SeasonRepository>((ref) {
  final dataSource = ref.watch(seasonDataSourceProvider);
  return SeasonRepository(dataSource);
});

// ══════════════════════════════════════════════════════════════════════════════
// Use Case Providers
// ══════════════════════════════════════════════════════════════════════════════

final createSeasonUseCaseProvider = Provider<CreateSeasonUseCase>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return CreateSeasonUseCase(repository);
});

final updateSeasonUseCaseProvider = Provider<UpdateSeasonUseCase>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return UpdateSeasonUseCase(repository);
});

final deleteSeasonUseCaseProvider = Provider<DeleteSeasonUseCase>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return DeleteSeasonUseCase(repository);
});

final setActiveSeasonUseCaseProvider = Provider<SetActiveSeasonUseCase>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return SetActiveSeasonUseCase(repository);
});

// ══════════════════════════════════════════════════════════════════════════════
// State Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Provider that watches all seasons as a stream.
final seasonsStreamProvider = StreamProvider<List<Season>>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return repository.watchSeasons();
});

/// Provider that returns all seasons as a list (synchronous).
final seasonsListProvider = Provider<List<Season>>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return repository.getAllSeasons();
});

/// Provider for the currently active season.
final activeSeasonProvider = Provider<Season?>((ref) {
  final repository = ref.watch(seasonRepositoryProvider);
  return repository.getActiveSeason();
});

/// Provider for a specific season by ID.
final seasonByIdProvider = Provider.family<Season?, String>((ref, id) {
  final repository = ref.watch(seasonRepositoryProvider);
  return repository.getSeasonById(id);
});
