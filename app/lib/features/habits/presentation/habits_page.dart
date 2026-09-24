import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/notifications/habit_notifications.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/core/widgets/animated_trash.dart';
import 'package:socra_task/core/widgets/socra_app_bar.dart';
import 'package:socra_task/core/widgets/theme_toggle.dart';
import 'package:socra_task/features/calendar/data/calendar_providers.dart';
import 'package:socra_task/features/habits/data/habit_providers.dart';
import 'package:socra_task/features/habits/data/habit_repository.dart';

/// Loop-style habits: today check-ins, 7-day dots, streaks, score,
/// flexible schedules, detail stats. Reminders arrive with the
/// notification layer.
class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    return Scaffold(
      appBar: const SocraAppBar(
        title: 'Habits',
        actions: [ThemeToggleButton()],
      ),
      body: habits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.repeat_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('No habits yet'),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _HabitDialog.showCreate(context, ref),
                    icon: const Icon(Icons.add_outlined),
                    label: const Text('New habit'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) =>
                _HabitCard(habit: items[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add habit',
        onPressed: () => _HabitDialog.showCreate(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

String scheduleSummary(Habit habit) {
  switch (habit.kind) {
    case 'weekly':
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final days = [
        for (var i = 0; i < 7; i++)
          if ((habit.weeklyDays & (1 << i)) != 0) names[i],
      ];
      if (days.isEmpty) return 'Pick days';
      return days.join(', ');
    case 'xPerWeek':
      return '${habit.timesPerWeek}× per week';
    case 'everyNDays':
      return habit.intervalDays <= 1
          ? 'Every day'
          : 'Every ${habit.intervalDays} days';
    default:
      return 'Every day';
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(habitRepositoryProvider);
    final checksAsync = ref.watch(habitChecksProvider(habit.id));
    final color =
        eventPalette[habit.colorId % eventPalette.length];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _HabitDetail.show(context, ref, habit),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w600)),
                        Text(scheduleSummary(habit),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall),
                      ],
                    ),
                  ),
                  _StreakChip(habitId: habit.id),
                  const SizedBox(width: 8),
                  _TodayCheck(habit: habit),
                ],
              ),
              const SizedBox(height: 12),
              checksAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (err, _) => const SizedBox.shrink(),
                data: (checks) => _WeekDots(
                  checks: {for (final c in checks) c.day: c},
                  onToggle: (day, done) async {
                    done
                        ? await repo.checkIn(habit.id, day)
                        : await repo.checkIn(habit.id, day, done: true);
                    await HabitNotifications.instance
                        .rescheduleAll(repo);
                  },
                ),
              ),
              const SizedBox(height: 8),
              _ScoreBar(habitId: habit.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakChip extends ConsumerWidget {
  const _StreakChip({required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future:
          ref.watch(habitRepositoryProvider).streak(habitId, DateTime.now()),
      builder: (context, snap) {
        final streak = snap.data ?? 0;
        return Chip(
          avatar: Icon(
            Icons.local_fire_department_outlined,
            size: 18,
            color: streak > 0 ? Colors.orange : null,
          ),
          label: Text('$streak'),
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }
}

class _TodayCheck extends ConsumerWidget {
  const _TodayCheck({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(habitRepositoryProvider);
    final checksAsync = ref.watch(habitChecksProvider(habit.id));
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final check = checksAsync.valueOrNull?.where((c) =>
        c.day.year == today.year &&
        c.day.month == today.month &&
        c.day.day == today.day);
    final done =
        check != null && check.isNotEmpty && check.single.done;
    final due = repo.isDue(habit, today);
    return IconButton(
      tooltip: done ? 'Undo today' : 'Mark today done',
      iconSize: 32,
      icon: Icon(
        done
            ? Icons.check_circle
            : Icons.radio_button_unchecked_outlined,
        color: done ? SocraTheme.ecoGreen : null,
      ),
      onPressed: !due && !done
          ? null
          : () async {
              done
                  ? await repo.checkIn(habit.id, today)
                  : await repo.checkIn(habit.id, today, done: true);
              await HabitNotifications.instance.rescheduleAll(repo);
            },
    );
  }
}

class _WeekDots extends StatelessWidget {
  const _WeekDots({
    required this.checks,
    required this.onToggle,
  });

  final Map<DateTime, HabitCheck> checks;
  final void Function(DateTime day, bool isDone) onToggle;

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Row(
      children: [
        for (var i = 6; i >= 0; i--) ...[
          Builder(builder: (context) {
            final day = today.subtract(Duration(days: i));
            final future = day.isAfter(today);
            // Weekday lookup needs the repo-free schedule check inline.
            return _Dot(
              day: day,
              future: future,
              check: checks[DateTime(day.year, day.month, day.day)],
              onToggle: onToggle,
            );
          }),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.day,
    required this.future,
    required this.check,
    required this.onToggle,
  });

  final DateTime day;
  final bool future;
  final HabitCheck? check;
  final void Function(DateTime day, bool isDone) onToggle;

  @override
  Widget build(BuildContext context) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final done = check?.done ?? false;
    final skipped = check?.skipped ?? false;
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(letters[(day.weekday - 1) % 7],
              style: Theme.of(context).textTheme.bodySmall),
          IconButton(
            tooltip:
                'Toggle ${day.month}/${day.day}${done ? ' (done)' : ''}',
            iconSize: 26,
            onPressed: future
                ? null
                : () => onToggle(day, done),
            icon: Icon(
              done
                  ? Icons.check_circle
                  : skipped
                      ? Icons.remove_circle_outline_outlined
                      : Icons.circle_outlined,
              color: done
                  ? SocraTheme.ecoGreen
                  : skipped
                      ? scheme.onSurfaceVariant
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends ConsumerWidget {
  const _ScoreBar({required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.watch(habitRepositoryProvider).score(habitId),
      builder: (context, snap) {
        final score = (snap.data ?? 0.0).clamp(0.0, 1.0);
        return Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: score,
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: 8),
            Text('${(score * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      },
    );
  }
}

/// Detail bottom sheet: stats, history, edit, delete.
class _HabitDetail {
  static Future<void> show(
      BuildContext context, WidgetRef ref, Habit habit) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _DetailSheet(habitId: habit.id),
    );
  }
}

class _DetailSheet extends ConsumerWidget {
  const _DetailSheet({required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final repo = ref.watch(habitRepositoryProvider);
    return habits.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (items) {
        final matches = items.where((h) => h.id == habitId).toList();
        if (matches.isEmpty) {
          // Deleted elsewhere: close on the next frame (never pop
          // synchronously inside build).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
          return const SizedBox.shrink();
        }
        final habit = matches.single;
        final color =
            eventPalette[habit.colorId % eventPalette.length];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(habit.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge),
                    ),
                    IconButton(
                      tooltip: 'Edit habit',
                      icon:
                          const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                        _HabitDialog.showEdit(context, ref, habit);
                      },
                    ),
                    AnimatedTrashButton(
                      tooltip: 'Delete habit',
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:
                                const Text('Delete this habit?'),
                            content: Text(
                                '“${habit.name}” and its history will be removed.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Keep'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context)
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
                          await repo.deleteHabit(habit.id);
                          await HabitNotifications.instance
                              .cancelHabit(habit.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
                if (habit.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(habit.description),
                ],
                const SizedBox(height: 12),
                FutureBuilder(
                  future: Future.wait([
                    repo.streak(habit.id, DateTime.now()),
                    repo.score(habit.id),
                    repo.checksFor(
                      habit.id,
                      DateTime.now()
                          .subtract(const Duration(days: 30)),
                      DateTime.now(),
                    ),
                  ]),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final streak = snap.data![0] as int;
                    final score = snap.data![1] as double;
                    final checks =
                        snap.data![2] as Map<DateTime, HabitCheck>;
                    var due = 0;
                    var done = 0;
                    checks.forEach((day, c) {
                      if (repo.isDue(habit, day)) {
                        due++;
                        if (c.done) done++;
                      }
                    });
                    final rate =
                        due == 0 ? 0 : (done * 100 / due).round();
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _Stat(
                            label: 'Current streak',
                            value: '$streak'),
                        _Stat(
                            label: 'Strength',
                            value:
                                '${(score.clamp(0.0, 1.0) * 100).round()}%'),
                        _Stat(
                            label: '30-day rate',
                            value: '$rate%'),
                        _Stat(
                            label: 'Schedule',
                            value: scheduleSummary(habit)),
                        _Stat(
                          label: 'Reminder',
                          value: habit.reminderMinutes == null
                              ? 'Off'
                              : MaterialLocalizations.of(context)
                                  .formatTimeOfDay(TimeOfDay(
                                      hour:
                                          habit.reminderMinutes! ~/
                                              60,
                                      minute:
                                          habit.reminderMinutes! %
                                              60)),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Daily reminder picker row: bell + current time (or Off), tap to
/// set via time picker, X to clear.
class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.minutes, required this.onPick});

  final int? minutes;
  final ValueChanged<int?> onPick;

  @override
  Widget build(BuildContext context) {
    final label = minutes == null
        ? 'Off'
        : MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay(hour: minutes! ~/ 60, minute: minutes! % 60));
    return Row(
      children: [
        const Icon(Icons.notifications_outlined, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text('Reminder: $label')),
        if (minutes != null)
          IconButton(
            tooltip: 'Clear reminder',
            iconSize: 20,
            icon: const Icon(Icons.close_outlined),
            onPressed: () => onPick(null),
          ),
        TextButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: minutes == null
                  ? const TimeOfDay(hour: 8, minute: 0)
                  : TimeOfDay(
                      hour: minutes! ~/ 60,
                      minute: minutes! % 60),
            );
            if (picked != null) {
              onPick(picked.hour * 60 + picked.minute);
            }
          },
          child: Text(minutes == null ? 'Set' : 'Change'),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Create/edit dialog with schedule picker.
class _HabitDialog {
  static Future<void> showCreate(
      BuildContext context, WidgetRef ref) {
    return showDialog<void>(
      context: context,
      builder: (context) => const _HabitForm(),
    );
  }

  static Future<void> showEdit(
      BuildContext context, WidgetRef ref, Habit habit) {
    return showDialog<void>(
      context: context,
      builder: (context) => _HabitForm(habit: habit),
    );
  }
}

class _HabitForm extends ConsumerStatefulWidget {
  const _HabitForm({this.habit});

  final Habit? habit;

  @override
  ConsumerState<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<_HabitForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.habit?.name ?? '');
  late final TextEditingController _description = TextEditingController(
      text: widget.habit?.description ?? '');
  late int _colorId = widget.habit?.colorId ?? 0;
  late String _kind = widget.habit?.kind ?? 'daily';
  late final List<bool> _weekdays = widget.habit == null
      ? List.filled(7, true)
      : [
          for (var i = 0; i < 7; i++)
            (widget.habit!.weeklyDays & (1 << i)) != 0,
        ];
  late final TextEditingController _times = TextEditingController(
      text: '${widget.habit?.timesPerWeek ?? 3}');
  late final TextEditingController _interval = TextEditingController(
      text: '${widget.habit?.intervalDays ?? 2}');
  int? _reminderMinutes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reminderMinutes = widget.habit?.reminderMinutes;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _times.dispose();
    _interval.dispose();
    super.dispose();
  }

  HabitSchedule _schedule() {
    switch (_kind) {
      case 'weekly':
        final days = _weekdays.contains(true)
            ? List<bool>.from(_weekdays)
            : List.filled(7, true);
        return HabitSchedule.weekly(days);
      case 'xPerWeek':
        return HabitSchedule.xPerWeek(
            int.tryParse(_times.text) ?? 3);
      case 'everyNDays':
        return HabitSchedule.everyNDays(
          int.tryParse(_interval.text) ?? 2,
          DateTime.now(),
        );
      default:
        return scheduleDaily();
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give the habit a name');
      return;
    }
    final repo = ref.read(habitRepositoryProvider);
    int? habitId = widget.habit?.id;
    if (widget.habit == null) {
      habitId = await repo.createHabit(
        name: _name.text.trim(),
        schedule: _schedule(),
        description: _description.text.trim(),
        colorId: _colorId,
      );
    } else {
      // Schedule edits apply going forward; history is untouched.
      await repo.updateHabit(
        widget.habit!.id,
        name: _name.text.trim(),
        description: _description.text.trim(),
        colorId: _colorId,
      );
      await repo.updateSchedule(widget.habit!.id, _schedule());
    }
    await repo.setReminder(habitId!, _reminderMinutes);
    await HabitNotifications.instance.rescheduleAll(repo);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return AlertDialog(
      title: Text(widget.habit == null ? 'New habit' : 'Edit habit'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                decoration:
                    const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _description,
                decoration: const InputDecoration(
                    labelText: 'Why it matters (optional)'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                children: [
                  for (var i = 0;
                      i < eventPalette.length;
                      i++)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _colorId = i),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: eventPalette[i],
                          shape: BoxShape.circle,
                          border: _colorId == i
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                  width: 2,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration:
                    const InputDecoration(labelText: 'Repeats'),
                items: const [
                  DropdownMenuItem(
                      value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(
                      value: 'weekly',
                      child: Text('Weekly days')),
                  DropdownMenuItem(
                      value: 'xPerWeek',
                      child: Text('Times per week')),
                  DropdownMenuItem(
                      value: 'everyNDays',
                      child: Text('Every N days')),
                ],
                onChanged: (v) =>
                    setState(() => _kind = v ?? 'daily'),
              ),
              if (_kind == 'weekly')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 4,
                    children: [
                      for (var i = 0; i < 7; i++)
                        FilterChip(
                          label: Text(dayNames[i]),
                          selected: _weekdays[i],
                          onSelected: (v) => setState(
                              () => _weekdays[i] = v),
                        ),
                    ],
                  ),
                ),
              if (_kind == 'xPerWeek')
                TextField(
                  controller: _times,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Times per week'),
                ),
              if (_kind == 'everyNDays')
                TextField(
                  controller: _interval,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Every N days'),
                ),
              const SizedBox(height: 8),
              _ReminderRow(
                minutes: _reminderMinutes,
                onPick: (v) =>
                    setState(() => _reminderMinutes = v),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .error)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
