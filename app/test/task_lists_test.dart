import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  test('ensureDefaultList seeds a Tasks list exactly once', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);

    final first = await repo.ensureDefaultList();
    final second = await repo.ensureDefaultList();
    expect(first, second);

    final lists = await repo.watchLists().first;
    expect(lists.map((l) => l.name), contains('Tasks'));
  });

  test('createList + renameList + watchLists', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);
    await repo.ensureDefaultList();

    final id = await repo.createList('Work');
    await expectLater(
      repo.watchLists(),
      emitsThrough(predicate<List<TaskList>>(
          (ls) => ls.any((l) => l.name == 'Work'))),
    );

    await repo.renameList(id, 'Job');
    final lists = await repo.watchLists().first;
    expect(lists.any((l) => l.name == 'Job'), isTrue);
  });

  test('tasks live in a list; moveTask relocates', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final inbox = await repo.ensureDefaultList();
    final work = await repo.createList('Work');

    final id = await repo.createTask('Report', listId: work);
    await expectLater(
      repo.watchTopTasks(work),
      emitsThrough(predicate<List<Task>>(
          (ts) => ts.any((t) => t.id == id))),
    );
    await expectLater(
      repo.watchTopTasks(inbox),
      emitsThrough(predicate<List<Task>>(
          (ts) => ts.every((t) => t.id != id))),
    );

    await repo.moveTask(id, inbox);
    final inboxTasks = await repo.watchTopTasks(inbox).first;
    expect(inboxTasks.any((t) => t.id == id), isTrue);
  });

  test('subtasks nest one level and complete independently', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final inbox = await repo.ensureDefaultList();

    final parent = await repo.createTask('Trip', listId: inbox);
    final sub =
        await repo.createTask('Book flights', listId: inbox, parentId: parent);

    // Subtasks hide from the top-level stream…
    await expectLater(
      repo.watchTopTasks(inbox),
      emitsThrough(predicate<List<Task>>(
          (ts) => ts.every((t) => t.id != sub))),
    );
    // …and show under the parent.
    final subs = await repo.watchSubtasks(parent).first;
    expect(subs.map((t) => t.id), contains(sub));

    await repo.completeTask(sub);
    final parentRow =
        (await repo.watchTopTasks(inbox).first).singleWhere((t) => t.id == parent);
    expect(parentRow.done, isFalse);
  });

  test('setDueDate stores and clears', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final inbox = await repo.ensureDefaultList();

    final id = await repo.createTask('Dated', listId: inbox);
    final due = DateTime(2026, 10, 1, 9);
    await repo.setDueDate(id, due);
    var row =
        (await repo.watchTopTasks(inbox).first).singleWhere((t) => t.id == id);
    expect(row.dueAt, due);

    await repo.setDueDate(id, null);
    row = (await repo.watchTopTasks(inbox).first).singleWhere((t) => t.id == id);
    expect(row.dueAt, isNull);
  });

  test('deleteList moves its tasks home and drops the list', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = TaskRepository(db);
    final inbox = await repo.ensureDefaultList();
    final work = await repo.createList('Work');
    final id = await repo.createTask('Stray', listId: work);

    await repo.deleteList(work);

    final lists = await repo.watchLists().first;
    expect(lists.any((l) => l.id == work), isFalse);
    final home = await repo.watchTopTasks(inbox).first;
    expect(home.any((t) => t.id == id), isTrue);
  });
}
