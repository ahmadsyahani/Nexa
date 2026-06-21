import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    // Initialize Timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap here if needed
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'nexa_main_channel_custom',
          'Nexa Notifications Custom',
          channelDescription: 'General notifications for Nexa App',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          sound: RawResourceAndroidNotificationSound('nexa_sound'),
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'nexa_scheduled_channel_custom',
          'Nexa Scheduled Custom',
          channelDescription: 'Scheduled reminders for Nexa App',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('nexa_sound'),
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showPomodoroNotification({
    required int id,
    required String title,
    required String body,
    required int remainingSeconds,
  }) async {
    final int endTime =
        DateTime.now().millisecondsSinceEpoch + (remainingSeconds * 1000);

    AndroidNotificationDetails
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'nexa_pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Ongoing Pomodoro Timer for Dynamic/Origin Island',
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      usesChronometer: true,
      chronometerCountDown: true,
      when: endTime,
      autoCancel: false,
      showWhen: true,
      color: const Color(0xFFEF4444), // Primary color for visual
      colorized: true,
      category: AndroidNotificationCategory.stopwatch,
      // For some Chinese OEMs (Vivo/iQOO), specific categories and flags trigger the Origin Island
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: '$title  •  ',
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> cancelPomodoroNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
