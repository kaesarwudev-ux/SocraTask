import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';

const _feedIcs = 'BEGIN:VCALENDAR\r\n'
    'VERSION:2.0\r\n'
    'PRODID:-//Google Inc//Google Calendar//EN\r\n'
    'BEGIN:VEVENT\r\n'
    'UID:match-1@google.com\r\n'
    'DTSTART:20261010T150000Z\r\n'
    'DTEND:20261010T170000Z\r\n'
    'SUMMARY:Match day\r\n'
    'LOCATION:Stadium\r\n'
    'END:VEVENT\r\n'
    'END:VCALENDAR\r\n';

MockClient _client() => MockClient((request) async {
      expect(request.url.toString(), contains('basic.ics'));
      return http.Response(_feedIcs, 200);
    });

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

void main() {
  test('subscribeFeed fetches, parses and stores events', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db, client: _client());

    final feedId = await repo.subscribeFeed(
      name: 'Football',
      url: 'https://example.com/basic.ics',
    );

    final feeds = await repo.watchFeeds().first;
    expect(feeds.any((f) => f.id == feedId && f.url.isNotEmpty), isTrue);

    final events = await repo
        .watchRange(DateTime(2026, 10, 9), DateTime(2026, 10, 11))
        .first;
    final match = events.singleWhere((e) => e.title == 'Match day');
    expect(match.feedId, feedId);
    expect(match.uid, 'match-1@google.com');
    expect(match.location, 'Stadium');
  });

  test('refreshFeed twice does not duplicate', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db, client: _client());

    final feedId = await repo.subscribeFeed(
      name: 'Football',
      url: 'https://example.com/basic.ics',
    );
    await repo.refreshFeed(feedId);

    final events = await repo
        .watchRange(DateTime(2026, 10, 9), DateTime(2026, 10, 11))
        .first;
    expect(events.where((e) => e.uid == 'match-1@google.com'), hasLength(1));
  });

  test('import creates a local feed; export round-trips', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db);

    final feedId = await repo.importIcs(_feedIcs, name: 'Holidays file');
    final feeds = await repo.watchFeeds().first;
    final feed = feeds.singleWhere((f) => f.id == feedId);
    expect(feed.url, isEmpty);

    final out = await repo.exportFeed(feedId);
    expect(out, contains('Match day'));
  });

  test('deleteFeed removes the feed and its events', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db, client: _client());

    final feedId = await repo.subscribeFeed(
      name: 'Football',
      url: 'https://example.com/basic.ics',
    );
    await repo.deleteFeed(feedId);

    expect(await repo.watchFeeds().first, isEmpty);
    final events = await repo
        .watchRange(DateTime(2026, 10, 9), DateTime(2026, 10, 11))
        .first;
    expect(events, isEmpty);
  });

  test('disabled feeds hide from range queries', () async {
    final db = _memoryDb();
    addTearDown(db.close);
    final repo = EventRepository(db, client: _client());

    final feedId = await repo.subscribeFeed(
      name: 'Football',
      url: 'https://example.com/basic.ics',
    );
    await repo.setFeedEnabled(feedId, false);

    final events = await repo
        .watchRange(DateTime(2026, 10, 9), DateTime(2026, 10, 11))
        .first;
    expect(events, isEmpty);
  });
}
