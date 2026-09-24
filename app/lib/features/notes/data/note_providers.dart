import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/notes/data/note_repository.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(databaseProvider));
});

enum NotesNav { notes, archive, trash }

final notesNavProvider =
    StateProvider<NotesNav>((ref) => NotesNav.notes);

/// Label id filter, or null for all.
final notesLabelFilterProvider = StateProvider<int?>((ref) => null);

final notesQueryProvider = StateProvider<String>((ref) => '');

/// True = masonry grid, false = single-column list.
final notesGridProvider = StateProvider<bool>((ref) => true);

final notesHomeProvider = StreamProvider<List<Note>>((ref) {
  final label = ref.watch(notesLabelFilterProvider);
  return ref.watch(noteRepositoryProvider).watchNotes(labelId: label);
});

final notesArchivedProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchNotes(archived: true);
});

final notesTrashProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchNotes(trashed: true);
});

final labelsProvider = StreamProvider<List<Label>>((ref) {
  return ref.watch(noteRepositoryProvider).watchLabels();
});

/// Keep's 12 colors, tuned per brightness.
Color noteCardColor(int colorId, Brightness brightness) {
  const light = [
    Color(0xFFFFFFFF),
    Color(0xFFF28B82),
    Color(0xFFFBBC04),
    Color(0xFFFFF475),
    Color(0xFFCCFF90),
    Color(0xFFA7FFEB),
    Color(0xFFCBF0F8),
    Color(0xFFAECBFA),
    Color(0xFFD7AEFB),
    Color(0xFFFDCFE8),
    Color(0xFFE6C9A1),
    Color(0xFFE8EAED),
  ];
  const dark = [
    Color(0xFF202124),
    Color(0xFF5C2B29),
    Color(0xFF614A19),
    Color(0xFF635D19),
    Color(0xFF345920),
    Color(0xFF16504B),
    Color(0xFF2D555E),
    Color(0xFF1E3A5F),
    Color(0xFF42275E),
    Color(0xFF5B2246),
    Color(0xFF442F19),
    Color(0xFF3C4043),
  ];
  final set = brightness == Brightness.dark ? dark : light;
  return set[colorId % set.length];
}
