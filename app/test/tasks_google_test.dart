import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';
import 'package:socra_task/features/tasks/presentation/tasks_page.dart';

Future<ProviderContainer> _seeded() async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = TaskRepository(db);
  final inbox = await repo.ensureDefaultList();
  final work = await repo.createList('Work');
  await repo.createTask('Home chore', listId: inbox);
  await repo.createTask('Quarterly report', listId: work);
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );
  addTearDown(() {
    container.dispose();
    return db.close();
  });
  container.read(activeListProvider.notifier).state = inbox;
  return container;
}

Future<void> _pump(
    WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: TasksPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Only the active list tasks show; switcher swaps lists',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      expect(find.text('Home chore'), findsOneWidget);
      expect(find.text('Quarterly report'), findsNothing);

      // Switch to Work via the list menu.
      await tester.tap(find.byTooltip('Switch task list'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Work').last);
      await tester.pumpAndSettle();

      expect(find.text('Quarterly report'), findsOneWidget);
      expect(find.text('Home chore'), findsNothing);
    });
  });

  testWidgets('Subtasks expand indented under their parent',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      final repo = container.read(taskRepositoryProvider);
      final inbox = container.read(activeListProvider)!;
      final parent =
          await repo.createTask('Plan trip', listId: inbox);
      await repo.createTask('Book flights',
          listId: inbox, parentId: parent);
      await _pump(tester, container);

      // Hidden until expanded (tap the parent's chevron, the last one).
      await tester.tap(find.byTooltip('Show subtasks').last);
      await tester.pumpAndSettle();
      expect(find.text('Book flights'), findsOneWidget);
    });
  });

  testWidgets('Due chip shows date; overdue reads red',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      final repo = container.read(taskRepositoryProvider);
      final inbox = container.read(activeListProvider)!;
      final id = await repo.createTask('Urgent', listId: inbox);
      await repo.setDueDate(
          id, DateTime.now().subtract(const Duration(days: 1)));
      await _pump(tester, container);

      final chip = find.byTooltip('Edit due date').first;
      expect(chip, findsOneWidget);
      final chipText = tester
          .widgetList<Text>(find.descendant(
              of: chip, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .join();
      expect(chipText, isNotEmpty);
      final style = tester
          .widgetList<Text>(find.descendant(
              of: chip, matching: find.byType(Text)))
          .map((t) => t.style?.color)
          .first;
      expect(style, Theme.of(tester.element(chip)).colorScheme.error);
    });
  });

  testWidgets('Sort menu orders by due date',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      final repo = container.read(taskRepositoryProvider);
      final inbox = container.read(activeListProvider)!;
      final late = await repo.createTask('Later thing', listId: inbox);
      await repo.setDueDate(
          late, DateTime.now().add(const Duration(days: 9)));
      final soon = await repo.createTask('Soon thing', listId: inbox);
      await repo.setDueDate(
          soon, DateTime.now().add(const Duration(days: 1)));
      await _pump(tester, container);

      // Manual order: creation order (Home chore, Later, Soon).
      var order = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .length;
      expect(order, greaterThanOrEqualTo(3));

      await tester.tap(find.byTooltip('Sort tasks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('By date').last);
      await tester.pumpAndSettle();

      final titles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((s) => s.endsWith('thing'))
          .toList();
      expect(titles, ['Soon thing', 'Later thing']);
    });
  });
}
