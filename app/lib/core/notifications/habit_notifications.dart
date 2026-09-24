import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:socra_task/features/habits/data/habit_repository.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local habit reminders. Everything stays on-device: daily alarms are
/// scheduled with the OS (exact where granted), no server involved.
///
/// Limits (documented, not hidden):
/// - Reboots do NOT re-arm alarms yet (needs a native BOOT_COMPLETED
///   receiver). Opening the app re-arms everything.
/// - Only the next 3 due occurrences per habit are queued.
class HabitNotifications {
  HabitNotifications._();

  static final HabitNotifications instance = HabitNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  static const _channel = AndroidNotificationChannel(
    'socra_habits',
    'Habit reminders',
    description: 'Daily nudges for your habits',
    importance: Importance.high,
  );

  /// Safe to call anywhere (tests included): failures are swallowed and
  /// reported as false since plugins have no platform channels in tests.
  Future<bool> init() async {
    if (_ready) return true;
    try {
      tzdata.initializeTimeZones();
      try {
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Etc/UTC'));
      }
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      const linux = LinuxInitializationSettings(
          defaultActionName: 'Open SocraTask');
      await _plugin.initialize(
        settings: const InitializationSettings(
            android: android, iOS: darwin, macOS: darwin, linux: linux),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _ready = true;
      return true;
    } catch (e) {
      debugPrint('HabitNotifications.init failed: $e');
      return false;
    }
  }

  /// Recomputes every habit's queued alarms from scratch. Call on app
  /// start and after any habit/check-in/reminder change.
  Future<void> rescheduleAll(HabitRepository repo) async {
    if (!await init()) return;
    try {
      await _plugin.cancelAll();
      final habits = await repo.watchHabits().first;
      final now = DateTime.now();
      for (final habit in habits) {
        var cursor = now;
        for (var i = 0; i < 3; i++) {
          final next = nextReminder(habit, cursor);
          if (next == null) break;
          await _plugin.zonedSchedule(
            id: _idFor(habit.id, next),
            scheduledDate: tz.TZDateTime.from(next, tz.local),
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(),
              linux: const LinuxNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            title: habit.name,
            body: 'Time for ${habit.name}',
          );
          cursor = next.add(const Duration(minutes: 1));
        }
      }
    } catch (e) {
      debugPrint('HabitNotifications.rescheduleAll failed: $e');
    }
  }

  Future<void> cancelHabit(int habitId) async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id ~/ 100000 == habitId) {
          await _plugin.cancel(id: request.id);
        }
      }
    } catch (e) {
      debugPrint('HabitNotifications.cancelHabit failed: $e');
    }
  }

  static int _idFor(int habitId, DateTime at) =>
      habitId * 100000 +
      (at.millisecondsSinceEpoch ~/ 60000) % 100000;
}
