import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  test('createEvent appears in day range query', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    final day = DateTime(2026, 10, 5);
    await repo.createEvent(
      title: 'Dentist',
      start: DateTime(2026, 10, 5, 9),
      end: DateTime(2026, 10, 5, 10),
    );

    final events = await repo.watchDay(day).first;
    expect(events.map((e) => e.title), contains('Dentist'));
  });

  test('all-day event spans its day and shows in agenda', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    await repo.createEvent(
      title: 'Holiday',
      start: DateTime(2026, 10, 5),
      end: DateTime(2026, 10, 5, 23, 59),
      allDay: true,
    );

    final day = await repo.watchDay(DateTime(2026, 10, 5)).first;
    expect(day.any((e) => e.title == 'Holiday' && e.allDay), isTrue);
    final next = await repo.watchDay(DateTime(2026, 10, 6)).first;
    expect(next.any((e) => e.title == 'Holiday'), isFalse);
  });

  test('updateEvent edits details; deleteEvent soft-deletes', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    final id = await repo.createEvent(
      title: 'Lunch',
      start: DateTime(2026, 10, 5, 12),
      end: DateTime(2026, 10, 5, 13),
    );
    await repo.updateEvent(id,
        title: 'Lunch with Sam', location: 'Café Nero');

    var events = await repo.watchDay(DateTime(2026, 10, 5)).first;
    final edited = events.singleWhere((e) => e.id == id);
    expect(edited.title, 'Lunch with Sam');
    expect(edited.location, 'Café Nero');

    await repo.deleteEvent(id);
    events = await repo.watchDay(DateTime(2026, 10, 5)).first;
    expect(events.any((e) => e.id == id), isFalse);
  });

  test('multi-day range query covers agenda window', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    await repo.createEvent(
      title: 'Mon standup',
      start: DateTime(2026, 10, 5, 9, 30),
      end: DateTime(2026, 10, 5, 9, 45),
    );
    await repo.createEvent(
      title: 'Wed review',
      start: DateTime(2026, 10, 7, 15),
      end: DateTime(2026, 10, 7, 16),
    );

    final week = await repo
        .watchRange(DateTime(2026, 10, 5), DateTime(2026, 10, 12))
        .first;
    expect(week.map((e) => e.title),
        containsAll(['Mon standup', 'Wed review']));
  });

  test('guests, busy, visibility and reminders round-trip', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    final id = await repo.createEvent(
      title: 'Planning',
      start: DateTime(2026, 10, 5, 9),
      end: DateTime(2026, 10, 5, 10),
      guests: const ['sam@example.com', 'jo@example.com'],
      busy: false,
      visibility: 'Private',
      reminders: const ['10 minutes before'],
    );
    var events = await repo.watchDay(DateTime(2026, 10, 5)).first;
    var e = events.singleWhere((e) => e.id == id);
    expect(eventGuests(e), ['sam@example.com', 'jo@example.com']);
    expect(e.busy, isFalse);
    expect(e.visibility, 'Private');
    expect(eventReminders(e), ['10 minutes before']);

    await repo.updateEvent(id,
        guests: const ['sam@example.com'],
        busy: true,
        visibility: 'Public',
        reminders: const []);
    events = await repo.watchDay(DateTime(2026, 10, 5)).first;
    e = events.singleWhere((e) => e.id == id);
    expect(eventGuests(e), ['sam@example.com']);
    expect(e.busy, isTrue);
    expect(e.visibility, 'Public');
    expect(eventReminders(e), isEmpty);
  });

  test('moveEvent transfers the event to another calendar', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    final id = await repo.createEvent(
      title: 'Movable',
      start: DateTime(2026, 10, 5, 9),
      end: DateTime(2026, 10, 5, 10),
    );
    final other = await repo.importIcs(
      'BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\nUID:x\r\n'
      'DTSTART:20261006T090000Z\r\nDTEND:20261006T100000Z\r\n'
      'SUMMARY:Other\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n',
      name: 'Second',
    );
    await repo.moveEvent(id, other);

    final events =
        await repo.watchDay(DateTime(2026, 10, 5)).first;
    expect(
        events.singleWhere((e) => e.id == id).feedId, other);
  });
}
