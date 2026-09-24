import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Named task lists (Google-Tasks-style: Work, Personal, …).
class TaskLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Tasks table. Soft-delete via [deletedAt]; every mutation bumps
/// [version] and sets [dirty] for the outbox (see `prompt.md` §2).
/// [listId] groups into a [TaskLists] row; [parentId] nests one subtask
/// level (NULL = top-level).
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get project => text().withDefault(const Constant('Inbox'))();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  IntColumn get listId => integer().withDefault(const Constant(0))();
  IntColumn get parentId => integer().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Outbox queue: one row per local mutation, pushed on reconnect
/// (see `prompt.md` §2 sync_queue).
class OutboxOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  IntColumn get entityId => integer()();
  TextColumn get op => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Calendar events (Google-Calendar parity slice 1: timed + all-day,
/// details + location; recurrence/reminders land with their layers).
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  BoolColumn get allDay => boolean().withDefault(const Constant(false))();
  IntColumn get colorId => integer().withDefault(const Constant(0))();
  IntColumn get feedId => integer().withDefault(const Constant(0))();
  TextColumn get uid => text().withDefault(const Constant(''))();
  TextColumn get guests =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get busy => boolean().withDefault(const Constant(true))();
  TextColumn get visibility =>
      text().withDefault(const Constant('Default'))();
  TextColumn get reminders =>
      text().withDefault(const Constant('[]'))();
  IntColumn get guestFlags => integer().withDefault(const Constant(6))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Subscribed calendars (Google/Outlook ICS URLs) and local imports.
/// `url` empty = local-only feed (manual events + file imports).
class CalendarFeeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get url => text().withDefault(const Constant(''))();
  IntColumn get colorId => integer().withDefault(const Constant(0))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Notes (Google-Keep parity slice 1: text + checklists, colors, labels,
/// pin/archive/trash; reminders land with the notification layer).
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  IntColumn get colorId => integer().withDefault(const Constant(0))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  BoolColumn get trashed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashedAt => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Labels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class NoteLabels extends Table {
  IntColumn get noteId => integer()();
  IntColumn get labelId => integer()();

  @override
  Set<Column> get primaryKey => {noteId, labelId};
}

class ChecklistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId => integer()();
  TextColumn get content => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Habits (Loop-style): flexible schedules, done/skip check-ins.
/// kind: 'daily' | 'weekly' | 'xPerWeek' | 'everyNDays'.
/// weeklyDays: Mon..Sun bitmask; timesPerWeek / intervalDays per kind;
/// anchor: reference date for everyNDays.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get colorId => integer().withDefault(const Constant(0))();
  TextColumn get kind => text().withDefault(const Constant('daily'))();
  IntColumn get weeklyDays => integer().withDefault(const Constant(127))();
  IntColumn get timesPerWeek => integer().withDefault(const Constant(1))();
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  DateTimeColumn get anchor =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get reminderMinutes => integer().nullable()();
  RealColumn get score => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// One row per habit per day: done, skipped, or absent (missed/unmarked).
class HabitChecks extends Table {
  IntColumn get habitId => integer()();
  DateTimeColumn get day => dateTime()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {habitId, day};
}

/// Flashcards: decks (sets) and cards. Same DB, local-first.
class FlashDecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class FlashCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer()();
  TextColumn get term => text()();
  TextColumn get definition => text()();
  TextColumn get imageTerm => text().nullable()();
  TextColumn get imageDef => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  // Merge: Gizmo types — familiar per-card switcher
  TextColumn get type => text().withDefault(const Constant('basic'))(); // basic|cloze|free|choice|tf
  TextColumn get highlights => text().withDefault(const Constant('[]'))(); // JSON ranges for cloze/highlight
  TextColumn get options => text().withDefault(const Constant('[]'))(); // JSON list for choice
  IntColumn get answerIndex => integer().withDefault(const Constant(-1))(); // correct index for choice/tf
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Study Space hub (rebuilt v2): boards, widgets, ink strokes, shapes.
/// Persistence only — all interaction state lives in memory (see
/// features/study_space). Drag writes commit on release, never per-frame.
class StudyBoards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Study Space'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class BoardWidgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boardId => integer()();
  TextColumn get type => text()();
  RealColumn get x => real().withDefault(const Constant(40))();
  RealColumn get y => real().withDefault(const Constant(40))();
  RealColumn get w => real().withDefault(const Constant(320))();
  RealColumn get h => real().withDefault(const Constant(220))();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  IntColumn get z => integer().withDefault(const Constant(0))();
}

class BoardStrokes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boardId => integer()();
  TextColumn get tool => text()();
  TextColumn get pointsJson => text()();
  TextColumn get color => text()();
  RealColumn get width => real()();
  RealColumn get opacity => real().withDefault(const Constant(1.0))();
}

class BoardShapes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boardId => integer()();
  TextColumn get kind => text()();
  RealColumn get x => real()();
  RealColumn get y => real()();
  RealColumn get w => real()();
  RealColumn get h => real()();
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get styleJson => text().withDefault(const Constant('{}'))();
}

@DriftDatabase(tables: [
  Tasks,
  TaskLists,
  OutboxOps,
  Events,
  CalendarFeeds,
  Notes,
  Labels,
  NoteLabels,
  ChecklistItems,
  Habits,
  HabitChecks,
  FlashDecks,
  FlashCards,
  StudyBoards,
  BoardWidgets,
  BoardStrokes,
  BoardShapes,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'socra_task'));

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.createTable(taskLists);
            await m.addColumn(tasks, tasks.listId);
            await m.addColumn(tasks, tasks.parentId);
            final home = await into(taskLists).insert(
              TaskListsCompanion.insert(name: 'Tasks'),
            );
            await customStatement(
              'UPDATE tasks SET list_id = ?',
              [home],
            );
          }
          if (from <= 2) {
            await m.createTable(events);
          }
          if (from <= 3) {
            await m.createTable(calendarFeeds);
            await m.addColumn(events, events.feedId);
            await m.addColumn(events, events.uid);
            final local = await into(calendarFeeds).insert(
              CalendarFeedsCompanion.insert(name: 'My calendar'),
            );
            await customStatement(
              'UPDATE events SET feed_id = ?',
              [local],
            );
          }
          if (from <= 4) {
            await m.createTable(notes);
            await m.createTable(labels);
            await m.createTable(noteLabels);
            await m.createTable(checklistItems);
          }
          if (from <= 5) {
            await m.createTable(habits);
            await m.createTable(habitChecks);
          }
          if (from <= 6) {
            await m.addColumn(events, events.guests);
            await m.addColumn(events, events.busy);
            await m.addColumn(events, events.visibility);
            await m.addColumn(events, events.reminders);
            await m.addColumn(events, events.guestFlags);
          }
          if (from <= 7) {
            await m.addColumn(habits, habits.reminderMinutes);
          }
          if (from <= 8) {
            await m.createTable(flashDecks);
            await m.createTable(flashCards);
          }
          if (from <= 9) {
            await m.addColumn(flashCards, flashCards.type);
            await m.addColumn(flashCards, flashCards.highlights);
            await m.addColumn(flashCards, flashCards.options);
            await m.addColumn(flashCards, flashCards.answerIndex);
          }
          // Study Space tables removed in v12 (feature deleted).
          if (from <= 11) {
            await customStatement('DROP TABLE IF EXISTS board_shapes');
            await customStatement('DROP TABLE IF EXISTS board_strokes');
            await customStatement('DROP TABLE IF EXISTS board_widgets');
            await customStatement('DROP TABLE IF EXISTS study_boards');
          }
          // Study Space rebuilt v2 (clean architecture).
          if (from <= 12) {
            await m.createTable(studyBoards);
            await m.createTable(boardWidgets);
            await m.createTable(boardStrokes);
            await m.createTable(boardShapes);
          }
        },
      );
}
