// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FarmerPulse';

  @override
  String get homeTitle => 'Dashboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get farmersLabel => 'Farmers';

  @override
  String get noDataFound => 'No data found.';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';
}
