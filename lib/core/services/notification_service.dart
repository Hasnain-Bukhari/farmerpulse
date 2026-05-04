import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service for managing local notifications and reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for handling notification taps
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions (especially important for iOS).
  Future<bool> requestPermissions() async {
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android, permissions are handled in AndroidManifest.xml
    return result ?? true;
  }

  /// Schedule a one-time notification.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Farm Reminders',
          channelDescription: 'Notifications for farm activity reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule a repeating notification.
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime firstTime,
    required RepeatInterval interval,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(firstTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Farm Reminders',
          channelDescription: 'Notifications for farm activity reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: _getDateTimeComponents(interval),
    );
  }

  /// Schedule a custom repeating notification (every X days).
  Future<void> scheduleCustomRepeatingNotification({
    required int baseId,
    required String title,
    required String body,
    required DateTime firstTime,
    required int intervalDays,
    required int totalNotifications,
    String? payload,
  }) async {
    for (int i = 0; i < totalNotifications; i++) {
      final scheduledTime = firstTime.add(Duration(days: intervalDays * i));
      await scheduleNotification(
        id: baseId + i,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      );
    }
  }

  /// Cancel a specific notification.
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel multiple notifications by ID range.
  Future<void> cancelNotificationRange(int baseId, int count) async {
    for (int i = 0; i < count; i++) {
      await cancelNotification(baseId + i);
    }
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get list of pending notifications.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Show an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Farm Reminders',
          channelDescription: 'Notifications for farm activity reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Handle notification tap events.
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Handle navigation to specific screens based on payload
    // This will be implemented when integrating with the app router
    print('Notification tapped with payload: ${response.payload}');
  }

  /// Convert RepeatInterval to DateTimeComponents.
  DateTimeComponents? _getDateTimeComponents(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return DateTimeComponents.time;
      case RepeatInterval.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatInterval.everyMinute:
        return DateTimeComponents.time;
      case RepeatInterval.hourly:
        return DateTimeComponents.time;
      case RepeatInterval.yearly:
        return DateTimeComponents.dateAndTime;
    }
  }
}

/// Custom repeat intervals for reminders.
enum CustomRepeatInterval {
  daily(1, 'Daily'),
  every2Days(2, 'Every 2 days'),
  every3Days(3, 'Every 3 days'),
  weekly(7, 'Weekly'),
  every2Weeks(14, 'Every 2 weeks'),
  monthly(30, 'Monthly');

  const CustomRepeatInterval(this.days, this.label);

  final int days;
  final String label;
}