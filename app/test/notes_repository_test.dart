import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/notes/data/note_repository.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  test('create + edit + pin ordering', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = NoteRepository(db);

    final a = await repo.createNote(title: 'Shopping', body: 'Milk');
    await repo.createNote(title: 'Ideas', body: 'App');
    await repo.setPinned(a, true);

    final notes = await repo.watchNotes().first;
    expect(notes.first.id, a);
    expect(notes.map((n) => n.title), containsAll(['Shopping', 'Ideas']));
  });

  test('checklist items toggle independently', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = NoteRepository(db);

    final id = await repo.createNote(title: 'Trip');
    final item = await repo.addChecklistItem(id, 'Passport');
    await repo.addChecklistItem(id, 'Tickets');
    await repo.toggleChecklistItem(item, true);

    final items = await repo.watchChecklist(id).first;
    expect(items.singleWhere((i) => i.id == item).done, isTrue);
    expect(items.where((i) => !i.done), hasLength(1));
  });

  test('labels attach, filter and rename', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = NoteRepository(db);

    final id = await repo.createNote(title: 'Labeled', body: 'x');
    final label = await repo.createLabel('Work');
    await repo.setNoteLabel(id, label, true);

    var filtered = await repo.watchNotes(labelId: label).first;
    expect(filtered.map((n) => n.id), contains(id));

    await repo.setNoteLabel(id, label, false);
    filtered = await repo.watchNotes(labelId: label).first;
    expect(filtered.map((n) => n.id), isNot(contains(id)));

    await repo.renameLabel(label, 'Job');
    final labels = await repo.watchLabels().first;
    expect(labels.single.name, 'Job');
  });

  test('archive hides; trash restores; empty trash purges', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = NoteRepository(db);

    final id = await repo.createNote(title: 'Old', body: 'x');
    await repo.setArchived(id, true);
    expect(await repo.watchNotes().first, isEmpty);
    expect((await repo.watchNotes(archived: true).first).map((n) => n.id),
        contains(id));

    await repo.setArchived(id, false);
    await repo.trashNote(id);
    expect(await repo.watchNotes().first, isEmpty);
    await repo.restoreNote(id);
    expect((await repo.watchNotes().first).map((n) => n.id), contains(id));

    await repo.trashNote(id);
    await repo.emptyTrash();
    expect(await repo.watchNotes(trashed: true).first, isEmpty);
  });

  test('search matches title and body', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = NoteRepository(db);

    await repo.createNote(title: 'Grocery', body: 'oat milk');
    await repo.createNote(title: 'Ideas', body: 'startup');

    expect((await repo.searchNotes('oat')).map((n) => n.title),
        ['Grocery']);
    expect((await repo.searchNotes('IDEAS')).map((n) => n.title),
        ['Ideas']);
  });
}
