import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/calendar/data/calendar_providers.dart';
import 'package:socra_task/features/calendar/data/event_repository.dart';
import 'package:socra_task/features/calendar/data/ics.dart';

/// Full-screen event editor (Google's "More options" page): title bar
/// with Save, date/time pills, all-day + repeat, details/guests columns,
/// notifications, busy/visibility, description.
class FullEditorPage extends ConsumerStatefulWidget {
  const FullEditorPage({
    this.event,
    required this.initialStart,
    this.initialEnd,
    this.initialFeedId,
    this.initialTitle = '',
    this.initialDescription,
    this.initialLocation,
    super.key,
  });

  /// Null = create mode.
  final Event? event;
  final DateTime initialStart;
  final DateTime? initialEnd;
  final int? initialFeedId;
  final String initialTitle;
  final String? initialDescription;
  final String? initialLocation;

  static Future<void> openCreate(
    BuildContext context,
    WidgetRef ref,
    DateTime start, {
    int? feedId,
  }) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullEditorPage(
          initialStart: start,
          initialEnd: start.add(const Duration(hours: 1)),
          initialFeedId: feedId,
        ),
      ),
    );
  }

  static Future<void> openEdit(
      BuildContext context, WidgetRef ref, Event event) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullEditorPage(
          event: event,
          initialStart: event.start,
          initialEnd: event.end,
        ),
      ),
    );
  }

  @override
  ConsumerState<FullEditorPage> createState() => _FullEditorPageState();
}

class _Reminder {
  _Reminder({required this.email, required this.amount, required this.unit});

  bool email;
  int amount;
  String unit;

  String get label {
    final units = amount == 1 ? unit : '${unit}s';
    final base = '$amount $units before';
    return email ? 'Email $base' : base;
  }

  static _Reminder? parse(String label) {
    final m = RegExp(
            r'^(Email )?(\d+)\s+(minute|hour|day|week)s?\s+before$')
        .firstMatch(label.trim());
    if (m == null) return null;
    return _Reminder(
      email: m.group(1) != null,
      amount: int.parse(m.group(2)!),
      unit: m.group(3)!,
    );
  }
}

class _FullEditorPageState extends ConsumerState<FullEditorPage> {
  late final TextEditingController _title =
      TextEditingController(text: widget.event?.title ?? widget.initialTitle);
  late final TextEditingController _location = TextEditingController(
      text: widget.event?.location ?? widget.initialLocation ?? '');
  late final TextEditingController _description = TextEditingController(
      text: widget.event?.description ?? widget.initialDescription ?? '');
  final _guestCtrl = TextEditingController();
  late DateTime _start = widget.initialStart;
  late DateTime _end =
      widget.initialEnd ?? widget.initialStart.add(const Duration(hours: 1));
  late bool _allDay = widget.event?.allDay ?? false;
  late int _colorId = widget.event?.colorId ?? 0;
  int? _feedId;
  late final List<String> _guests = widget.event == null
      ? []
      : eventGuests(widget.event!);
  late bool _busy = widget.event?.busy ?? true;
  late String _visibility = widget.event?.visibility ?? 'Default';
  late final List<_Reminder> _reminders = widget.event == null
      ? [
          _Reminder(email: false, amount: 10, unit: 'minute'),
        ]
      : [
          for (final r in eventReminders(widget.event!))
            _Reminder.parse(r),
        ].whereType<_Reminder>().toList();
  late int _guestFlags = widget.event?.guestFlags ?? 6;
  int _tab = 0;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _guestCtrl.dispose();
    super.dispose();
  }

  bool get _isCreate => widget.event == null;

  Future<void> _pickDateTime(bool isStart) async {
    final initial = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;
    if (_allDay) {
      setState(() {
        if (isStart) {
          _start = date;
        } else {
          _end = date;
        }
      });
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted) return;
    setState(() {
      final picked = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? initial.hour,
        time?.minute ?? initial.minute,
      );
      if (isStart) {
        _start = picked;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give the event a title');
      return;
    }
    if (!_end.isAfter(_start)) {
      setState(() => _error = 'End must be after start');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(eventRepositoryProvider);
    final desc = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();
    final loc = _location.text.trim().isEmpty
        ? null
        : _location.text.trim();
    if (_isCreate) {
      await repo.createEvent(
        title: _title.text.trim(),
        start: _start,
        end: _end,
        description: desc,
        location: loc,
        allDay: _allDay,
        colorId: _colorId,
        feedId: _feedId,
        guests: _guests,
        busy: _busy,
        visibility: _visibility,
        reminders: [for (final r in _reminders) r.label],
        guestFlags: _guestFlags,
      );
    } else {
      await repo.updateEvent(
        widget.event!.id,
        title: _title.text.trim(),
        description: desc,
        location: loc,
        start: _start,
        end: _end,
        allDay: _allDay,
        colorId: _colorId,
        guests: _guests,
        busy: _busy,
        visibility: _visibility,
        reminders: [for (final r in _reminders) r.label],
        guestFlags: _guestFlags,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this event?'),
        content: Text('“${widget.event!.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(eventRepositoryProvider)
          .deleteEvent(widget.event!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _duplicate() async {
    final e = widget.event!;
    final repo = ref.read(eventRepositoryProvider);
    await repo.createEvent(
      title: '${e.title} (copy)',
      start: e.start,
      end: e.end,
      description: e.description,
      location: e.location,
      allDay: e.allDay,
      colorId: e.colorId,
      feedId: e.feedId,
      guests: eventGuests(e),
      busy: e.busy,
      visibility: e.visibility,
      reminders: eventReminders(e),
      guestFlags: e.guestFlags,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event duplicated')),
      );
    }
  }

  /// Saves this event as a standalone `.ics` file (print or publish).
  Future<void> _saveIcsFile(String action) async {
    final e = _isCreate ? null : widget.event!;
    final title = _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim();
    final ics = serializeIcs(
      events: [
        IcsEvent(
          uid: e == null
              ? 'socra-${DateTime.now().millisecondsSinceEpoch}'
              : (e.uid.isEmpty ? 'socra-event-${e.id}' : e.uid),
          title: title,
          start: _start,
          end: _end,
          allDay: _allDay,
          description: _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
          location: _location.text.trim().isEmpty
              ? null
              : _location.text.trim(),
          attendees: _guests,
        ),
      ],
      prodId: '-//SocraTask//EN',
    );
    final uri = await FilePicker.saveFile(
      dialogTitle: '$action event',
      fileName: '$title.ics',
      bytes: Uint8List.fromList(utf8.encode(ics)),
    );
    if (uri != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $uri')),
      );
    }
  }

  Future<void> _print() => _saveIcsFile('Print');

  Future<void> _publish() => _saveIcsFile('Publish');

  /// Change owner = move the event onto another calendar (feed).
  Future<void> _changeOwner() async {
    final feeds = await ref.read(feedsProvider.future);
    if (!mounted) return;
    final pick = await showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0),
      items: [
        for (final f in feeds)
          PopupMenuItem(value: f.id, child: Text(f.name)),
      ],
    );
    if (pick != null) {
      await ref.read(eventRepositoryProvider).moveEvent(
            widget.event!.id,
            pick,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event moved')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width > 900;
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Top bar: close, title, Save, More actions.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_outlined),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _title,
                      style:
                          Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Add title',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    offset: const Offset(0, 48),
                    onSelected: (choice) {
                      if (choice == 'delete' && !_isCreate) {
                        _delete();
                      } else if (choice == 'duplicate' &&
                          !_isCreate) {
                        _duplicate();
                      } else if (choice == 'print') {
                        _print();
                      } else if (choice == 'publish') {
                        _publish();
                      } else if (choice == 'owner' && !_isCreate) {
                        _changeOwner();
                      }
                    },
                    itemBuilder: (context) => [
                      if (!_isCreate) ...[
                        const PopupMenuItem(
                          value: 'print',
                          child: Text('Print'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Text('Duplicate'),
                        ),
                        const PopupMenuItem(
                          value: 'publish',
                          child: Text('Publish event'),
                        ),
                        const PopupMenuItem(
                          value: 'instance',
                          enabled: false,
                          child: Text(
                              'Publish this instance of the event'),
                        ),
                        const PopupMenuItem(
                          value: 'owner',
                          child: Text('Change owner'),
                        ),
                      ] else
                        const PopupMenuItem(
                          value: 'print',
                          child: Text('Print'),
                        ),
                    ],
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('More actions'),
                          Icon(Icons.arrow_drop_down_outlined),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date/time pills + timezone.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _PillButton(
                    label: loc.formatMediumDate(_start),
                    onTap: () => _pickDateTime(true),
                  ),
                  if (!_allDay)
                    _PillButton(
                      label: loc.formatTimeOfDay(
                          TimeOfDay.fromDateTime(_start)),
                      onTap: () => _pickDateTime(true),
                    ),
                  const Text('to'),
                  if (!_allDay)
                    _PillButton(
                      label: loc.formatTimeOfDay(
                          TimeOfDay.fromDateTime(_end)),
                      onTap: () => _pickDateTime(false),
                    ),
                  _PillButton(
                    label: loc.formatMediumDate(_end),
                    onTap: () => _pickDateTime(false),
                  ),
                  Text(
                    '(${_tzLabel()})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: _allDay,
                    onChanged: (v) =>
                        setState(() => _allDay = v ?? false),
                  ),
                  const Text('All day'),
                  const SizedBox(width: 16),
                  Tooltip(
                    message: 'Repeats',
                    child: DropdownButton<String>(
                      value: 'Doesn’t repeat',
                      items: const [
                        DropdownMenuItem(
                          value: 'Doesn’t repeat',
                          child: Text('Doesn’t repeat'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error!,
                    style: TextStyle(color: scheme.error)),
              ),
            // Tabs.
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Event details'),
                Tab(text: 'Find a time'),
              ],
              onTap: (i) => setState(() => _tab = i),
            ),
            Expanded(
              child: _tab == 0
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: wide
                          ? Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: _detailsColumn()),
                                const SizedBox(width: 32),
                                Expanded(child: _guestsColumn()),
                              ],
                            )
                          : Column(
                              children: [
                                _detailsColumn(),
                                const SizedBox(height: 24),
                                _guestsColumn(),
                              ],
                            ),
                    )
                  : _FindATime(
                      start: _start,
                      end: _end,
                      ignoreId: widget.event?.id,
                    ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  String _tzLabel() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final h = offset.inHours.abs();
    final m = offset.inMinutes.abs() % 60;
    final zone = DateTime.now().timeZoneName;
    if (m == 0) return '(GMT$sign$h) $zone';
    return '(GMT$sign$h:${m.toString().padLeft(2, '0')}) $zone';
  }

  Widget _detailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _location,
          decoration: const InputDecoration(
            labelText: 'Add location',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Text('Notifications',
            style: Theme.of(context).textTheme.titleSmall),
        for (var i = 0; i < _reminders.length; i++)
          _ReminderRow(
            reminder: _reminders[i],
            onRemove: () =>
                setState(() => _reminders.removeAt(i)),
          ),
        TextButton.icon(
          onPressed: () => setState(() => _reminders.add(
              _Reminder(email: false, amount: 10, unit: 'minute'))),
          icon: const Icon(Icons.add_outlined, size: 18),
          label: const Text('Add notification'),
        ),
        const SizedBox(height: 12),
        _FeedPicker(
          feedId: _feedId ?? widget.event?.feedId,
          colorId: _colorId,
          onPick: (feedId, colorId) => setState(() {
            _feedId = feedId;
            _colorId = colorId;
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<bool>(
                initialValue: _busy,
                decoration: const InputDecoration(labelText: 'Show as'),
                items: const [
                  DropdownMenuItem(
                      value: true, child: Text('Busy')),
                  DropdownMenuItem(
                      value: false, child: Text('Free')),
                ],
                onChanged: (v) =>
                    setState(() => _busy = v ?? true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _visibility,
                decoration:
                    const InputDecoration(labelText: 'Visibility'),
                items: const [
                  DropdownMenuItem(
                      value: 'Default',
                      child: Text('Default visibility')),
                  DropdownMenuItem(
                      value: 'Public', child: Text('Public')),
                  DropdownMenuItem(
                      value: 'Private', child: Text('Private')),
                ],
                onChanged: (v) => setState(
                    () => _visibility = v ?? 'Default'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          decoration: const InputDecoration(
            labelText: 'Add description',
            alignLabelWithHint: true,
          ),
          maxLines: 6,
          minLines: 4,
        ),
      ],
    );
  }

  Widget _guestsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Guests',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _guestCtrl,
          decoration: const InputDecoration(
            hintText: 'Add guests',
            prefixIcon: Icon(Icons.group_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (v) {
            final email = v.trim();
            if (email.isEmpty || _guests.contains(email)) return;
            setState(() {
              _guests.add(email);
              _guestCtrl.clear();
            });
          },
        ),
        for (final g in _guests)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(g.characters.first)),
            title: Text(g),
            trailing: IconButton(
              tooltip: 'Remove guest',
              iconSize: 20,
              icon: const Icon(Icons.close_outlined),
              onPressed: () =>
                  setState(() => _guests.remove(g)),
            ),
          ),
        const SizedBox(height: 8),
        Text('Guest permissions',
            style: Theme.of(context).textTheme.titleSmall),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Modify event'),
          value: (_guestFlags & 1) != 0,
          onChanged: (v) => setState(() => _guestFlags =
              v == true ? _guestFlags | 1 : _guestFlags & ~1),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Invite others'),
          value: (_guestFlags & 2) != 0,
          onChanged: (v) => setState(() => _guestFlags =
              v == true ? _guestFlags | 2 : _guestFlags & ~2),
        ),
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('See guest list'),
          value: (_guestFlags & 4) != 0,
          onChanged: (v) => setState(() => _guestFlags =
              v == true ? _guestFlags | 4 : _guestFlags & ~4),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ReminderRow extends StatefulWidget {
  const _ReminderRow({required this.reminder, required this.onRemove});

  final _Reminder reminder;
  final VoidCallback onRemove;

  @override
  State<_ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<_ReminderRow> {
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = '${widget.reminder.amount}';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<bool>(
          value: widget.reminder.email,
          items: const [
            DropdownMenuItem(
                value: false, child: Text('Notification')),
            DropdownMenuItem(value: true, child: Text('Email')),
          ],
          onChanged: (v) =>
              setState(() => widget.reminder.email = v ?? false),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(isDense: true),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n > 0) {
                widget.reminder.amount = n;
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: widget.reminder.unit,
          items: const [
            DropdownMenuItem(
                value: 'minute', child: Text('minutes')),
            DropdownMenuItem(value: 'hour', child: Text('hours')),
            DropdownMenuItem(value: 'day', child: Text('days')),
            DropdownMenuItem(value: 'week', child: Text('weeks')),
          ],
          onChanged: (v) =>
              setState(() => widget.reminder.unit = v ?? 'minute'),
        ),
        IconButton(
          tooltip: 'Remove notification',
          iconSize: 20,
          icon: const Icon(Icons.close_outlined),
          onPressed: widget.onRemove,
        ),
      ],
    );
  }
}

class _FeedPicker extends ConsumerWidget {
  const _FeedPicker({
    required this.feedId,
    required this.colorId,
    required this.onPick,
  });

  final int? feedId;
  final int colorId;
  final void Function(int feedId, int colorId) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(feedsProvider);
    return feeds.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final current = items.where((f) => f.id == feedId).firstOrNull ??
            items.first;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final pick = await showMenu<int>(
              context: context,
              position: const RelativeRect.fromLTRB(100, 200, 0, 0),
              items: [
                for (final f in items)
                  PopupMenuItem(
                    value: f.id,
                    child: Text(f.name),
                  ),
              ],
            );
            if (pick != null) {
              final feed =
                  items.singleWhere((f) => f.id == pick);
              onPick(feed.id, feed.colorId);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(current.name)),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: eventPalette[
                        colorId % eventPalette.length],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Find a time": overlapping events on the same day, or all clear.
class _FindATime extends ConsumerWidget {
  const _FindATime({
    required this.start,
    required this.end,
    required this.ignoreId,
  });

  final DateTime start;
  final DateTime end;
  final int? ignoreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = DateTime(start.year, start.month, start.day);
    final eventsAsync = ref.watch(dayEventsProvider(day));
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          const Center(child: Text('Could not load the day')),
      data: (events) {
        final clashes = events
            .where((e) =>
                e.id != ignoreId &&
                e.start.isBefore(end) &&
                e.end.isAfter(start))
            .toList();
        if (clashes.isEmpty) {
          return const Center(
            child: Text('No conflicts in this time range'),
          );
        }
        final loc = MaterialLocalizations.of(context);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clashes.length,
          itemBuilder: (context, i) {
            final e = clashes[i];
            return ListTile(
              dense: true,
              title: Text(e.title),
              subtitle: Text(
                '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(e.start))} – '
                '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(e.end))}',
              ),
            );
          },
        );
      },
    );
  }
}
