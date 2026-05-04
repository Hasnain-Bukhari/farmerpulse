import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'generated/l10n/app_localizations.dart';
import 'shared/providers/locale_provider.dart';

/// Root application widget.
///
/// [App] is a [ConsumerWidget] so it can watch [localeProvider] and
/// rebuild [MaterialApp.router] whenever the user changes the language.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      // ── Identity ──────────────────────────────────────────────────────────
      title: 'FarmerPulse',

      // ── Routing ───────────────────────────────────────────────────────────
      routerConfig: AppRouter.router,

      // ── Theme ─────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Localisation ──────────────────────────────────────────────────────
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      debugShowCheckedModeBanner: false,
    );
  }
}
