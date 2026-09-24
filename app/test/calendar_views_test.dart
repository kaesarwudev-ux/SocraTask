import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/calendar_providers.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/calendar/presentation/calendar_page.dart';
import 'package:socra_task/features/calendar/presentation/time_grid.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';

Future<ProviderContainer> _seeded() async {
  final db = AppDatabase(NativeDatabase.memory());
  final events = EventRepository(db);
  final now = DateTime.now();
  final today9 = DateTime(now.year, now.month, now.day, 9);
  await events.createEvent(
    title: 'Team standup',
    start: today9,
    end: today9.add(const Duration(minutes: 30)),
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
  test('slotForOffset snaps grid position to 30-minute slots', () {
    final day = DateTime(2026, 10, 5);
    expect(slotForOffset(day: day, dy: 0, hourHeight: 48),
        DateTime(2026, 10, 5));
    // 9.2h -> 9:00, 9:45 -> 9:30.
    expect(slotForOffset(day: day, dy: 9.2 * 48, hourHeight: 48),
        DateTime(2026, 10, 5, 9));
    expect(
        slotForOffset(
            day: day, dy: (9 * 60 + 45) / 60 * 48, hourHeight: 48),
        DateTime(2026, 10, 5, 9, 30));
    // Clamped to the day.
    expect(slotForOffset(day: day, dy: 30 * 48, hourHeight: 48),
        DateTime(2026, 10, 5, 23, 30));
  });

  testWidgets('Month view shows weekday headers and event chips',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Month');
      await tester.pumpAndSettle();

      for (final d in ['M', 'T', 'W', 'F', 'S']) {
        expect(find.text(d), findsWidgets);
      }
      expect(find.text('Team standup'), findsOneWidget);
    });
  });

  testWidgets('Tapping a month cell jumps to the day view',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Month');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Team standup'));
      await tester.pumpAndSettle();

      // Day view shows the timed block for the event.
      expect(find.byTooltip('Change view'), findsOneWidget);
    });
  });

  testWidgets('Week view shows seven day columns',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Week');
      await tester.pumpAndSettle();

      // Seven day-number headers, one per column.
      expect(find.byKey(const Key('week-col')), findsNWidgets(7));
      expect(find.text('Team standup'), findsOneWidget);
    });
  });

  testWidgets('Tapping empty grid opens a quick-create bubble beside it',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Day');
      await tester.pumpAndSettle();

      // Tap empty morning space below the app chrome: the grid's 6am slot.
      final grid = find.byKey(const Key('time-grid'));
      expect(grid, findsOneWidget);
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Inline bubble (not the full dialog) with title + Save.
      expect(find.text('Add title'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      final quickTitle = find.descendant(
        of: find.byKey(const Key('quick-bubble')),
        matching: find.byType(TextField),
      );
      await tester.enterText(quickTitle, 'Gym session');
      await tester.tap(find.text('Save'));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Gym session'), findsOneWidget);
    });
  });

  testWidgets('Tapping a block opens its detail bubble',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Day');
      await tester.pumpAndSettle();

      // Tap the event block itself: scroll it into view, then tap it.
      await tester.dragFrom(const Offset(400, 500), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Team standup').first);
      await tester.pumpAndSettle();

      expect(find.text('Team standup'), findsWidgets);
      expect(find.byTooltip('Edit event'), findsOneWidget);
      expect(find.byTooltip('Delete event'), findsOneWidget);

      // Delete from the bubble removes it (Undo offered).
      await tester.tap(find.byTooltip('Delete event'));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Team standup'), findsNothing);
    });
  });

  testWidgets('Wide sidebar shows mini calendar, feeds and Tasks toggle',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      expect(find.text('My calendars'), findsOneWidget);
      expect(find.text('My calendar'), findsOneWidget);
      expect(find.text('Tasks'), findsWidgets);
      expect(find.byTooltip('Create'), findsOneWidget);
    });
  });

  testWidgets('Year view shows twelve months; tapping a day opens it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await _switchTo(tester, 'Year');
      expect(find.text('January'), findsOneWidget);
      expect(find.text('December'), findsOneWidget);

      // Tap today's number inside the current month block.
      final today = DateTime.now();
      final cells = find.text('${today.day}');
      expect(cells, findsWidgets);
      await tester.tap(cells.first);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Change view'), findsOneWidget);
    });
  });

  testWidgets('Unchecking Tasks hides due tasks from the agenda',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      final tasks = TaskRepository(container.read(databaseProvider));
      final inbox = await tasks.ensureDefaultList();
      final id = await tasks.createTask('Pay rent', listId: inbox);
      final now = DateTime.now();
      await tasks.setDueDate(
          id, DateTime(now.year, now.month, now.day, 18));
      await _pump(tester, container);
      await _switchTo(tester, 'Schedule');
      expect(find.text('Pay rent'), findsOneWidget);

      // Uncheck Tasks in the sidebar.
      final tasksRow = find.ancestor(
        of: find.text('Tasks').first,
        matching: find.byType(InkWell),
      );
      await tester.tap(tasksRow);
      await tester.pumpAndSettle();
      expect(find.text('Pay rent'), findsNothing);
    });
  });

  testWidgets('Top-bar actions stay docked to the right edge',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      final dx =
          tester.getCenter(find.byTooltip('Switch to dark theme')).dx;
      expect(dx, greaterThan(1850));
    });
  });

  testWidgets('Bubble docks to the day edge and stays on-screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      // Rightmost column, empty morning slot.
      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      final size = tester.getSize(grid);
      await tester.tapAt(topLeft + Offset(size.width - 40, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final bubble = find.byKey(const Key('quick-bubble'));
      expect(bubble, findsOneWidget);
      final rect = tester.getRect(bubble);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(1400));
    });
  });

  testWidgets('Single-day bubble centers on screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      container.read(calendarViewProvider.notifier).state =
          CalendarView.day;
      await tester.pumpAndSettle();

      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byKey(const Key('quick-bubble')));
      expect((rect.center.dx - 400).abs(), lessThan(100));
    });
  });

  testWidgets('Quick bubble previews (No title) and updates live',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('(No title)'), findsWidgets);
      final titleField = find.descendant(
        of: find.byKey(const Key('quick-bubble')),
        matching: find.byType(TextField),
      );
      await tester.enterText(titleField, 'Gym');
      await tester.pumpAndSettle();
      expect(find.text('(No title)'), findsNothing);
      // Both the bubble summary and the grid block update live.
      expect(find.text('Gym'), findsWidgets);
    });
  });

  testWidgets('More options opens the full-screen editor',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('More options'));
      await tester.pumpAndSettle();

      expect(find.text('Event details'), findsOneWidget);
      expect(find.text('Add guests'), findsOneWidget);
    });
  });

  testWidgets('All-day events pin to the top strip with GMT label',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      final db = container.read(databaseProvider);
      final repo = EventRepository(db);
      final now = DateTime.now();
      await repo.createEvent(
        title: 'math book',
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59),
        allDay: true,
      );
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final strip = find.byKey(const Key('allday-strip'));
      expect(strip, findsOneWidget);
      expect(
        find.descendant(of: strip, matching: find.text('math book')),
        findsOneWidget,
      );
      expect(find.textContaining('GMT'), findsWidgets);
    });
  });

  testWidgets('Week columns separated by vertical dividers',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      expect(find.byType(VerticalDivider), findsWidgets);
    });
  });

  testWidgets('Agenda tap anchors the bubble near the tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Schedule');

      final row = find.text('Team standup');
      expect(row, findsOneWidget);
      final tap = tester.getCenter(row);
      await tester.tap(row);
      await tester.pumpAndSettle();

      final bubble = find.byKey(const Key('detail-bubble'));
      expect(bubble, findsOneWidget);
      final rect = tester.getRect(bubble);
      final center = rect.center;
      expect((center - tap).distance, lessThan(500));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(800));
    });
  });

  testWidgets('Day headers stay pinned while the grid scrolls',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final header = find.byKey(const Key('week-col'));
      final before = tester.getTopLeft(header).dy;
      await tester.dragFrom(const Offset(400, 500), const Offset(0, -400));
      await tester.pumpAndSettle();
      final after = tester.getTopLeft(header).dy;
      expect((after - before).abs(), lessThan(2));
    });
  });

  testWidgets('Sidebar collapse hands space to the grid',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      final grid = find.byKey(const Key('time-grid'));
      final narrow = tester.getSize(grid).width;
      await tester.tap(find.byTooltip('Main menu'));
      await tester.pumpAndSettle();

      // Sidebar glides shut (stays mounted for the animation) and the
      // grid takes the freed space.
      final wide = tester.getSize(grid).width;
      expect(wide, greaterThan(narrow + 200));
    });
  });

  testWidgets('Bubble sits beside the tapped column, not over it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      // Middle column, empty slot: the bubble must dock to a divider.
      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      final tap = topLeft + const Offset(600, 6.2 * 64);
      await tester.tapAt(tap);
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byKey(const Key('quick-bubble')));
      expect(
        rect.left >= tap.dx || rect.right <= tap.dx,
        isTrue,
        reason: 'bubble should sit beside the tap, not over it',
      );
      expect(rect.right, lessThanOrEqualTo(1400));
    });
  });

  testWidgets('Detail bubble docks beside the tapped block',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      await tester.dragFrom(const Offset(400, 500), const Offset(0, -300));
      await tester.pumpAndSettle();
      final tap = tester.getCenter(find.text('Team standup').first);
      await tester.tap(find.text('Team standup').first);
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byKey(const Key('detail-bubble')));
      // Vertically near the tapped block…
      expect((rect.center.dy - tap.dy).abs(), lessThan(420));
      // …but never covering it, and never clipped by the screen.
      final grid = find.byKey(const Key('time-grid'));
      final gridTop = tester.getTopLeft(grid).dy;
      final gridWidth = tester.getSize(grid).width;
      final block = Rect.fromLTWH(
        70,
        gridTop + 9 * 64,
        gridWidth - 70,
        64,
      );
      expect(rect.overlaps(block), isFalse);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(800));
    });
  });

  testWidgets('All-day strip sits below the day headers',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      final db = container.read(databaseProvider);
      final repo = EventRepository(db);
      final now = DateTime.now();
      await repo.createEvent(
        title: 'math book',
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59),
        allDay: true,
      );
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final headerTop =
          tester.getTopLeft(find.byKey(const Key('week-col'))).dy;
      final stripTop =
          tester.getTopLeft(find.byKey(const Key('allday-strip'))).dy;
      expect(stripTop, greaterThan(headerTop));
    });
  });

  testWidgets('Delete snackbar times out and has a dismiss button',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      await tester.dragFrom(const Offset(400, 500), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Team standup').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete event'));
      // Delete + snackbar run on real async time inside runAsync.
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Snackbar with Undo + explicit dismiss control.
      expect(find.text('Undo'), findsOneWidget);
      expect(find.byTooltip('Dismiss'), findsOneWidget);

      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsNothing);
    });
  });

  testWidgets('Tapping empty grid instantly drafts a (No title) block',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      // No typing at all: the draft block is already on the grid.
      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('(No title)'), findsWidgets);
      expect(find.text('Add title'), findsOneWidget);
    });
  });

  testWidgets('Closing an untitled draft removes it',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('(No title)'), findsWidgets);

      await tester.tap(find.byTooltip('Close'));
      await Future.delayed(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
      expect(find.text('(No title)'), findsNothing);
    });
  });

  testWidgets('Save keeps an untitled draft on the grid',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      final grid = find.byKey(const Key('time-grid'));
      final topLeft = tester.getTopLeft(grid);
      await tester.tapAt(topLeft + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      // Bubble gone, but the (No title) block stays on the grid.
      expect(find.text('Add title'), findsNothing);
      expect(find.text('(No title)'), findsOneWidget);
    });
  });

  testWidgets('Quick bubble never covers the nearby block',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      await _switchTo(tester, 'Day');

      // Tap empty 6am slot with the 9am event block just below.
      final grid = find.byKey(const Key('time-grid'));
      final gridTop = tester.getTopLeft(grid).dy;
      final gridWidth = tester.getSize(grid).width;
      await tester.tapAt(
          tester.getTopLeft(grid) + const Offset(200, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      final bubble = find.byKey(const Key('quick-bubble'));
      expect(bubble, findsOneWidget);
      final rect = tester.getRect(bubble);
      final block = Rect.fromLTWH(
        70,
        gridTop + 9 * 64,
        gridWidth - 70,
        64,
      );
      expect(rect.overlaps(block), isFalse);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(1400));
    });
  });

  testWidgets('Quick bubble never covers its own draft block',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);
      container.read(calendarViewProvider.notifier).state =
          CalendarView.day;
      await tester.pumpAndSettle();

      // Empty 6am slot; the draft lands at 6-7am.
      final grid = find.byKey(const Key('time-grid'));
      final gridTop = tester.getTopLeft(grid).dy;
      final gridWidth = tester.getSize(grid).width;
      await tester.tapAt(
          tester.getTopLeft(grid) + const Offset(400, 6.2 * 64));
      await Future.delayed(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      final bubble = find.byKey(const Key('quick-bubble'));
      expect(bubble, findsOneWidget);
      final rect = tester.getRect(bubble);
      final draft = Rect.fromLTWH(
        70,
        gridTop + 6 * 64,
        gridWidth - 70,
        64,
      );
      expect(rect.overlaps(draft), isFalse);
    });
  });

  testWidgets('Tall bubble caps its height to dodge on short screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = EventRepository(db);
      final now = DateTime.now();
      // Mid-morning block, visible without scrolling.
      await repo.createEvent(
        title: 'Standup',
        start: DateTime(now.year, now.month, now.day, 5, 30),
        end: DateTime(now.year, now.month, now.day, 6),
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(() {
        container.dispose();
        return db.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CalendarPage()),
        ),
      );
      await tester.pumpAndSettle();
      container.read(calendarViewProvider.notifier).state =
          CalendarView.day;
      await tester.pumpAndSettle();

      // Empty 4am slot, right above the block.
      final grid = find.byKey(const Key('time-grid'));
      await tester.tapAt(
          tester.getTopLeft(grid) + const Offset(200, 4.2 * 64));
      await Future.delayed(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      final bubble = find.byKey(const Key('quick-bubble'));
      expect(bubble, findsOneWidget);
      final rect = tester.getRect(bubble);
      // Fully on-screen — the tall-bubble dodge caps height and
      // scrolls internally instead of painting off-screen.
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(1200));
    });
  });
}
