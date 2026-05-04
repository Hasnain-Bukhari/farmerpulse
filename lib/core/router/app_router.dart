import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

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

  // ── Route names ───────────────────────────────────────────────────────────
  static const String splashName = 'splash';
  static const String homeName = 'home';
  static const String settingsName = 'settings';

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
        routes: [
          GoRoute(
            path: 'settings',
            name: settingsName,
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsScreen(),
          ),
        ],
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
