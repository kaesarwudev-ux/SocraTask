import 'package:socra_task/core/data/database.dart';

/// Flexible schedule (Loop-style). Only the fields for [kind] matter.
class HabitSchedule {
  const HabitSchedule.daily()
      : kind = 'daily',
        weeklyDays = 127,
        timesPerWeek = 1,
        intervalDays = 1,
        anchor = null;

  HabitSchedule.weekly(List<bool> days)
      : kind = 'weekly',
        weeklyDays = _bits(days),
        timesPerWeek = 1,
        intervalDays = 1,
        anchor = null;

  const HabitSchedule.xPerWeek(this.timesPerWeek)
      : kind = 'xPerWeek',
        weeklyDays = 127,
        intervalDays = 1,
        anchor = null;

  const HabitSchedule.everyNDays(this.intervalDays, DateTime anchorDate)
      : kind = 'everyNDays',
        weeklyDays = 127,
        timesPerWeek = 1,
        anchor = anchorDate;

  final String kind;
  final int weeklyDays;
  final int timesPerWeek;
  final int intervalDays;
  final DateTime? anchor;

  static int _bits(List<bool> days) {
    assert(days.length == 7);
    var bits = 0;
    for (var i = 0; i < 7; i++) {
      if (days[i]) bits |= (1 << i);
    }
    return bits;
  }
}

HabitSchedule scheduleDaily() => const HabitSchedule.daily();

DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

/// Pure schedule check shared by the repository, UI and reminders.
bool habitIsDue(Habit habit, DateTime date) {
  final day = _midnight(date);
  switch (habit.kind) {
    case 'daily':
    case 'xPerWeek':
      return true;
    case 'weekly':
      final bit = (day.weekday - 1) % 7;
      return (habit.weeklyDays & (1 << bit)) != 0;
    case 'everyNDays':
      final anchor = _midnight(habit.anchor);
      if (day.isBefore(anchor)) return false;
      final interval =
          habit.intervalDays <= 0 ? 1 : habit.intervalDays;
      return day.difference(anchor).inDays % interval == 0;
    default:
      return true;
  }
}

/// Next occurrence of the habit's daily reminder at/after [now],
/// skipping non-due days (30-day lookahead). Null when no reminder is
/// configured or nothing is due in window.
DateTime? nextReminder(Habit habit, DateTime now) {
  final minutes = habit.reminderMinutes;
  if (minutes == null) return null;
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  for (var i = 0; i < 30; i++) {
    final day = _midnight(now).add(Duration(days: i));
    if (!habitIsDue(habit, day)) continue;
    final at =
        DateTime(day.year, day.month, day.day, hour, minute);
    if (!at.isBefore(now)) return at;
  }
  return null;
}
