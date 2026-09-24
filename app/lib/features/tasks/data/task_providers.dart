import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/tasks/data/task_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

final listsStreamProvider = StreamProvider<List<TaskList>>((ref) {
  return ref.watch(taskRepositoryProvider).watchLists();
});

/// Active list id; null = first available (the default list).
final activeListProvider = StateProvider<int?>((ref) => null);

/// Google-Tasks-style sort: manual creation order vs due date.
enum TaskSort { manual, date }

final taskSortProvider = StateProvider<TaskSort>((ref) => TaskSort.manual);
