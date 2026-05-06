import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/season/presentation/screens/season_list_screen.dart';
import '../../features/season/presentation/screens/season_form_screen.dart';
import '../../features/season/presentation/screens/season_detail_screen.dart';
import '../../features/plot/presentation/screens/plot_form_screen.dart';
import '../../features/plot/presentation/screens/plot_list_screen.dart';
import '../../features/plot/presentation/screens/all_plots_screen.dart';
import '../../features/activity/presentation/screens/activity_form_screen.dart';
import '../../features/activity/presentation/screens/activity_list_screen.dart';
import '../../features/activity/presentation/screens/activity_timeline_screen.dart';
import '../../features/activity/presentation/screens/all_activities_screen.dart';
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
  static const String backup = '/settings/backup';
  static const String seasons = '/seasons';
  static const String allPlots = '/plots';
  static const String allActivities = '/activities';
  static const String seasonsCreate = '/seasons/create';
  static String seasonDetail(String id) => '/seasons/$id';
  static String seasonEdit(String id) => '/seasons/$id/edit';
  static String plotList(String seasonId) => '/seasons/$seasonId/plots';
  static String plotAdd(String seasonId) => '/seasons/$seasonId/plots/add';
  static String plotEdit(String seasonId, String plotId) => '/seasons/$seasonId/plots/$plotId/edit';
  static String activityList(String plotId) => '/plots/$plotId/activities';
  static String activityAdd(String plotId) => '/plots/$plotId/activities/add';
  static String activityEdit(String plotId, String activityId) =>
      '/plots/$plotId/activities/$activityId/edit';
  static String activityTimeline(String plotId) => '/plots/$plotId/activities/timeline';
  
  // Analytics routes
  static const String analytics = '/analytics/profit-loss';
  static String analyticsForSeason(String seasonId) => '/analytics/profit-loss?seasonId=$seasonId';
  static const String revenueAdd = '/analytics/revenue/add';
  static String revenueAddForSeason(String seasonId) => '/analytics/revenue/add?seasonId=$seasonId';
  static String revenueEdit(String revenueId) => '/analytics/revenue/$revenueId/edit';
  
  // Reminder routes
  static const String reminders = '/reminders';
  static const String remindersAdd = '/reminders/add';
  static String reminderEdit(String reminderId) => '/reminders/$reminderId/edit';

  // ── Route names ───────────────────────────────────────────────────────────
  static const String splashName = 'splash';
  static const String homeName = 'home';
  static const String settingsName = 'settings';
  static const String backupName = 'backup';
  static const String seasonsName = 'seasons';
  static const String allPlotsName = 'all-plots';
  static const String allActivitiesName = 'all-activities';
  static const String seasonsCreateName = 'seasons-create';
  static const String seasonDetailName = 'season-detail';
  static const String seasonEditName = 'season-edit';
  static const String plotListName = 'plot-list';
  static const String plotAddName = 'plot-add';
  static const String plotEditName = 'plot-edit';
  static const String activityListName = 'activity-list';
  static const String activityAddName = 'activity-add';
  static const String activityEditName = 'activity-edit';
  static const String activityTimelineName = 'activity-timeline';
  
  // Analytics route names
  static const String analyticsName = 'analytics-profit-loss';
  static const String revenueAddName = 'revenue-add';
  static const String revenueEditName = 'revenue-edit';
  
  // Reminder route names
  static const String remindersName = 'reminders';
  static const String remindersAddName = 'reminders-add';
  static const String reminderEditName = 'reminder-edit';

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
      GoRoute(
        path: backup,
        name: backupName,
        builder: (BuildContext context, GoRouterState state) =>
            const BackupScreen(),
      ),
      
      // ── Global Routes ─────────────────────────────────────────────────────
      GoRoute(
        path: allPlots,
        name: allPlotsName,
        builder: (BuildContext context, GoRouterState state) =>
            const AllPlotsScreen(),
      ),
      GoRoute(
        path: allActivities,
        name: allActivitiesName,
        builder: (BuildContext context, GoRouterState state) =>
            const AllActivitiesScreen(),
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
        path: '/seasons/:seasonId/plots',
        name: plotListName,
        builder: (BuildContext context, GoRouterState state) {
          final seasonId = state.pathParameters['seasonId']!;
          return PlotListScreen(seasonId: seasonId);
        },
      ),
      GoRoute(
        path: '/seasons/:seasonId/plots/add',
        name: plotAddName,
        builder: (BuildContext context, GoRouterState state) {
          final seasonId = state.pathParameters['seasonId']!;
          return PlotFormScreen(seasonId: seasonId);
        },
      ),
      GoRoute(
        path: '/seasons/:seasonId/plots/:plotId/edit',
        name: plotEditName,
        builder: (BuildContext context, GoRouterState state) {
          final seasonId = state.pathParameters['seasonId']!;
          final plotId = state.pathParameters['plotId']!;
          return PlotFormScreen(seasonId: seasonId, plotId: plotId);
        },
      ),
      
      // ── Activity Routes ───────────────────────────────────────────────────
      GoRoute(
        path: '/plots/:plotId/activities',
        name: activityListName,
        builder: (BuildContext context, GoRouterState state) {
          final plotId = state.pathParameters['plotId']!;
          return ActivityListScreen(plotId: plotId);
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
      GoRoute(
        path: '/plots/:plotId/activities/timeline',
        name: activityTimelineName,
        builder: (BuildContext context, GoRouterState state) {
          final plotId = state.pathParameters['plotId']!;
          return ActivityTimelineScreen(plotId: plotId);
        },
      ),
      
      // ── Analytics Routes ──────────────────────────────────────────────────
      GoRoute(
        path: '/analytics/profit-loss',
        name: analyticsName,
        builder: (BuildContext context, GoRouterState state) {
          final seasonId = state.uri.queryParameters['seasonId'];
          return ProfitLossScreen(seasonId: seasonId);
        },
      ),
      GoRoute(
        path: '/analytics/revenue/add',
        name: revenueAddName,
        builder: (BuildContext context, GoRouterState state) {
          final seasonId = state.uri.queryParameters['seasonId'];
          final plotId = state.uri.queryParameters['plotId'];
          return RevenueFormScreen(
            seasonId: seasonId,
            plotId: plotId,
          );
        },
      ),
      GoRoute(
        path: '/analytics/revenue/:revenueId/edit',
        name: revenueEditName,
        builder: (BuildContext context, GoRouterState state) {
          final revenueId = state.pathParameters['revenueId']!;
          return RevenueFormScreen(revenueId: revenueId);
        },
      ),
      
      // ── Reminder Routes ───────────────────────────────────────────────────
      GoRoute(
        path: '/reminders',
        name: remindersName,
        builder: (BuildContext context, GoRouterState state) =>
            const RemindersListScreen(),
      ),
      GoRoute(
        path: '/reminders/add',
        name: remindersAddName,
        builder: (BuildContext context, GoRouterState state) {
          final plotId = state.uri.queryParameters['plotId'];
          final activityId = state.uri.queryParameters['activityId'];
          return ReminderFormScreen(
            plotId: plotId,
            activityId: activityId,
          );
        },
      ),
      GoRoute(
        path: '/reminders/:reminderId/edit',
        name: reminderEditName,
        builder: (BuildContext context, GoRouterState state) {
          final reminderId = state.pathParameters['reminderId']!;
          return ReminderFormScreen(reminderId: reminderId);
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

/// Provider for the app router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
