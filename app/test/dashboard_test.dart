import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/dashboard/presentation/dashboard_page.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';

void main() {
  testWidgets('Dashboard shows live open/done task counts',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = TaskRepository(db);
      final first = await repo.createTask('Open one');
      await repo.createTask('Open two');
      final done = await repo.createTask('Done one');
      await repo.completeTask(done);
      // Sanity: `first` is unused beyond creation; silence lints.
      expect(first, isNot(-1));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const MaterialApp(home: DashboardPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 open'), findsOneWidget);
      expect(find.text('1 done'), findsOneWidget);
      await db.close();
    });
  });
}
