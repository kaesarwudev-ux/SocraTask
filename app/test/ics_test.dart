import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/features/calendar/data/ics.dart';

const _sample = 'BEGIN:VCALENDAR\r\n'
    'VERSION:2.0\r\n'
    'PRODID:-//Google Inc//Google Calendar 70.9054//EN\r\n'
    'BEGIN:VEVENT\r\n'
    'UID:abc123@example.com\r\n'
    'DTSTAMP:20261001T120000Z\r\n'
    'DTSTART:20261005T090000Z\r\n'
    'DTEND:20261005T100000Z\r\n'
    'SUMMARY:Team standup\r\n'
    'DESCRIPTION:Daily sync with a very long line that gets folded \r\n'
    ' across two lines per RFC 5545\r\n'
    'LOCATION:Room 3\r\n'
    'END:VEVENT\r\n'
    'BEGIN:VEVENT\r\n'
    'UID:holiday@example.com\r\n'
    'DTSTART;VALUE=DATE:20261006\r\n'
    'DTEND;VALUE=DATE:20261007\r\n'
    'SUMMARY:Public holiday\r\n'
    'END:VEVENT\r\n'
    'BEGIN:VEVENT\r\n'
    'UID: floating@example.com\r\n'
    'DTSTART:20261007T150000\r\n'
    'DTEND:20261007T160000\r\n'
    'SUMMARY:Floating lunch\r\n'
    'END:VEVENT\r\n'
    'END:VCALENDAR\r\n';

void main() {
  test('parses timed, all-day and floating events + folded lines', () {
    final events = parseIcs(_sample);
    expect(events, hasLength(3));

    final standup = events.singleWhere((e) => e.uid == 'abc123@example.com');
    expect(standup.title, 'Team standup');
    expect(standup.start, DateTime.utc(2026, 10, 5, 9));
    expect(standup.end, DateTime.utc(2026, 10, 5, 10));
    expect(standup.allDay, isFalse);
    expect(standup.location, 'Room 3');
    expect(standup.description, contains('folded across two lines'));

    final holiday = events.singleWhere((e) => e.title == 'Public holiday');
    expect(holiday.allDay, isTrue);
    expect(holiday.start, DateTime(2026, 10, 6));
  });

  test('skips VEVENTs without usable dates instead of crashing', () {
    const bad = 'BEGIN:VCALENDAR\r\n'
        'BEGIN:VEVENT\r\n'
        'UID:nope\r\n'
        'SUMMARY:Dateless\r\n'
        'END:VEVENT\r\n'
        'END:VCALENDAR\r\n';
    expect(parseIcs(bad), isEmpty);
  });

  test('serializes events back to a parseable calendar', () {
    final parsed = parseIcs(_sample);
    final out = serializeIcs(
      events: parsed,
      prodId: '-//SocraTask//EN',
    );
    expect(out, contains('BEGIN:VCALENDAR'));
    expect(out, contains('Team standup'));

    final roundTrip = parseIcs(out);
    expect(roundTrip.map((e) => e.title),
        containsAll(['Team standup', 'Public holiday', 'Floating lunch']));
    final standup =
        roundTrip.singleWhere((e) => e.uid == 'abc123@example.com');
    expect(standup.start, DateTime.utc(2026, 10, 5, 9));
  });
}
