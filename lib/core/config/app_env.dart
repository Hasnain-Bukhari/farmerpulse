/// Simple environment configuration.
///
/// Switch between [AppEnv.dev] and [AppEnv.prod] by changing [_current].
/// For a more robust solution consider using `--dart-define` build flags
/// or the `flutter_config` / `envied` packages.
enum _Env { dev, prod }

class AppEnv {
  AppEnv._();

  // ── Change this to [_Env.prod] before a production build ─────────────────
  static const _Env _current = _Env.dev;

  static bool get isDev => _current == _Env.dev;
  static bool get isProd => _current == _Env.prod;

  /// Log-level label shown in debug output.
  static String get name => _current.name.toUpperCase();

  // ── Environment-specific values ──────────────────────────────────────────
  /// Base API URL (if/when a backend is introduced).
  static String get apiBaseUrl {
    switch (_current) {
      case _Env.dev:
        return 'https://api-dev.farmerpulse.example.com';
      case _Env.prod:
        return 'https://api.farmerpulse.example.com';
    }
  }
}
