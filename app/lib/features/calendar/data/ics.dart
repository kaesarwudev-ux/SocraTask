/// Minimal RFC 5545 reader/writer for calendar interop (Google/Outlook
/// `.ics` files and subscription URLs). Covers timed (UTC + floating),
/// all-day, folded lines and basic text unescaping. RRULE expansion and
/// VTIMEZONE math are out of scope for v1 and skipped, never crashed on.
class IcsEvent {
  IcsEvent({
    required this.uid,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    this.description,
    this.location,
    this.attendees = const [],
  });

  final String uid;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final String? description;
  final String? location;
  final List<String> attendees;

  List<String> get guests => attendees;
}

List<String> _unfold(String raw) {
  final lines = raw.split(RegExp(r'\r\n|\r|\n'));
  final out = <String>[];
  for (final line in lines) {
    if (line.startsWith(' ') || line.startsWith('\t')) {
      if (out.isEmpty) continue;
      out[out.length - 1] = out.last + line.substring(1);
    } else {
      out.add(line);
    }
  }
  return out;
}

String _unescape(String v) => v
    .replaceAll(r'\\n', '\n')
    .replaceAll(r'\\N', '\n')
    .replaceAll(r'\\,', ',')
    .replaceAll(r'\\;', ';')
    .replaceAll(r'\\', '');

String _escape(String v) => v
    .replaceAll(r'\', r'\\')
    .replaceAll('\n', r'\n')
    .replaceAll(',', r'\,')
    .replaceAll(';', r'\;');

DateTime? _parseStamp(String value, bool dateOnly) {
  try {
    if (dateOnly) {
      final y = int.parse(value.substring(0, 4));
      final m = int.parse(value.substring(4, 6));
      final d = int.parse(value.substring(6, 8));
      return DateTime(y, m, d);
    }
    final utc = value.endsWith('Z');
    final v = utc ? value.substring(0, value.length - 1) : value;
    final y = int.parse(v.substring(0, 4));
    final mo = int.parse(v.substring(4, 6));
    final d = int.parse(v.substring(6, 8));
    final h = int.parse(v.substring(9, 11));
    final mi = int.parse(v.substring(11, 13));
    final s = v.length >= 15 ? int.parse(v.substring(13, 15)) : 0;
    return utc
        ? DateTime.utc(y, mo, d, h, mi, s)
        : DateTime(y, mo, d, h, mi, s);
  } catch (_) {
    return null;
  }
}

({String name, Map<String, String> params, String value}) _splitLine(
    String line) {
  final colon = line.indexOf(':');
  final head = colon == -1 ? line : line.substring(0, colon);
  final value = colon == -1 ? '' : line.substring(colon + 1);
  final parts = head.split(';');
  final params = <String, String>{};
  for (final p in parts.skip(1)) {
    final eq = p.indexOf('=');
    if (eq != -1) params[p.substring(0, eq)] = p.substring(eq + 1);
  }
  return (name: parts.first, params: params, value: value);
}

List<IcsEvent> parseIcs(String raw) {
  final lines = _unfold(raw);
  final events = <IcsEvent>[];
  Map<String, ({Map<String, String> params, String value})>? current;
  var attendees = <String>[];
  for (final line in lines) {
    if (line == 'BEGIN:VEVENT') {
      current = {};
      attendees = [];
    } else if (line == 'END:VEVENT') {
      final block = current;
      current = null;
      if (block == null) continue;
      final uid = block['UID']?.value ?? '';
      final title = _unescape(block['SUMMARY']?.value ?? '').trim();
      if (title.isEmpty) continue;
      final startProp = block['DTSTART'];
      final endProp = block['DTEND'];
      if (startProp == null || endProp == null) continue;
      final allDay = startProp.params['VALUE'] == 'DATE';
      final start = _parseStamp(startProp.value, allDay);
      var end = _parseStamp(endProp.value, allDay);
      if (start == null || end == null) continue;
      if (allDay) {
        // DATE end is exclusive per RFC 5545; clamp to the last day.
        end = DateTime(end.year, end.month, end.day)
            .subtract(const Duration(seconds: 1));
        if (!end.isAfter(start)) {
          end = DateTime(start.year, start.month, start.day, 23, 59, 59);
        }
      }
      if (!end.isAfter(start)) continue;
      events.add(IcsEvent(
        uid: uid.isEmpty
            ? 'socra-${start.toIso8601String()}-$title'
            : uid,
        title: title,
        start: start,
        end: end,
        allDay: allDay,
        description: block['DESCRIPTION'] == null
            ? null
            : _unescape(block['DESCRIPTION']!.value),
        location: block['LOCATION'] == null
            ? null
            : _unescape(block['LOCATION']!.value),
        attendees: List.unmodifiable(attendees),
      ));
    } else if (current != null) {
      final split = _splitLine(line);
      if (split.name == 'ATTENDEE') {
        final mail = split.value.replaceFirst(
            RegExp('^mailto:', caseSensitive: false), '').trim();
        if (mail.isNotEmpty && !attendees.contains(mail)) {
          attendees.add(mail);
        }
        continue;
      }
      current[split.name] = (params: split.params, value: split.value);
    }
  }
  return events;
}

String _stamp(DateTime t, {required bool utc, required bool dateOnly}) {
  String p(int n, [int w = 2]) => n.toString().padLeft(w, '0');
  if (dateOnly) return '${p(t.year, 4)}${p(t.month)}${p(t.day)}';
  final base =
      '${p(t.year, 4)}${p(t.month)}${p(t.day)}T${p(t.hour)}${p(t.minute)}${p(t.second)}';
  return utc ? '${base}Z' : base;
}

String _fold(String line) {
  // RFC 5545: max 75 octets; fold on a safe character boundary.
  if (line.length <= 74) return line;
  final out = StringBuffer(line.substring(0, 74));
  var rest = line.substring(74);
  while (rest.isNotEmpty) {
    final take = rest.length > 73 ? 73 : rest.length;
    out.write('\r\n ${rest.substring(0, take)}');
    rest = rest.substring(take);
  }
  return out.toString();
}

/// Serializes events to an `.ics` calendar (UTC stamps; all-day as DATE).
String serializeIcs({
  required List<IcsEvent> events,
  required String prodId,
}) {
  final buf = StringBuffer()
    ..writeln('BEGIN:VCALENDAR')
    ..writeln('VERSION:2.0')
    ..writeln('PRODID:$prodId');
  for (final e in events) {
    buf.writeln('BEGIN:VEVENT');
    buf.writeln(_fold('UID:${e.uid}'));
    buf.writeln(_fold(
        'DTSTAMP:${_stamp(DateTime.now().toUtc(), utc: true, dateOnly: false)}'));
    if (e.allDay) {
      buf.writeln(
          'DTSTART;VALUE=DATE:${_stamp(e.start, utc: false, dateOnly: true)}');
      final exclusiveEnd =
          DateTime(e.end.year, e.end.month, e.end.day)
              .add(const Duration(days: 1));
      buf.writeln(
          'DTEND;VALUE=DATE:${_stamp(exclusiveEnd, utc: false, dateOnly: true)}');
    } else {
      final utcStart =
          e.start.isUtc ? e.start : e.start.toUtc();
      final utcEnd = e.end.isUtc ? e.end : e.end.toUtc();
      buf.writeln(
          'DTSTART:${_stamp(utcStart, utc: true, dateOnly: false)}');
      buf.writeln('DTEND:${_stamp(utcEnd, utc: true, dateOnly: false)}');
    }
    buf.writeln(_fold('SUMMARY:${_escape(e.title)}'));
    if (e.description != null && e.description!.isNotEmpty) {
      buf.writeln(_fold('DESCRIPTION:${_escape(e.description!)}'));
    }
    if (e.location != null && e.location!.isNotEmpty) {
      buf.writeln(_fold('LOCATION:${_escape(e.location!)}'));
    }
    for (final a in e.attendees) {
      buf.writeln(_fold('ATTENDEE;CN=${_escape(a)}:mailto:$a'));
    }
    buf.writeln('END:VEVENT');
  }
  buf.writeln('END:VCALENDAR');
  return buf.toString().replaceAll('\n', '\r\n');
}
