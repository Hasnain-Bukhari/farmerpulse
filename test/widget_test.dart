// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:farmerpulse/features/home/presentation/screens/home_screen.dart';
import 'package:farmerpulse/features/settings/presentation/screens/settings_screen.dart';
import 'package:farmerpulse/features/splash/presentation/screens/splash_screen.dart';

void main() {
  // ── SplashScreen ──────────────────────────────────────────────────────────
  group('SplashScreen', () {
    testWidgets('displays app name text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      expect(find.text('FarmerPulse'), findsOneWidget);
    });
  });

  // ── HomeScreen ────────────────────────────────────────────────────────────
  group('HomeScreen', () {
    testWidgets('shows dashboard title and FAB', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Add Farmer'), findsOneWidget);
    });

    testWidgets('shows summary cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Farmers'), findsOneWidget);
      expect(find.text('Farms'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
    });
  });

  // ── SettingsScreen ────────────────────────────────────────────────────────
  group('SettingsScreen', () {
    testWidgets('shows language options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.textContaining('Urdu'), findsOneWidget);
    });
  });
}
