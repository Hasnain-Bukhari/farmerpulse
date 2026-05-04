import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/db/hive_helper.dart';

/// Provider for managing locale settings.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    try {
      final savedLocaleCode = HiveHelper.getPref<String>('locale');
      if (savedLocaleCode != null) {
        state = Locale(savedLocaleCode);
      }
    } catch (e) {
      // Use default locale if error
      state = const Locale('en');
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await HiveHelper.setPref('locale', locale.languageCode);
  }
}

/// Provider for locale settings.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Provider for checking if RTL is active.
final isRtlProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'ur';
});