import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/core/widgets/animated_trash.dart';
import 'package:socra_task/core/widgets/socra_app_bar.dart';
import 'package:socra_task/core/widgets/theme_toggle.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

/// Tasks page with Google-Tasks parity (see `prompt.md` §3.3):
/// named lists, one-level subtasks, due date/time, sort (manual/date),
/// move-between-lists. Completes glide down; deletes pop out via a
/// centered confirm.
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final _openKey = GlobalKey<AnimatedListState>();
  final _doneKey = GlobalKey<AnimatedListState>();
  final List<Task> _open = [];
  final List<Task> _done = [];
  final Set<int> _completing = {};
  final Set<int> _deleting = {};
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    ref.read(taskRepositoryProvider).ensureDefaultList();
  }

  bool _inFlight(int id) =>
      _completing.contains(id) || _deleting.contains(id);

  int? _effectiveList(List<TaskList> lists) {
    if (lists.isEmpty) return null;
    final active = ref.watch(activeListProvider);
    if (active != null && lists.any((l) => l.id == active)) return active;
    return lists.first.id;
  }

  bool _reconcile(List<Task> snapshot, int? listId, TaskSort sort) {
    if (listId == null) return false;
    final scoped =
        snapshot.where((t) => t.listId == listId).toList();
    var wantOpen =
        scoped.where((t) => !t.done).toList();
    var wantDone = scoped.where((t) => t.done).toList();
    if (sort == TaskSort.date) {
      int byDate(Task a, Task b) {
        if (a.dueAt == null && b.dueAt == null) {
          return a.createdAt.compareTo(b.createdAt);
        }
        if (a.dueAt == null) return 1;
        if (b.dueAt == null) return -1;
        return a.dueAt!.compareTo(b.dueAt!);
      }
      wantOpen.sort(byDate);
      wantDone.sort(byDate);
    }
    return _syncList(_open, _openKey, wantOpen) |
        _syncList(_done, _doneKey, wantDone);
  }

  bool _syncList(
    List<Task> current,
    GlobalKey<AnimatedListState> key,
    List<Task> want,
  ) {
    var changed = false;
    final wantIds = want.map((t) => t.id).toSet();
    for (var i = current.length - 1; i >= 0; i--) {
      final id = current[i].id;
      if (!wantIds.contains(id) && !_inFlight(id)) {
        final removed = current.removeAt(i);
        changed = true;
        key.currentState?.removeItem(
          i,
          (context, animation) => _glideDownTransition(removed, animation),
        );
      }
    }
    // Keep manual order aligned with the desired order (date sort or
    // creation order from the stream).
    final orderOk = current.length == want.length &&
        List.generate(current.length,
                (i) => current[i].id == want[i].id)
            .every((e) => e);
    if (!orderOk && current.isNotEmpty) {
      final byId = {for (final t in current) t.id: t};
      current
        ..clear()
        ..addAll([
          for (final w in want)
            if (byId.containsKey(w.id)) byId[w.id]!,
        ]);
      changed = true;
    }
    for (final task in want) {
      if (!current.any((t) => t.id == task.id) && !_inFlight(task.id)) {
        // Insert at the desired position, not just the end.
        final at = want.indexOf(task).clamp(0, current.length);
        current.insert(at, task);
        changed = true;
        key.currentState?.insertItem(at);
      }
    }
    for (var i = 0; i < current.length; i++) {
      final fresh = want.where((t) => t.id == current[i].id);
      if (fresh.isNotEmpty && fresh.single != current[i]) {
        current[i] = fresh.single;
        changed = true;
      }
    }
    return changed;
  }

  /// Exit that travels DOWNWARD (never a shrink-in-place): the row slides
  /// down while fading; the slot collapses underneath it on the same beat.
  Widget _glideDownTransition(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1.5),
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(animation),
          child: _TaskRow(
            task: task,
            completing: false,
            onToggle: null,
            onDeleteTap: null,
            onDueTap: null,
            moveTargets: const [],
            onAddSubtask: null,
            onMoveTo: null,
          ),
        ),
      ),
    );
  }

  /// Delete pop: quick swell then vanish, like a bubble popping.
  Widget _popTransition(Task task, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final scale = t < 0.35 ? 1 + 0.6 * t : 1.21 * (1 - (t - 0.35) / 0.65);
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: _TaskRow(
        task: task,
        completing: false,
        onToggle: null,
        onDeleteTap: null,
        onDueTap: null,
        moveTargets: const [],
        onAddSubtask: null,
        onMoveTo: null,
      ),
    );
  }

  /// Entry: drops in from slightly above and settles (small zoom-out).
  /// (Defined once, below next to [_row].)

  Future<void> _complete(Task task) async {
    if (_completing.contains(task.id)) return;
    setState(() => _completing.add(task.id));
    // Beat 1: strikethrough + zoom in place.
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final openIndex = _open.indexWhere((t) => t.id == task.id);
    if (openIndex != -1) {
      _open.removeAt(openIndex);
      _openKey.currentState?.removeItem(
        openIndex,
        (context, animation) => _glideDownTransition(task, animation),
      );
    }
    // Beat 2: arrives at the top of Done.
    final doneTask = task.copyWith(done: true);
    _done.insert(0, doneTask);
    _doneKey.currentState?.insertItem(0);
    setState(() => _completing.remove(task.id));
    await ref.read(taskRepositoryProvider).completeTask(task.id);
  }

  Future<void> _uncomplete(Task task) async {
    final doneIndex = _done.indexWhere((t) => t.id == task.id);
    if (doneIndex != -1) {
      _done.removeAt(doneIndex);
      _doneKey.currentState?.removeItem(
        doneIndex,
        (context, animation) => _glideDownTransition(task, animation),
      );
    }
    _open.add(task.copyWith(done: false));
    _openKey.currentState?.insertItem(_open.length - 1);
    final db = ref.read(databaseProvider);
    await (db.update(db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(done: const Value(false)),
    );
    await db.into(db.outboxOps).insert(OutboxOpsCompanion.insert(
          kind: 'task',
          entityId: task.id,
          op: 'update',
        ));
  }

  Future<void> _askDelete(Task task, bool wasDone) async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Same width as the quick-add AlertDialog (280), not full-bleed.
        child: SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete this task?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '“${task.title}” will move to trash.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Keep'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
    if (confirmed != true || !mounted) return;
    _deleting.add(task.id);
    final list = wasDone ? _done : _open;
    final key = wasDone ? _doneKey : _openKey;
    final index = list.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      list.removeAt(index);
      key.currentState?.removeItem(
        index,
        (context, animation) => _popTransition(task, animation),
      );
      setState(() {});
    }
    await ref.read(taskRepositoryProvider).deleteTask(task.id);
    _deleting.remove(task.id);
  }

  Future<void> _pickDueDate(Task task) async {
    final now = DateTime.now();
    final initial = task.dueAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted) return;
    final due = time == null
        ? DateTime(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await ref.read(taskRepositoryProvider).setDueDate(task.id, due);
  }

  Future<void> _addSubtask(Task parent) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'A smaller step…'),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (title != null && title.trim().isNotEmpty) {
      await ref.read(taskRepositoryProvider).createTask(
            title.trim(),
            listId: parent.listId,
            parentId: parent.id,
          );
      setState(() => _expanded.add(parent.id));
    }
  }

  Future<void> _moveTo(Task task, bool wasDone, int target) async {
    final list = wasDone ? _done : _open;
    final key = wasDone ? _doneKey : _openKey;
    final index = list.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      list.removeAt(index);
      key.currentState?.removeItem(
        index,
        (context, animation) => _glideDownTransition(task, animation),
      );
      setState(() {});
    }
    await ref.read(taskRepositoryProvider).moveTask(task.id, target);
  }

  Future<void> _quickAdd(int listId) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'What needs doing?'),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (title != null && title.trim().isNotEmpty) {
      final id = await ref
          .read(taskRepositoryProvider)
          .createTask(title.trim(), listId: listId);
      // Immediately ask for a due date, like Calendar does.
      if (!mounted) return;
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        helpText: 'Due date (optional)',
      );
      if (date != null && mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        );
        final due = time == null
            ? DateTime(date.year, date.month, date.day)
            : DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
        await ref.read(taskRepositoryProvider).setDueDate(id, due);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksStreamProvider);
    final lists = ref.watch(listsStreamProvider);
    final sort = ref.watch(taskSortProvider);
    final listId = lists.valueOrNull == null
        ? null
        : _effectiveList(lists.valueOrNull!);
    final items = tasks.valueOrNull;
    if (items != null && listId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _reconcile(items, listId, sort)) setState(() {});
      });
    }
    final activeName = lists.valueOrNull == null || listId == null
        ? 'Tasks'
        : lists.valueOrNull!
            .firstWhere((l) => l.id == listId,
                orElse: () => lists.valueOrNull!.first)
            .name;
    return Scaffold(
      appBar: SocraAppBar(
        title: activeName,
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
          _AppBarPill(
            tooltip: 'Switch task list',
            icon: Icons.list_outlined,
            label: 'Lists',
            onTap: () => _ListsDialog.show(context),
          ),
          const SizedBox(width: 8),
          // Anchored under the pill itself via its own BuildContext.
          Builder(
            builder: (pillContext) => _AppBarPill(
              tooltip: 'Sort tasks',
              icon: Icons.sort_outlined,
              label: sort == TaskSort.manual ? 'My order' : 'By date',
              onTap: () async {
                final box =
                    pillContext.findRenderObject()! as RenderBox;
                final overlay = Overlay.of(pillContext)
                    .context
                    .findRenderObject()! as RenderBox;
                final pick = await showMenu<TaskSort>(
                  context: pillContext,
                  position: RelativeRect.fromRect(
                    box.localToGlobal(Offset.zero) & box.size,
                    Offset.zero & overlay.size,
                  ),
                  items: const [
                    PopupMenuItem(
                      value: TaskSort.manual,
                      child: Text('My order'),
                    ),
                    PopupMenuItem(
                      value: TaskSort.date,
                      child: Text('By date'),
                    ),
                  ],
                );
                if (pick != null) {
                  ref.read(taskSortProvider.notifier).state = pick;
                }
              },
            ),
          ),
        ],
      ),
      body: tasks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load tasks: $e')),
        data: (_) {
          if (listId == null || (_open.isEmpty && _done.isEmpty)) {
            return const Center(child: Text('No tasks yet'));
          }
          final moveTargets = (lists.valueOrNull ?? [])
              .where((l) => l.id != listId)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader(context, 'To do', _open.length),
              AnimatedList(
                key: _openKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: _open.length,
                itemBuilder: (context, i, animation) => _entryTransition(
                  _row(_open[i], wasDone: false, moveTargets: moveTargets),
                  animation,
                ),
              ),
              const SizedBox(height: 16),
              _sectionHeader(context, 'Done', _done.length),
              AnimatedList(
                key: _doneKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: _done.length,
                itemBuilder: (context, i, animation) => _entryTransition(
                  _row(_done[i], wasDone: true, moveTargets: moveTargets),
                  animation,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: listId == null
          ? null
          : FloatingActionButton(
              onPressed: () => _quickAdd(listId),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label ($count)',
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _entryTransition(Widget child, Animation<double> animation) {
    // Entry: drops in from slightly above and settles (small zoom-out).
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.4),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.08, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: SizeTransition(sizeFactor: animation, child: child),
        ),
      ),
    );
  }

  Widget _row(Task task,
      {required bool wasDone,
      required List<TaskList> moveTargets}) {
    final completing = _completing.contains(task.id);
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TaskRow(
            task: task,
            completing: completing,
            onToggle: wasDone
                ? () => _uncomplete(task)
                : (completing ? null : () => _complete(task)),
            onDeleteTap: () => _askDelete(task, wasDone),
            onDueTap: () => _pickDueDate(task),
            expanded: _expanded.contains(task.id),
            moveTargets: moveTargets,
            onAddSubtask: () => _addSubtask(task),
            onMoveTo: (target) => _moveTo(task, wasDone, target),
            onToggleExpand: () => setState(() {
              if (_expanded.contains(task.id)) {
                _expanded.remove(task.id);
              } else {
                _expanded.add(task.id);
              }
            }),
          ),
          if (_expanded.contains(task.id))
            _SubtaskSection(
              parent: task,
              onAddSubtask: () => _addSubtask(task),
            ),
        ],
      ),
    );
  }
}

/// Indented one-level subtasks of [parent]. Done subtasks stay visible,
/// struck through, Google-style. Empty sections offer an inline add.
class _SubtaskSection extends ConsumerStatefulWidget {
  const _SubtaskSection({required this.parent, required this.onAddSubtask});

  final Task parent;
  final VoidCallback onAddSubtask;

  @override
  ConsumerState<_SubtaskSection> createState() => _SubtaskSectionState();
}

class _SubtaskSectionState extends ConsumerState<_SubtaskSection> {
  @override
  Widget build(BuildContext context) {
    final subs = ref.watch(_subtasksProvider(widget.parent.id));
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: subs.when(
        loading: () => const SizedBox.shrink(),
        error: (err, _) => const SizedBox.shrink(),
        data: (items) {
          return Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final sub in items)
                  _SubtaskRow(
                    key: ValueKey(sub.id),
                    sub: sub,
                    onToggle: () => ref
                        .read(taskRepositoryProvider)
                        .completeTask(sub.id),
                    onDelete: () => _askDeleteSub(sub),
                  ),
                if (items.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.onAddSubtask,
                      icon: const Icon(Icons.add_outlined, size: 18),
                      label: const Text('Add subtask'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _askDeleteSub(Task sub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this subtask?'),
        content: Text('“${sub.title}” will move to trash.'),
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
    if (confirmed == true) {
      await ref.read(taskRepositoryProvider).deleteTask(sub.id);
    }
  }
}

final _subtasksProvider =
    StreamProvider.family<List<Task>, int>((ref, parentId) {
  return ref.watch(taskRepositoryProvider).watchSubtasks(parentId);
});

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.sub,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Task sub;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Checkbox(
          value: sub.done,
          visualDensity: VisualDensity.compact,
          onChanged: sub.done ? null : (_) => onToggle(),
        ),
        Expanded(
          child: Text(
            sub.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration:
                      sub.done ? TextDecoration.lineThrough : null,
                  color: sub.done ? scheme.onSurfaceVariant : null,
                ),
          ),
        ),
        AnimatedTrashButton(
          tooltip: 'Delete subtask',
          onTap: onDelete,
        ),
      ],
    );
  }
}

/// Rounded pill button for the app bar: icon left of label, hover tint,
/// tap target ≥44px tall. One pill per action, spaced 8px apart.
class _AppBarPill extends StatelessWidget {
  const _AppBarPill({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          hoverColor: SocraTheme.rowHover,
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Switch / create / rename / delete lists.
class _ListsDialog extends ConsumerWidget {
  const _ListsDialog();

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const Dialog(child: _ListsDialog()),
    );
  }

  Future<void> _promptName(
    BuildContext context,
    WidgetRef ref, {
    String? initial,
    required Future<void> Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: initial ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'New list' : 'Rename list'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List name'),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await onSave(name.trim());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(listsStreamProvider);
    final active = ref.watch(activeListProvider);
    final repo = ref.watch(taskRepositoryProvider);
    return SizedBox(
      width: 280,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Task lists',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            lists.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load lists: $e'),
              data: (items) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final list in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: list.id == active
                            ? SocraTheme.rowTint
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          hoverColor: SocraTheme.rowHover,
                          onTap: () {
                            ref
                                .read(activeListProvider.notifier)
                                .state = list.id;
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(list.name)),
                                if (list.id == active)
                                  Icon(Icons.check,
                                      size: 20,
                                      color: SocraTheme.ecoGreen),
                                IconButton(
                                  tooltip: 'Rename list',
                                  iconSize: 20,
                                  icon:
                                      const Icon(Icons.edit_outlined),
                                  onPressed: () => _promptName(
                                    context,
                                    ref,
                                    initial: list.name,
                                    onSave: (n) =>
                                        repo.renameList(list.id, n),
                                  ),
                                ),
                                AnimatedTrashButton(
                                  tooltip: 'Delete list',
                                  onTap: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Delete this list?'),
                                        content: Text(
                                            '“${list.name}” tasks move to Tasks.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, false),
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
                                                Navigator.pop(
                                                    context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      if (active == list.id) {
                                        ref
                                            .read(activeListProvider
                                                .notifier)
                                            .state = null;
                                      }
                                      await repo.deleteList(list.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => _promptName(context, ref,
                  onSave: (n) async {
                final id = await repo.createList(n);
                ref.read(activeListProvider.notifier).state = id;
              }),
              child: const Text('New list'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.completing,
    required this.onToggle,
    required this.onDeleteTap,
    required this.onDueTap,
    required this.moveTargets,
    required this.onAddSubtask,
    required this.onMoveTo,
    this.expanded = false,
    this.onToggleExpand,
  });

  final Task task;
  final bool completing;
  final VoidCallback? onToggle;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onDueTap;
  final List<TaskList> moveTargets;
  final VoidCallback? onAddSubtask;
  final ValueChanged<int>? onMoveTo;
  final bool expanded;
  final VoidCallback? onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final struck = task.done || completing;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      // Beat 1 of completing: zoom in place + strikethrough.
      child: AnimatedScale(
        scale: completing ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: completing
                ? SocraTheme.rowTint
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Checkbox(value: task.done, onChanged: (_) => onToggle?.call()),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        decoration:
                            struck ? TextDecoration.lineThrough : null,
                        color: struck
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                  child: Text(task.title),
                ),
              ),
              if (task.dueAt != null || !task.done)
                _DueChip(task: task, onTap: onDueTap),
              if (!task.done)
                IconButton(
                  tooltip: expanded ? 'Hide subtasks' : 'Show subtasks',
                  iconSize: 20,
                  onPressed: onToggleExpand,
                  icon: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_outlined),
                  ),
                ),
              if (!task.done)
                PopupMenuButton<String>(
                  tooltip: 'Task options',
                  iconSize: 20,
                  icon: const Icon(Icons.more_vert_outlined),
                  onSelected: (choice) {
                    if (choice == 'subtask') {
                      onAddSubtask?.call();
                    } else if (choice.startsWith('move:')) {
                      onMoveTo?.call(int.parse(choice.substring(5)));
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'subtask',
                      child: Text('Add subtask'),
                    ),
                    for (final target in moveTargets) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'move:${target.id}',
                        child: Text('Move to ${target.name}'),
                      ),
                    ],
                  ],
                ),
              AnimatedTrashButton(
                tooltip: 'Delete task',
                onTap: onDeleteTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Due chip: formatted date (+time when set); red when overdue and open.
/// Tap opens the date/time pickers.
class _DueChip extends StatelessWidget {
  const _DueChip({required this.task, required this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final due = task.dueAt;
    if (due == null) {
      return IconButton(
        tooltip: 'Add due date',
        iconSize: 20,
        onPressed: onTap,
        icon: const Icon(Icons.event_outlined),
      );
    }
    final loc = MaterialLocalizations.of(context);
    final hasTime = due.hour != 0 || due.minute != 0;
    final label = hasTime
        ? '${loc.formatMediumDate(due)}, ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(due))}'
        : loc.formatMediumDate(due);
    final overdue = !task.done && due.isBefore(DateTime.now());
    final color = overdue
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: 'Edit due date',
      preferBelow: false,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(label, style: TextStyle(color: color, fontSize: 12)),
        ),
      ),
    );
  }
}

/// Simple outlined trash can: static tapered body, and a separate lid
/// floating above it on a visible hinge dot. On hover the lid flips up
/// around the hinge while the icon crossfades to the active color.
