import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/calendar/presentation/calendar_page.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

Future<ProviderContainer> _seeded() async {
  final db = AppDatabase(NativeDatabase.memory());
  final events = EventRepository(db);
  final now = DateTime.now();
  await events.createEvent(
    title: 'Team standup',
    start: DateTime(now.year, now.month, now.day, 9),
    end: DateTime(now.year, now.month, now.day, 10),
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

void main() {
  testWidgets('Options sheet lists calendars with visibility toggles',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Calendar options'));
      await tester.pumpAndSettle();

      final sheet = find.byType(BottomSheet);
      expect(
        find.descendant(of: sheet, matching: find.text('My calendar')),
        findsOneWidget,
      );
      expect(find.byType(Switch), findsWidgets);
      expect(find.text('Import .ics file'), findsOneWidget);
      expect(find.text('Subscribe via link'), findsOneWidget);
    });
  });

  testWidgets('Hiding a calendar removes its events from the agenda',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      expect(find.text('Team standup'), findsOneWidget);

      await tester.tap(find.byTooltip('Calendar options'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).first);
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Sheet still open; close it and check the agenda.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Team standup'), findsNothing);
    });
  });

  testWidgets('Subscribing with a bad link shows an inline error',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.byTooltip('Calendar options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Subscribe via link'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).at(0), 'Bogus');
      await tester.enterText(
          find.byType(TextField).at(1), 'not a url');
      await tester.tap(find.text('Subscribe'));
      await tester.pumpAndSettle();

      expect(find.textContaining('does not look like'), findsOneWidget);
    });
  });
}
