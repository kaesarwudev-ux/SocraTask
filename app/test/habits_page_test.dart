import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/habits/data/habit_repository.dart';
import 'package:socra_task/features/habits/presentation/habits_page.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

DateTime _d(int y, int m, int d) => DateTime(y, m, d);

Future<ProviderContainer> _seeded() async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = HabitRepository(db);
  final run = await repo.createHabit(
      name: 'Run', schedule: scheduleDaily());
  await repo.checkIn(run, _d(2026, 9, 19), done: true);
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );
  addTearDown(() {
    container.dispose();
    return db.close();
  });
  return container;
}

Future<void> _pump(
    WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HabitsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Habit rows show streak and today check',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      expect(find.text('Run'), findsOneWidget);
      // Today check circle present for the open habit.
      expect(find.byTooltip('Mark today done'), findsWidgets);
    });
  });

  testWidgets('Tapping today check completes it',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Mark today done').first);
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Checked state flips the tooltip.
      expect(find.byTooltip('Mark today done'), findsNothing);
    });
  });

  testWidgets('Add dialog creates a weekly habit',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Add habit'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField).first, 'Gym sessions');
      // Pick the weekly schedule.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly days').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Gym sessions'), findsOneWidget);
    });
  });

  testWidgets('Detail sheet shows stats and deletes',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.text('Run'));
      await tester.pumpAndSettle();
      expect(find.text('Current streak'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete habit'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ));
      // Two routes pop in succession (dialog, then sheet): settle with
      // plain pumps since settle trips on the disposed animation.
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Run'), findsNothing);
    });
  });

  testWidgets('Reminder can be set from the dialog and shows in detail',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Add habit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Meditate');
      // Reminder row offers Set.
      expect(find.text('Reminder: Off'), findsOneWidget);
      await tester.tap(find.text('Set'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Meditate'), findsOneWidget);
      await tester.tap(find.text('Meditate'));
      await tester.pumpAndSettle();
      // 8:00 default surfaces in the stats.
      expect(find.textContaining('8:'), findsWidgets);
    });
  });
}
