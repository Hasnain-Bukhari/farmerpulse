import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

// ── Locale Provider ───────────────────────────────────────────────────────────

/// Reads the persisted locale from Hive and exposes it as a [Locale].
///
/// Consumers call:
///   `ref.read(localeProvider.notifier).setLocale('ur')`
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = Hive.box<dynamic>(AppConstants.prefsBox)
        .get(AppConstants.prefLocale) as String?;
    return Locale(saved ?? AppConstants.localeEn);
  }

  /// Persist and apply a new locale by language code.
  Future<void> setLocale(String languageCode) async {
    await Hive.box<dynamic>(AppConstants.prefsBox)
        .put(AppConstants.prefLocale, languageCode);
    state = Locale(languageCode);
  }
}

/// Global locale provider — used by [MaterialApp.router] to drive l10n.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
