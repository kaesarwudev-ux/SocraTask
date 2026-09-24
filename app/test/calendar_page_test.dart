import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/calendar/presentation/calendar_page.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';

Future<ProviderContainer> _seeded() async {
  final db = AppDatabase(NativeDatabase.memory());
  final events = EventRepository(db);
  final tasks = TaskRepository(db);
  final now = DateTime.now();
  final today9 = DateTime(now.year, now.month, now.day, 9);
  await events.createEvent(
    title: 'Team standup',
    start: today9,
    end: today9.add(const Duration(minutes: 30)),
    location: 'Room 3',
  );
  final inbox = await tasks.ensureDefaultList();
  await tasks.createTask('File taxes', listId: inbox);
  await tasks.setDueDate(
    (await tasks.watchTasks().first)
        .singleWhere((t) => t.title == 'File taxes')
        .id,
    DateTime(now.year, now.month, now.day, 17),
  );
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
      child: const MaterialApp(home: CalendarPage()),
    ),
  );
  await tester.pumpAndSettle();
}


Future<void> _switchTo(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Change view'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Agenda lists events and task due-dates',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Schedule');
      expect(find.text('Team standup'), findsOneWidget);
      expect(find.text('File taxes'), findsOneWidget);
      expect(find.text('Room 3'), findsOneWidget);
    });
  });

  testWidgets('Day view shows timed block and now-line',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Day');
      await tester.pumpAndSettle();

      expect(find.text('Team standup'), findsOneWidget);
      // Now-line marker for today.
      expect(find.byKey(const Key('now-line')), findsOneWidget);
    });
  });

  testWidgets('FAB creates an event through the full editor',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Add event'));
      await tester.pumpAndSettle();
      expect(find.text('Event details'), findsOneWidget);
      // Title field inside the editor (not the top-bar search field).
      final titleField = find.descendant(
        of: find.byType(Scaffold).last,
        matching: find.byType(TextField),
      );
      await tester.enterText(titleField.first, 'Gym session');
      await tester.tap(find.text('Save'));
      // Save is async; let the stream echo arrive.
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Gym session'), findsOneWidget);
    });
  });

  testWidgets('Inline search finds the event and opens its editor',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, 'standup');
      await tester.pumpAndSettle();

      // Result appears in the dropdown (a ListTile; agenda rows are not
      // tiles); tapping opens the full editor.
      final result = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Team standup'),
      );
      expect(result, findsOneWidget);
      await tester.tap(result);
      await tester.pumpAndSettle();
      expect(find.text('Event details'), findsOneWidget);
    });
  });

  testWidgets('More actions menu lists the full action set',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Schedule');

      // Open the existing event through its detail bubble.
      await tester.tap(find.text('Team standup'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit event'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();

      for (final label in [
        'Print',
        'Delete',
        'Duplicate',
        'Publish event',
        'Change owner',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      // Recurrence instances don't exist yet: disabled with reason.
      final instance = find.text('Publish this instance of the event');
      expect(instance, findsOneWidget);
    });
  });

  testWidgets('Save and More actions share one height with spacing',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Add event'));
      await tester.pumpAndSettle();

      final saveBox = find.widgetWithText(FilledButton, 'Save');
      final saveSize = tester.getSize(saveBox);
      final more = find.byTooltip('More actions');
      expect(more, findsOneWidget);
      final moreSize = tester.getSize(more);
      expect((moreSize.height - saveSize.height).abs(), lessThan(1));
      // Gap between the two buttons (Save sits left of More actions).
      final saveRight =
          tester.getTopLeft(saveBox).dx + saveSize.width;
      final moreLeft = tester.getTopLeft(more).dx;
      expect(moreLeft - saveRight, greaterThanOrEqualTo(12));
    });
  });
}
