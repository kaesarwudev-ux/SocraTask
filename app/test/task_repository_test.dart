import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  test('createTask appears in watchTasks', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);

    await repo.createTask('Buy milk');

    await expectLater(
      repo.watchTasks(),
      emitsThrough(
        predicate<List<Task>>((tasks) =>
            tasks.any((t) => t.title == 'Buy milk' && !t.done)),
      ),
    );
  });

  test('createTask enqueues exactly one outbox op', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);

    await repo.createTask('Buy milk');

    final ops = await repo.pendingOps();
    expect(ops, hasLength(1));
    expect(ops.single.kind, 'task');
    expect(ops.single.op, 'create');
  });

  test('completeTask marks done and keeps the row', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);

    final id = await repo.createTask('Buy milk');
    await repo.completeTask(id);

    await expectLater(
      repo.watchTasks(),
      emitsThrough(
        predicate<List<Task>>(
            (tasks) => tasks.any((t) => t.id == id && t.done)),
      ),
    );
  });

  test('deleteTask soft-deletes: hidden from tasks, visible in trash',
      () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);

    final id = await repo.createTask('Buy milk');
    await repo.deleteTask(id);

    await expectLater(
      repo.watchTasks(),
      emitsThrough(
        predicate<List<Task>>((tasks) => tasks.every((t) => t.id != id)),
      ),
    );
    final trash = await repo.watchTrash().first;
    expect(trash.any((t) => t.id == id), isTrue);
  });
}
