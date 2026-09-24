import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/habits/data/habit_repository.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

void main() {
  test('daily habit streak counts consecutive dones', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(name: 'Run', schedule: scheduleDaily());
    await repo.checkIn(id, _d(2026, 9, 18), done: true);
    await repo.checkIn(id, _d(2026, 9, 19), done: true);
    await repo.checkIn(id, _d(2026, 9, 20), done: true);

    expect(await repo.streak(id, _d(2026, 9, 20)), 3);
  });

  test('a miss breaks the streak; a skip does not', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(name: 'Run', schedule: scheduleDaily());
    await repo.checkIn(id, _d(2026, 9, 18), done: true);
    await repo.checkIn(id, _d(2026, 9, 19), done: true);
    // 9-20 missed entirely.
    expect(await repo.streak(id, _d(2026, 9, 21)), 0);

    final id2 = await repo.createHabit(name: 'Read', schedule: scheduleDaily());
    await repo.checkIn(id2, _d(2026, 9, 18), done: true);
    await repo.checkIn(id2, _d(2026, 9, 19), skip: true);
    await repo.checkIn(id2, _d(2026, 9, 20), done: true);
    expect(await repo.streak(id2, _d(2026, 9, 20)), 2);
  });

  test('weekly schedule only counts scheduled days', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    // Mon + Wed + Fri.
    final id = await repo.createHabit(
      name: 'Gym',
      schedule:
          HabitSchedule.weekly([true, false, true, false, true, false, false]),
    );
    // Mon 2026-09-21, Wed 23, Fri 25.
    await repo.checkIn(id, _d(2026, 9, 21), done: true);
    await repo.checkIn(id, _d(2026, 9, 23), done: true);
    await repo.checkIn(id, _d(2026, 9, 25), done: true);

    expect(await repo.streak(id, _d(2026, 9, 25)), 3);
    // Tuesday is not a gym day: not due, streak untouched.
    expect(repo.isDue(
        await repo.getHabit(id), _d(2026, 9, 22)), isFalse);
  });

  test('every-N-days schedule gates due dates', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(
      name: 'Water plants',
      schedule: HabitSchedule.everyNDays(2, _d(2026, 9, 20)),
    );
    final habit = await repo.getHabit(id);
    expect(repo.isDue(habit, _d(2026, 9, 20)), isTrue);
    expect(repo.isDue(habit, _d(2026, 9, 21)), isFalse);
    expect(repo.isDue(habit, _d(2026, 9, 22)), isTrue);
  });

  test('score rises on done and falls on missed due days', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(name: 'Run', schedule: scheduleDaily());
    final asOf = _d(2026, 9, 19);
    final fresh = await repo.score(id, asOf);
    await repo.checkIn(id, _d(2026, 9, 18), done: true);
    final afterDone = await repo.score(id, asOf);
    expect(afterDone, greaterThan(fresh));

    // Miss 9-19..9-25 (seven due days).
    final afterMiss = await repo.score(id, _d(2026, 9, 26));
    expect(afterMiss, lessThan(afterDone));
  });

  test('rename, recolor, delete habit', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    final id = await repo.createHabit(name: 'Run', schedule: scheduleDaily());
    await repo.updateHabit(id, name: 'Morning run', colorId: 3);
    final habit = await repo.getHabit(id);
    expect(habit.name, 'Morning run');
    expect(habit.colorId, 3);

    await repo.deleteHabit(id);
    expect(await repo.watchHabits().first, isEmpty);
  });
}
