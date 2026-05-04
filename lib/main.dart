import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/hive_helper.dart';

/// Application entry point.
///
/// Order of operations:
///   1. Ensure Flutter bindings are initialised.
///   2. Initialise Hive (local database) and open all required boxes.
///   3. Wrap the widget tree in [ProviderScope] for Riverpod.
///   4. Launch the [App] widget.
Future<void> main() async {
  // Must be called before any async work if runApp hasn't been called yet.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local database and open Hive boxes.
  await HiveHelper.init();

  runApp(
    // ProviderScope is required at the root for Riverpod to work.
    const ProviderScope(
      child: App(),
    ),
  );
}
