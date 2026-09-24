import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

/// Shared event color palette (Google-style per-calendar colors).
const eventPalette = [
  SocraTheme.ecoGreen,
  Color(0xFF4F7CFF),
  Color(0xFFD9932A),
  Color(0xFF8E6FB8),
];

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(databaseProvider));
});

DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

final selectedDayProvider =
    StateProvider<DateTime>((ref) => _midnight(DateTime.now()));

enum CalendarView { agenda, day, week, fourDay, month, year }

final calendarViewProvider =
    StateProvider<CalendarView>((ref) => CalendarView.week);

final agendaProvider =
    StreamProvider.autoDispose.family<List<Event>, DateTime>((ref, day) {
  final start = _midnight(day);
  return ref
      .watch(eventRepositoryProvider)
      .watchRange(start, start.add(const Duration(days: 7)));
});

final dayEventsProvider =
    StreamProvider.autoDispose.family<List<Event>, DateTime>((ref, day) {
  return ref.watch(eventRepositoryProvider).watchDay(_midnight(day));
});

final feedsProvider = StreamProvider<List<CalendarFeed>>((ref) {
  return ref.watch(eventRepositoryProvider).watchFeeds();
});

/// Show task due-dates overlaid on the calendar (the "Tasks" calendar).
final showTasksProvider = StateProvider<bool>((ref) => true);

/// Left sidebar collapsed (hamburger).
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
