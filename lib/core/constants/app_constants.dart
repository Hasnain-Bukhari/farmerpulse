/// App-wide constants.
///
/// Centralise magic strings and numbers here so they are easy to find,
/// update, and reference throughout the codebase.
class AppConstants {
  AppConstants._();

  // ── App metadata ──────────────────────────────────────────────────────────
  static const String appName = 'FarmerPulse';

  // ── Hive box names ────────────────────────────────────────────────────────
  /// Box that stores farmer records.
  static const String farmersBox = 'farmersBox';

  /// Box that stores user preferences (locale, theme, etc.).
  static const String prefsBox = 'prefsBox';

  // ── Preference keys ───────────────────────────────────────────────────────
  static const String prefLocale = 'locale';

  // ── Supported locales ─────────────────────────────────────────────────────
  static const String localeEn = 'en';
  static const String localeUr = 'ur';

  // ── Route names ───────────────────────────────────────────────────────────
  // Kept in sync with AppRouter; defined here to avoid circular imports.
  static const String routeSplash = '/';
  static const String routeHome = '/home';
  static const String routeSettings = '/settings';
}
