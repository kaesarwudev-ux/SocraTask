import 'dart:convert';
import 'dart:math' as math;
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/features/study_space/data/study_space_repository.dart';
import 'package:socra_task/features/study_space/presentation/board_card.dart';
import 'package:socra_task/features/study_space/presentation/board_state.dart';
import 'package:socra_task/features/study_space/presentation/cards_content.dart';
import 'package:socra_task/features/study_space/presentation/ink.dart';

/// Infinite canvas board (v2). Research applied:
/// - Excalidraw: separate static (committed ink+grid) vs interactive
///   (live stroke, selection, previews) layers with RepaintBoundary each.
/// - tldraw: pointer state machine (idle/drawing/shaping/texting), shift
///   toggles selection, snapshot-then-commit transforms.
/// - Flutter perf issue #72066: ValueNotifier for live stroke (never
///   setState the page on pointer move), isComplex/willChange hints,
///   guarded hit-testing (never before layout).
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.boardId,
    required this.state,
    required this.repo,
    required this.trans,
    required this.bg,
    required this.gridColor,
    required this.widgets,
    required this.strokes,
    required this.shapes,
  });

  final int boardId;
  final BoardState state;
  final StudySpaceRepository repo;
  final TransformationController trans;
  final Color bg;
  final Color gridColor;
  final List<BoardWidget> widgets;
  final List<BoardStroke> strokes;
  final List<BoardShape> shapes;

  @override
  State<BoardView> createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> {
  Offset? _shapeStart;
  Offset? _textStart;

  /// In-memory undo (strokes + widgets). Redo stack cleared on new action.
  final List<Future<void> Function()> _undo = [];
  final List<Future<void> Function()> _redo = [];
  final List<BoardStroke> _undoneStrokes = [];

  void _pushUndo(Future<void> Function() action) {
    _undo.add(action);
    _redo.clear();
    if (_undo.length > 50) _undo.removeAt(0);
  }

  Future<void> undo() async {
    if (_undo.isNotEmpty) {
      await _undo.removeLast()();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Undo'),
            duration: Duration(seconds: 1),
            showCloseIcon: true));
      }
      return;
    }
    final repo = widget.repo;
    final last = await repo.latestStrokes(widget.boardId, 1);
    if (last.isEmpty) return;
    _undoneStrokes.add(last.first);
    await repo.deleteStroke(last.first.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Undo stroke'),
          duration: Duration(seconds: 1),
          showCloseIcon: true));
    }
  }

  Future<void> redo() async {
    if (_redo.isNotEmpty) {
      await _redo.removeLast()();
      return;
    }
    if (_undoneStrokes.isEmpty) return;
    final s = _undoneStrokes.removeLast();
    await widget.repo.restoreStroke(s);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Redo stroke'),
          duration: Duration(seconds: 1),
          showCloseIcon: true));
    }
  }

  Offset _toCanvas(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return global;
    try {
      return widget.trans.toScene(box.globalToLocal(global));
    } catch (_) {
      return global;
    }
  }

  Color _inkColor(BuildContext context) {
    const def = Color(0xFF1A1A1A);
    if (widget.state.color == def) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1E1E1E);
    }
    return widget.state.color;
  }

  int? _hitTest(Offset p) {
    for (final w in widget.widgets) {
      if (p.dx >= w.x &&
          p.dx <= w.x + w.w &&
          p.dy >= w.y &&
          p.dy <= w.y + w.h) {
        return w.id;
      }
    }
    for (final s in widget.shapes) {
      if (p.dx >= s.x &&
          p.dx <= s.x + s.w &&
          p.dy >= s.y &&
          p.dy <= s.y + s.h) {
        return s.id;
      }
    }
    return null;
  }

  Future<void> _eraseAt(Offset pos) async {
    final st = widget.state;
    final thresh =
        st.eraserMode == EraserMode.stroke ? st.width * 1.8 : st.width * 0.9;
    for (final s in widget.strokes) {
      try {
        final pts = (jsonDecode(s.pointsJson) as List)
            .map((e) =>
                Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()))
            .toList();
        for (final pt in pts) {
          if ((pt - pos).distance < thresh + s.width) {
            await widget.repo.deleteStroke(s.id);
            final snap = s;
            _pushUndo(() => widget.repo.restoreStroke(snap));
            return;
          }
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final isSelect = st.tool == BoardTool.select;
    return Listener(
      onPointerDown: (e) {
        final pressure =
            e.pressure == 0 ? 1.0 : e.pressure.clamp(0.2, 1.0);
        final pos = _toCanvas(e.position);
        if (st.tool == BoardTool.text) {
          _textStart = pos;
          return;
        }
        if (st.tool.isShape) {
          _shapeStart = pos;
          return;
        }
        if (st.tool.isPen) {
          final stylus = e.kind == PointerDeviceKind.stylus;
          st.beginStroke(pos.dx, pos.dy, stylus ? pressure : 1.0);
        } else if (st.tool == BoardTool.eraser) {
          _eraseAt(pos);
        } else if (isSelect) {
          if (_hitTest(pos) == null &&
              !HardwareKeyboard.instance.isShiftPressed) {
            st.clearSelection();
          }
        }
      },
      onPointerMove: (e) {
        final pressure =
            e.pressure == 0 ? 1.0 : e.pressure.clamp(0.2, 1.0);
        final pos = _toCanvas(e.position);
        if (_textStart != null) {
          st.setPreview(Rect.fromPoints(_textStart!, pos));
          return;
        }
        if (_shapeStart != null) {
          st.setPreview(Rect.fromPoints(_shapeStart!, pos));
          return;
        }
        if (st.tool == BoardTool.eraser) {
          _eraseAt(pos);
          return;
        }
        if (st.liveStroke.value.isNotEmpty) {
          st.appendStroke(pos.dx, pos.dy, pressure);
        }
      },
      onPointerUp: (e) async {
        if (_textStart != null) {
          final end = _toCanvas(e.position);
          final rect = Rect.fromPoints(_textStart!, end);
          _textStart = null;
          st.setPreview(null);
          if (rect.width.abs() > 20 && rect.height.abs() > 20) {
            final norm = Rect.fromPoints(rect.topLeft, rect.bottomRight);
            await widget.repo.addWidget(widget.boardId,
                type: 'text',
                x: norm.left,
                y: norm.top,
                w: norm.width.clamp(120, 800),
                h: norm.height.clamp(40, 400),
                payload: {
                  'text': 'Type here…',
                  'font': st.font,
                  'size': st.fontSize,
                  'bold': st.bold,
                  'italic': st.italic,
                  'underline': st.underline,
                  'strike': st.strike,
                  'color': toHex(_inkColor(context)),
                });
            st.setTool(BoardTool.select);
          }
          return;
        }
        if (_shapeStart != null) {
          final end = _toCanvas(e.position);
          final rect = Rect.fromPoints(_shapeStart!, end);
          _shapeStart = null;
          st.setPreview(null);
          if (rect.width.abs() >= 8 && rect.height.abs() >= 8) {
            final norm = Rect.fromPoints(rect.topLeft, rect.bottomRight);
            await widget.repo.addShape(widget.boardId,
                kind: st.tool.shapeKind,
                x: norm.left,
                y: norm.top,
                w: norm.width,
                h: norm.height,
                style: {
                  'color': toHex(_inkColor(context)),
                  'width': st.width,
                });
            st.setTool(BoardTool.select);
          }
          return;
        }
        final pts = st.takeStroke();
        if (pts.length > 1) {
          await widget.repo.addStroke(widget.boardId,
              tool: st.tool.name,
              points: pts,
              color: toHex(_inkColor(context)),
              width: st.width,
              opacity: st.tool == BoardTool.highlighter ? 0.4 : 1);
        }
      },
      child: InteractiveViewer(
        transformationController: widget.trans,
        minScale: 0.1,
        maxScale: 5.0,
        boundaryMargin: EdgeInsets.all(double.infinity),
        // Pan ONLY with Select active — otherwise the board moves while
        // drawing (the reported bug). Pinch-zoom stays available always.
        panEnabled: isSelect,
        scaleEnabled: true,
        onInteractionStart: (_) => widget.state.panning.value = true,
        onInteractionEnd: (_) => widget.state.panning.value = false,
        child: Container(
          width: 20000,
          height: 20000,
          color: widget.bg,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: const Size(20000, 20000),
                  painter: _GridPainter(color: widget.gridColor),
                  isComplex: true,
                  willChange: false,
                ),
              ),
              RepaintBoundary(
                child: CustomPaint(
                  size: const Size(20000, 20000),
                  painter: CommittedInk(widget.strokes),
                  isComplex: true,
                ),
              ),
              RepaintBoundary(
                child: ValueListenableBuilder<List<List<double>>>(
                  valueListenable: st.liveStroke,
                  builder: (context, pts, _) => CustomPaint(
                    size: const Size(20000, 20000),
                    painter: LiveInk(pts, _inkColor(context), st.width,
                        st.tool.name),
                  ),
                ),
              ),
              ...widget.shapes.map((s) => _ShapeItem(
                    key: ValueKey('s-${s.id}'),
                    shape: s,
                    selected: st.selected.contains(s.id),
                    toCanvas: _toCanvas,
                    onSelect: (shift) => shift
                        ? st.toggleSelect([s.id])
                        : st.selectOnly([s.id]),
                    onMoveEnd: (x, y) =>
                        widget.repo.moveShape(s.id, x, y),
                    onDelete: () {
                      widget.repo.deleteShape(s.id);
                      st.deselect(s.id);
                    },
                    inkColor: _inkColor(context),
                  )),
              if (st.previewRect != null)
                Positioned.fromRect(
                  rect: st.previewRect!,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _inkColor(context), width: 2),
                        color: _inkColor(context).withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ...widget.widgets.map((w) => BoardCard(
                    key: ValueKey('w-${w.id}'),
                    widget: w,
                    selected: st.selected.contains(w.id),
                    toCanvas: _toCanvas,
                    onSelect: (shift) => shift
                        ? st.toggleSelect([w.id])
                        : st.selectOnly([w.id]),
                    onMoveEnd: (x, y) =>
                        widget.repo.moveWidget(w.id, x, y),
                    onResizeEnd: (nw, nh, nx, ny) async {
                      await widget.repo.resizeWidget(w.id, nw, nh);
                      await widget.repo.moveWidget(w.id, nx, ny);
                    },
              onDelete: () {
                widget.repo.deleteWidget(w.id);
                st.deselect(w.id);
              },
              content: WidgetBody(
                      type: w.type,
                      payload: decodePayload(w.payloadJson),
                      onUpdatePayload: (p) =>
                          widget.repo.updateWidgetPayload(w.id, p),
                      size: Size(w.w, w.h),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < s.width; x += 24) {
      for (var y = 0.0; y < s.height; y += 24) {
        c.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

/// Canvas shape with transient drag + commit on release.
class _ShapeItem extends StatefulWidget {
  const _ShapeItem({
    super.key,
    required this.shape,
    required this.selected,
    required this.toCanvas,
    required this.onSelect,
    required this.onMoveEnd,
    required this.onDelete,
    required this.inkColor,
  });

  final BoardShape shape;
  final bool selected;
  final Offset Function(Offset global) toCanvas;
  final void Function(bool shift) onSelect;
  final void Function(double x, double y) onMoveEnd;
  final VoidCallback onDelete;
  final Color inkColor;

  @override
  State<_ShapeItem> createState() => _ShapeItemState();
}

class _ShapeItemState extends State<_ShapeItem> {
  Offset? _delta;
  Offset? _grab;
  late double _sx;
  late double _sy;

  @override
  Widget build(BuildContext context) {
    final s = widget.shape;
    final off = _delta ?? Offset.zero;
    return Positioned(
      left: s.x + off.dx,
      top: s.y + off.dy,
      width: s.w,
      height: s.h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onSelect(
            HardwareKeyboard.instance.isShiftPressed),
        onPanStart: (d) {
          _grab = widget.toCanvas(d.globalPosition);
          _sx = s.x;
          _sy = s.y;
          _delta = Offset.zero;
        },
        onPanUpdate: (d) {
          final grab = _grab;
          if (grab == null) return;
          setState(
              () => _delta = widget.toCanvas(d.globalPosition) - grab);
        },
        onPanEnd: (_) {
          final off = _delta;
          _delta = null;
          _grab = null;
          if (off == null || (off.dx == 0 && off.dy == 0)) return;
          widget.onMoveEnd(_sx + off.dx, _sy + off.dy);
          setState(() {});
        },
        onDoubleTap: widget.onDelete,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(s.w, s.h),
            painter: _ShapePainter(
                kind: s.kind, color: _shapeColor(s.styleJson)),
          ),
        ),
      ),
    );
  }

  Color _shapeColor(String json) {
    try {
      final m = jsonDecode(json);
      if (m['color'] is String) {
        return Color(
            int.parse((m['color'] as String).replaceFirst('#', '0x')));
      }
    } catch (_) {}
    return widget.inkColor;
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({required this.kind, required this.color});
  final String kind;
  final Color color;

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final pf = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final r = Rect.fromLTWH(0, 0, s.width, s.height);
    c.save();
    c.clipRect(r);
    switch (kind) {
      case 'rect':
        c.drawRect(r, pf);
        c.drawRect(r, p);
        break;
      case 'roundRect':
        final rr = RRect.fromRectAndRadius(r, const Radius.circular(12));
        c.drawRRect(rr, pf);
        c.drawRRect(rr, p);
        break;
      case 'circle':
        final d = math.min(s.width, s.height);
        final cr = Rect.fromCenter(
            center: r.center, width: d, height: d);
        c.drawOval(cr, pf);
        c.drawOval(cr, p);
        break;
      case 'ellipse':
        c.drawOval(r, pf);
        c.drawOval(r, p);
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(r.center.dx, r.top)
          ..lineTo(r.left, r.bottom)
          ..lineTo(r.right, r.bottom)
          ..close();
        c.drawPath(path, pf);
        c.drawPath(path, p);
        break;
      case 'line':
        c.drawLine(
            Offset(0, s.height / 2), Offset(s.width, s.height / 2), p);
        break;
      case 'arrow':
        final path = Path()
          ..moveTo(0, s.height / 2)
          ..lineTo(s.width - 12, s.height / 2)
          ..lineTo(s.width - 12, s.height / 2 - 8)
          ..lineTo(s.width, s.height / 2)
          ..lineTo(s.width - 12, s.height / 2 + 8)
          ..lineTo(s.width - 12, s.height / 2)
          ..close();
        c.drawPath(path, pf);
        c.drawPath(path, p);
        break;
      case 'flowProcess':
        c.drawRect(r, pf);
        c.drawRect(r, p);
        break;
      case 'flowDecision':
        final path = Path()
          ..moveTo(r.center.dx, r.top)
          ..lineTo(r.right, r.center.dy)
          ..lineTo(r.center.dx, r.bottom)
          ..lineTo(r.left, r.center.dy)
          ..close();
        c.drawPath(path, pf);
        c.drawPath(path, p);
        break;
      case 'flowData':
        final path = Path()
          ..moveTo(r.left + 16, r.top)
          ..lineTo(r.right, r.top)
          ..lineTo(r.right - 16, r.bottom)
          ..lineTo(r.left, r.bottom)
          ..close();
        c.drawPath(path, pf);
        c.drawPath(path, p);
        break;
      default:
        c.drawRect(r, pf);
        c.drawRect(r, p);
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => true;
}
