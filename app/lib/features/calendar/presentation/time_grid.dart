import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/calendar_providers.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';

/// Snaps a vertical grid offset to a 30-minute slot on [day].
DateTime slotForOffset({
  required DateTime day,
  required double dy,
  required double hourHeight,
}) {
  final totalMinutes = (dy / hourHeight * 60).round();
  final snapped = (totalMinutes ~/ 30) * 30;
  final clamped = snapped.clamp(0, 23 * 60 + 30);
  return DateTime(day.year, day.month, day.day).add(
    Duration(minutes: clamped),
  );
}

double topFor(DateTime t, double hourHeight) =>
    (t.hour * 60 + t.minute) / 60 * hourHeight;

double heightFor(DateTime start, DateTime end, double hourHeight) {
  final h = end.difference(start).inMinutes.clamp(30, 24 * 60) /
      60 *
      hourHeight;
  return h.clamp(40.0, 24 * hourHeight);
}

/// Local time-zone label like "GMT+12" / "GMT-5:30", as above the gutter.
String gmtLabel() {
  final offset = DateTime.now().timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs();
  final minutes = offset.inMinutes.abs() % 60;
  if (minutes == 0) return 'GMT$sign$hours';
  return 'GMT$sign$hours:${minutes.toString().padLeft(2, '0')}';
}

/// Tap context: derived slot, global tap point, the tapped day column's
/// global rect, and — for block taps — the tapped block's own global
/// rect, so bubbles dock beside the block instead of over it.
class GridTap {
  const GridTap({
    required this.slot,
    required this.global,
    required this.dayRect,
    required this.singleDay,
    this.anchorRect,
  });

  final DateTime slot;
  final Offset global;
  final Rect dayRect;
  final bool singleDay;
  final Rect? anchorRect;
}

/// Pixels per hour in the timed grids.
const gridHourHeight = 64.0;

/// Shared timed grid for Day (1 col), 4-day and Week views.
/// One tap handler hit-tests event blocks first, so tapping a block edits
/// it while tapping empty space creates an event at the tapped time —
/// no gesture-arena conflicts.
class TimeGrid extends ConsumerWidget {
  const TimeGrid({
    required this.days,
    required this.eventsByDay,
    required this.allDayByDay,
    this.tasksByDay = const {},
    required this.onEmptySlot,
    required this.onEventTap,
    this.onTaskTap,
    super.key,
  });

  final List<DateTime> days;
  final Map<DateTime, List<Event>> eventsByDay;
  final Map<DateTime, List<Event>> allDayByDay;
  final Map<DateTime, List<Task>> tasksByDay;

  /// Empty slot tapped, with anchor context for the bubble.
  final void Function(GridTap tap) onEmptySlot;

  /// Existing block tapped, with anchor context for the bubble.
  final void Function(Event event, GridTap tap) onEventTap;
  final void Function(Task task, GridTap tap)? onTaskTap;

  // Wide enough for "10:00 AM" on one line at bodySmall.
  static const gutterWidth = 70.0;
  static const minColWidth = 150.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Columns never squeeze below a readable width; the grid scrolls
        // sideways instead and stretches fluidly on wide windows.
        final tight = constraints.maxWidth - gutterWidth <
            days.length * minColWidth;
        final contentWidth = tight
            ? gutterWidth + days.length * minColWidth
            : constraints.maxWidth;
        // Reserve 1px per inter-column divider so the row sums exactly.
        final colWidth = (contentWidth -
                gutterWidth -
                (days.length - 1)) /
            days.length;
        final header = SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              // Day headers on top…
              Row(
                children: [
                  const SizedBox(width: gutterWidth),
                  for (var i = 0; i < days.length; i++) ...[
                    if (i > 0) const VerticalDivider(width: 1),
                    SizedBox(
                      width: colWidth,
                      child: Container(
                        key: const Key('week-col'),
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        child: _DayHeader(day: days[i]),
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(height: 1),
              // …then GMT + all-day strip pinned right under the dates.
              Row(
                key: const Key('allday-strip'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: gutterWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        gmtLabel(),
                        style:
                            Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  for (var i = 0; i < days.length; i++) ...[
                    if (i > 0) const VerticalDivider(width: 1),
                    SizedBox(
                      width: colWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final e in allDayByDay[days[i]] ??
                              const <Event>[])
                            _AllDayChip(
                              event: e,
                              onTapUp: (pos) => onEventTap(
                                e,
                                GridTap(
                                  slot: e.start,
                                  global: pos,
                                  // Chips anchor to the tap point itself.
                                  dayRect: Rect.zero,
                                  singleDay: days.length == 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(height: 1),
            ],
          ),
        );
        // Hour rows scroll under the pinned header above.
        final body = _GridBody(
          days: days,
          eventsByDay: eventsByDay,
          tasksByDay: tasksByDay,
          contentWidth: contentWidth,
          colWidth: colWidth,
          onEmptySlot: onEmptySlot,
          onEventTap: onEventTap,
          onTaskTap: onTaskTap,
        );
        final content = Column(
          children: [
            header,
            Expanded(
              child: SingleChildScrollView(child: body),
            ),
          ],
        );
        return tight
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: content,
              )
            : content;
      },
    );
  }

}

/// Hour grid with its own detector key, so tap-to-global-rect math is
/// exact (no ambiguous ancestor lookups).
class _GridBody extends ConsumerStatefulWidget {
  const _GridBody({
    required this.days,
    required this.eventsByDay,
    this.tasksByDay = const {},
    required this.contentWidth,
    required this.colWidth,
    required this.onEmptySlot,
    required this.onEventTap,
    this.onTaskTap,
  });

  final List<DateTime> days;
  final Map<DateTime, List<Event>> eventsByDay;
  final Map<DateTime, List<Task>> tasksByDay;
  final double contentWidth;
  final double colWidth;
  final void Function(GridTap tap) onEmptySlot;
  final void Function(Event event, GridTap tap) onEventTap;
  final void Function(Task task, GridTap tap)? onTaskTap;

  @override
  ConsumerState<_GridBody> createState() => _GridBodyState();
}

class _GridBodyState extends ConsumerState<_GridBody> {
  final _detectorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final days = widget.days;
    final colWidth = widget.colWidth;
    return SizedBox(
      key: const Key('time-grid'),
      width: widget.contentWidth,
      height: 24 * gridHourHeight,
      child: GestureDetector(
        key: _detectorKey,
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          // localPosition is already relative to this detector.
          // Columns are colWidth wide with 1px dividers between.
          const stepPad = 1.0;
          final local = details.localPosition;
          final stride = colWidth + stepPad;
          final col = ((local.dx - TimeGrid.gutterWidth) / stride)
              .floor()
              .clamp(0, days.length - 1);
          final day = days[col];
          final dy = local.dy
              .clamp(0.0, 24 * gridHourHeight);
          final box = _detectorKey.currentContext!.findRenderObject()!
              as RenderBox;
          final dayLeft = box
              .localToGlobal(Offset(
                  TimeGrid.gutterWidth + col * (colWidth + 1), 0))
              .dx;
          final dayRect = Rect.fromLTWH(
            dayLeft,
            box.localToGlobal(Offset.zero).dy,
            colWidth,
            24 * gridHourHeight,
          );
          final tap = GridTap(
            slot: slotForOffset(
              day: day,
              dy: dy,
              hourHeight: gridHourHeight,
            ),
            global: details.globalPosition,
            dayRect: dayRect,
            singleDay: days.length == 1,
          );
          // Event block hit first; anchor to the block's own rect so
          // the bubble docks beside it, not over it.
          for (final e in widget.eventsByDay[day] ?? const <Event>[]) {
            final top =
                topFor(e.start, gridHourHeight);
            final height = heightFor(
                e.start, e.end, gridHourHeight);
            if (dy >= top && dy <= top + height) {
              final blockLeft = box
                  .localToGlobal(Offset(
                      TimeGrid.gutterWidth +
                          col * (colWidth + 1) +
                          2,
                      0))
                  .dx;
              final blockTop =
                  box.localToGlobal(Offset(0, top)).dy;
              widget.onEventTap(
                e,
                GridTap(
                  slot: slotForOffset(
                    day: day,
                    dy: dy,
                    hourHeight: gridHourHeight,
                  ),
                  global: details.globalPosition,
                  dayRect: Rect.fromLTWH(
                    dayLeft,
                    box.localToGlobal(Offset.zero).dy,
                    colWidth,
                    24 * gridHourHeight,
                  ),
                  singleDay: days.length == 1,
                  anchorRect: Rect.fromLTWH(
                    blockLeft,
                    blockTop,
                    colWidth - 4,
                    height,
                  ),
                ),
              );
              return;
            }
          }
          // Empty slot: anchor to the nearest block in this column
          // (within ~5 hours) so the bubble docks beside existing
          // content instead of covering it.
          Rect? nearby;
          var nearest = double.infinity;
          for (final e in widget.eventsByDay[day] ?? const <Event>[]) {
            final top =
                topFor(e.start, gridHourHeight);
            final height = heightFor(
                e.start, e.end, gridHourHeight);
            final gap = top > dy
                ? top - dy
                : dy > top + height
                    ? dy - (top + height)
                    : 0.0;
            if (gap < nearest) {
              nearest = gap;
              final blockLeft = box
                  .localToGlobal(Offset(
                      TimeGrid.gutterWidth +
                          col * (colWidth + 1) +
                          2,
                      0))
                  .dx;
              nearby = Rect.fromLTWH(
                blockLeft,
                box.localToGlobal(Offset(0, top)).dy,
                colWidth - 4,
                height,
              );
            }
          }
          widget.onEmptySlot(
            GridTap(
              slot: tap.slot,
              global: tap.global,
              dayRect: tap.dayRect,
              singleDay: tap.singleDay,
              anchorRect:
                  nearest <= 5 * gridHourHeight ? nearby : null,
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: TimeGrid.gutterWidth,
              child: Column(
                children: [
                  for (var h = 0; h < 24; h++)
                    SizedBox(
                      height: gridHourHeight,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: Text(
                            MaterialLocalizations.of(context)
                                .formatTimeOfDay(TimeOfDay(
                                    hour: h, minute: 0)),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) const VerticalDivider(width: 1),
              SizedBox(
                width: colWidth,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        for (var h = 0; h < 24; h++)
                          SizedBox(
                            height: gridHourHeight,
                            child: const Divider(height: 1),
                          ),
                      ],
                    ),
                    for (final e in widget.eventsByDay[days[i]] ??
                        const <Event>[])
                      _Block(event: e),
                    for (final t in widget.tasksByDay[days[i]] ??
                        const <Task>[])
                      _TaskBlock(
                          task: t,
                          onTapUp: widget.onTaskTap == null
                              ? null
                              : (pos) => widget.onTaskTap!(
                                  t,
                                  GridTap(
                                      slot: t.dueAt!,
                                      global: pos,
                                      dayRect: Rect.zero,
                                      singleDay: days.length == 1))),
                    _ColumnNowLine(day: days[i]),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AllDayChip extends StatelessWidget {
  const _AllDayChip({required this.event, required this.onTapUp});

  final Event event;
  final ValueChanged<Offset> onTapUp;

  @override
  Widget build(BuildContext context) {
    final color =
        eventPalette[event.colorId % eventPalette.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => onTapUp(details.globalPosition),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    const letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final now = DateTime.now();
    final isToday = now.year == day.year &&
        now.month == day.month &&
        now.day == day.day;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(letters[day.weekday % 7],
            style: Theme.of(context).textTheme.bodySmall),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: isToday
              ? BoxDecoration(
                  color: scheme.primary, shape: BoxShape.circle)
              : null,
          child: Text(
            '${day.day}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                  color: isToday ? scheme.onPrimary : null,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final top = topFor(event.start, gridHourHeight);
    final height =
        heightFor(event.start, event.end, gridHourHeight);
    final color =
        eventPalette[event.colorId % eventPalette.length];
    final loc = MaterialLocalizations.of(context);
    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      // Solid fill, no side tag — like Google's blocks.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: height >= 32
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(eventTitle(event),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                  if (height >= 56)
                    Text(
                      '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start))} – '
                      '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end))}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _TaskBlock extends StatelessWidget {
  const _TaskBlock({required this.task, required this.onTapUp});

  final Task task;
  final ValueChanged<Offset>? onTapUp;

  @override
  Widget build(BuildContext context) {
    final start = task.dueAt!;
    // Tasks as 1-hour blocks at due time
    final top = topFor(start, gridHourHeight);
    const height = 32.0;
    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: onTapUp == null
            ? null
            : (details) => onTapUp!(details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF55825C).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outlined, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColumnNowLine extends StatelessWidget {
  const _ColumnNowLine({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    if (now.year != day.year ||
        now.month != day.month ||
        now.day != day.day) {
      return const SizedBox.shrink();
    }
    final color = Theme.of(context).colorScheme.error;
    return Positioned(
      key: const Key('now-line'),
      top: topFor(now, gridHourHeight),
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          Expanded(child: Container(height: 2, color: color)),
        ],
      ),
    );
  }
}
