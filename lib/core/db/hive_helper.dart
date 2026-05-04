import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

/// Helper that initialises Hive and opens all required boxes.
///
/// Call [HiveHelper.init] once in [main] before [runApp].
/// Access boxes anywhere via static getters without re-opening them.
class HiveHelper {
  HiveHelper._();

  static late Box<dynamic> _prefsBox;

  /// Opens all Hive boxes the app needs.
  static Future<void> init() async {
    if (kIsWeb) {
      // Hive works in-browser without a path.
      await Hive.initFlutter();
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocDir.path);
    }

    // Register type adapters here when you generate them:
    // Hive.registerAdapter(FarmerAdapter());

    // Open boxes
    _prefsBox = await Hive.openBox<dynamic>(AppConstants.prefsBox);
    await Hive.openBox<dynamic>(AppConstants.farmersBox);
  }

  /// User preferences box (locale, theme choice, etc.)
  static Box<dynamic> get prefsBox => _prefsBox;

  /// Convenience: read a preference value.
  static T? getPref<T>(String key) => _prefsBox.get(key) as T?;

  /// Convenience: write a preference value.
  static Future<void> setPref<T>(String key, T value) =>
      _prefsBox.put(key, value);
}
