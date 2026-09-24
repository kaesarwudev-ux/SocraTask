import 'dart:convert';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/study_space/data/study_space_repository.dart';
import 'package:socra_task/features/study_space/presentation/board_state.dart';
import 'package:socra_task/features/study_space/presentation/board_view.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

final _spaceRepo =
    Provider<StudySpaceRepository>((ref) => StudySpaceRepository(ref.watch(databaseProvider)));

/// Study Space hub (v2 rebuild). Thin shell: the board owns all pointer
/// state. This widget only rebuilds on tool/zoom/hub changes — never on
/// pointer moves (the old lag root cause).
class StudySpacePage extends ConsumerStatefulWidget {
  const StudySpacePage({super.key});
  @override
  ConsumerState<StudySpacePage> createState() => _StudySpacePageState();
}

class _StudySpacePageState extends ConsumerState<StudySpacePage> {
  int? _boardId;
  List<StudyBoard> _boards = [];
  final _trans = TransformationController();
  late final BoardState _board = BoardState();
  final _boardKey = GlobalKey<BoardViewState>();
  final _markerKey = GlobalKey();
  final _eraserKey = GlobalKey();
  OverlayEntry? _toolPopup;

  @override
  void initState() {
    super.initState();
    _board.addListener(_onBoardChanged);
    _load();
  }

  void _onBoardChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideToolPopup();
    _board.removeListener(_onBoardChanged);
    _board.dispose();
    _trans.dispose();
    super.dispose();
  }

  /// Horizontal colour+thickness popup beside the active pen tool.
  /// Shows every time marker/eraser is (re)selected, hides on tool switch
  /// or tap-outside.
  void _showToolPopup() {
    _hideToolPopup();
    final key = _board.tool == BoardTool.marker ? _markerKey : _eraserKey;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    _toolPopup = OverlayEntry(
      builder: (_) => Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hideToolPopup,
          ),
        ),
        Positioned(
          left: 76,
          top: (pos.dy - 8).clamp(80.0, 600.0),
          child: TapRegion(
            onTapOutside: (_) => _hideToolPopup(),
            child: _ToolPopupCard(
              board: _board,
              onChanged: () {
                setState(() {});
                _toolPopup?.markNeedsBuild();
              },
            ),
          ),
        ),
      ]),
    );
    Overlay.of(context).insert(_toolPopup!);
  }

  void _hideToolPopup() {
    _toolPopup?.remove();
    _toolPopup = null;
  }

  void _selectTool(BoardTool t) {
    setState(() => _board.tool = t);
    if (t == BoardTool.marker || t == BoardTool.eraser) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showToolPopup());
    } else {
      _hideToolPopup();
    }
  }

  Future<void> _load() async {
    final repo = ref.read(_spaceRepo);
    final id = await repo.ensureBoard();
    final all = await repo.fetchBoards();
    if (mounted) {
      setState(() {
        _boardId = id;
        _boards = all;
      });
    }
  }

  Future<void> _createHub() async {
    final ctrl =
        TextEditingController(text: 'Study Hub ${_boards.length + 1}');
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New Study Hub'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final repo = ref.read(_spaceRepo);
    final id = await repo.createBoard(name.trim());
    final all = await repo.fetchBoards();
    setState(() {
      _boardId = id;
      _boards = all;
    });
  }

  Color _canvasBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0A0A0A)
          : SocraTheme.cream;

  Color _gridColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06);

  Future<void> _pickFont() async {
    final all = GoogleFonts.asMap().keys.toList()..sort();
    String filter = '';
    final ctrl = TextEditingController();
    final picked = await showDialog<String>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: const Text('Every Google Font — default Roboto'),
          content: SizedBox(
            width: 420,
            height: 460,
            child: Column(children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                    hintText: 'Search 1500+ fonts...',
                    prefixIcon: Icon(Icons.search)),
                onChanged: (v) => setS(() => filter = v.toLowerCase()),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: all
                      .where((f) => f.toLowerCase().contains(filter))
                      .length,
                  itemBuilder: (c, i) {
                    final list = all
                        .where((f) => f.toLowerCase().contains(filter))
                        .toList();
                    final f = list[i];
                    final style = GoogleFonts.getFont(f, fontSize: 16);
                    return ListTile(
                      title: Text(f, style: style),
                      subtitle: Text('The quick brown fox',
                          style: style.copyWith(fontSize: 12)),
                      onTap: () => Navigator.pop(c, f),
                      selected: f == _board.font,
                    );
                  },
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Close'))
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _board.font = picked);
    }
  }

  Map<String, double> _optimalSize(String type) {
    switch (type) {
      case 'flashcard':
        return {'w': 340, 'h': 200};
      case 'calendar':
        return {'w': 340, 'h': 300};
      case 'todo':
        return {'w': 320, 'h': 260};
      case 'pomodoro':
        return {'w': 260, 'h': 280};
      case 'clock':
        return {'w': 240, 'h': 120};
      case 'stopwatch':
        return {'w': 260, 'h': 140};
      case 'timer':
        return {'w': 160, 'h': 320};
      case 'text':
        return {'w': 260, 'h': 80};
      case 'file':
      case 'notes':
        return {'w': 360, 'h': 260};
      default:
        return {'w': 320, 'h': 220};
    }
  }

  Future<void> _addWidget(String type,
      {Map<String, dynamic> payload = const {}}) async {
    if (_boardId == null) return;
    final sz = _optimalSize(type);
    final rnd = math.Random();
    final off = 120 + rnd.nextDouble() * 300;
    await ref.read(_spaceRepo).addWidget(_boardId!,
        type: type,
        x: off,
        y: off,
        w: sz['w']!,
        h: sz['h']!,
        payload: payload);
  }

  Future<void> _addFileWidget() async {
    final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'doc', 'docx', 'ppt', 'pptx', 'pdf']);
    if (picked.isEmpty) return;
    final f = picked.single;
    String content = f.name;
    final ext = f.name.split('.').last.toLowerCase();
    if (ext == 'txt' || ext == 'md') {
      try {
        final bytes = await f.readAsBytes();
        if (bytes != null) {
          content = utf8.decode(bytes, allowMalformed: true);
          if (content.length > 4000) {
            content = '${content.substring(0, 4000)}\n…';
          }
        }
      } catch (_) {}
    }
    await _addWidget('file',
        payload: {'name': f.name, 'ext': ext, 'content': content});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_boardId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: _canvasBg(context),
      body: Column(children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: isDark ? Colors.black : scheme.surface,
          child: Row(children: [
            const Icon(Icons.auto_awesome_mosaic_outlined, size: 20),
            const SizedBox(width: 8),
            const Text('Study Hub:',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _boardId,
              items: _boards
                  .map((b) =>
                      DropdownMenuItem(value: b.id, child: Text(b.title)))
                  .toList(),
              onChanged: (v) => setState(() => _boardId = v),
            ),
            IconButton(
                tooltip: 'New Hub',
                icon: const Icon(Icons.add),
                onPressed: _createHub),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove),
              tooltip: 'Zoom out',
              onPressed: () => setState(() => _trans.value *=
                  Matrix4.diagonal3Values(0.9, 0.9, 1)),
            ),
            SizedBox(
              width: 140,
              child: ValueListenableBuilder<Matrix4>(
                valueListenable: _trans,
                builder: (c, v, _) => Slider(
                  value: v.getMaxScaleOnAxis().clamp(0.1, 5.0),
                  min: 0.1,
                  max: 5.0,
                  divisions: 49,
                  label:
                      '${(v.getMaxScaleOnAxis() * 100).round().clamp(10, 500)}%',
                  onChanged: (s) => setState(() => _trans.value =
                      Matrix4.diagonal3Values(s, s, 1)),
                ),
              ),
            ),
            ValueListenableBuilder<Matrix4>(
              valueListenable: _trans,
              builder: (c, v, _) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    '${(v.getMaxScaleOnAxis() * 100).round().clamp(10, 500)}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Zoom in',
              onPressed: () => setState(() => _trans.value *=
                  Matrix4.diagonal3Values(1.1, 1.1, 1)),
            ),
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              tooltip: 'Reset',
              onPressed: () =>
                  setState(() => _trans.value = Matrix4.identity()),
            ),
          ]),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PillChip(
                      icon: Icons.style_outlined,
                      label: 'Flashcards',
                      onTap: () => _addWidget('flashcard')),
                  _PillChip(
                      icon: Icons.calendar_month_outlined,
                      label: 'Calendar',
                      onTap: () => _addWidget('calendar')),
                  _PillChip(
                      icon: Icons.checklist_outlined,
                      label: 'To Do',
                      onTap: () => _addWidget('todo')),
                  _PillChip(
                      icon: Icons.timer_outlined,
                      label: 'Pomodoro',
                      onTap: () => _addWidget('pomodoro')),
                  _PillChip(
                      icon: Icons.schedule,
                      label: 'Clock',
                      onTap: () => _addWidget('clock')),
                  _PillChip(
                      icon: Icons.timer,
                      label: 'Stopwatch',
                      onTap: () => _addWidget('stopwatch')),
                  _PillChip(
                      icon: Icons.hourglass_bottom_outlined,
                      label: 'Timer',
                      onTap: () => _addWidget('timer')),
                  _PillChip(
                      icon: Icons.note_alt_outlined,
                      label: 'Notes',
                      onTap: () => _addWidget('notes')),
                  _PillChip(
                      icon: Icons.description_outlined,
                      label: 'File',
                      onTap: _addFileWidget),
                  _PillChip(
                      icon: Icons.text_fields,
                      label: 'Textbox',
                      onTap: () => _selectTool(BoardTool.text)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: Border(
                    right: BorderSide(
                        color: scheme.outlineVariant
                            .withValues(alpha: 0.5))),
              ),
              child: SingleChildScrollView(
                child: Column(children: [
                  _VTool(
                      icon: Icons.pan_tool_alt_outlined,
                      label: 'Select',
                      selected: _board.tool == BoardTool.select,
                      onTap: () => _selectTool(BoardTool.select)),
                  _VTool(
                      key: _markerKey,
                      icon: Icons.edit_outlined,
                      label: 'Marker',
                      selected: _board.tool == BoardTool.marker,
                      onTap: () => _selectTool(BoardTool.marker)),
                  _VTool(
                      key: _eraserKey,
                      icon: Icons.cleaning_services_outlined,
                      label: 'Eraser',
                      selected: _board.tool == BoardTool.eraser,
                      onTap: () => _selectTool(BoardTool.eraser)),
                  const Divider(height: 16),
                  _VTool(
                      icon: Icons.text_fields,
                      label: 'Text',
                      selected: _board.tool == BoardTool.text,
                      onTap: () => _selectTool(BoardTool.text)),
                  PopupMenuButton<BoardTool>(
                    tooltip: 'Shapes',
                    onSelected: (v) => _selectTool(v),
                    itemBuilder: (c) => const [
                      PopupMenuItem(
                          value: BoardTool.shapeRect,
                          child: _MenuRow(
                              icon: Icons.rectangle_outlined,
                              label: 'Rectangle')),
                      PopupMenuItem(
                          value: BoardTool.shapeRoundRect,
                          child: _MenuRow(
                              icon: Icons.rounded_corner,
                              label: 'Rounded')),
                      PopupMenuItem(
                          value: BoardTool.shapeCircle,
                          child: _MenuRow(
                              icon: Icons.circle_outlined,
                              label: 'Circle')),
                      PopupMenuItem(
                          value: BoardTool.shapeEllipse,
                          child: _MenuRow(
                              icon: Icons.circle_outlined,
                              label: 'Ellipse')),
                      PopupMenuItem(
                          value: BoardTool.shapeTriangle,
                          child: _MenuRow(
                              icon: Icons.change_history,
                              label: 'Triangle')),
                      PopupMenuItem(
                          value: BoardTool.shapeLine,
                          child: _MenuRow(
                              icon: Icons.horizontal_rule,
                              label: 'Line')),
                      PopupMenuItem(
                          value: BoardTool.shapeArrow,
                          child: _MenuRow(
                              icon: Icons.arrow_forward,
                              label: 'Arrow')),
                    ],
                    child: _VTool(
                        icon: Icons.category_outlined,
                        label: 'Shapes',
                        selected: _board.tool.isShape &&
                            !_board.tool.name.startsWith('flow'),
                        onTap: () {}),
                  ),
                  PopupMenuButton<BoardTool>(
                    tooltip: 'Diagrams',
                    onSelected: (v) => _selectTool(v),
                    itemBuilder: (c) => const [
                      PopupMenuItem(
                          value: BoardTool.flowProcess,
                          child: _MenuRow(
                              icon: Icons.web_asset,
                              label: 'Process')),
                      PopupMenuItem(
                          value: BoardTool.flowDecision,
                          child: _MenuRow(
                              icon: Icons.diamond_outlined,
                              label: 'Decision')),
                      PopupMenuItem(
                          value: BoardTool.flowData,
                          child: _MenuRow(
                              icon: Icons.view_agenda_outlined,
                              label: 'Data')),
                    ],
                    child: _VTool(
                        icon: Icons.account_tree_outlined,
                        label: 'Flow',
                        selected:
                            _board.tool.name.startsWith('flow'),
                        onTap: () {}),
                  ),
                  const Divider(height: 16),
                  if (_board.tool == BoardTool.text) ...[
                    IconButton(
                        tooltip: 'Font: ${_board.font}',
                        icon: const Icon(Icons.font_download_outlined,
                            size: 20),
                        onPressed: _pickFont),
                    IconButton(
                        icon: Icon(Icons.format_bold,
                            color: _board.bold
                                ? SocraTheme.ecoGreen
                                : null),
                        onPressed: () =>
                            setState(() => _board.bold = !_board.bold)),
                    IconButton(
                        icon: Icon(Icons.format_italic,
                            color: _board.italic
                                ? SocraTheme.ecoGreen
                                : null),
                        onPressed: () => setState(
                            () => _board.italic = !_board.italic)),
                    IconButton(
                        icon: Icon(Icons.format_underlined,
                            color: _board.underline
                                ? SocraTheme.ecoGreen
                                : null),
                        onPressed: () => setState(() =>
                            _board.underline = !_board.underline)),
                    IconButton(
                        icon: Icon(Icons.strikethrough_s,
                            color: _board.strike
                                ? SocraTheme.ecoGreen
                                : null),
                        onPressed: () => setState(
                            () => _board.strike = !_board.strike)),
                  ],
                  const SizedBox(height: 8),
                  IconButton(
                      tooltip: 'Clear ink',
                      icon:
                          const Icon(Icons.delete_sweep_outlined),
                      onPressed: () => ref
                          .read(_spaceRepo)
                          .clearStrokes(_boardId!)),
                  IconButton(
                      tooltip: 'Undo (Ctrl+Z)',
                      icon: const Icon(Icons.undo),
                      onPressed: () => _boardKey.currentState?.undo()),
                  IconButton(
                      tooltip: 'Redo (Ctrl+Y)',
                      icon: const Icon(Icons.redo),
                      onPressed: () => _boardKey.currentState?.redo()),
                ]),
              ),
            ),
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final widgets =
                    ref.watch(_widgetsProvider(_boardId!));
                final strokes =
                    ref.watch(_strokesProvider(_boardId!));
                final shapes = ref.watch(_shapesProvider(_boardId!));
                return widgets.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (wlist) => strokes.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Text('$e'),
                    data: (slist) => shapes.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                      data: (shlist) => ValueListenableBuilder<bool>(
                        valueListenable: _board.panning,
                        builder: (c, panning, _) => MouseRegion(
                          cursor: panning
                              ? SystemMouseCursors.grabbing
                              : _board.tool == BoardTool.select
                                  ? SystemMouseCursors.grab
                                  : SystemMouseCursors.precise,
                        child: BoardView(
                          key: _boardKey,
                          boardId: _boardId!,
                          state: _board,
                          repo: ref.watch(_spaceRepo),
                          trans: _trans,
                          bg: _canvasBg(context),
                          gridColor: _gridColor(context),
                          widgets: wlist,
                          strokes: slist,
                          shapes: shlist,
                        ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Horizontal colour + thickness box that pops beside the marker/eraser
/// button the moment it is (re)selected.
class _ToolPopupCard extends StatelessWidget {
  const _ToolPopupCard({required this.board, required this.onChanged});
  final BoardState board;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEraser = board.tool == BoardTool.eraser;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: scheme.surface,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEraser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Colors.black,
                  Colors.white,
                  SocraTheme.ecoGreen,
                  Colors.redAccent,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                ]
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              board.color = c;
                              onChanged();
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: board.color == c
                                        ? scheme.primary
                                        : scheme.outlineVariant,
                                    width: 2),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            if (!isEraser)
              Container(
                  width: 1,
                  height: 40,
                  color: scheme.outlineVariant,
                  margin: const EdgeInsets.only(right: 12)),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Center(
                child: Container(
                  width: board.width.clamp(2, 24),
                  height: board.width.clamp(2, 24),
                  decoration: BoxDecoration(
                    color: isEraser
                        ? scheme.onSurfaceVariant
                        : board.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${board.width.toStringAsFixed(1)} px',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant)),
                SizedBox(
                  width: 140,
                  child: Slider(
                    value: board.width,
                    min: 1,
                    max: 24,
                    divisions: 12,
                    label: board.width.toStringAsFixed(1),
                    onChanged: (v) {
                      board.width = v;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
            if (isEraser) ...[
              Container(
                  width: 1,
                  height: 40,
                  color: scheme.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: 12)),
              SegmentedButton<EraserMode>(
                segments: const [
                  ButtonSegment(
                      value: EraserMode.stroke,
                      label:
                          Text('Stroke', style: TextStyle(fontSize: 11)),
                      icon: Icon(Icons.layers_clear, size: 14)),
                  ButtonSegment(
                      value: EraserMode.pixel,
                      label:
                          Text('Pixel', style: TextStyle(fontSize: 11)),
                      icon: Icon(Icons.gradient, size: 14)),
                ],
                selected: {board.eraserMode},
                onSelectionChanged: (s) {
                  board.eraserMode = s.first;
                  onChanged();
                },
                showSelectedIcon: false,
                style: const ButtonStyle(
                    visualDensity: VisualDensity.compact),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label),
      ]);
}

class _VTool extends StatelessWidget {
  const _VTool(
      {super.key,
      required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: selected
                    ? SocraTheme.ecoGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Icon(icon,
                  size: 20,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      color: selected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

class _PillChip extends StatelessWidget {
  const _PillChip(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          avatar: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          onPressed: onTap,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: StadiumBorder(
              side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5))),
        ),
      );
}

final _widgetsProvider = StreamProvider.family<List<BoardWidget>, int>(
    (ref, id) => ref.watch(_spaceRepo).watchWidgets(id));
final _strokesProvider = StreamProvider.family<List<BoardStroke>, int>(
    (ref, id) => ref.watch(_spaceRepo).watchStrokes(id));
final _shapesProvider = StreamProvider.family<List<BoardShape>, int>(
    (ref, id) => ref.watch(_spaceRepo).watchShapes(id));
