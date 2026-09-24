import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/notes/data/note_repository.dart';
import 'package:socra_task/features/notes/presentation/notes_page.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

Future<ProviderContainer> _seeded() async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = NoteRepository(db);
  await repo.createNote(title: 'Shopping', body: 'Milk and eggs');
  final pinned =
      await repo.createNote(title: 'Pinned idea', body: 'Build this');
  await repo.setPinned(pinned, true);
  final label = await repo.createLabel('Personal');
  final labeled = await repo.createNote(title: 'Journal', body: 'Today…');
  await repo.setNoteLabel(labeled, label, true);
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
      child: const MaterialApp(home: NotesPage()),
    ),
  );
  await tester.pumpAndSettle();
}

Offset _center(WidgetTester tester, String text) =>
    tester.getCenter(find.text(text).first);

void main() {
  testWidgets('Pinned notes render above the rest',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      expect(_center(tester, 'Pinned idea').dy,
          lessThan(_center(tester, 'Shopping').dy));
    });
  });

  testWidgets('Search filters the grid', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.enterText(find.byType(TextField).first, 'milk');
      await tester.pumpAndSettle();

      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Journal'), findsNothing);
    });
  });

  testWidgets('Archive moves the note out; Archive nav shows it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      // Open the note editor and archive it.
      await tester.tap(find.text('Shopping'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Archive note'));
      await tester.pumpAndSettle();

      expect(find.text('Shopping'), findsNothing);
      await tester.tap(find.text('Archive').last);
      await tester.pumpAndSettle();
      expect(find.text('Shopping'), findsOneWidget);
    });
  });

  testWidgets('Trash, restore and empty trash',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.text('Shopping'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete note'));
      await tester.pumpAndSettle();
      expect(find.text('Shopping'), findsNothing);

      await tester.tap(find.text('Trash').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shopping'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      final notesNav = find.ancestor(
        of: find.text('Sticky Notes'),
        matching: find.byType(InkWell),
      );
      expect(notesNav, findsOneWidget);
      await tester.tap(notesNav);
      await tester.pumpAndSettle();
      expect(find.text('Shopping'), findsOneWidget);
    });
  });

  testWidgets('Checklist items toggle inside the editor',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final container = await _seeded();
      final repo = NoteRepository(
          container.read(databaseProvider));
      final id = await repo.createNote(title: 'Packing');
      await repo.addChecklistItem(id, 'Socks');
      await _pump(tester, container);

      await tester.tap(find.text('Packing'));
      await tester.pumpAndSettle();
      final inDialog = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Socks'),
      );
      expect(inDialog, findsOneWidget);

      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Checkbox),
      ));
      await tester.pumpAndSettle();
      final box = tester.widget<Checkbox>(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Checkbox),
      ));
      expect(box.value, isTrue);
    });
  });

  testWidgets('Label nav filters the grid', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final container = await _seeded();
      await _pump(tester, container);

      await tester.tap(find.text('Personal').last);
      await tester.pumpAndSettle();
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('Shopping'), findsNothing);
    });
  });
}
