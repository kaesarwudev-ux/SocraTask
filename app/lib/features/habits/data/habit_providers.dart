import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/habits/data/habit_repository.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(ref.watch(databaseProvider));
});

final habitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
});

final habitChecksProvider =
    StreamProvider.autoDispose.family<List<HabitCheck>, int>((ref, id) {
  return ref.watch(habitRepositoryProvider).watchChecks(id);
});
