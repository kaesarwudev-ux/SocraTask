import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/ics.dart';

/// Decodes the JSON string columns used for guests/reminders.
List<String> decodeList(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<String>().toList();
    }
    return [];
  } catch (_) {
    return [];
  }
}

String encodeList(List<String> items) => jsonEncode(items);

/// Display title: untitled drafts render as "(No title)" everywhere.
String eventTitle(Event e) => e.title.isEmpty ? '(No title)' : e.title;

/// Decoded event guest emails.
List<String> eventGuests(Event e) => decodeList(e.guests);

/// Decoded event reminder labels (e.g. "10 minutes before").
List<String> eventReminders(Event e) => decodeList(e.reminders);

/// Local-first event operations + calendar feeds (Google/Outlook ICS
/// URLs and `.ics` file imports). Same outbox discipline as tasks.
class EventRepository {
  EventRepository(this._db, {http.Client? client})
      : _client = client ?? http.Client();

  final AppDatabase _db;
  final http.Client _client;

  static DateTime _dayStart(DateTime day) =>
      DateTime(day.year, day.month, day.day);
  static DateTime _dayEnd(DateTime day) =>
      DateTime(day.year, day.month, day.day, 23, 59, 59);

  /// Matches events whose feed is enabled (or feeds table still empty
  /// pre-migration edge — treated as visible).
  SimpleSelectStatement<Events, Event> _visible(
      SimpleSelectStatement<Events, Event> query) {
    final enabled = _db.selectOnly(_db.calendarFeeds)
      ..addColumns([_db.calendarFeeds.id])
      ..where(_db.calendarFeeds.id.equalsExp(_db.events.feedId) &
          _db.calendarFeeds.enabled);
    return query..where((e) => existsQuery(enabled));
  }

  /// Events overlapping [day] (timed or all-day), ordered by start.
  Future<Event?> getEvent(int id) {
    return (_db.select(_db.events)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Event>> watchDay(DateTime day) {
    final start = _dayStart(day);
    final end = _dayEnd(day);
    return _visible(
      _db.select(_db.events)
        ..where((e) =>
            e.deletedAt.isNull() &
            e.start.isSmallerOrEqualValue(end) &
            e.end.isBiggerOrEqualValue(start))
        ..orderBy([
          (e) => OrderingTerm(
              expression: e.allDay, mode: OrderingMode.desc),
          (e) => OrderingTerm.asc(e.start),
        ]),
    ).watch();
  }

  /// Events overlapping [from]..[to] inclusive, ordered by start.
  Stream<List<Event>> watchRange(DateTime from, DateTime to) {
    final start = _dayStart(from);
    final end = _dayEnd(to);
    return _visible(
      _db.select(_db.events)
        ..where((e) =>
            e.deletedAt.isNull() &
            e.start.isSmallerOrEqualValue(end) &
            e.end.isBiggerOrEqualValue(start))
        ..orderBy([(e) => OrderingTerm.asc(e.start)]),
    ).watch();
  }

  Stream<List<CalendarFeed>> watchFeeds() {
    return (_db.select(_db.calendarFeeds)
          ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
        .watch();
  }

  Future<int> ensureDefaultFeed() async {
    final existing = await (_db.select(_db.calendarFeeds)
          ..where((f) => f.url.equals(''))
          ..orderBy([(f) => OrderingTerm.asc(f.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.calendarFeeds).insert(
          CalendarFeedsCompanion.insert(name: 'My calendar'),
        );
  }

  Future<int> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    String? location,
    bool allDay = false,
    int colorId = 0,
    int? feedId,
    List<String> guests = const [],
    bool busy = true,
    String visibility = 'Default',
    List<String> reminders = const [],
    int guestFlags = 6,
  }) async {
    final clean = title.trim();
    if (!end.isAfter(start)) {
      throw ArgumentError('Event end must be after start');
    }
    // NOTE: empty titles are allowed — fresh drafts render as "(No title)"
    // until the user types. Callers that need a title validate in UI.
    return _db.transaction(() async {
      final resolvedFeed = feedId ?? await ensureDefaultFeed();
      final id = await _db.into(_db.events).insert(
            EventsCompanion.insert(
              title: clean,
              start: start,
              end: end,
              description: Value(description),
              location: Value(location),
              allDay: Value(allDay),
              colorId: Value(colorId),
              feedId: Value(resolvedFeed),
              guests: Value(encodeList(guests)),
              busy: Value(busy),
              visibility: Value(visibility),
              reminders: Value(encodeList(reminders)),
              guestFlags: Value(guestFlags),
              dirty: const Value(true),
            ),
          );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'event',
              entityId: id,
              op: 'create',
            ),
          );
      return id;
    });
  }

  Future<void> updateEvent(
    int id, {
    String? title,
    String? description,
    String? location,
    DateTime? start,
    DateTime? end,
    bool? allDay,
    int? colorId,
    int? feedId,
    List<String>? guests,
    bool? busy,
    String? visibility,
    List<String>? reminders,
    int? guestFlags,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.events)..where((e) => e.id.equals(id))).write(
        EventsCompanion(
          title: title == null ? const Value.absent() : Value(title),
          description:
              description == null ? const Value.absent() : Value(description),
          location:
              location == null ? const Value.absent() : Value(location),
          start: start == null ? const Value.absent() : Value(start),
          end: end == null ? const Value.absent() : Value(end),
          allDay: allDay == null ? const Value.absent() : Value(allDay),
          colorId:
              colorId == null ? const Value.absent() : Value(colorId),
          feedId:
              feedId == null ? const Value.absent() : Value(feedId),
          guests: guests == null
              ? const Value.absent()
              : Value(encodeList(guests)),
          busy: busy == null ? const Value.absent() : Value(busy),
          visibility: visibility == null
              ? const Value.absent()
              : Value(visibility),
          reminders: reminders == null
              ? const Value.absent()
              : Value(encodeList(reminders)),
          guestFlags: guestFlags == null
              ? const Value.absent()
              : Value(guestFlags),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'event',
              entityId: id,
              op: 'update',
            ),
          );
    });
  }

  Future<void> deleteEvent(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.events)..where((e) => e.id.equals(id))).write(
        EventsCompanion(
          deletedAt: Value(DateTime.now()),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'event',
              entityId: id,
              op: 'delete',
            ),
          );
    });
  }

  /// Subscribes to a Google/Outlook-style ICS URL and pulls it now.
  /// Returns the feed id. Throws [ClientException] on HTTP failure.
  Future<int> subscribeFeed({
    required String name,
    required String url,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Feed name is required');
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError('That link does not look like a calendar URL');
    }
    final feedId = await _db.into(_db.calendarFeeds).insert(
          CalendarFeedsCompanion.insert(
            name: cleanName,
            url: Value(url.trim()),
          ),
        );
    try {
      await refreshFeed(feedId);
    } catch (_) {
      await (_db.delete(_db.calendarFeeds)
            ..where((f) => f.id.equals(feedId)))
          .go();
      rethrow;
    }
    return feedId;
  }

  /// Re-pulls a subscribed feed, replacing its synced events (manual
  /// events live on local feeds, so nothing user-made is lost).
  Future<void> refreshFeed(int feedId) async {
    final feed = await (_db.select(_db.calendarFeeds)
          ..where((f) => f.id.equals(feedId)))
        .getSingleOrNull();
    if (feed == null) throw StateError('Feed not found');
    if (feed.url.isEmpty) return;
    final response = await _client.get(Uri.parse(feed.url));
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Calendar returned HTTP ${response.statusCode}',
        Uri.parse(feed.url),
      );
    }
    final parsed = parseIcs(response.body);
    await _db.transaction(() async {
      await (_db.delete(_db.events)
            ..where((e) =>
                e.feedId.equals(feedId) & e.deletedAt.isNull()))
          .go();
      for (final item in parsed) {
        await _db.into(_db.events).insert(
              EventsCompanion.insert(
                title: item.title,
                start: item.start,
                end: item.end,
                description: Value(item.description),
                location: Value(item.location),
                allDay: Value(item.allDay),
                colorId: Value(feed.colorId),
                feedId: Value(feedId),
                uid: Value(item.uid),
                guests: Value(encodeList(item.attendees)),
              ),
            );
      }
      await (_db.update(_db.calendarFeeds)
            ..where((f) => f.id.equals(feedId)))
          .write(CalendarFeedsCompanion(
        lastSyncAt: Value(DateTime.now()),
      ));
    });
  }

  /// Imports an `.ics` file's contents into a new local feed.
  Future<int> importIcs(String content, {required String name}) async {
    final parsed = parseIcs(content);
    if (parsed.isEmpty) {
      throw ArgumentError('No events found in that file');
    }
    return _db.transaction(() async {
      final feedId = await _db.into(_db.calendarFeeds).insert(
            CalendarFeedsCompanion.insert(name: name.trim().isEmpty
                ? 'Imported calendar'
                : name.trim()),
          );
      for (final item in parsed) {
        await _db.into(_db.events).insert(
              EventsCompanion.insert(
                title: item.title,
                start: item.start,
                end: item.end,
                description: Value(item.description),
                location: Value(item.location),
                allDay: Value(item.allDay),
                feedId: Value(feedId),
                uid: Value(item.uid),
                guests: Value(encodeList(item.attendees)),
                dirty: const Value(true),
              ),
            );
      }
      return feedId;
    });
  }

  /// Serializes one feed to `.ics` for export.
  Future<String> exportFeed(int feedId) async {
    final rows = await (_db.select(_db.events)
          ..where((e) =>
              e.feedId.equals(feedId) & e.deletedAt.isNull())
          ..orderBy([(e) => OrderingTerm.asc(e.start)]))
        .get();
    return serializeIcs(
      events: [
        for (final e in rows)
          IcsEvent(
            uid: e.uid.isEmpty ? 'socra-event-${e.id}' : e.uid,
            title: e.title,
            start: e.start,
            end: e.end,
            allDay: e.allDay,
            description: e.description,
            location: e.location,
            attendees: eventGuests(e),
          ),
      ],
      prodId: '-//SocraTask//EN',
    );
  }

  Future<void> moveEvent(int id, int feedId) async {
    await _db.transaction(() async {
      await (_db.update(_db.events)..where((e) => e.id.equals(id))).write(
        EventsCompanion(
          feedId: Value(feedId),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _db.into(_db.outboxOps).insert(
            OutboxOpsCompanion.insert(
              kind: 'event',
              entityId: id,
              op: 'update',
            ),
          );
    });
  }

  Future<void> setFeedEnabled(int id, bool enabled) async {
    await (_db.update(_db.calendarFeeds)..where((f) => f.id.equals(id)))
        .write(CalendarFeedsCompanion(enabled: Value(enabled)));
  }

  Future<void> deleteFeed(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.events)..where((e) => e.feedId.equals(id)))
          .go();
      await (_db.delete(_db.calendarFeeds)..where((f) => f.id.equals(id)))
          .go();
    });
  }
}
