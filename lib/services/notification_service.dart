import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize time zones
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          debugPrint('Notification tapped with payload: ${response.payload}');
          // Navigate based on payload
        }
      },
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mental_health_channel',
      'Mental Health Notifications',
      channelDescription: 'Notifications for the mental health app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    final effectiveDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        0, // Use a unique ID for each notification
        title,
        body,
        tz.TZDateTime.from(effectiveDate, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Added missing parameter
        //timeInterpretation: TimeInterpretation.absoluteTime, // Updated parameter name
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to schedule daily reminder: $e');
    }
  }

  Future<void> scheduleWeeklyReminder({
    required String title,
    required String body,
    required TimeOfDay time,
    required int dayOfWeek, // 1 = Monday, 7 = Sunday
    String? payload,
  }) async {
    final scheduledDate = _nextInstanceOfDayTime(dayOfWeek, time);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weekly_reminder_channel',
      'Weekly Reminders',
      channelDescription: 'Weekly reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        dayOfWeek, // Use day of week as ID
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Added missing parameter
        //timeInterpretation: TimeInterpretation.absoluteTime, // Updated parameter name
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Repeat weekly
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to schedule weekly reminder: $e');
    }
  }

  DateTime _nextInstanceOfDayTime(int dayOfWeek, TimeOfDay time) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday

    // Calculate days until next occurrence
    int daysUntilTarget = dayOfWeek - currentDayOfWeek;
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7;
    } else if (daysUntilTarget == 0) {
      // If same day, check if time has passed
      final currentTimeMinutes = now.hour * 60 + now.minute;
      final targetTimeMinutes = time.hour * 60 + time.minute;

      if (targetTimeMinutes <= currentTimeMinutes) {
        // Time has passed, schedule for next week
        daysUntilTarget = 7;
      }
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysUntilTarget,
      time.hour,
      time.minute,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'achievement_channel',
      'Achievement Notifications',
      channelDescription: 'Notifications for achievements',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.purple,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Use timestamp as unique ID
        title,
        body,
        platformDetails,
        payload: 'achievement',
      );
    } catch (e) {
      debugPrint('Failed to show achievement notification: $e');
    }
  }
}