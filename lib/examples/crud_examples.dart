/// Example CRUD Operations
/// 
/// This file demonstrates all Create, Read, Update, Delete operations
/// for Season and Plot features with practical examples.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/season/domain/entities/season.dart';
import '../features/season/presentation/providers/season_providers.dart';
import '../features/plot/domain/entities/plot.dart';
import '../features/plot/presentation/providers/plot_providers.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SEASON CRUD EXAMPLES
// ══════════════════════════════════════════════════════════════════════════════

class SeasonCRUDExamples {
  
  // ─────────────────────────────────────────────────────────────────────────────
  // CREATE - Add a new season
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> createSeason(WidgetRef ref) async {
    final season = Season(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Winter 2026',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 3, 31),
      isActive: true,
      cropType: 'Wheat',
      notes: 'Focus on drought-resistant varieties',
    );

    try {
      // Call the use case through provider
      await ref.read(createSeasonUseCaseProvider).call(season);
      debugPrint('✅ CREATE: Season created successfully - ${season.name}');
      
      // UI automatically updates via stream!
      // No manual state update needed!
    } catch (e) {
      debugPrint('❌ CREATE ERROR: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // READ - Get seasons in different ways
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Method 1: Stream-based (auto-updates UI)
  static Widget readSeasonsStream(WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsStreamProvider);

    return seasonsAsync.when(
      data: (seasons) {
        debugPrint('📖 READ (Stream): Found ${seasons.length} seasons');
        return ListView.builder(
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(seasons[index].name),
              subtitle: Text('${seasons[index].getDurationInDays()} days'),
            );
          },
        );
      },
      loading: () {
        debugPrint('⏳ READ: Loading seasons...');
        return const CircularProgressIndicator();
      },
      error: (error, stack) {
        debugPrint('❌ READ ERROR: $error');
        return Text('Error: $error');
      },
    );
  }

  /// Method 2: Synchronous list
  static void readSeasonsList(WidgetRef ref) {
    final seasons = ref.read(seasonsListProvider);
    debugPrint('📖 READ (List): Found ${seasons.length} seasons');
    for (final season in seasons) {
      debugPrint('  - ${season.name} (${season.isActive ? "ACTIVE" : "inactive"})');
    }
  }

  /// Method 3: Get active season
  static void readActiveSeason(WidgetRef ref) {
    final activeSeason = ref.read(activeSeasonProvider);
    if (activeSeason != null) {
      debugPrint('📖 READ (Active): ${activeSeason.name}');
    } else {
      debugPrint('📖 READ (Active): No active season');
    }
  }

  /// Method 4: Get specific season by ID
  static void readSeasonById(WidgetRef ref, String seasonId) {
    final season = ref.read(seasonByIdProvider(seasonId));
    if (season != null) {
      debugPrint('📖 READ (By ID): ${season.name}');
      debugPrint('   Start: ${season.startDate}');
      debugPrint('   End: ${season.endDate}');
      debugPrint('   Duration: ${season.getDurationInDays()} days');
    } else {
      debugPrint('📖 READ (By ID): Season not found');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UPDATE - Modify an existing season
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> updateSeason(WidgetRef ref, String seasonId) async {
    // 1. Get existing season
    final season = ref.read(seasonByIdProvider(seasonId));
    
    if (season == null) {
      debugPrint('❌ UPDATE ERROR: Season not found');
      return;
    }

    // 2. Create modified copy (entities are immutable)
    final updatedSeason = season.copyWith(
      cropType: 'Corn', // Changed crop
      notes: 'Updated notes with new information',
    );

    try {
      // 3. Save changes
      await ref.read(updateSeasonUseCaseProvider).call(updatedSeason);
      debugPrint('✅ UPDATE: Season updated - ${updatedSeason.name}');
      debugPrint('   New crop: ${updatedSeason.cropType}');
      
      // UI automatically updates via stream!
    } catch (e) {
      debugPrint('❌ UPDATE ERROR: $e');
    }
  }

  /// Update multiple fields
  static Future<void> updateSeasonMultipleFields(
    WidgetRef ref,
    String seasonId,
  ) async {
    final season = ref.read(seasonByIdProvider(seasonId));
    if (season == null) return;

    final updated = season.copyWith(
      name: 'Winter 2026 - Extended',
      endDate: DateTime(2026, 4, 15), // Extended duration
      cropType: 'Mixed Crops',
      notes: 'Extended season for better yield',
    );

    try {
      await ref.read(updateSeasonUseCaseProvider).call(updated);
      debugPrint('✅ UPDATE: Multiple fields updated');
    } catch (e) {
      debugPrint('❌ UPDATE ERROR: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DELETE - Remove a season
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> deleteSeason(WidgetRef ref, String seasonId) async {
    // Optional: Get season details before deleting (for confirmation)
    final season = ref.read(seasonByIdProvider(seasonId));
    if (season != null) {
      debugPrint('🗑️ DELETE: Deleting season "${season.name}"');
    }

    try {
      await ref.read(deleteSeasonUseCaseProvider).call(seasonId);
      debugPrint('✅ DELETE: Season deleted successfully');
      
      // UI automatically updates via stream!
    } catch (e) {
      debugPrint('❌ DELETE ERROR: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SPECIAL OPERATION - Set active season
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> setActiveSeason(WidgetRef ref, String seasonId) async {
    try {
      // Deactivates all other seasons, activates this one
      await ref.read(setActiveSeasonUseCaseProvider).call(seasonId);
      debugPrint('✅ ACTIVE: Season set as active');
      
      // UI automatically updates!
    } catch (e) {
      debugPrint('❌ ACTIVE ERROR: $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLOT CRUD EXAMPLES
// ══════════════════════════════════════════════════════════════════════════════

class PlotCRUDExamples {
  
  // ─────────────────────────────────────────────────────────────────────────────
  // CREATE - Add a new plot
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> createPlot(WidgetRef ref, String seasonId) async {
    final plot = Plot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      seasonId: seasonId, // Link to parent season
      name: 'Plot A1',
      area: 2.5,
      areaUnit: 'acres',
      location: '40.7128,-74.0060',
      soilType: 'Loamy clay',
      status: PlotStatus.active,
      notes: 'North-facing plot with good drainage',
    );

    try {
      await ref.read(createPlotUseCaseProvider).call(plot);
      debugPrint('✅ CREATE: Plot created - ${plot.name}');
      debugPrint('   Linked to season: $seasonId');
      
      // UI automatically updates via stream!
    } catch (e) {
      debugPrint('❌ CREATE ERROR: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // READ - Get plots in different ways
  // ─────────────────────────────────────────────────────────────────────────────
  
  /// Method 1: Stream all plots
  static Widget readPlotsStream(WidgetRef ref) {
    final plotsAsync = ref.watch(plotsStreamProvider);

    return plotsAsync.when(
      data: (plots) {
        debugPrint('📖 READ (Stream): Found ${plots.length} plots');
        return ListView.builder(
          itemCount: plots.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(plots[index].name),
              subtitle: Text('${plots[index].area} ${plots[index].areaUnit}'),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  /// Method 2: Stream plots for specific season
  static Widget readPlotsBySeasonStream(WidgetRef ref, String seasonId) {
    final plotsAsync = ref.watch(plotsBySeasonStreamProvider(seasonId));

    return plotsAsync.when(
      data: (plots) {
        debugPrint('📖 READ (Season $seasonId): Found ${plots.length} plots');
        return ListView.builder(
          itemCount: plots.length,
          itemBuilder: (context, index) {
            final plot = plots[index];
            return ListTile(
              title: Text(plot.name),
              subtitle: Text('${plot.area} ${plot.areaUnit} - ${plot.status.label}'),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  /// Method 3: Get specific plot by ID
  static void readPlotById(WidgetRef ref, String plotId) {
    final plot = ref.read(plotByIdProvider(plotId));
    if (plot != null) {
      debugPrint('📖 READ (By ID): ${plot.name}');
      debugPrint('   Area: ${plot.area} ${plot.areaUnit}');
      debugPrint('   Status: ${plot.status.label}');
      debugPrint('   Location: ${plot.location ?? "Not set"}');
    } else {
      debugPrint('📖 READ (By ID): Plot not found');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UPDATE - Modify an existing plot
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> updatePlot(WidgetRef ref, String plotId) async {
    final plot = ref.read(plotByIdProvider(plotId));
    
    if (plot == null) {
      debugPrint('❌ UPDATE ERROR: Plot not found');
      return;
    }

    // Change status to fallow
    final updated = plot.copyWith(
      status: PlotStatus.fallow,
      notes: 'Resting for next season',
    );

    try {
      await ref.read(updatePlotUseCaseProvider).call(updated);
      debugPrint('✅ UPDATE: Plot updated - ${updated.name}');
      debugPrint('   New status: ${updated.status.label}');
      
      // UI automatically updates!
    } catch (e) {
      debugPrint('❌ UPDATE ERROR: $e');
    }
  }

  /// Update area
  static Future<void> updatePlotArea(
    WidgetRef ref,
    String plotId,
    double newArea,
  ) async {
    final plot = ref.read(plotByIdProvider(plotId));
    if (plot == null) return;

    final updated = plot.copyWith(area: newArea);

    try {
      await ref.read(updatePlotUseCaseProvider).call(updated);
      debugPrint('✅ UPDATE: Plot area changed to $newArea ${plot.areaUnit}');
    } catch (e) {
      debugPrint('❌ UPDATE ERROR: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DELETE - Remove a plot
  // ─────────────────────────────────────────────────────────────────────────────
  
  static Future<void> deletePlot(WidgetRef ref, String plotId) async {
    final plot = ref.read(plotByIdProvider(plotId));
    if (plot != null) {
      debugPrint('🗑️ DELETE: Deleting plot "${plot.name}"');
    }

    try {
      await ref.read(deletePlotUseCaseProvider).call(plotId);
      debugPrint('✅ DELETE: Plot deleted successfully');
      
      // UI automatically updates!
    } catch (e) {
      debugPrint('❌ DELETE ERROR: $e');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPLEX EXAMPLES - Multiple operations
// ══════════════════════════════════════════════════════════════════════════════

class ComplexCRUDExamples {
  
  /// Create season with multiple plots
  static Future<void> createSeasonWithPlots(WidgetRef ref) async {
    // 1. Create season
    final season = Season(
      id: 'season-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Summer 2026',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 8, 31),
      isActive: false,
      cropType: 'Mixed Vegetables',
    );

    try {
      await ref.read(createSeasonUseCaseProvider).call(season);
      debugPrint('✅ Created season: ${season.name}');

      // 2. Create multiple plots
      final plotNames = ['Plot A', 'Plot B', 'Plot C'];
      for (final name in plotNames) {
        final plot = Plot(
          id: 'plot-${DateTime.now().millisecondsSinceEpoch}-$name',
          seasonId: season.id,
          name: name,
          area: 2.0,
          areaUnit: 'acres',
          status: PlotStatus.active,
        );

        await ref.read(createPlotUseCaseProvider).call(plot);
        debugPrint('  ✅ Created plot: $name');
      }

      debugPrint('🎉 Season with ${plotNames.length} plots created!');
    } catch (e) {
      debugPrint('❌ ERROR: $e');
    }
  }

  /// Get season details with all plots
  static Future<Map<String, dynamic>> getSeasonWithPlots(
    WidgetRef ref,
    String seasonId,
  ) async {
    final season = ref.read(seasonByIdProvider(seasonId));
    final repository = ref.read(plotRepositoryProvider);
    final plots = repository.getPlotsBySeasonId(seasonId);

    final totalArea = plots.fold(0.0, (sum, plot) => sum + plot.area);
    final activePlots = plots.where((p) => p.status == PlotStatus.active).length;

    debugPrint('📊 SEASON SUMMARY: ${season?.name}');
    debugPrint('   Total plots: ${plots.length}');
    debugPrint('   Active plots: $activePlots');
    debugPrint('   Total area: $totalArea acres');

    return {
      'season': season,
      'plots': plots,
      'plotCount': plots.length,
      'activePlots': activePlots,
      'totalArea': totalArea,
    };
  }

  /// Delete season with all its plots (cascade delete)
  static Future<void> deleteSeasonCascade(
    WidgetRef ref,
    String seasonId,
  ) async {
    final season = ref.read(seasonByIdProvider(seasonId));
    final repository = ref.read(plotRepositoryProvider);
    
    if (season == null) {
      debugPrint('❌ Season not found');
      return;
    }

    try {
      // 1. Get all plots
      final plots = repository.getPlotsBySeasonId(seasonId);
      debugPrint('🗑️ CASCADE DELETE: ${season.name}');
      debugPrint('   Will delete ${plots.length} plots');

      // 2. Delete all plots
      for (final plot in plots) {
        await ref.read(deletePlotUseCaseProvider).call(plot.id);
        debugPrint('  ✅ Deleted plot: ${plot.name}');
      }

      // 3. Delete season
      await ref.read(deleteSeasonUseCaseProvider).call(seasonId);
      debugPrint('  ✅ Deleted season: ${season.name}');
      
      debugPrint('🎉 Cascade delete complete!');
    } catch (e) {
      debugPrint('❌ CASCADE ERROR: $e');
    }
  }

  /// Update all plots in a season to fallow
  static Future<void> setAllPlotsToFallow(
    WidgetRef ref,
    String seasonId,
  ) async {
    final repository = ref.read(plotRepositoryProvider);
    final plots = repository.getPlotsBySeasonId(seasonId);

    debugPrint('🔄 Setting ${plots.length} plots to fallow');

    for (final plot in plots) {
      final updated = plot.copyWith(status: PlotStatus.fallow);
      await ref.read(updatePlotUseCaseProvider).call(updated);
      debugPrint('  ✅ ${plot.name} → Fallow');
    }

    debugPrint('🎉 All plots updated!');
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// USAGE IN UI
// ══════════════════════════════════════════════════════════════════════════════

/// Example screen showing how to use CRUD operations
class CRUDDemoScreen extends ConsumerWidget {
  const CRUDDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Create Season
          ElevatedButton(
            onPressed: () => SeasonCRUDExamples.createSeason(ref),
            child: const Text('Create Season'),
          ),
          
          // Read Seasons
          const Text('Seasons:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: SeasonCRUDExamples.readSeasonsStream(ref),
          ),
          
          // Create Plot (needs season ID)
          ElevatedButton(
            onPressed: () {
              final activeSeason = ref.read(activeSeasonProvider);
              if (activeSeason != null) {
                PlotCRUDExamples.createPlot(ref, activeSeason.id);
              }
            },
            child: const Text('Create Plot in Active Season'),
          ),
          
          // Complex operations
          ElevatedButton(
            onPressed: () => ComplexCRUDExamples.createSeasonWithPlots(ref),
            child: const Text('Create Season + 3 Plots'),
          ),
        ],
      ),
    );
  }
}
