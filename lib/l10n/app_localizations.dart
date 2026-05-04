import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationDelegates: AppLocalizations.localizationDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  // App title and basic info
  String get appTitle => 'FarmerPulse';
  String get appDescription => 'Farm management made simple';

  // Navigation
  String get home => 'Home';
  String get seasons => 'Seasons';
  String get plots => 'Plots';
  String get activities => 'Activities';
  String get reminders => 'Reminders';
  String get analytics => 'Analytics';
  String get settings => 'Settings';

  // Common actions
  String get add => 'Add';
  String get edit => 'Edit';
  String get delete => 'Delete';
  String get save => 'Save';
  String get cancel => 'Cancel';
  String get update => 'Update';
  String get create => 'Create';
  String get remove => 'Remove';
  String get done => 'Done';
  String get next => 'Next';
  String get back => 'Back';
  String get confirm => 'Confirm';
  String get yes => 'Yes';
  String get no => 'No';

  // Form fields
  String get name => 'Name';
  String get description => 'Description';
  String get notes => 'Notes';
  String get date => 'Date';
  String get time => 'Time';
  String get amount => 'Amount';
  String get type => 'Type';
  String get status => 'Status';
  String get area => 'Area';
  String get location => 'Location';
  String get title => 'Title';

  // Validation messages
  String get fieldRequired => 'This field is required';
  String get invalidAmount => 'Enter a valid amount';
  String get invalidDate => 'Enter a valid date';
  String get invalidEmail => 'Enter a valid email';

  // Dashboard
  String get dashboard => 'Dashboard';
  String get farmOverview => 'Farm Overview';
  String get quickActions => 'Quick Actions';
  String get recentActivity => 'Recent Activity';
  String get totalExpenses => 'Total Expenses';
  String get activeSeasons => 'Active Seasons';
  String get productivityScore => 'Productivity Score';

  // Season management
  String get seasonName => 'Season Name';
  String get startDate => 'Start Date';
  String get endDate => 'End Date';
  String get cropType => 'Crop Type';
  String get isActive => 'Active';
  String get createSeason => 'Create Season';
  String get editSeason => 'Edit Season';
  String get seasonDetails => 'Season Details';
  String get manageSeason => 'Manage Season';
  String get deleteSeason => 'Delete Season';
  String get seasonCreated => 'Season created successfully';
  String get seasonUpdated => 'Season updated successfully';
  String get seasonDeleted => 'Season deleted successfully';

  // Plot management
  String get plotName => 'Plot Name';
  String get plotArea => 'Plot Area';
  String get soilType => 'Soil Type';
  String get createPlot => 'Create Plot';
  String get editPlot => 'Edit Plot';
  String get plotDetails => 'Plot Details';
  String get managePlot => 'Manage Plot';
  String get deletePlot => 'Delete Plot';
  String get plotCreated => 'Plot created successfully';
  String get plotUpdated => 'Plot updated successfully';
  String get plotDeleted => 'Plot deleted successfully';

  // Activity management
  String get activityTitle => 'Activity Title';
  String get activityType => 'Activity Type';
  String get duration => 'Duration';
  String get cost => 'Cost';
  String get quantity => 'Quantity';
  String get unit => 'Unit';
  String get createActivity => 'Create Activity';
  String get editActivity => 'Edit Activity';
  String get activityDetails => 'Activity Details';
  String get manageActivity => 'Manage Activity';
  String get deleteActivity => 'Delete Activity';
  String get activityCreated => 'Activity created successfully';
  String get activityUpdated => 'Activity updated successfully';
  String get activityDeleted => 'Activity deleted successfully';
  String get timeline => 'Timeline';

  // Activity types
  String get landPreparation => 'Land Preparation';
  String get seeding => 'Seeding';
  String get watering => 'Watering';
  String get spray => 'Spray';
  String get harvest => 'Harvest';
  String get fertilizer => 'Fertilizer';
  String get cleaning => 'Cleaning';

  // Reminder management
  String get reminderTitle => 'Reminder Title';
  String get reminderDescription => 'Reminder Description';
  String get scheduledTime => 'Scheduled Time';
  String get repeat => 'Repeat';
  String get createReminder => 'Create Reminder';
  String get editReminder => 'Edit Reminder';
  String get reminderDetails => 'Reminder Details';
  String get manageReminder => 'Manage Reminder';
  String get deleteReminder => 'Delete Reminder';
  String get reminderCreated => 'Reminder created successfully';
  String get reminderUpdated => 'Reminder updated successfully';
  String get reminderDeleted => 'Reminder deleted successfully';
  String get completeReminder => 'Complete Reminder';
  String get reminderCompleted => 'Reminder completed';

  // Analytics and profit/loss
  String get profitLoss => 'Profit & Loss';
  String get revenue => 'Revenue';
  String get expenses => 'Expenses';
  String get profit => 'Profit';
  String get loss => 'Loss';
  String get netProfit => 'Net Profit';
  String get profitMargin => 'Profit Margin';
  String get roi => 'Return on Investment';
  String get breakEven => 'Break Even';
  String get addRevenue => 'Add Revenue';
  String get editRevenue => 'Edit Revenue';
  String get revenueType => 'Revenue Type';
  String get revenueAmount => 'Revenue Amount';
  String get recordedDate => 'Recorded Date';

  // Revenue types
  String get harvestSales => 'Harvest Sales';
  String get livestockSales => 'Livestock Sales';
  String get produceSales => 'Produce Sales';
  String get equipmentRental => 'Equipment Rental';
  String get services => 'Services';
  String get subsidies => 'Subsidies';
  String get insurance => 'Insurance';
  String get other => 'Other';

  // Status and states
  String get active => 'Active';
  String get inactive => 'Inactive';
  String get pending => 'Pending';
  String get completed => 'Completed';
  String get cancelled => 'Cancelled';
  String get overdue => 'Overdue';
  String get dueToday => 'Due Today';
  String get upcoming => 'Upcoming';

  // Time periods
  String get today => 'Today';
  String get tomorrow => 'Tomorrow';
  String get yesterday => 'Yesterday';
  String get thisWeek => 'This Week';
  String get lastWeek => 'Last Week';
  String get thisMonth => 'This Month';
  String get lastMonth => 'Last Month';
  String get daily => 'Daily';
  String get weekly => 'Weekly';
  String get monthly => 'Monthly';

  // Settings
  String get language => 'Language';
  String get theme => 'Theme';
  String get notifications => 'Notifications';
  String get backup => 'Backup';
  String get restore => 'Restore';
  String get export => 'Export';
  String get import => 'Import';
  String get data => 'Data';

  // Backup and export
  String get backupData => 'Backup Data';
  String get restoreData => 'Restore Data';
  String get exportData => 'Export Data';
  String get importData => 'Import Data';
  String get selectFile => 'Select File';
  String get backupCreated => 'Backup created successfully';
  String get dataRestored => 'Data restored successfully';
  String get dataExported => 'Data exported successfully';
  String get dataImported => 'Data imported successfully';

  // Error messages
  String get error => 'Error';
  String get errorOccurred => 'An error occurred';
  String get errorLoadingData => 'Error loading data';
  String get errorSavingData => 'Error saving data';
  String get errorCreatingBackup => 'Error creating backup';
  String get errorRestoringData => 'Error restoring data';
  String get tryAgain => 'Try Again';

  // Success messages
  String get success => 'Success';
  String get operationCompleted => 'Operation completed successfully';
  String get dataSaved => 'Data saved successfully';

  // Empty states
  String get noSeasonsYet => 'No seasons yet';
  String get noPlotsYet => 'No plots yet';
  String get noActivitiesYet => 'No activities yet';
  String get noRemindersYet => 'No reminders yet';
  String get noRevenueYet => 'No revenue recorded yet';
  String get noDataFound => 'No data found';

  // Confirmation dialogs
  String get areYouSure => 'Are you sure?';
  String get deleteConfirmation => 'This action cannot be undone.';
  String get restoreConfirmation => 'This will replace all current data.';

  // Units
  String get hectare => 'Hectare';
  String get acre => 'Acre';
  String get squareMeter => 'Square Meter';
  String get minutes => 'Minutes';
  String get hours => 'Hours';
  String get days => 'Days';
  String get kg => 'Kg';
  String get liter => 'Liter';
  String get piece => 'Piece';

  // Languages
  String get english => 'English';
  String get urdu => 'اردو';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue on GitHub with a '
    'reproducible sample app and the gen-l10n configuration that was used.'
  );
}