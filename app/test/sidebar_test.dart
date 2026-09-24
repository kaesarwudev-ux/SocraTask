import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/main.dart';

void main() {
  test('Light theme is creamy with a muted eco-green accent', () {
    final scheme = SocraTheme.light().colorScheme;
    expect(scheme.surface, const Color(0xFFFAF6ED));
    expect(scheme.primary, const Color(0xFF55825C));
  });

  testWidgets('Selected rail row is green-tinted with a green icon',
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

      // Dashboard is the selected branch on boot: its rail icon is green.
      // (The page body reuses the same icon, so check the set.)
      final dashIcons = tester
          .widgetList<Icon>(find.byIcon(Icons.dashboard_outlined))
          .toList();
      expect(dashIcons, isNotEmpty);
      expect(
        dashIcons.any((i) => i.color == const Color(0xFF55825C)),
        isTrue,
      );

      // Unselected rows use the default on-surface color.
      final idleIcon = tester.widget<Icon>(
        find.byIcon(Icons.check_circle_outlined),
      );
      expect(idleIcon.color, isNot(const Color(0xFF55825C)));
      await db.close();
    });
  });

  testWidgets('Rail rows highlight the whole row on hover',
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

      // Every destination row is an InkWell with a hover tint so the
      // entire row (icon + label) highlights — framework animates it.
      final wells = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .where((w) => w.hoverColor != null)
          .toList();
      expect(wells.length, greaterThanOrEqualTo(4));
      await db.close();
    });
  });

  testWidgets('Wide rail shows one pill per destination (icon + label)',
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

      for (final label in ['Dashboard', 'Tasks', 'Calendar', 'Sticky Notes']) {
        expect(find.byKey(ValueKey('rail-pill-$label')), findsOneWidget);
      }
      await db.close();
    });
  });
}
