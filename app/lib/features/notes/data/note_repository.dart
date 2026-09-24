import 'package:drift/drift.dart';
import 'package:socra_task/core/data/database.dart';

/// Local-first notes (Keep parity slice 1). No outbox sync yet — notes
/// sync lands with the account layer; all writes are local + immediate.
class NoteRepository {
  NoteRepository(this._db);

  final AppDatabase _db;

  Stream<List<Note>> watchNotes({
    bool archived = false,
    bool trashed = false,
    int? labelId,
  }) {
    final base = _db.select(_db.notes)
      ..where((n) =>
          n.archived.equals(archived) & n.trashed.equals(trashed));
    if (labelId != null) {
      final tagged = _db.selectOnly(_db.noteLabels)
        ..addColumns([_db.noteLabels.noteId])
        ..where(_db.noteLabels.labelId.equals(labelId) &
            _db.noteLabels.noteId.equalsExp(_db.notes.id));
      base.where((n) => existsQuery(tagged));
    }
    return (base
          ..orderBy([
            (n) => OrderingTerm(
                expression: n.pinned, mode: OrderingMode.desc),
            (n) => OrderingTerm.desc(n.updatedAt),
          ]))
        .watch();
  }

  Stream<List<Label>> watchLabels() {
    return (_db.select(_db.labels)
          ..orderBy([(l) => OrderingTerm.asc(l.name)]))
        .watch();
  }

  Stream<List<ChecklistItem>> watchChecklist(int noteId) {
    return (_db.select(_db.checklistItems)
          ..where((c) => c.noteId.equals(noteId))
          ..orderBy([(c) => OrderingTerm.asc(c.position)]))
        .watch();
  }

  Future<List<Note>> searchNotes(String query) async {
    final q = '%${query.trim().replaceAll('%', '')}%';
    if (q == '%%') return [];
    return (_db.select(_db.notes)
          ..where((n) =>
              n.trashed.equals(false) &
              (n.title.like(q) | n.body.like(q)))
          ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
        .get();
  }

  Future<int> createNote({String title = '', String body = ''}) async {
    return _db.into(_db.notes).insert(
          NotesCompanion.insert(
            title: Value(title),
            body: Value(body),
          ),
        );
  }

  Future<void> updateNote(int id, {String? title, String? body}) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
        title: title == null ? const Value.absent() : Value(title),
        body: body == null ? const Value.absent() : Value(body),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setNoteColor(int id, int colorId) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
          colorId: Value(colorId), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setPinned(int id, bool pinned) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
          pinned: Value(pinned), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setArchived(int id, bool archived) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
          archived: Value(archived),
          updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> trashNote(int id) async {
    final now = DateTime.now();
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
          trashed: const Value(true),
          trashedAt: Value(now),
          updatedAt: Value(now)),
    );
  }

  Future<void> restoreNote(int id) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(
          trashed: const Value(false),
          trashedAt: const Value.absent(),
          updatedAt: Value(DateTime.now())),
    );
  }

  /// Permanently deletes trashed notes (plus their items + label links).
  Future<void> emptyTrash() async {
    await _db.transaction(() async {
      final trashed = await (_db.select(_db.notes)
            ..where((n) => n.trashed.equals(true)))
          .get();
      for (final note in trashed) {
        await (_db.delete(_db.checklistItems)
              ..where((c) => c.noteId.equals(note.id)))
            .go();
        await (_db.delete(_db.noteLabels)
              ..where((l) => l.noteId.equals(note.id)))
            .go();
        await (_db.delete(_db.notes)..where((n) => n.id.equals(note.id)))
            .go();
      }
    });
  }

  Future<int> addChecklistItem(int noteId, String text) async {
    final clean = text.trim();
    if (clean.isEmpty) throw ArgumentError('Item text is required');
    final existing = await (_db.select(_db.checklistItems)
          ..where((c) => c.noteId.equals(noteId)))
        .get();
    final position = existing.isEmpty
        ? 0
        : existing
                .map((c) => c.position)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final id = await _db.into(_db.checklistItems).insert(
          ChecklistItemsCompanion.insert(
            noteId: noteId,
            content: clean,
            position: Value(position),
          ),
        );
    await _touch(noteId);
    return id;
  }

  Future<void> toggleChecklistItem(int itemId, bool done) async {
    await (_db.update(_db.checklistItems)
          ..where((c) => c.id.equals(itemId)))
        .write(ChecklistItemsCompanion(done: Value(done)));
  }

  Future<void> removeChecklistItem(int itemId) async {
    await (_db.delete(_db.checklistItems)
          ..where((c) => c.id.equals(itemId)))
        .go();
  }

  Future<int> createLabel(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Label name is required');
    return _db
        .into(_db.labels)
        .insert(LabelsCompanion.insert(name: clean));
  }

  Future<void> renameLabel(int id, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Label name is required');
    await (_db.update(_db.labels)..where((l) => l.id.equals(id)))
        .write(LabelsCompanion(name: Value(clean)));
  }

  Future<void> deleteLabel(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.noteLabels)
            ..where((l) => l.labelId.equals(id)))
          .go();
      await (_db.delete(_db.labels)..where((l) => l.id.equals(id))).go();
    });
  }

  Future<void> setNoteLabel(int noteId, int labelId, bool attached) async {
    if (attached) {
      await _db.into(_db.noteLabels).insertOnConflictUpdate(
            NoteLabelsCompanion.insert(noteId: noteId, labelId: labelId),
          );
    } else {
      await (_db.delete(_db.noteLabels)
            ..where((l) =>
                l.noteId.equals(noteId) & l.labelId.equals(labelId)))
          .go();
    }
  }

  Future<List<Label>> noteLabels(int noteId) async {
    final rows = await (_db.select(_db.noteLabels)
          ..where((l) => l.noteId.equals(noteId)))
        .get();
    if (rows.isEmpty) return [];
    return (_db.select(_db.labels)
          ..where((l) =>
              l.id.isIn(rows.map((r) => r.labelId).toList())))
        .get();
  }

  Future<void> _touch(int noteId) async {
    await (_db.update(_db.notes)..where((n) => n.id.equals(noteId)))
        .write(NotesCompanion(updatedAt: Value(DateTime.now())));
  }
}
