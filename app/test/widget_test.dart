import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/main.dart';

// runAsync everywhere: pages watch drift streams and drift's executor uses
// the real event loop; the fake-async test zone would otherwise report a
// pending timer at teardown.
Future<void> _pumpApp(WidgetTester tester) async {
  final db = AppDatabase(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const SocraTaskApp(),
    ),
  );
  await tester.pumpAndSettle();
  await db.close();
}

void main() {
  testWidgets('App boots to Dashboard with rail on tablet/desktop',
      (WidgetTester tester) async {
    await tester.runAsync(() => _pumpApp(tester));

    expect(find.text('Dashboard'), findsWidgets);
    // Custom sidebar rail: one hover-highlight row per destination.
    expect(find.byType(InkWell), findsWidgets);
  });

  testWidgets('Phone width uses bottom nav', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() => _pumpApp(tester));

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Tapping Tasks navigates to Tasks page',
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

      await tester.tap(find.byKey(const ValueKey('rail-pill-Tasks')));
      await tester.pumpAndSettle();

      expect(find.text('No tasks yet'), findsOneWidget);
      await db.close();
    });
  });

  testWidgets('App rail collapses to icons and expands back',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const SocraTaskApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Labeled pills while expanded.
      expect(find.byKey(const ValueKey('rail-pill-Dashboard')), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
      expect(
        tester.getSize(find.byKey(const ValueKey('app-rail'))).width,
        280,
      );

      await tester.tap(find.byTooltip('Collapse sidebar'));
      await tester.pumpAndSettle();

      // Rail narrows to icons; toggle flips.
      expect(
        tester.getSize(find.byKey(const ValueKey('app-rail'))).width,
        72,
      );
      expect(find.byTooltip('Expand sidebar'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('rail-pill-Dashboard')), findsOneWidget);

      await tester.tap(find.byTooltip('Expand sidebar'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('app-rail'))).width,
        280,
      );
      expect(find.text('Dashboard'), findsWidgets);
      await db.close();
    });
  });
}
