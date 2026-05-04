import 'package:flutter/material.dart';

/// Central theme configuration.
///
/// Uses Material 3 (useMaterial3: true) for a modern look.
/// A single [ColorScheme] seed keeps light/dark themes in sync
/// without maintaining two separate colour palettes.
class AppTheme {
  AppTheme._();

  // ── Brand colour ──────────────────────────────────────────────────────────
  static const Color _seedColor = Color(0xFF2E7D32); // deep green — agriculture

  // ── Light Theme ───────────────────────────────────────────────────────────
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
    ),
  );
}
