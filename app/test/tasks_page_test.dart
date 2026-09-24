import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';
import 'package:socra_task/features/tasks/presentation/tasks_page.dart';
import 'package:socra_task/main.dart';

Future<AppDatabase> _seededDb() async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = TaskRepository(db);
  await repo.createTask('Open task');
  final doneId = await repo.createTask('Finished task');
  await repo.completeTask(doneId);
  return db;
}

Future<void> _pumpTasks(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: TasksPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Tasks split into To do and Done sections',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await _seededDb();
      await _pumpTasks(tester, db);
      expect(find.textContaining('To do'), findsOneWidget);
      expect(find.textContaining('Done'), findsOneWidget);
      await db.close();
    });
  });

  testWidgets('Completing moves the task down with strikethrough',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await _seededDb();
      await _pumpTasks(tester, db);

      await tester.tap(find.byType(Checkbox).first);
      // The complete ceremony runs on real time inside runAsync.
      await Future.delayed(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Moved to Done, struck through (effective style via the animated
      // ancestor — Text.style itself stays null).
      final struck = tester
          .elementList(find.text('Open task'))
          .map((e) => DefaultTextStyle.of(e).style.decoration);
      expect(struck, isNotEmpty);
      expect(struck.any((d) => d == TextDecoration.lineThrough), isTrue);
      await db.close();
    });
  });

  testWidgets('Delete pops a centered confirm, then pops out',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await _seededDb();
      await _pumpTasks(tester, db);

      await tester.tap(find.byTooltip('Delete task').first);
      await tester.pumpAndSettle();
      expect(find.text('Delete this task?'), findsOneWidget);

      await tester.tap(find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Delete'),
      ));
      // Pop-out runs on real time inside runAsync.
      await Future.delayed(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Open task'), findsNothing);
      await db.close();
    });
  });

  testWidgets('Theme toggle flips light and dark',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const SocraTaskApp(),
        ),
      );
      await tester.pumpAndSettle();

      Brightness now() =>
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

      await tester.tap(find.byTooltip('Switch to dark theme'));
      await tester.pumpAndSettle();
      expect(now(), Brightness.dark);

      await tester.tap(find.byTooltip('Switch to light theme'));
      await tester.pumpAndSettle();
      expect(now(), Brightness.light);
      await db.close();
    });
  });
}
