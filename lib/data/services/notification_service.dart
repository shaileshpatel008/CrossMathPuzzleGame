import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'settings_service.dart';

/// Daily-challenge reminder (Settings › Notifications).
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  static const _reminderId = 7001;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<NotificationService> init() async {
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
      final s = SettingsService.to;
      everAll([s.reminder, s.reminderHour, s.reminderMinute], (_) => sync());
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
    return this;
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final a = await android?.requestNotificationsPermission();
    final i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return (a ?? true) && (i ?? true);
  }

  /// (Re)schedules or cancels the daily reminder from current settings.
  Future<void> sync() async {
    if (!_ready) return;
    final s = SettingsService.to;
    await _plugin.cancel(id: _reminderId);
    if (!s.reminder.value) return;
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      s.reminderHour.value,
      s.reminderMinute.value,
    );
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: "Today's Daily Challenge is ready",
      body: 'Keep your streak alive — a fresh puzzle is waiting.',
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily reminder',
          channelDescription: 'A daily nudge to play the Daily Challenge',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
