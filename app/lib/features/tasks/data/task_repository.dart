import 'package:drift/drift.dart';
import 'package:socra_task/core/data/database.dart';

/// Local-first task operations. Every write lands in SQLite first and
/// enqueues an outbox op; sync pushes the queue when online.
/// Never blocks on network (see `prompt.md` §2).
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  /// All top-level, untrashed tasks across lists (dashboard + legacy).
  Stream<List<Task>> watchTasks() {
    return (_db.select(_db.tasks)
          ..where((t) =>
              t.deletedAt.isNull() & t.parentId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// Top-level tasks of one list.
  Stream<List<Task>> watchTopTasks(int listId) {
    return (_db.select(_db.tasks)
          ..where((t) => t.deletedAt.isNull() &
              t.parentId.isNull() &
              t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Stream<List<Task>> watchSubtasks(int parentId) {
    return (_db.select(_db.tasks)
          ..where((t) =>
              t.deletedAt.isNull() & t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Stream<List<Task>> watchTrash() {
    return (_db.select(_db.tasks)
          ..where((t) => t.deletedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .watch();
  }

  Stream<List<TaskList>> watchLists() {
    return (_db.select(_db.taskLists)
          ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
        .watch();
  }

  Future<List<OutboxOp>> pendingOps() => _db.select(_db.outboxOps).get();

  /// Idempotent default list; every task belongs somewhere.
  Future<int> ensureDefaultList() async {
    final existing = await (_db.select(_db.taskLists)
          ..where((l) => l.name.equals('Tasks'))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db
        .into(_db.taskLists)
        .insert(TaskListsCompanion.insert(name: 'Tasks'));
  }

  Future<int> createList(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('List name is required');
    return _db
        .into(_db.taskLists)
        .insert(TaskListsCompanion.insert(name: clean));
  }

  Future<void> renameList(int id, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('List name is required');
    await (_db.update(_db.taskLists)..where((l) => l.id.equals(id)))
        .write(TaskListsCompanion(name: Value(clean)));
  }

  /// Drops the list; its tasks move home to the default list.
  Future<void> deleteList(int id) async {
    final home = await ensureDefaultList();
    if (id == home) throw StateError('Cannot delete the default list');
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.listId.equals(id)))
          .write(TasksCompanion(listId: Value(home)));
      await (_db.delete(_db.taskLists)..where((l) => l.id.equals(id)))
          .go();
    });
  }

  Future<int> createTask(
    String title, {
    int? listId,
    int? parentId,
  }) async {
    final clean = title.trim();
    if (clean.isEmpty) throw ArgumentError('Task title is required');
    return _db.transaction(() async {
      final resolvedList = listId ?? await ensureDefaultList();
      final id = await _db.into(_db.tasks).insert(
            TasksCompanion.insert(
              title: clean,
              listId: Value(resolvedList),
              parentId: Value(parentId),
              dirty: const Value(true),
            ),
          );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'task',
              entityId: id,
              op: 'create',
            ),
          );
      return id;
    });
  }

  Future<void> completeTask(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          done: const Value(true),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'task',
              entityId: id,
              op: 'update',
            ),
          );
    });
  }

  Future<void> deleteTask(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          deletedAt: Value(DateTime.now()),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'task',
              entityId: id,
              op: 'delete',
            ),
          );
    });
  }

  Future<void> moveTask(int id, int listId) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          listId: Value(listId),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'task',
              entityId: id,
              op: 'update',
            ),
          );
    });
  }

  Future<void> setDueDate(int id, DateTime? due) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          dueAt: Value(due),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'task',
              entityId: id,
              op: 'update',
            ),
          );
    });
  }
}
