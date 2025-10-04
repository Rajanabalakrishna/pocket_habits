// services/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Notifications for habit reminders',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    final status = await Permission.notification.request();
    if (status.isDenied) {
      print('Notification permission denied');
    }

    // For Android, also check exact alarm permission
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final exactAlarmPermission = await androidPlugin.canScheduleExactNotifications();
        if (exactAlarmPermission != true) {
          print('Exact alarm permission not granted');
          // Request exact alarm permission
          await androidPlugin.requestExactAlarmsPermission();
        }
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    print('Scheduling reminder for habit: ${habit.name}');
    print('Reminder time: ${habit.reminderTime}');

    if (habit.reminderTime == null) {
      print('No reminder time set');
      return;
    }

    // Cancel existing notification for this habit
    await cancelHabitReminder(habit.id);

    final reminderParts = habit.reminderTime!.split(':');
    final reminderHour = int.parse(reminderParts[0]);
    final reminderMinute = int.parse(reminderParts[1]);

    final now = DateTime.now();
    var notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    ).subtract(const Duration(minutes: 30));

    // If notification time is in the past, schedule for tomorrow
    if (notificationTime.isBefore(now)) {
      notificationTime = notificationTime.add(const Duration(days: 1));
    }

    // Check if habit is scheduled for today
    if (!_isHabitScheduledToday(habit)) {
      print('Habit not scheduled for today');
      return;
    }

    print('Notification scheduled for: $notificationTime');

    // Schedule the notification
    await _scheduleNotification(
      id: habit.id.hashCode,
      title: 'Habit Reminder',
      body: 'Don\'t forget: ${habit.name} in 30 minutes!',
      scheduledTime: notificationTime,
      payload: habit.id,
    );

    // Check if notification was actually scheduled
    final pendingNotifications = await getPendingNotifications();
    print('Total pending notifications: ${pendingNotifications.length}');
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Only schedule if the time is in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
        print('Notification scheduled successfully for ID: $id');
      } else {
        print('Scheduled time is in the past, not scheduling notification');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      // Fallback to inexact scheduling if exact alarms are not allowed
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
        print('Notification scheduled with inexact timing for ID: $id');
      } catch (fallbackError) {
        print('Failed to schedule notification even with inexact timing: $fallbackError');
      }
    }
  }

  bool _isHabitScheduledToday(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday;

    switch (habit.frequency.type) {
      case 'daily':
        return habit.frequency.days.contains(weekday);
      case 'weekly':
        return habit.frequency.days.contains(weekday);
      case 'custom':
        return habit.frequency.days.contains(weekday);
      case 'monthly':
        return habit.frequency.days.contains(today.day);
      default:
        return false;
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    await _notifications.cancel(habitId.hashCode);
    print('Cancelled notification for habit: $habitId');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> rescheduleAllHabits(List<Habit> habits) async {
    await cancelAllNotifications();
    for (final habit in habits) {
      await scheduleHabitReminder(habit);
    }
  }

  // Test notification method

}
