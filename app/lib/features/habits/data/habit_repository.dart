import 'package:drift/drift.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/habits/data/habit_schedule.dart';
export 'package:socra_task/features/habits/data/habit_schedule.dart';

/// Local-first habits. Score is a simplified Loop-style strength in
/// [0,1]: +0.15 per done, −0.03 per missed due day, skips neutral,
/// computed deterministically from history (no stored drift).
class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;

  Stream<List<Habit>> watchHabits() {
    return (_db.select(_db.habits)
          ..orderBy([(h) => OrderingTerm.desc(h.createdAt)]))
        .watch();
  }

  Stream<List<HabitCheck>> watchChecks(int id) {
    return (_db.select(_db.habitChecks)
          ..where((c) => c.habitId.equals(id))
          ..orderBy([(c) => OrderingTerm.desc(c.day)]))
        .watch();
  }

  Future<Habit> getHabit(int id) {
    return (_db.select(_db.habits)..where((h) => h.id.equals(id)))
        .getSingle();
  }

  Future<int> createHabit({
    required String name,
    required HabitSchedule schedule,
    String description = '',
    int colorId = 0,
  }) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Habit name is required');
    return _db.into(_db.habits).insert(
          HabitsCompanion.insert(
            name: clean,
            description: Value(description),
            colorId: Value(colorId),
            kind: Value(schedule.kind),
            weeklyDays: Value(schedule.weeklyDays),
            timesPerWeek: Value(schedule.timesPerWeek),
            intervalDays: Value(schedule.intervalDays),
            anchor: Value(schedule.anchor ?? DateTime.now()),
          ),
        );
  }

  Future<void> updateHabit(
    int id, {
    String? name,
    String? description,
    int? colorId,
  }) async {    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        description: description == null
            ? const Value.absent()
            : Value(description),
        colorId:
            colorId == null ? const Value.absent() : Value(colorId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateSchedule(int id, HabitSchedule schedule) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        kind: Value(schedule.kind),
        weeklyDays: Value(schedule.weeklyDays),
        timesPerWeek: Value(schedule.timesPerWeek),
        intervalDays: Value(schedule.intervalDays),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setReminder(int id, int? minutesAfterMidnight) async {
    if (minutesAfterMidnight != null &&
        (minutesAfterMidnight < 0 || minutesAfterMidnight >= 24 * 60)) {
      throw ArgumentError('Reminder must be a time of day in minutes');
    }
    await (_db.update(_db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
          reminderMinutes: Value(minutesAfterMidnight),
          updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteHabit(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.habitChecks)
            ..where((c) => c.habitId.equals(id)))
          .go();
      await (_db.delete(_db.habits)..where((h) => h.id.equals(id))).go();
    });
  }

  /// Marks a day done, skipped, or clears it (both false). Upserts.
  Future<void> checkIn(
    int id,
    DateTime day, {
    bool done = false,
    bool skip = false,
  }) async {
    await _db.into(_db.habitChecks).insertOnConflictUpdate(
          HabitChecksCompanion.insert(
            habitId: id,
            day: _midnight(day),
            done: Value(done),
            skipped: Value(skip),
          ),
        );
  }

  Future<Map<DateTime, HabitCheck>> checksFor(
      int id, DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.habitChecks)
          ..where((c) =>
              c.habitId.equals(id) &
              c.day.isBiggerOrEqualValue(_midnight(from)) &
              c.day.isSmallerOrEqualValue(_midnight(to))))
        .get();
    return {for (final r in rows) r.day: r};
  }

  bool isDue(Habit habit, DateTime date) =>
      habitIsDue(habit, date);

  DateTime _midnight(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// Consecutive due-days done as of [asOf] (skips and off-days are
  /// neutral — they neither extend nor break the run).
  Future<int> streak(int id, DateTime asOf) async {
    final habit = await getHabit(id);
    final start = _midnight(asOf).subtract(const Duration(days: 730));
    final checks = await checksFor(id, start, asOf);
    var run = 0;
    var day = _midnight(asOf);
    for (var i = 0; i < 730; i++) {
      if (!isDue(habit, day)) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      final check = checks[day];
      if (check == null || (!check.done && !check.skipped)) break;
      if (check.done) run++;
      day = day.subtract(const Duration(days: 1));
    }
    return run;
  }

  /// Strength in [0,1] over due days before [asOf] (exclusive of that
  /// date — today is still in progress, never a miss).
  Future<double> score(int id, [DateTime? asOf]) async {
    final habit = await getHabit(id);
    final end = _midnight(asOf ?? DateTime.now());
    final rows = await (_db.select(_db.habitChecks)
          ..where((c) => c.habitId.equals(id))
          ..orderBy([(c) => OrderingTerm.asc(c.day)]))
        .get();
    if (rows.isEmpty) return 0.0;
    var cursor = _midnight(rows.first.day);
    var value = 0.0;
    var guard = 0;
    while (cursor.isBefore(end) && guard++ < 730) {
      if (isDue(habit, cursor)) {
        final hit = rows.where((r) =>
            r.day.year == cursor.year &&
            r.day.month == cursor.month &&
            r.day.day == cursor.day);
        if (hit.isNotEmpty && hit.single.done) {
          value = (value + 0.15).clamp(0.0, 1.0);
        } else if (hit.isEmpty ||
            (!hit.single.done && !hit.single.skipped)) {
          value = (value - 0.03).clamp(0.0, 1.0);
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return value;
  }
}
