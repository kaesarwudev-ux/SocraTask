import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/habits/data/habit_repository.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  test('reminder minutes persist and clear', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(
        name: 'Run', schedule: scheduleDaily());
    await repo.setReminder(id, 8 * 60);
    expect((await repo.getHabit(id)).reminderMinutes, 8 * 60);

    await repo.setReminder(id, null);
    expect((await repo.getHabit(id)).reminderMinutes, isNull);
  });

  test('next reminder today when time is ahead', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(
        name: 'Run', schedule: scheduleDaily());
    await repo.setReminder(id, 8 * 60);
    final habit = await repo.getHabit(id);

    // Monday 2026-09-21 07:00 -> today 08:00.
    expect(
      nextReminder(habit, DateTime(2026, 9, 21, 7)),
      DateTime(2026, 9, 21, 8),
    );
    // 09:00 -> tomorrow 08:00.
    expect(
      nextReminder(habit, DateTime(2026, 9, 21, 9)),
      DateTime(2026, 9, 22, 8),
    );
  });

  test('next reminder skips non-due days', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    // Mondays only.
    final id = await repo.createHabit(
      name: 'Gym',
      schedule: HabitSchedule.weekly(
          [true, false, false, false, false, false, false]),
    );
    await repo.setReminder(id, 18 * 60);
    final habit = await repo.getHabit(id);

    // Tuesday 2026-09-22 10:00 -> next Monday 2026-09-28 18:00.
    expect(
      nextReminder(habit, DateTime(2026, 9, 22, 10)),
      DateTime(2026, 9, 28, 18),
    );
  });

  test('no reminder configured returns null', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(
        name: 'Run', schedule: scheduleDaily());
    expect(
      nextReminder(await repo.getHabit(id), DateTime(2026, 9, 21, 7)),
      isNull,
    );
  });
}
