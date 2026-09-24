import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/core/widgets/animated_trash.dart';
import 'package:socra_task/core/widgets/socra_logo.dart';
import 'package:socra_task/core/widgets/theme_toggle.dart';
import 'package:socra_task/features/calendar/data/calendar_providers.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/calendar/presentation/calendar_bubbles.dart';
import 'package:socra_task/features/calendar/presentation/full_editor.dart';
import 'package:socra_task/features/calendar/presentation/time_grid.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

/// Google-Calendar parity: agenda + day + week + 4-day + month views,
/// timed/all-day events with details + location, task due-dates overlaid
/// in the agenda. Tap empty grid space to create at the tapped time.
/// Google-Calendar-style page: top bar (logo, Today, chevrons, title,
/// search, view dropdown), left sidebar (Create, mini calendar, feed
/// checkboxes, Tasks toggle), main grid. Accent stays SocraTask green.
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  /// Pixels per hour (single source lives in time_grid.dart).
  static const hourHeight = gridHourHeight;
  static const sidebarWidth = 280.0;

  static const palette = [
    SocraTheme.ecoGreen,
    Color(0xFF4F7CFF),
    Color(0xFFD9932A),
    Color(0xFF8E6FB8),
  ];

  static const viewLabels = {
    CalendarView.day: 'Day',
    CalendarView.week: 'Week',
    CalendarView.month: 'Month',
    CalendarView.year: 'Year',
    CalendarView.agenda: 'Schedule',
    CalendarView.fourDay: '4 days',
  };

  static const viewShortcuts = {
    CalendarView.day: 'D',
    CalendarView.week: 'W',
    CalendarView.month: 'M',
    CalendarView.year: 'Y',
    CalendarView.agenda: 'A',
    CalendarView.fourDay: 'X',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(calendarViewProvider);
    final day = ref.watch(selectedDayProvider);
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final loc = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: SafeArea(
          child: Padding(
            // Air above the chrome + inset from the window edges; the
            // hamburger lines up with the sidebar content below.
            padding:
                const EdgeInsets.only(left: 8, right: 12, top: 10),
            child: LayoutBuilder(
            builder: (context, constraints) {
              final roomy = constraints.maxWidth > 900;
              final medium = constraints.maxWidth > 640;
              return Row(
                children: [
                  IconButton(
                    tooltip: 'Main menu',
                    icon: const Icon(Icons.menu_outlined),
                    onPressed: () => ref
                        .read(sidebarCollapsedProvider.notifier)
                        .state = !collapsed,
                  ),
                  const SocraLogo(size: 36),
                  if (roomy) ...[
                    const SizedBox(width: 8),
                    Text('Calendar',
                        style:
                            Theme.of(context).textTheme.titleLarge),
                  ],
                  const SizedBox(width: 16),
                  FilledButton.tonal(
                    onPressed: () => ref
                        .read(selectedDayProvider.notifier)
                        .state = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day),
                    child: const Text('Today'),
                  ),
              IconButton(
                tooltip: 'Previous',
                icon: const Icon(Icons.chevron_left_outlined),
                onPressed: () =>
                    ref.read(selectedDayProvider.notifier).state =
                        _shift(day, view, -1),
              ),
              IconButton(
                tooltip: 'Next',
                icon: const Icon(Icons.chevron_right_outlined),
                onPressed: () =>
                    ref.read(selectedDayProvider.notifier).state =
                        _shift(day, view, 1),
              ),
              const SizedBox(width: 4),
              // Absorbs all free space so the right cluster stays docked
              // to the window edge on any width.
              Expanded(
                child: Text(
                  _titleFor(view, day, loc),
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (medium) ...[
                _SearchField(compact: !roomy),
                const SizedBox(width: 12),
              ],
              PopupMenuButton<CalendarView>(
                tooltip: 'Change view',
                offset: const Offset(0, 48),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label hidden on narrow windows to save space.
                      if (constraints.maxWidth > 900)
                        Text(viewLabels[view]!),
                      const Icon(Icons.arrow_drop_down_outlined),
                    ],
                  ),
                ),
                onSelected: (v) => ref
                    .read(calendarViewProvider.notifier)
                    .state = v,
                itemBuilder: (context) => [
                  for (final v in CalendarView.values)
                    PopupMenuItem(
                      value: v,
                      child: Row(
                        children: [
                          Expanded(child: Text(viewLabels[v]!)),
                          Text(viewShortcuts[v]!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall),
                        ],
                      ),
                    ),
                ],
              ),
              IconButton(
                tooltip: 'Calendar options',
                icon: const Icon(Icons.more_vert_outlined),
                onPressed: () => _CalendarsSheet.show(context),
              ),
              const ThemeToggleButton(),
            ],
          );
            },
          ),
        ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 1000;
          // Animated collapse: the sidebar glides shut and the grid
          // fluidly takes the freed space.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: wide && !collapsed ? sidebarWidth : 0,
                // Clip while gliding shut so content never paints outside.
                child: ClipRect(
                  child: OverflowBox(
                    minWidth: 0,
                    maxWidth: sidebarWidth,
                    alignment: Alignment.centerLeft,
                    child: const SizedBox(
                        width: sidebarWidth, child: _Sidebar()),
                  ),
                ),
              ),
              Expanded(child: _ViewBody(view: view, day: day)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add event',
        onPressed: () => FullEditorPage.openCreate(context, ref, day),
        child: const Icon(Icons.add),
      ),
    );
  }

  static DateTime _shift(DateTime day, CalendarView view, int dir) {
    if (view == CalendarView.month || view == CalendarView.year) {
      return DateTime(day.year, day.month + dir, 1);
    }
    final step = switch (view) {
      CalendarView.day => 1,
      CalendarView.week || CalendarView.agenda => 7,
      CalendarView.fourDay => 4,
      CalendarView.month || CalendarView.year => 30,
    };
    return day.add(Duration(days: step * dir));
  }

  static String _titleFor(
      CalendarView view, DateTime day, MaterialLocalizations loc) {
    if (view == CalendarView.month) {
      return '${_monthName(day.month)} ${day.year}';
    }
    if (view == CalendarView.year) {
      return '${day.year}';
    }
    return loc.formatMediumDate(day);
  }

  static String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m - 1];
}

/// Left sidebar: Create split button, mini month, feed checkboxes,
/// Tasks toggle. Mirrors Google's left rail.
class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final feeds = ref.watch(feedsProvider);
    final showTasks = ref.watch(showTasksProvider);
    final repo = ref.watch(eventRepositoryProvider);
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PopupMenuButton<String>(
          tooltip: 'Create',
          offset: const Offset(0, 48),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              boxShadow: kElevationToShadow[1],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_outlined),
                SizedBox(width: 8),
                Text('Create'),
                Icon(Icons.arrow_drop_down_outlined),
              ],
            ),
          ),
          onSelected: (choice) {
            if (choice == 'event') {
              FullEditorPage.openCreate(context, ref, day);
            } else {
              GoRouter.of(context).go('/tasks');
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'event', child: Text('Event')),
            PopupMenuItem(value: 'task', child: Text('Task')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                '${CalendarPage._monthName(day.month)} ${day.year}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Previous month',
              iconSize: 20,
              icon: const Icon(Icons.chevron_left_outlined),
              onPressed: () => ref
                  .read(selectedDayProvider.notifier)
                  .state = DateTime(day.year, day.month - 1, 1),
            ),
            IconButton(
              tooltip: 'Next month',
              iconSize: 20,
              icon: const Icon(Icons.chevron_right_outlined),
              onPressed: () => ref
                  .read(selectedDayProvider.notifier)
                  .state = DateTime(day.year, day.month + 1, 1),
            ),
          ],
        ),
        _MiniMonth(
          month: DateTime(day.year, day.month, 1),
          selected: day,
          onPick: (d) =>
              ref.read(selectedDayProvider.notifier).state = d,
        ),
        const SizedBox(height: 8),
        _Collapsible(
          title: 'My calendars',
          child: feeds.when(
            loading: () => const SizedBox.shrink(),
            error: (_, err) => const SizedBox.shrink(),
            data: (items) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final f
                    in items.where((f) => f.url.isEmpty))
                  _FeedCheck(
                    name: f.name,
                    color: eventPalette[
                        f.colorId % eventPalette.length],
                    value: f.enabled,
                    onChanged: (v) =>
                        repo.setFeedEnabled(f.id, v ?? true),
                  ),
                _FeedCheck(
                  name: 'Tasks',
                  color: scheme.primary,
                  value: showTasks,
                  onChanged: (v) => ref
                      .read(showTasksProvider.notifier)
                      .state = v ?? true,
                ),
              ],
            ),
          ),
        ),
        _Collapsible(
          title: 'Other calendars',
          trailing: IconButton(
            tooltip: 'Add calendar',
            iconSize: 20,
            icon: const Icon(Icons.add_outlined),
            onPressed: () => _CalendarsSheet.show(context),
          ),
          child: feeds.when(
            loading: () => const SizedBox.shrink(),
            error: (_, err) => const SizedBox.shrink(),
            data: (items) {
              final subs =
                  items.where((f) => f.url.isNotEmpty).toList();
              if (subs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  child: Text('No subscriptions yet'),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final f in subs)
                    _FeedCheck(
                      name: f.name,
                      color: eventPalette[
                          f.colorId % eventPalette.length],
                      value: f.enabled,
                      onChanged: (v) =>
                          repo.setFeedEnabled(f.id, v ?? true),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Collapsible extends StatefulWidget {
  const _Collapsible({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(widget.title)),
                if (widget.trailing != null) widget.trailing!,
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                      Icons.expand_more_outlined, size: 20),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _open ? widget.child : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _FeedCheck extends StatelessWidget {
  const _FeedCheck({
    required this.name,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String name;
  final Color color;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      hoverColor: SocraTheme.rowHover,
      onTap: () => onChanged(!value),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: value,
              visualDensity: VisualDensity.compact,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? color
                    : null,
              ),
              onChanged: onChanged,
            ),
            Expanded(child: Text(name)),
          ],
        ),
      ),
    );
  }
}

/// Compact month grid reused by the sidebar and the year view.
class _MiniMonth extends StatelessWidget {
  const _MiniMonth({
    required this.month,
    required this.selected,
    required this.onPick,
    this.showHeader = false,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onPick;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    const letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final gridStart =
        month.subtract(Duration(days: month.weekday % 7));
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              CalendarPage._monthName(month.month),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        Row(
          children: [
            for (final l in letters)
              Expanded(
                child: Center(
                  child: Text(l,
                      style:
                          Theme.of(context).textTheme.bodySmall),
                ),
              ),
          ],
        ),
        for (var r = 0; r < 6; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Builder(builder: (context) {
                  final d =
                      gridStart.add(Duration(days: r * 7 + c));
                  final inMonth = d.month == month.month;
                  final isToday = now.year == d.year &&
                      now.month == d.month &&
                      now.day == d.day;
                  final isSel = selected.year == d.year &&
                      selected.month == d.month &&
                      selected.day == d.day;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onPick(d),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        padding:
                            const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: isToday ? scheme.primary : null,
                          shape: BoxShape.circle,
                          border: isSel && !isToday
                              ? Border.all(color: scheme.primary)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isToday
                                  ? scheme.onPrimary
                                  : (inMonth
                                      ? null
                                      : scheme.onSurfaceVariant.withValues(
                                          alpha: 0.5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
      ],
    );
  }
}

/// Year view: twelve mini months; tapping a day opens it.
class _YearView extends ConsumerWidget {
  const _YearView({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Columns grow/shrink with the window, 2–4 across.
        final cols =
            (constraints.maxWidth / 320).floor().clamp(2, 4);
        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: 0.95,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: 12,
          itemBuilder: (context, i) {
            final month = DateTime(day.year, i + 1, 1);
            return _MiniMonth(
              month: month,
              selected: day,
              showHeader: true,
              onPick: (d) {
                ref.read(selectedDayProvider.notifier).state = d;
                ref.read(calendarViewProvider.notifier).state =
                    CalendarView.day;
              },
            );
          },
        );
      },
    );
  }
}

/// Inline top-bar search: compact field that widens slightly on focus.
/// Typing drops down matching events; picking one opens its editor.
/// The text field shows the native I-beam cursor on hover.
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({this.compact = false});

  /// Narrow windows get a slimmer field.
  final bool compact;

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _fieldKey = GlobalKey();
  OverlayEntry? _entry;
  String _text = '';

  // Fixed once: computing from DateTime.now() in build would resubscribe
  // the range provider on every frame (infinite rebuild loop).
  late final DateTime _rangeFrom =
      DateTime.now().subtract(const Duration(days: 60));
  late final DateTime _rangeTo =
      DateTime.now().add(const Duration(days: 60));

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) {
        _hideResults();
      }
      // Width animates with focus.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hideResults();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _hideResults() {
    _entry?.remove();
    _entry = null;
  }

  void _refreshResults() {
    if (_text.isEmpty || !_focus.hasFocus) {
      _hideResults();
      return;
    }
    if (_entry == null) {
      final box =
          _fieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final topLeft = box.localToGlobal(Offset.zero);
      _entry = OverlayEntry(
        builder: (context) => Positioned(
          left: topLeft.dx,
          top: topLeft.dy + box.size.height + 8,
          width: 320,
          child: TapRegion(
            onTapOutside: (_) => _hideResults(),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 320),
                child: _ResultsList(
                  range: (_rangeFrom, _rangeTo),
                  query: _text,
                  onPick: (e) {
                    _hideResults();
                    _focus.unfocus();
                    FullEditorPage.openEdit(context, ref, e);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: _fieldKey,
      duration: const Duration(milliseconds: 200),
      width:
          _focus.hasFocus ? (widget.compact ? 220 : 300) : (widget.compact ? 150 : 220),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search_outlined, size: 20),
          suffixIcon: _text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  iconSize: 18,
                  icon: const Icon(Icons.close_outlined),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _text = '');
                    _hideResults();
                  },
                ),
          isDense: true,
          filled: true,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (v) {
          setState(() => _text = v.trim());
          _refreshResults();
        },
        onSubmitted: (_) => _hideResults(),
      ),
    );
  }
}

/// Live results card for the inline search field.
class _ResultsList extends ConsumerWidget {
  const _ResultsList({
    required this.range,
    required this.query,
    required this.onPick,
  });

  final (DateTime, DateTime) range;
  final String query;
  final ValueChanged<Event> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(_rangeProvider(range));
    return eventsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (events) {
        final q = query.toLowerCase();
        final hits = events
            .where((e) =>
                e.title.toLowerCase().contains(q) ||
                (e.location?.toLowerCase().contains(q) ?? false))
            .take(8)
            .toList();
        if (hits.isEmpty) return const SizedBox.shrink();
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: [
            for (final e in hits)
              ListTile(
                dense: true,
                title: Text(eventTitle(e),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: e.location != null
                    ? Text(e.location!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                    : null,
                onTap: () => onPick(e),
              ),
          ],
        );
      },
    );
  }
}

class _ViewBody extends ConsumerWidget {
  const _ViewBody({required this.view, required this.day});

  final CalendarView view;
  final DateTime day;

  static DateTime _sunday(DateTime d) {
    final m = DateTime(d.year, d.month, d.day);
    return m.subtract(Duration(days: m.weekday % 7));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (view) {
      CalendarView.agenda => _AgendaList(day: day),
      CalendarView.day => _TimedView(days: [day]),
      CalendarView.week => _TimedView(
          days: [for (var i = 0; i < 7; i++) _sunday(day).add(Duration(days: i))],
        ),
      CalendarView.fourDay => _TimedView(
          days: [for (var i = 0; i < 4; i++) day.add(Duration(days: i))],
        ),
      CalendarView.month => _MonthView(day: day),
      CalendarView.year => _YearView(day: day),
    };
  }
}

/// Timed grid (day/week/4-day) with all-day strip on top.
class _TimedView extends ConsumerWidget {
  const _TimedView({required this.days});

  final List<DateTime> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = days.first;
    final last = days.last;
    final eventsAsync = ref.watch(_rangeProvider((first, last)));
    final tasksAsync = ref.watch(tasksStreamProvider);
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (events) {
        final byDay = <DateTime, List<Event>>{};
        final allDayByDay = <DateTime, List<Event>>{};
        for (final e in events) {
          if (e.allDay) {
            for (final d in days) {
              if (!_sameDay(e.start, d) && !_spans(e, d)) continue;
              (allDayByDay[d] ??= []).add(e);
            }
            continue;
          }
          for (final d in days) {
            if (!_sameDay(e.start, d) && !_spans(e, d)) continue;
            (byDay[d] ??= []).add(e);
          }
        }
        // Surface scheduled todos (tasks with due date) in calendar grids
        final tasksByDay = <DateTime, List<Task>>{};
        final tasks = tasksAsync.valueOrNull ?? const <Task>[];
        for (final t in tasks) {
          if (t.done || t.dueAt == null) continue;
          for (final d in days) {
            if (t.dueAt!.year == d.year && t.dueAt!.month == d.month && t.dueAt!.day == d.day) {
              (tasksByDay[d] ??= []).add(t);
            }
          }
        }
        return TimeGrid(
          days: days,
          eventsByDay: byDay,
          allDayByDay: allDayByDay,
          tasksByDay: tasksByDay,
          onEmptySlot: (tap) => CalendarBubbles.showQuickCreate(
              context, ref, tap),
          onEventTap: (e, tap) =>
              CalendarBubbles.showDetail(context, ref, e, tap),
          onTaskTap: (t, tap) =>
              CalendarBubbles.showTaskDetail(context, ref, t, tap),
        );
      },
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _spans(Event e, DateTime d) {
    final start = DateTime(d.year, d.month, d.day);
    final end = start.add(const Duration(days: 1));
    return e.start.isBefore(end) && e.end.isAfter(start);
  }
}

final _rangeProvider = StreamProvider.autoDispose
    .family<List<Event>, (DateTime, DateTime)>((ref, range) {
  return ref
      .watch(eventRepositoryProvider)
      .watchRange(range.$1, range.$2);
});

class _AgendaList extends ConsumerWidget {
  const _AgendaList({required this.day});

  final DateTime day;

  String _header(DateTime d, MaterialLocalizations loc) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = that.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return loc.formatFullDate(that);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(agendaProvider(day));
    final tasks = ref.watch(tasksStreamProvider);
    final showTasks = ref.watch(showTasksProvider);
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load events: $e')),
      data: (items) {
        final windowEnd = day.add(const Duration(days: 7));
        final dueTasks = showTasks
            ? (tasks.valueOrNull ?? [])
                .where((t) =>
                    t.dueAt != null &&
                    !t.dueAt!.isBefore(day) &&
                    t.dueAt!.isBefore(windowEnd))
                .toList()
            : <Task>[];
        if (items.isEmpty && dueTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                const Text('Nothing scheduled this week'),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => FullEditorPage.openCreate(
                      context, ref, day),
                  icon: const Icon(Icons.add_outlined),
                  label: const Text('Create event'),
                ),
              ],
            ),
          );
        }
        final byDay = <DateTime, List<_AgendaEntry>>{};
        for (final e in items) {
          final d = DateTime(e.start.year, e.start.month, e.start.day);
          (byDay[d] ??= []).add(_AgendaEntry.event(e));
        }
        for (final t in dueTasks) {
          final d = DateTime(
              t.dueAt!.year, t.dueAt!.month, t.dueAt!.day);
          (byDay[d] ??= []).add(_AgendaEntry.task(t));
        }
        final days = byDay.keys.toList()..sort();
        final loc = MaterialLocalizations.of(context);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
          itemCount: days.length,
          itemBuilder: (context, i) {
            final d = days[i];
            final entries = byDay[d]!..sort(_byTime);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_header(d, loc),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                for (final entry in entries)
                  _AgendaRow(entry: entry, day: d),
              ],
            );
          },
        ),
          ),
        );
      },
    );
  }

  static int _byTime(_AgendaEntry a, _AgendaEntry b) {
    DateTime ta, tb;
    bool aa, ab;
    if (a.event != null) {
      ta = a.event!.start;
      aa = a.event!.allDay;
    } else {
      ta = a.task!.dueAt!;
      aa = false;
    }
    if (b.event != null) {
      tb = b.event!.start;
      ab = b.event!.allDay;
    } else {
      tb = b.task!.dueAt!;
      ab = false;
    }
    if (aa != ab) return aa ? -1 : 1;
    return ta.compareTo(tb);
  }
}

class _AgendaEntry {
  _AgendaEntry.event(this.event) : task = null;
  _AgendaEntry.task(this.task) : event = null;
  final Event? event;
  final Task? task;
}

class _AgendaRow extends ConsumerWidget {
  const _AgendaRow({required this.entry, required this.day});

  final _AgendaEntry entry;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (entry.task != null) {
      final t = entry.task!;
      final time = loc.formatTimeOfDay(TimeOfDay.fromDateTime(t.dueAt!));
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          t.done
              ? Icons.check_circle_outlined
              : Icons.circle_outlined,
          color: t.done ? SocraTheme.ecoGreen : scheme.onSurfaceVariant,
        ),
        title: Text(t.title,
            style: t.done
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null),
        trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      );
    }
    final e = entry.event!;
    final color = eventPalette[e.colorId % eventPalette.length];
    final when = e.allDay
        ? 'All day'
        : '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(e.start))} – '
            '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(e.end))}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => CalendarBubbles.showDetailCentered(
          context, ref, e, details.globalPosition),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventTitle(e),
                      style: Theme.of(context).textTheme.bodyLarge),
                  if (e.location != null && e.location!.isNotEmpty)
                    Text(e.location!,
                        style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text(when, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MonthView extends ConsumerWidget {
  const _MonthView({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthStart = DateTime(day.year, day.month, 1);
    final gridStart =
        monthStart.subtract(Duration(days: monthStart.weekday % 7));
    final gridEnd = gridStart.add(const Duration(days: 41));
    final eventsAsync = ref.watch(_rangeProvider((gridStart, gridEnd)));
    final tasksAsync = ref.watch(tasksStreamProvider);
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (events) {
        final byDay = <DateTime, List<Event>>{};
        for (final e in events) {
          var d = DateTime(e.start.year, e.start.month, e.start.day);
          final last =
              DateTime(e.end.year, e.end.month, e.end.day);
          while (!d.isAfter(last)) {
            (byDay[d] ??= []).add(e);
            d = d.add(const Duration(days: 1));
          }
        }
        // Google-style: tasks with a due date appear on that day too,
        // with a checkbox icon so you can tell them apart.
        final tasksByDay = <DateTime, List<Task>>{};
        for (final t in tasksAsync.valueOrNull ?? const <Task>[]) {
          if (t.done || t.dueAt == null) continue;
          final d = DateTime(t.dueAt!.year, t.dueAt!.month, t.dueAt!.day);
          if (!d.isBefore(gridStart) && !d.isAfter(gridEnd)) {
            (tasksByDay[d] ??= []).add(t);
          }
        }
        const letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
        return Column(
          children: [
            Row(
              children: [
                for (final l in letters)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 4),
                        child: Text(l,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.0,
                ),
                itemCount: 42,
                itemBuilder: (context, i) {
                  final d = gridStart.add(Duration(days: i));
                  final inMonth = d.month == day.month;
                  final dayEvents = byDay[d] ?? const <Event>[];
                  final now = DateTime.now();
                  final isToday = now.year == d.year &&
                      now.month == d.month &&
                      now.day == d.day;
                  final scheme = Theme.of(context).colorScheme;
                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedDayProvider.notifier).state = d;
                      ref
                          .read(calendarViewProvider.notifier)
                          .state = CalendarView.day;
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: inMonth
                            ? scheme.surfaceContainerLow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: scheme.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: isToday
                                  ? BoxDecoration(
                                      color: scheme.primary,
                                      shape: BoxShape.circle)
                                  : null,
                              child: Text(
                                '${d.day}',
                                style: TextStyle(
                                  color: isToday
                                      ? scheme.onPrimary
                                      : (inMonth
                                          ? null
                                          : scheme.onSurfaceVariant
                                              .withValues(alpha: 0.5)),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                           for (final e in dayEvents.take(2))
                             Padding(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 4, vertical: 1),
                               child: Container(
                                 width: double.infinity,
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4, vertical: 1),
                                 decoration: BoxDecoration(
                                   color: eventPalette[
                                           e.colorId %
                                               eventPalette.length]
                                       .withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(4),
                                 ),
                                 child: Text(
                                   e.title,
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                   style: const TextStyle(fontSize: 10),
                                 ),
                               ),
                             ),
                           // Tasks on this day — with a checkbox icon so
                           // you can tell them from events at a glance.
                           for (final t
                               in (tasksByDay[d] ?? const <Task>[]).take(
                                   dayEvents.isEmpty ? 2 : 1))
                             Padding(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 4, vertical: 1),
                               child: Container(
                                 width: double.infinity,
                                 padding: const EdgeInsets.symmetric(
                                     horizontal: 4, vertical: 1),
                                 decoration: BoxDecoration(
                                   color: SocraTheme.ecoGreen
                                       .withValues(alpha: 0.18),
                                   borderRadius: BorderRadius.circular(4),
                                 ),
                                 child: Row(
                                   children: [
                                     const Icon(
                                         Icons
                                             .check_box_outline_blank_outlined,
                                         size: 10),
                                     const SizedBox(width: 2),
                                     Expanded(
                                       child: Text(
                                         t.title,
                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                         style: const TextStyle(
                                             fontSize: 10),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           if (dayEvents.length +
                                   (tasksByDay[d]?.length ?? 0) >
                               2)
                             Padding(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 4),
                               child: Text(
                                 '+${dayEvents.length + (tasksByDay[d]?.length ?? 0) - 2}',
                                 style: TextStyle(
                                     fontSize: 10,
                                     color: scheme.onSurfaceVariant),
                               ),
                             ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Create/edit sheet for events.

/// Calendars sheet: visibility toggles, refresh, import/export, subscribe.
/// Same dialog language as Tasks (280-wide, red destructive confirms).
class _CalendarsSheet extends ConsumerWidget {
  const _CalendarsSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _CalendarsSheet(),
    );
  }

  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );
    if (picked.isEmpty || !context.mounted) return;
    final file = picked.single;
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      bytes = null;
    }
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read that file')),
        );
      }
      return;
    }
    try {
      final name = file.name.replaceAll(RegExp(r'\.ics$', caseSensitive: false), '');
      await ref
          .read(eventRepositoryProvider)
          .importIcs(utf8.decode(bytes), name: name);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  Future<void> _exportFeed(
      BuildContext context, WidgetRef ref, CalendarFeed feed) async {
    final ics =
        await ref.read(eventRepositoryProvider).exportFeed(feed.id);
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Export ${feed.name}',
      fileName: '${feed.name}.ics',
      bytes: Uint8List.fromList(utf8.encode(ics)),
    );
    if (uri == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to $uri')),
    );
  }

  Future<void> _subscribeDialog(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final url = TextEditingController();
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Subscribe via link'),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Paste a Google or Outlook calendar’s secret iCal address '
                  '(it ends in .ics). SocraTask pulls it over HTTPS — '
                  'nothing leaves your device except that download.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: url,
                  decoration:
                      const InputDecoration(labelText: 'Calendar URL'),
                  keyboardType: TextInputType.url,
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(eventRepositoryProvider)
                      .subscribeFeed(name: name.text, url: url.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  setState(() => error = '$e'.replaceFirst('Exception: ', ''));
                }
              },
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    url.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(feedsProvider);
    final repo = ref.watch(eventRepositoryProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Calendars',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Flexible(
              child: feeds.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Could not load: $e'),
                data: (items) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final feed in items)
                      _FeedRow(
                        feed: feed,
                        onToggle: (v) =>
                            repo.setFeedEnabled(feed.id, v),
                        onRefresh: feed.url.isEmpty
                            ? null
                            : () async {
                                try {
                                  await repo.refreshFeed(feed.id);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                'Refresh failed: $e')));
                                  }
                                }
                              },
                        onExport: () =>
                            _exportFeed(context, ref, feed),
                        onDelete: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title:
                                  const Text('Delete this calendar?'),
                              content: Text(
                                  '“${feed.name}” and its events will be removed from this device.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Keep'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .error,
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await repo.deleteFeed(feed.id);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _importFile(context, ref),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Import .ics file'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _subscribeDialog(context, ref),
                    icon: const Icon(Icons.link_outlined),
                    label: const Text('Subscribe via link'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedRow extends StatelessWidget {
  const _FeedRow({
    required this.feed,
    required this.onToggle,
    required this.onRefresh,
    required this.onExport,
    required this.onDelete,
  });

  final CalendarFeed feed;
  final ValueChanged<bool> onToggle;
  final Future<void> Function()? onRefresh;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sub = feed.url.isEmpty
        ? 'On this device'
        : 'Synced${feed.lastSyncAt == null ? '' : ' · ${MaterialLocalizations.of(context).formatMediumDate(feed.lastSyncAt!)}'}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: SocraTheme.rowHover,
          onTap: () => onToggle(!feed.enabled),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: eventPalette[
                        feed.colorId % eventPalette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feed.name),
                      Text(sub,
                          style:
                              Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    tooltip: 'Refresh now',
                    iconSize: 20,
                    icon: const Icon(Icons.refresh_outlined),
                    onPressed: onRefresh,
                  ),
                IconButton(
                  tooltip: 'Export .ics',
                  iconSize: 20,
                  icon: const Icon(Icons.download_outlined),
                  onPressed: onExport,
                ),
                Switch(value: feed.enabled, onChanged: onToggle),
                AnimatedTrashButton(
                  tooltip: 'Delete calendar',
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
