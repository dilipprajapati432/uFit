// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String? timeZoneName = await const MethodChannel('ufit/timezone').invokeMethod<String>('getTimeZone');
      print("TIMEZONE RESOLVED FROM NATIVE: $timeZoneName");
      if (timeZoneName != null) {
        var mappedName = timeZoneName.trim();
        if (mappedName == 'Asia/Calcutta') {
          mappedName = 'Asia/Kolkata';
        } else if (mappedName == 'Asia/Katmandu') {
          mappedName = 'Asia/Kathmandu';
        }
        try {
          tz.setLocalLocation(tz.getLocation(mappedName));
          print("TIMEZONE SET SUCCESSFULLY TO: ${tz.local.name}");
        } catch (e) {
          print("FAILED TO GET LOCATION FOR $mappedName: $e. Trying generic fallback.");
          tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));
          print("TIMEZONE SET TO GENERIC FALLBACK: ${tz.local.name}");
        }
      }
    } catch (e, stack) {
      print("ERROR INITIALIZING TIMEZONE: $e\n$stack");
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));
        print("TIMEZONE FALLBACK TO Asia/Kathmandu WORKED");
      } catch (err) {
        print("TIMEZONE FALLBACK FAILED: $err");
      }
    }

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
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
      final notificationId = (id & 0x7ffffff) * 10 + day;
      try {
        await _plugin.zonedSchedule(
          notificationId,
          'Time for your habit!',
          "Don't break your streak — complete $habitName",
          _nextInstanceOfDayTime(day, hour, minute),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_reminders',
              'Habit Reminders',
              channelDescription: 'Daily habit reminders',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
            iOS: DarwinNotificationDetails(categoryIdentifier: 'habit'),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (e, stack) {
        print("ERROR SCHEDULING HABIT REMINDER (ID: $notificationId): $e\n$stack");
      }
    }
  }

  static Future<void> scheduleWaterReminder() async {
    await cancelWaterReminders();

    try {
      final prefs = await SharedPreferences.getInstance();
      final startHour = prefs.getInt('water_start_hour') ?? 8;
      final startMinute = prefs.getInt('water_start_minute') ?? 0;
      final endHour = prefs.getInt('water_end_hour') ?? 22;
      final endMinute = prefs.getInt('water_end_minute') ?? 0;
      final intervalHours = prefs.getInt('water_interval_hours') ?? 2;

      int startTotalMinutes = startHour * 60 + startMinute;
      int endTotalMinutes = endHour * 60 + endMinute;

      if (endTotalMinutes <= startTotalMinutes) {
        endTotalMinutes = 24 * 60 - 1; // Default to end of day if invalid range
      }

      int currentTotalMinutes = startTotalMinutes;
      int idOffset = 0;

      while (currentTotalMinutes <= endTotalMinutes && idOffset < 50) {
        final hour = currentTotalMinutes ~/ 60;
        final minute = currentTotalMinutes % 60;

        await _plugin.zonedSchedule(
          1000 + idOffset,
          'Hydration Check!',
          'Have you had your water today? Stay hydrated!',
          _nextInstanceOfTime(hour, minute),
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

        currentTotalMinutes += intervalHours * 60;
        idOffset++;
      }
    } catch (_) {}
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
      await _plugin.cancel((habitId & 0x7ffffff) * 10 + day);
    }
  }

  static Future<void> cancelWaterReminders() async {
    for (int id = 1000; id <= 1050; id++) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> cancelSleepReminder() async {
    await _plugin.cancel(2000);
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
