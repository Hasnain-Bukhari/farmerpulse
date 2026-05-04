import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/season/presentation/screens/season_list_screen.dart';
import '../../features/season/presentation/screens/season_form_screen.dart';
import '../../features/season/presentation/screens/season_detail_screen.dart';
import '../../features/plot/presentation/screens/plot_form_screen.dart';
import '../../features/activity/presentation/screens/activity_form_screen.dart';
import '../../features/activity/presentation/screens/activity_timeline_screen.dart';
import '../../features/reminder/presentation/screens/reminder_form_screen.dart';
import '../../features/reminder/presentation/screens/reminders_list_screen.dart';
import '../../features/analytics/presentation/screens/profit_loss_screen.dart';
import '../../features/analytics/presentation/screens/revenue_form_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/backup_screen.dart';

/// Central routing configuration using [GoRouter].
///
/// All named routes are declared here. To navigate, use:
///   `context.go(AppRouter.home)`  or
///   `context.goNamed('home')`
class AppRouter {
  AppRouter._();

  // ── Route paths ───────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String seasons = '/seasons';
  static const String seasonsCreate = '/seasons/create';
  static String seasonDetail(String id) => '/seasons/$id';
  static String seasonEdit(String id) => '/seasons/$id/edit';
  static String plotAdd(String seasonId) => '/seasons/$seasonId/plots/add';
  static String activityTimeline(String plotId) => '/plots/$plotId/activities';
  static String activityAdd(String plotId) => '/plots/$plotId/activities/add';
  static String activityEdit(String plotId, String activityId) =>
      '/plots/$plotId/activities/$activityId/edit';

  // ── Route names ───────────────────────────────────────────────────────────
  static const String splashName = 'splash';
  static const String homeName = 'home';
  static const String settingsName = 'settings';
  static const String seasonsName = 'seasons';
  static const String seasonsCreateName = 'seasons-create';
  static const String seasonDetailName = 'season-detail';
  static const String seasonEditName = 'season-edit';
  static const String plotAddName = 'plot-add';
  static const String activityTimelineName = 'activity-timeline';
  static const String activityAddName = 'activity-add';
  static const String activityEditName = 'activity-edit';

  /// The single [GoRouter] instance used by [MaterialApp.router].
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: splashName,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: home,
        name: homeName,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: settings,
        name: settingsName,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      
      // ── Season Routes ─────────────────────────────────────────────────────
      GoRoute(
        path: seasons,
        name: seasonsName,
        builder: (BuildContext context, GoRouterState state) =>
            const SeasonListScreen(),
      ),
      GoRoute(
        path: seasonsCreate,
        name: seasonsCreateName,
        builder: (BuildContext context, GoRouterState state) =>
            const SeasonFormScreen(),
      ),
      GoRoute(
        path: '/seasons/:id',
        name: seasonDetailName,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return SeasonDetailScreen(seasonId: id);
        },
      ),
      GoRoute(
        path: '/seasons/:id/edit',
        name: seasonEditName,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return SeasonFormScreen(seasonId: id);
        },
      ),
      
      // ── Plot Routes ───────────────────────────────────────────────────────
      GoRoute(
        path: '/seasons/:seasonId/plots/add',
        name: plotAddName,
        builder: (BuildContext context, GoRouterState state) {
          final seasonId = state.pathParameters['seasonId']!;
          return PlotFormScreen(seasonId: seasonId);
        },
      ),
      
      // ── Activity Routes ───────────────────────────────────────────────────
      GoRoute(
        path: '/plots/:plotId/activities',
        name: activityTimelineName,
        builder: (BuildContext context, GoRouterState state) {
          final plotId = state.pathParameters['plotId']!;
          return ActivityTimelineScreen(plotId: plotId);
        },
      ),
      GoRoute(
        path: '/plots/:plotId/activities/add',
        name: activityAddName,
        builder: (BuildContext context, GoRouterState state) {
          final plotId = state.pathParameters['plotId']!;
          return ActivityFormScreen(plotId: plotId);
        },
      ),
      GoRoute(
        path: '/plots/:plotId/activities/:activityId/edit',
        name: activityEditName,
        builder: (BuildContext context, GoRouterState state) {
          final plotId = state.pathParameters['plotId']!;
          final activityId = state.pathParameters['activityId']!;
          return ActivityFormScreen(
            plotId: plotId,
            activityId: activityId,
          );
        },
      ),
    ],
    // Custom error page shown for unknown routes
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
