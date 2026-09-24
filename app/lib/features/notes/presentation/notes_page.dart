import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/widgets/animated_trash.dart';
import 'package:socra_task/core/widgets/socra_app_bar.dart';
import 'package:socra_task/core/widgets/theme_toggle.dart';
import 'package:socra_task/features/notes/data/note_providers.dart';

/// Google-Keep parity slice 1: masonry grid/list, pin, colors, labels,
/// checklists, archive, trash (restore + empty), search. Reminders and
/// sharing arrive with the notification/account layers.
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(notesGridProvider);
    final wide = MediaQuery.sizeOf(context).width > 1000;
    final nav = ref.watch(notesNavProvider);
    return Scaffold(
      appBar: SocraAppBar(
        title: 'Sticky Notes',
        actions: [
          IconButton(
            tooltip: grid ? 'List view' : 'Grid view',
            icon: Icon(grid
                ? Icons.view_agenda_outlined
                : Icons.grid_view_outlined),
            onPressed: () =>
                ref.read(notesGridProvider.notifier).state = !grid,
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide) const _NotesNav(),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search notes',
                      prefixIcon: Icon(Icons.search_outlined),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(24)),
                      ),
                    ),
                    onChanged: (v) => ref
                        .read(notesQueryProvider.notifier)
                        .state = v,
                  ),
                ),
                Expanded(child: _NotesBody(grid: grid)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: nav == NotesNav.notes
          ? FloatingActionButton(
              tooltip: 'Add note',
              onPressed: () => _NoteEditor.showCreate(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _NotesNav extends ConsumerWidget {
  const _NotesNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(notesNavProvider);
    final labels = ref.watch(labelsProvider);
    final labelFilter = ref.watch(notesLabelFilterProvider);
    final repo = ref.watch(noteRepositoryProvider);
    return SizedBox(
      width: 240,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final item in [
            (NotesNav.notes, Icons.lightbulb_outlined, 'Sticky Notes'),
            (NotesNav.archive, Icons.archive_outlined, 'Archive'),
            (NotesNav.trash, Icons.delete_outlined, 'Trash'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: nav == item.$1
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    ref.read(notesNavProvider.notifier).state = item.$1;
                    ref
                        .read(notesLabelFilterProvider.notifier)
                        .state = null;
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(item.$2, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.$3)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text('Labels',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              IconButton(
                tooltip: 'Edit labels',
                iconSize: 20,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _LabelsDialog.show(context, ref),
              ),
            ],
          ),
          labels.when(
            loading: () => const SizedBox.shrink(),
            error: (err, _) => const SizedBox.shrink(),
            data: (items) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final label in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: labelFilter == label.id
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ref
                              .read(notesLabelFilterProvider.notifier)
                              .state = labelFilter == label.id
                              ? null
                              : label.id;
                          ref
                              .read(notesNavProvider.notifier)
                              .state = NotesNav.notes;
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.label_outlined,
                                  size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(label.name)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (nav == NotesNav.trash)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Empty trash?'),
                      content: const Text(
                          'All trashed notes will be permanently deleted.'),
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
                          child: const Text('Empty trash'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await repo.emptyTrash();
                },
                child: const Text('Empty trash'),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesBody extends ConsumerWidget {
  const _NotesBody({required this.grid});

  final bool grid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(notesNavProvider);
    final query = ref.watch(notesQueryProvider).trim();
    if (query.isNotEmpty) {
      return FutureBuilder(
        future: ref.watch(noteRepositoryProvider).searchNotes(query),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _cards(context, ref, snap.data!, showSections: false);
        },
      );
    }
    final stream = switch (nav) {
      NotesNav.notes => ref.watch(notesHomeProvider),
      NotesNav.archive => ref.watch(notesArchivedProvider),
      NotesNav.trash => ref.watch(notesTrashProvider),
    };
    return stream.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load: $e')),
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
            child: Text(nav == NotesNav.notes
                ? 'No notes yet'
                : nav == NotesNav.archive
                    ? 'Archived notes appear here'
                    : 'Trash is empty'),
          );
        }
        return _cards(context, ref, notes, showSections: true);
      },
    );
  }

  Widget _cards(
      BuildContext context, WidgetRef ref, List<Note> notes,
      {required bool showSections}) {
    if (!grid) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _NoteCard(note: notes[i]),
        ),
      );
    }
    final pinned = notes.where((n) => n.pinned).toList();
    final rest = notes.where((n) => !n.pinned).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSections && pinned.isNotEmpty) ...[
            _sectionHeader(context, 'PINNED'),
            _masonry(pinned),
            const SizedBox(height: 24),
          ],
          if (showSections && pinned.isNotEmpty && rest.isNotEmpty)
            _sectionHeader(context, 'OTHERS'),
          _masonry(showSections ? rest : notes),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(letterSpacing: 1.2)),
    );
  }

  Widget _masonry(List<Note> notes) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: notes.length,
      itemBuilder: (context, i) => _NoteCard(note: notes[i]),
    );
  }
}

class _NoteCard extends ConsumerStatefulWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  ConsumerState<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<_NoteCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final repo = ref.watch(noteRepositoryProvider);
    final brightness = Theme.of(context).brightness;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Card(
        margin: EdgeInsets.zero,
        color: noteCardColor(note.colorId, brightness),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _NoteEditor.showEdit(context, ref, note),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note.title.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Text(note.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      if (note.pinned)
                        const Icon(Icons.push_pin_outlined, size: 18),
                    ],
                  ),
                if (note.body.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(note.body,
                        maxLines: 6, overflow: TextOverflow.ellipsis),
                  ),
                _ChecklistPreview(noteId: note.id),
                _CardLabels(noteId: note.id),
                // Hover-only actions are built only while hovered so they
                // never intercept taps or confuse semantics when hidden.
                if (_hover)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: note.pinned ? 'Unpin' : 'Pin',
                        iconSize: 20,
                        icon: Icon(note.pinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined),
                        onPressed: () =>
                            repo.setPinned(note.id, !note.pinned),
                      ),
                      IconButton(
                        tooltip: 'Archive note',
                        iconSize: 20,
                        icon:
                            const Icon(Icons.archive_outlined),
                        onPressed: () =>
                            repo.setArchived(note.id, true),
                      ),
                      AnimatedTrashButton(
                        tooltip: 'Delete note',
                        onTap: () => repo.trashNote(note.id),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistPreview extends ConsumerWidget {
  const _ChecklistPreview({required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(_checklistProvider(noteId)).valueOrNull ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items.take(4))
            Row(
              children: [
                Icon(
                  item.done
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank_outlined,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: item.done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                ),
              ],
            ),
          if (items.length > 4) Text('+${items.length - 4} more'),
        ],
      ),
    );
  }
}

final _checklistProvider =
    StreamProvider.autoDispose.family<List<ChecklistItem>, int>(
        (ref, noteId) {
  return ref.watch(noteRepositoryProvider).watchChecklist(noteId);
});

class _CardLabels extends ConsumerWidget {
  const _CardLabels({required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.watch(noteRepositoryProvider).noteLabels(noteId),
      builder: (context, snap) {
        final labels = snap.data ?? const <Label>[];
        if (labels.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 4,
            children: [
              for (final label in labels)
                Chip(
                  label: Text(label.name,
                      style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Full editor dialog: title/body, checklist, palette, labels, actions.
class _NoteEditor {
  static Future<void> showCreate(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(noteRepositoryProvider);
    final id = await repo.createNote();
    if (!context.mounted) return;
    final note =
        (await repo.watchNotes().first).singleWhere((n) => n.id == id);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _EditorDialog(note: note),
    );
  }

  static Future<void> showEdit(
      BuildContext context, WidgetRef ref, Note note) {
    return showDialog<void>(
      context: context,
      builder: (context) => _EditorDialog(note: note),
    );
  }
}

class _EditorDialog extends ConsumerStatefulWidget {
  const _EditorDialog({required this.note});

  final Note note;

  @override
  ConsumerState<_EditorDialog> createState() => _EditorDialogState();
}

class _EditorDialogState extends ConsumerState<_EditorDialog> {
  late final TextEditingController _title =
      TextEditingController(text: widget.note.title);
  late final TextEditingController _body =
      TextEditingController(text: widget.note.body);
  final _itemCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _itemCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(noteRepositoryProvider);
    final noteAsync = ref.watch(_noteProvider(widget.note.id));
    final note = noteAsync.valueOrNull ?? widget.note;
    final brightness = Theme.of(context).brightness;
    return AlertDialog(
      backgroundColor: noteCardColor(note.colorId, brightness),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                    hintText: 'Title', border: InputBorder.none),
                style: Theme.of(context).textTheme.titleLarge,
                onChanged: (v) => repo.updateNote(note.id, title: v),
              ),
              TextField(
                controller: _body,
                decoration: const InputDecoration(
                    hintText: 'Take a note…',
                    border: InputBorder.none),
                maxLines: null,
                onChanged: (v) => repo.updateNote(note.id, body: v),
              ),
              _EditorChecklist(noteId: note.id),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemCtrl,
                      decoration: const InputDecoration(
                          hintText: 'List item',
                          border: InputBorder.none),
                      onSubmitted: (v) async {
                        if (v.trim().isEmpty) return;
                        await repo.addChecklistItem(note.id, v);
                        _itemCtrl.clear();
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add item',
                    icon: const Icon(Icons.add_outlined),
                    onPressed: () async {
                      if (_itemCtrl.text.trim().isEmpty) return;
                      await repo.addChecklistItem(
                          note.id, _itemCtrl.text);
                      _itemCtrl.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [
                  for (var i = 0; i < 12; i++)
                    GestureDetector(
                      onTap: () => repo.setNoteColor(note.id, i),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: noteCardColor(i, brightness),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline,
                          ),
                        ),
                        child: note.colorId == i
                            ? const Icon(Icons.check, size: 16)
                            : null,
                      ),
                    ),
                ],
              ),
              _EditorLabels(noteId: note.id, controller: _labelCtrl),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: note.pinned ? 'Unpin' : 'Pin note',
          icon: Icon(note.pinned
              ? Icons.push_pin
              : Icons.push_pin_outlined),
          onPressed: () => repo.setPinned(note.id, !note.pinned),
        ),
        if (!note.trashed) ...[
          IconButton(
            tooltip: note.archived ? 'Unarchive note' : 'Archive note',
            icon: Icon(note.archived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            onPressed: () async {
              await repo.setArchived(note.id, !note.archived);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          AnimatedTrashButton(
            tooltip: 'Delete note',
            onTap: () async {
              await repo.trashNote(note.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ] else
          TextButton(
            onPressed: () async {
              await repo.restoreNote(note.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Restore'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

final _noteProvider =
    StreamProvider.autoDispose.family<Note?, int>((ref, id) {
  return ref
      .watch(noteRepositoryProvider)
      .watchNotes()
      .map((notes) => notes.where((n) => n.id == id).firstOrNull)
      .distinct();
});

class _EditorChecklist extends ConsumerWidget {
  const _EditorChecklist({required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_checklistProvider(noteId));
    return items.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (list) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in list)
            Row(
              children: [
                Checkbox(
                  value: item.done,
                  visualDensity: VisualDensity.compact,
                  onChanged: (v) => ref
                      .read(noteRepositoryProvider)
                      .toggleChecklistItem(item.id, v ?? false),
                ),
                Expanded(
                  child: Text(item.content,
                      style: item.done
                          ? const TextStyle(
                              decoration:
                                  TextDecoration.lineThrough)
                          : null),
                ),
                IconButton(
                  tooltip: 'Remove item',
                  iconSize: 20,
                  icon: const Icon(Icons.close_outlined),
                  onPressed: () => ref
                      .read(noteRepositoryProvider)
                      .removeChecklistItem(item.id),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EditorLabels extends ConsumerWidget {
  const _EditorLabels({required this.noteId, required this.controller});

  final int noteId;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelsProvider);
    final repo = ref.watch(noteRepositoryProvider);
    return FutureBuilder(
      future: repo.noteLabels(noteId),
      builder: (context, snap) {
        final attached =
            (snap.data ?? const <Label>[]).map((l) => l.id).toSet();
        return labels.when(
          loading: () => const SizedBox.shrink(),
          error: (err, _) => const SizedBox.shrink(),
          data: (all) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 4,
                children: [
                  for (final label in all)
                    FilterChip(
                      label: Text(label.name),
                      selected: attached.contains(label.id),
                      onSelected: (v) =>
                          repo.setNoteLabel(noteId, label.id, v),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                          hintText: 'New label',
                          border: InputBorder.none),
                      onSubmitted: (v) async {
                        if (v.trim().isEmpty) return;
                        final id =
                            await repo.createLabel(v.trim());
                        await repo.setNoteLabel(noteId, id, true);
                        controller.clear();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LabelsDialog extends ConsumerWidget {
  const _LabelsDialog();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showDialog<void>(
      context: context,
      builder: (context) => const Dialog(child: _LabelsDialog()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelsProvider);
    final repo = ref.watch(noteRepositoryProvider);
    final ctrl = TextEditingController();
    return SizedBox(
      width: 280,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit labels',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            labels.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load: $e'),
              data: (items) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final label in items)
                    _LabelRow(label: label),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                        hintText: 'Create new label'),
                    onSubmitted: (v) async {
                      if (v.trim().isEmpty) return;
                      await repo.createLabel(v.trim());
                      ctrl.clear();
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Create label',
                  icon: const Icon(Icons.check_outlined),
                  onPressed: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    await repo.createLabel(ctrl.text.trim());
                    ctrl.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelRow extends ConsumerStatefulWidget {
  const _LabelRow({required this.label});

  final Label label;

  @override
  ConsumerState<_LabelRow> createState() => _LabelRowState();
}

class _LabelRowState extends ConsumerState<_LabelRow> {
  bool _editing = false;
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.label.name);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(noteRepositoryProvider);
    if (!_editing) {
      return Row(
        children: [
          Expanded(child: Text(widget.label.name)),
          IconButton(
            tooltip: 'Rename label',
            iconSize: 20,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => setState(() => _editing = true),
          ),
          AnimatedTrashButton(
            tooltip: 'Delete label',
            onTap: () => repo.deleteLabel(widget.label.id),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            onSubmitted: (v) async {
              if (v.trim().isNotEmpty) {
                await repo.renameLabel(widget.label.id, v.trim());
              }
              setState(() => _editing = false);
            },
          ),
        ),
        IconButton(
          tooltip: 'Save label',
          iconSize: 20,
          icon: const Icon(Icons.check_outlined),
          onPressed: () async {
            if (_ctrl.text.trim().isNotEmpty) {
              await repo.renameLabel(
                  widget.label.id, _ctrl.text.trim());
            }
            setState(() => _editing = false);
          },
        ),
      ],
    );
  }
}
