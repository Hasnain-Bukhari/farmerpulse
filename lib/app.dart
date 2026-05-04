import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_lifecycle_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isRtl = ref.watch(isRtlProvider);

    return AppLifecycleWrapper(
      child: MaterialApp.router(
        title: 'FarmerPulse',
        
        // Localization
        localizationsDelegates: AppLocalizations.localizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: currentLocale,
        
        // RTL support
        builder: (context, child) {
          return Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          );
        },
        
        // Theme
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        
        // Router
        routerConfig: AppRouter.router,
        
        // Debug
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}