// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
    
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required String time,
    required List<int> weekDays,
  }) async {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    for (final day in weekDays) {
      await _plugin.zonedSchedule(
        id * 10 + day,
        'Time for your habit!',
        "Don't break your streak — complete $habitName",
        _nextInstanceOfDayTime(day, hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Daily habit reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(categoryIdentifier: 'habit'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> scheduleWaterReminder() async {
    for (int hour = 8; hour <= 22; hour += 2) {
      await _plugin.zonedSchedule(
        1000 + hour,
        'Hydration Check!',
        'Have you had your water today? Stay hydrated!',
        _nextInstanceOfTime(hour, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders',
            'Water Reminders',
            channelDescription: 'Hydration reminders',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> scheduleSleepReminder(int hour, int minute) async {
    await _plugin.zonedSchedule(
      2000,
      'Bedtime Reminder',
      'Time to wind down. Good sleep = better results tomorrow!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_reminders',
          'Sleep Reminders',
          channelDescription: 'Bedtime reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showAchievementNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      9999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements', 'Achievements',
          channelDescription: 'Achievement notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelHabitReminders(int habitId) async {
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(habitId * 10 + day);
    }
  }

  static Future<void> cancelAll() async => await _plugin.cancelAll();

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  static tz.TZDateTime _nextInstanceOfDayTime(int weekday, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
