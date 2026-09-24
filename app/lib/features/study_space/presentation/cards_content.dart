import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/flashcards/data/flashcard_repository.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

/// Per-type widget bodies (v2). Each sizes to its content — no blank space.
/// Inner elements scale with the outer card via [size].
class WidgetBody extends StatelessWidget {
  const WidgetBody({
    super.key,
    required this.type,
    required this.payload,
    required this.onUpdatePayload,
    required this.size,
  });

  final String type;
  final Map<String, dynamic> payload;
  final void Function(Map<String, dynamic>) onUpdatePayload;
  final Size size;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'flashcard':
        return const _FlashBody();
      case 'calendar':
        return const _CalendarBody();
      case 'todo':
        return const _TodoBody();
      case 'pomodoro':
        return const _PomodoroBody();
      case 'clock':
        return const _ClockBody();
      case 'stopwatch':
        return const _StopwatchBody();
      case 'timer':
        return const _TimerBody();
      case 'text':
        return _TextBody(payload: payload, onUpdate: onUpdatePayload, size: size);
      case 'file':
        return _FileBody(payload: payload, size: size);
      case 'notes':
        return _NotesBody(
          initial: payload['content']?.toString() ?? '',
          onChanged: (v) => onUpdatePayload({...payload, 'content': v}),
        );
      default:
        return Text('$type widget',
            style: const TextStyle(fontWeight: FontWeight.w600));
    }
  }
}

class _FlashBody extends ConsumerWidget {
  const _FlashBody();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(_flashDecksProvider);
    return decks.when(
      loading: () => const Center(
          child: SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Text('$e', style: const TextStyle(fontSize: 12)),
      data: (ds) {
        if (ds.isEmpty) {
          return const Text('No decks — create in Flashcards',
              style: TextStyle(fontSize: 12));
        }
        final deck = ds.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(deck.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            FutureBuilder<List<FlashCard>>(
              future: FlashcardRepository(ref.watch(databaseProvider))
                  .fetchCards(deck.id),
              builder: (c, snap) {
                if (!snap.hasData) return const LinearProgressIndicator();
                final cards = snap.data!;
                if (cards.isEmpty) {
                  return const Text('No cards yet',
                      style: TextStyle(fontSize: 12));
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: cards
                      .take(3)
                      .map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: SocraTheme.ecoGreen,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(card.term,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(fontSize: 12))),
                            ]),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.style, size: 14),
                label:
                    const Text('Study', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        );
      },
    );
  }
}

final _flashDecksProvider = StreamProvider<List<FlashDeck>>(
    (ref) => FlashcardRepository(ref.watch(databaseProvider)).watchDecks());

class _CalendarBody extends StatelessWidget {
  const _CalendarBody();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Calendar — ${now.month}/${now.year}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map((d) => Text(d,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant)))
                    .toList()),
            const SizedBox(height: 6),
            for (var r = 0; r < 3; r++)
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                      7,
                      (c) => Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: r == 1 && c == 2
                                  ? SocraTheme.ecoGreen
                                  : Colors.transparent,
                              shape: BoxShape.circle),
                          child: Center(
                              child: Text('${7 + r * 7 + c}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: r == 1 && c == 2
                                          ? Colors.white
                                          : null)))))),
          ]),
        ),
      ],
    );
  }
}

class _TodoBody extends ConsumerWidget {
  const _TodoBody();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('To Do',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        tasks.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('$e', style: const TextStyle(fontSize: 12)),
          data: (ts) {
            if (ts.isEmpty) {
              return const Text('No tasks', style: TextStyle(fontSize: 12));
            }
            return Column(
                mainAxisSize: MainAxisSize.min,
                children: ts
                    .take(4)
                    .map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Icon(
                              t.done
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 16,
                              color: t.done
                                  ? SocraTheme.ecoGreen
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      decoration: t.done
                                          ? TextDecoration.lineThrough
                                          : null))),
                        ])))
                    .toList());
          },
        ),
      ],
    );
  }
}

class _TextBody extends StatelessWidget {
  const _TextBody(
      {required this.payload, required this.onUpdate, required this.size});
  final Map<String, dynamic> payload;
  final void Function(Map<String, dynamic>) onUpdate;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final txt = payload['text']?.toString() ?? 'Text';
    final font = payload['font']?.toString() ?? 'Roboto';
    final sz = (payload['size'] as num?)?.toDouble() ?? 16;
    final scale = (size.width / 260).clamp(0.7, 2.0);
    final bold = payload['bold'] == true;
    final italic = payload['italic'] == true;
    final underline = payload['underline'] == true;
    final strike = payload['strike'] == true;
    Color col = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final colorStr = payload['color']?.toString();
    try {
      if (colorStr != null) {
        col = Color(int.parse(colorStr.replaceFirst('#', '0x')));
      }
    } catch (_) {}
    final base = GoogleFonts.getFont(font,
        fontSize: sz * scale,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        decoration: strike
            ? TextDecoration.lineThrough
            : underline
                ? TextDecoration.underline
                : TextDecoration.none,
        color: col);
    return GestureDetector(
      onDoubleTap: () async {
        final ctrl = TextEditingController(text: txt);
        final res = await showDialog<String>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Edit text'),
            content: TextField(controller: ctrl, autofocus: true, maxLines: 4),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(c, ctrl.text),
                  child: const Text('Save')),
            ],
          ),
        );
        if (res != null) onUpdate({...payload, 'text': res});
      },
      child: Text(txt, style: base),
    );
  }
}

class _FileBody extends StatelessWidget {
  const _FileBody({required this.payload, required this.size});
  final Map<String, dynamic> payload;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final name = payload['name']?.toString() ?? 'File';
    final ext = payload['ext']?.toString() ?? '';
    final content = payload['content']?.toString() ?? '';
    final isTxt = ext == 'txt' || ext == 'md';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(
              ext == 'pdf'
                  ? Icons.picture_as_pdf
                  : ext.contains('ppt')
                      ? Icons.slideshow
                      : Icons.description,
              size: 20,
              color: SocraTheme.ecoGreen),
          const SizedBox(width: 6),
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
        const Divider(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: isTxt
                ? Text(content,
                    style: TextStyle(
                        fontSize: 12 * (size.width / 320).clamp(0.8, 1.2),
                        fontFamily: 'monospace'))
                : Column(children: [
                    Icon(
                        ext.contains('doc')
                            ? Icons.article
                            : Icons.slideshow,
                        size: 40 * (size.width / 340).clamp(0.8, 1.4),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('$ext file — $name',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                        content.isEmpty
                            ? 'Preview not available — open in external app'
                            : content,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 6),
                  ]),
          ),
        ),
      ],
    );
  }
}

class _NotesBody extends StatefulWidget {
  const _NotesBody({required this.initial, required this.onChanged});
  final String initial;
  final ValueChanged<String> onChanged;
  @override
  State<_NotesBody> createState() => _NotesBodyState();
}

class _NotesBodyState extends State<_NotesBody> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initial);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Expanded(
          child: TextField(
            controller: _ctrl,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              hintText: 'Type your notes…',
            ),
            onChanged: (v) {
              // Debounced commit so typing never hammers the DB.
              _debounce?.cancel();
              _debounce =
                  Timer(const Duration(milliseconds: 600), () {
                widget.onChanged(v);
              });
            },
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
      ],
    );
  }
}

class _PomodoroBody extends StatefulWidget {
  const _PomodoroBody();
  @override
  State<_PomodoroBody> createState() => _PomodoroBodyState();
}

class _PomodoroBodyState extends State<_PomodoroBody> {
  int _sec = 25 * 60;
  Timer? _t;
  bool _run = false;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const total = 25 * 60;
    final pct = (total - _sec) / total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Pomodoro',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _RingPainter(
                progress: pct,
                color: SocraTheme.ecoGreen,
                bg: Theme.of(context).colorScheme.surfaceContainerHighest),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '${(_sec ~/ 60).toString().padLeft(2, '0')}:${(_sec % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  InkWell(
                    onTap: () async {
                      final ctrl =
                          TextEditingController(text: '${_sec ~/ 60}');
                      final v = await showDialog<String>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Edit minutes'),
                          content: TextField(
                              controller: ctrl,
                              keyboardType: TextInputType.number,
                              autofocus: true),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Cancel')),
                            FilledButton(
                                onPressed: () => Navigator.pop(c, ctrl.text),
                                child: const Text('Save')),
                          ],
                        ),
                      );
                      if (v != null) {
                        final m = int.tryParse(v);
                        if (m != null) setState(() => _sec = m * 60);
                      }
                    },
                    child: Text('tap to edit',
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                  _run ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: SocraTheme.ecoGreen),
              iconSize: 28,
              onPressed: () {
                setState(() => _run = !_run);
                _t?.cancel();
                if (_run) {
                  _t = Timer.periodic(const Duration(seconds: 1),
                      (_) => setState(() => _sec = _sec > 0 ? _sec - 1 : 0));
                }
              },
            ),
            IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => setState(() => _sec = 25 * 60)),
          ],
        ),
      ],
    );
  }
}

/// Mathematically smooth ring: true circle + arc, anti-aliased, round caps.
class _RingPainter extends CustomPainter {
  _RingPainter(
      {required this.progress, required this.color, required this.bg});
  final double progress;
  final Color color;
  final Color bg;

  @override
  void paint(Canvas c, Size s) {
    const stroke = 8.0;
    final center = Offset(s.width / 2, s.height / 2);
    final radius =
        (s.width < s.height ? s.width : s.height) / 2 - stroke / 2;
    final bgP = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final fgP = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    c.drawCircle(center, radius, bgP);
    c.drawArc(Rect.fromCircle(center: center, radius: radius), -3.14159265 / 2,
        2 * 3.14159265 * progress.clamp(0.0, 1.0), false, fgP);
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) =>
      o.progress != progress || o.color != color;
}

class _ClockBody extends StatefulWidget {
  const _ClockBody();
  @override
  State<_ClockBody> createState() => _ClockBodyState();
}

class _ClockBodyState extends State<_ClockBody> {
  late Timer _t;
  DateTime _now = DateTime.now();
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Time',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(
              '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      );
}

class _StopwatchBody extends StatefulWidget {
  const _StopwatchBody();
  @override
  State<_StopwatchBody> createState() => _StopwatchBodyState();
}

class _StopwatchBodyState extends State<_StopwatchBody> {
  final Stopwatch _sw = Stopwatch();
  Timer? _t;
  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Stopwatch',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(
              '${_sw.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_sw.elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                    _sw.isRunning
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: SocraTheme.ecoGreen),
                onPressed: () => setState(() {
                  if (_sw.isRunning) {
                    _sw.stop();
                    _t?.cancel();
                  } else {
                    _sw.start();
                    _t = Timer.periodic(const Duration(milliseconds: 100),
                        (_) => setState(() {}));
                  }
                }),
              ),
              IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => setState(() {
                        _sw.reset();
                        _sw.stop();
                        _t?.cancel();
                      })),
            ],
          ),
        ],
      );
}

class _TimerBody extends StatefulWidget {
  const _TimerBody();
  @override
  State<_TimerBody> createState() => _TimerBodyState();
}

class _TimerBodyState extends State<_TimerBody> {
  int _total = 300;
  int _sec = 300;
  Timer? _t;
  bool _run = false;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _total == 0 ? 0.0 : (_total - _sec) / _total;
    return LayoutBuilder(builder: (context, c) {
      final h = c.maxHeight.isFinite ? c.maxHeight : 220.0;
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Timer',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                    '${(_sec ~/ 60).toString().padLeft(2, '0')}:${(_sec % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                        fontSize: (h * 0.12).clamp(18.0, 32.0),
                        fontWeight: FontWeight.w800)),
                InkWell(
                  onTap: () async {
                    final ctrl =
                        TextEditingController(text: '${_sec ~/ 60}');
                    final v = await showDialog<String>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Edit minutes'),
                        content: TextField(
                            controller: ctrl,
                            keyboardType: TextInputType.number,
                            autofocus: true),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(c, ctrl.text),
                              child: const Text('Save')),
                        ],
                      ),
                    );
                    if (v != null) {
                      final m = int.tryParse(v);
                      if (m != null) {
                        setState(() {
                          _total = m * 60;
                          _sec = m * 60;
                        });
                      }
                    }
                  },
                  child: Text('tap to edit',
                      style: Theme.of(context).textTheme.labelSmall),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  IconButton(
                    icon: Icon(
                        _run
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: Colors.orange),
                    onPressed: () {
                      setState(() => _run = !_run);
                      if (_run) {
                        _t = Timer.periodic(const Duration(seconds: 1),
                            (_) => setState(
                                () => _sec = _sec > 0 ? _sec - 1 : 0));
                      } else {
                        _t?.cancel();
                      }
                    },
                  ),
                  IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () => setState(() => _sec = _total)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 18,
            height: h * 0.7,
            decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999)),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: h * 0.7 * pct,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ],
      );
    });
  }
}
