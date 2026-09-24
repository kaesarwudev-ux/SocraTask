import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/widgets/animated_trash.dart';
import 'package:socra_task/features/calendar/data/calendar_providers.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/calendar/presentation/bubble_placement.dart';
import 'package:socra_task/features/calendar/presentation/full_editor.dart';
import 'package:socra_task/features/calendar/presentation/time_grid.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

/// Google-style inline bubbles: quick-create beside the tap point and an
/// event detail bubble on block taps. Positioned in the overlay next to
/// the tap, clamped on-screen — never a centered dialog.
class CalendarBubbles {
  static OverlayEntry? _current;

  static void hide() {
    try {
      _current?.remove();
    } catch (_) {
      // Already detached (e.g. previous test's tree is gone).
    }
    _current = null;
  }

  static void _showAt(
    BuildContext context,
    GridTap tap, {
    required Widget child,
    required Key bubbleKey,
    required double estHeight,
  }) {
    hide();
    final size = MediaQuery.sizeOf(context);
    // Day: large centered (560). Week/4-day: compact so it can sit
    // *right beside* the block with a tiny gap.
    final maxW = tap.singleDay ? 560.0 : 480.0;
    final width = math.min(maxW, math.max(300.0, size.width - 32));
    late double left;
    late Alignment alignment;
    // Edges of the tapped content (day column, or just the tap point).
    // A block tap additionally carries the block's own rect: the bubble
    // docks beside the block itself, never over it.
    final anchor = tap.anchorRect;
    final hasColumn =
        tap.dayRect != Rect.zero && tap.dayRect.width > 1;
    final rightEdge =
        anchor?.right ?? (hasColumn ? tap.dayRect.right : tap.global.dx);
    final leftEdge =
        anchor?.left ?? (hasColumn ? tap.dayRect.left : tap.global.dx);
    if (tap.singleDay) {
      // Day view: centered on screen.
      left = (size.width - width) / 2;
      alignment = Alignment.center;
    } else {
      // Sit *very close* beside the block — 2px gap, like Google.
      // Prefer the side with more free space, but never let it drift
      // far from the block: if the preferred side doesn't fit, try the
      // other side; if neither fits, clamp to the edge.
      const gap = 2.0;
      final spaceRight = size.width - 16 - (rightEdge + gap);
      final spaceLeft = leftEdge - gap - 16;
      final wantRight = spaceRight >= spaceLeft;
      if (wantRight && rightEdge + gap + width <= size.width - 16) {
        left = rightEdge + gap;
        alignment = Alignment.centerLeft;
      } else if (!wantRight && leftEdge - gap - width >= 16) {
        left = leftEdge - width - gap;
        alignment = Alignment.centerRight;
      } else if (rightEdge + gap + width <= size.width - 16) {
        left = rightEdge + gap;
        alignment = Alignment.centerLeft;
      } else if (leftEdge - gap - width >= 16) {
        left = leftEdge - width - gap;
        alignment = Alignment.centerRight;
      } else {
        // No side fits whole — pin to the edge with the larger gap,
        // still as close as possible to the block.
        left = wantRight
            ? math.min(rightEdge + gap, size.width - width - 16)
            : math.max(16.0, leftEdge - width - gap);
        alignment =
            wantRight ? Alignment.centerLeft : Alignment.centerRight;
      }
    }
    left = math.min(
        math.max(left, 16.0), math.max(16.0, size.width - width - 16));
    // Sit with its top edge flush to the block's top (4px gap),
    // *very close* like Google's bubble — you can still see the block.
    // Clamped to stay on-screen.
    final anchorTop = anchor?.top ?? tap.global.dy;
    var top = math.min(
        math.max(anchorTop, 72.0),
        math.max(72.0, size.height - estHeight - 16));
    // The avoid-rect dodge refines post-layout with the measured height
    // (estimates are conservative), so tall bubbles still clear blocks.
    final entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Clicks outside dismiss (transparent, so the grid stays live).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: hide,
              child: const SizedBox.expand(),
            ),
          ),
          _DodgingBubble(
            left: left,
            top: top,
            width: width,
            viewportHeight: size.height,
            avoid: tap.anchorRect,
            alignment: alignment,
            bubbleKey: bubbleKey,
            child: child,
          ),
        ],
      ),
    );
    _current = entry;
    Overlay.of(context).insert(entry);
  }

  /// Quick-create anchored beside the tapped grid slot. The draft event
  /// is inserted FIRST so its block renders instantly; the bubble then
  /// edits that draft live. Untitled drafts show as "(No title)".
  static Future<void> showQuickCreate(
    BuildContext context,
    WidgetRef ref,
    GridTap tap,
  ) async {
    final start = tap.slot;
    final draftId =
        await ref.read(eventRepositoryProvider).createEvent(
              title: '',
              start: start,
              end: start.add(const Duration(hours: 1)),
            );
    if (!context.mounted) return;
    // Anchor to the fresh block's own rect.
    final top = topFor(start, gridHourHeight);
    final height = heightFor(
        start, start.add(const Duration(hours: 1)), gridHourHeight);
    final anchor = Rect.fromLTWH(
      tap.dayRect.left + 2,
      tap.dayRect.top + top,
      math.max(0.0, tap.dayRect.width - 4),
      height,
    );
    _showAt(
      context,
      GridTap(
        slot: start,
        global: tap.global,
        dayRect: tap.dayRect,
        singleDay: tap.singleDay,
        anchorRect: anchor,
      ),
      bubbleKey: const Key('quick-bubble'),
      estHeight: 560,
      child: _QuickCreateBubble(draftId: draftId, initialStart: start),
    );
  }

  /// Detail bubble for an existing event block.
  static void showDetail(
    BuildContext context,
    WidgetRef ref,
    Event event,
    GridTap tap,
  ) {
    _showAt(
      context,
      tap,
      bubbleKey: const Key('detail-bubble'),
      estHeight: 300,
      child: _DetailBubble(event: event),
    );
  }

  /// Task detail bubble — same chrome as event detail but for a
  /// calendar task. Shows due date, complete + edit + delete.
  static void showTaskDetail(
    BuildContext context,
    WidgetRef ref,
    Task task,
    GridTap tap,
  ) {
    _showAt(
      context,
      tap,
      bubbleKey: const Key('task-detail-bubble'),
      estHeight: 260,
      child: _TaskDetailBubble(task: task),
    );
  }

  /// Detail bubble anchored near an agenda-row tap (no day column:
  /// docks to whichever side has room).
  static void showDetailCentered(
    BuildContext context,
    WidgetRef ref,
    Event event,
    Offset tap,
  ) {
    _showAt(
      context,
      GridTap(
        slot: event.start,
        global: tap,
        dayRect: Rect.zero,
        singleDay: false,
      ),
      bubbleKey: const Key('detail-bubble'),
      estHeight: 300,
      child: _DetailBubble(event: event),
    );
  }
}

/// Positions the bubble, then post-layout nudges it with its MEASURED
/// height so it never covers [avoid] (the tapped block) and never leaves
/// the viewport. Estimates alone can't do this: real content height
/// varies with text length, theme density and font scale.
class _DodgingBubble extends StatefulWidget {
  const _DodgingBubble({
    required this.left,
    required this.top,
    required this.width,
    required this.viewportHeight,
    required this.avoid,
    required this.alignment,
    required this.bubbleKey,
    required this.child,
  });

  final double left;
  final double top;
  final double width;
  final double viewportHeight;
  final Rect? avoid;
  final Alignment alignment;
  final Key bubbleKey;
  final Widget child;

  @override
  State<_DodgingBubble> createState() => _DodgingBubbleState();
}

class _DodgingBubbleState extends State<_DodgingBubble> {
  final _contentKey = GlobalKey();
  late double _top = widget.top;
  double? _cap;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _dodge());
  }

  void _dodge() {
    if (!mounted || _settled) return;
    final box =
        _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      // Layout not ready yet: retry next frame instead of giving up.
      WidgetsBinding.instance.addPostFrameCallback((_) => _dodge());
      return;
    }
    final p = refineBubble(
      left: widget.left,
      top: widget.top,
      width: widget.width,
      height: box.size.height,
      viewportHeight: widget.viewportHeight,
      avoid: widget.avoid,
    );
    // Always rebuild: this also flips the pre-settle Visibility on.
    setState(() {
      _top = p.top;
      _cap = p.maxHeight;
      _settled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: _top,
      width: widget.width,
      // Invisible (and untappable) until the dodge settles: no flash
      // of overlap, ever. Layout is maintained so measuring works.
      child: Visibility(
        visible: _settled,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        child: TapRegion(
          onTapOutside: (_) => CalendarBubbles.hide(),
          child: _Emerge(
            alignment: widget.alignment,
            // Hard guarantee: the bubble can never paint outside the
            // viewport — it scrolls internally instead of clipping.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: _cap ??
                    math.max(
                        200.0, widget.viewportHeight - 144),
              ),
              child: SingleChildScrollView(
                child: KeyedSubtree(
                  key: widget.bubbleKey,
                  child: Container(
                    key: _contentKey,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact delete feedback: message, 5-second countdown bar, Undo
/// action (via SnackBarAction) and an obvious dismiss cross.
class _UndoCountdown extends StatelessWidget {
  const _UndoCountdown({
    required this.label,
    required this.seconds,
    required this.onDismiss,
  });

  final String label;
  final int seconds;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 0.0),
                duration: Duration(seconds: seconds),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                    backgroundColor: scheme.onInverseSurface
                        .withValues(alpha: 0.2),
                  );
                },
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Dismiss',
          iconSize: 24,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close_outlined),
          onPressed: onDismiss,
        ),
      ],
    );
  }
}

/// Emerge animation: fades in while settling from 94% scale, anchored
/// to the side the bubble docked from.
class _Emerge extends StatefulWidget {
  const _Emerge({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;

  @override
  State<_Emerge> createState() => _EmergeState();
}

class _EmergeState extends State<_Emerge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 230),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        alignment: widget.alignment,
        scale: Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(
              parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: widget.child,
      ),
    );
  }
}

class _BubbleShell extends StatelessWidget {
  const _BubbleShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: child,
      ),
    );
  }
}

class _QuickCreateBubble extends ConsumerStatefulWidget {
  const _QuickCreateBubble({
    required this.draftId,
    required this.initialStart,
  });

  /// Row id of the already-inserted draft this bubble edits live.
  final int draftId;
  final DateTime initialStart;

  @override
  ConsumerState<_QuickCreateBubble> createState() =>
      _QuickCreateBubbleState();
}

class _QuickCreateBubbleState
    extends ConsumerState<_QuickCreateBubble> {
  final _title = TextEditingController();
  bool _isTask = false;
  late DateTime _start = widget.initialStart;
  late DateTime _end =
      widget.initialStart.add(const Duration(hours: 1));
  bool _allDay = false;
  String? _description;
  String? _location;
  int _feedId = 0;
  bool _saving = false;
  bool _saved = false;
  late final EventRepository _repo;

  @override
  void initState() {
    super.initState();
    // Captured here: ref must not be touched in dispose().
    _repo = ref.read(eventRepositoryProvider);
    _title.addListener(() {
      setState(() {});
      // Live block preview as you type.
      _repo.updateEvent(widget.draftId, title: _title.text);
    });
  }

  /// X-close: await the untitled-draft cleanup so callers observe a
  /// settled world; dispose() keeps a fire-and-forget backup for
  /// tap-outside dismissals.
  Future<void> _closeDiscard() async {
    if (!_saved && _title.text.trim().isEmpty) {
      _saved = true;
      await _repo.deleteEvent(widget.draftId);
    }
    CalendarBubbles.hide();
  }

  @override
  void dispose() {
    final title = _title.text.trim();
    if (!_saved && title.isEmpty) {
      // Dismissed an untitled draft: remove it again.
      _repo.deleteEvent(widget.draftId);
    } else if (!_saved) {
      // Dismissed a titled draft without Save: flush latest edits.
      _repo.updateEvent(
        widget.draftId,
        title: title,
        start: _start,
        end: _end.isAfter(_start)
            ? _end
            : _start.add(const Duration(hours: 1)),
        description: _description,
        location: _location,
        allDay: _allDay,
      );
    }
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTimes() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;
    if (_allDay) {
      setState(() {
        _start = date;
        _end = date;
      });
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (!mounted) return;
    setState(() {
      _start = DateTime(date.year, date.month, date.day,
          time?.hour ?? _start.hour, time?.minute ?? _start.minute);
      _end = _start.add(const Duration(hours: 1));
    });
    // Live block move.
    ref.read(eventRepositoryProvider).updateEvent(
          widget.draftId,
          start: _start,
          end: _end,
        );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final title = _title.text.trim();
    if (_isTask) {
      // Tasks live in the task list: drop the event draft, make a task.
      await ref
          .read(eventRepositoryProvider)
          .deleteEvent(widget.draftId);
      if (title.isNotEmpty) {
        final repo = ref.read(taskRepositoryProvider);
        final inbox = await repo.ensureDefaultList();
        final id = await repo.createTask(title, listId: inbox);
        await repo.setDueDate(id, _start);
      }
    } else {
      await ref.read(eventRepositoryProvider).updateEvent(
            widget.draftId,
            title: title,
            start: _start,
            end: _end.isAfter(_start)
                ? _end
                : _start.add(const Duration(hours: 1)),
            description: _description,
            location: _location,
            allDay: _allDay,
            feedId: _feedId == 0 ? null : _feedId,
          );
    }
    _saved = true;
    CalendarBubbles.hide();
  }

  void _moreOptions() async {
    _saved = true;
    CalendarBubbles.hide();
    final draft =
        await ref.read(eventRepositoryProvider).getEvent(widget.draftId);
    if (!mounted) return;
    if (draft == null) return;
    FullEditorPage.openEdit(context, ref, draft);
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final feeds = ref.watch(feedsProvider);
    final feedList = feeds.valueOrNull ?? const <CalendarFeed>[];
    if (_feedId == 0 && feedList.isNotEmpty) {
      _feedId = feedList.first.id;
    }
    final feed = feedList.where((f) => f.id == _feedId).firstOrNull;
    final dateLabel =
        '${loc.formatFullDate(_start)}, ${_allDay ? 'All day' : loc.formatTimeOfDay(TimeOfDay.fromDateTime(_start))}';
    return _BubbleShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.drag_handle_outlined,
                  size: 20, color: Colors.grey),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                iconSize: 20,
                icon: const Icon(Icons.close_outlined),
                onPressed: _closeDiscard,
              ),
            ],
          ),
          TextField(
            controller: _title,
            autofocus: true,
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: const InputDecoration(
              hintText: 'Add title',
              border: UnderlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          // Live summary: what the event looks like so far. Updates as
          // you type and pick, like Google's bubble.
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title.text.trim().isEmpty
                      ? '(No title)'
                      : _title.text.trim(),
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _title.text.trim().isEmpty
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                : null,
                          ),
                ),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TypeTab(
                label: 'Event',
                selected: !_isTask,
                onTap: () => setState(() => _isTask = false),
              ),
              const SizedBox(width: 4),
              _TypeTab(
                label: 'Task',
                selected: _isTask,
                onTap: () => setState(() => _isTask = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _pickTimes,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateLabel),
                        Text(
                          'Local time · Doesn’t repeat',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 20),
              const SizedBox(width: 16),
              const Text('All day'),
              const Spacer(),
              Switch(
                value: _allDay,
                onChanged: (v) {
                  setState(() => _allDay = v);
                  ref
                      .read(eventRepositoryProvider)
                      .updateEvent(widget.draftId, allDay: v);
                },
              ),
            ],
          ),
          _InlineField(
            icon: Icons.subject_outlined,
            hint: 'Add description',
            initial: _description,
            onSaved: (v) => _description = v,
          ),
          _InlineField(
            icon: Icons.place_outlined,
            hint: 'Add location',
            initial: _location,
            onSaved: (v) => _location = v,
          ),
          if (!_isTask && feedList.length > 1)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final pick = await showMenu<int>(
                  context: context,
                  position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                  items: [
                    for (final f in feedList)
                      PopupMenuItem(
                        value: f.id,
                        child: Text(f.name),
                      ),
                  ],
                );
                if (pick != null) setState(() => _feedId = pick);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text(feed?.name ?? 'Calendar')),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: eventPalette[
                            (feed?.colorId ?? 0) %
                                eventPalette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _moreOptions,
                child: Text('More options',
                    style: TextStyle(color: scheme.primary)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : null,
            fontWeight: selected ? FontWeight.w600 : null,
          ),
        ),
      ),
    );
  }
}

class _InlineField extends StatefulWidget {
  const _InlineField({
    required this.icon,
    required this.hint,
    required this.initial,
    required this.onSaved,
  });

  final IconData icon;
  final String hint;
  final String? initial;
  final ValueChanged<String?> onSaved;

  @override
  State<_InlineField> createState() => _InlineFieldState();
}

class _InlineFieldState extends State<_InlineField> {
  bool _open = false;
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    widget.onSaved(_ctrl.text.trim().isEmpty ? null : _ctrl.text.trim());
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_open && (widget.initial == null || widget.initial!.isEmpty)) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _open = true),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(widget.icon, size: 20),
              const SizedBox(width: 16),
              Text(widget.hint,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant)),
            ],
          ),
        ),
      );
    }
    return Row(
      children: [
        Icon(widget.icon, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _ctrl,
            autofocus: _open,
            decoration: InputDecoration(hintText: widget.hint),
          ),
        ),
      ],
    );
  }
}

class _DetailBubble extends ConsumerWidget {
  const _DetailBubble({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = MaterialLocalizations.of(context);
    final color =
        eventPalette[event.colorId % eventPalette.length];
    final when = event.allDay
        ? 'All day, ${loc.formatMediumDate(event.start)}'
        : '${loc.formatFullDate(event.start)}, '
            '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start))} – '
            '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end))}';
    return _BubbleShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit event',
                iconSize: 20,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  CalendarBubbles.hide();
                  FullEditorPage.openEdit(context, ref, event);
                },
              ),
              AnimatedTrashButton(
                tooltip: 'Delete event',
                onTap: () async {
                  // Google-style: delete immediately, offer Undo.
                  // Grab the messenger first: hiding the bubble below
                  // unmounts this context.
                  final messenger = ScaffoldMessenger.of(context);
                  final repo = ref.read(eventRepositoryProvider);
                  await repo.deleteEvent(event.id);
                  CalendarBubbles.hide();
                  messenger.showSnackBar(
                    SnackBar(
                      // Vanishes on its own after a few seconds, with a
                      // visible countdown bar.
                      duration: const Duration(seconds: 5),
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 8, 4),
                      content: _UndoCountdown(
                        label: 'Deleted “${event.title}”',
                        seconds: 5,
                        onDismiss: () =>
                            messenger.hideCurrentSnackBar(),
                      ),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          // Restore as a fresh row (same content).
                          await repo.createEvent(
                            title: event.title,
                            start: event.start,
                            end: event.end,
                            description: event.description,
                            location: event.location,
                            allDay: event.allDay,
                            colorId: event.colorId,
                            feedId: event.feedId,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Close',
                iconSize: 20,
                icon: const Icon(Icons.close_outlined),
                onPressed: CalendarBubbles.hide,
              ),
            ],
          ),
          Text(eventTitle(event),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(when,
              style: Theme.of(context).textTheme.bodyMedium),
          if (event.location != null && event.location!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(event.location!,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (event.description != null &&
              event.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(event.description!),
          ],
        ],
      ),
    );
  }
}

class _TaskDetailBubble extends ConsumerWidget {
  const _TaskDetailBubble({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = MaterialLocalizations.of(context);
    final due = task.dueAt == null
        ? 'No due date'
        : '${loc.formatFullDate(task.dueAt!)}, '
            '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(task.dueAt!))}';
    return _BubbleShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outlined, size: 14),
              const SizedBox(width: 6),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: Color(0xFF55825C), shape: BoxShape.circle),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit task',
                iconSize: 20,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  CalendarBubbles.hide();
                  // Reuse the Tasks quick-add flow for editing due date.
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: task.dueAt ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked == null || !context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: task.dueAt == null ? const TimeOfDay(hour: 9, minute: 0) : TimeOfDay.fromDateTime(task.dueAt!),
                  );
                  if (!context.mounted) return;
                  final dueAt = time == null
                      ? DateTime(picked.year, picked.month, picked.day)
                      : DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                  await ref.read(taskRepositoryProvider).setDueDate(task.id, dueAt);
                },
              ),
              IconButton(
                tooltip: 'Mark done',
                iconSize: 20,
                icon: Icon(task.done ? Icons.undo_outlined : Icons.check_outlined),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(taskRepositoryProvider).completeTask(task.id);
                  CalendarBubbles.hide();
                  messenger.showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 5),
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                      content: _UndoCountdown(label: 'Completed "${task.title}"', seconds: 5, onDismiss: () => messenger.hideCurrentSnackBar()),
                      action: SnackBarAction(label: 'Undo', onPressed: () async {
                        final db = ref.read(databaseProvider);
                        await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(const TasksCompanion(done: Value(false)));
                      }),
                    ),
                  );
                },
              ),
              AnimatedTrashButton(
                tooltip: 'Delete task',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final repo = ref.read(taskRepositoryProvider);
                  await repo.deleteTask(task.id);
                  CalendarBubbles.hide();
                  messenger.showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 5),
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                      content: _UndoCountdown(label: 'Deleted "${task.title}"', seconds: 5, onDismiss: () => messenger.hideCurrentSnackBar()),
                      action: SnackBarAction(label: 'Undo', onPressed: () async {
                        await repo.createTask(task.title, listId: task.listId);
                      }),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Close',
                iconSize: 20,
                icon: const Icon(Icons.close_outlined),
                onPressed: CalendarBubbles.hide,
              ),
            ],
          ),
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(due, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
