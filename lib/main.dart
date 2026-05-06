import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/hive_helper.dart';

/// Application entry point - Production Version
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveHelper.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
