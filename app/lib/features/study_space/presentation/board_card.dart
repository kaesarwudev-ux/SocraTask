import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';

/// Draggable + resizable board card (v2). Lag fixes vs the deleted version:
/// - Drag uses ABSOLUTE canvas mapping (toScene of global pointer pos) so
///   1 screen px == 1 canvas px at any zoom — no scale division bugs.
/// - Transient position/size lives in THIS card's state during the gesture;
///   Drift commits ONCE on release (never per-frame).
/// - 8 handles with per-handle cursors (tldraw/Docs convention) on a
///   Clip.none overlay so they are never cut off.
class BoardCard extends StatefulWidget {
  const BoardCard({
    super.key,
    required this.widget,
    required this.selected,
    required this.toCanvas,
    required this.onSelect,
    required this.onMoveEnd,
    required this.onResizeEnd,
    required this.onDelete,
    required this.content,
  });

  final BoardWidget widget;
  final bool selected;
  final Offset Function(Offset global) toCanvas;
  final void Function(bool shift) onSelect;
  final void Function(double x, double y) onMoveEnd;
  final void Function(double w, double h, double x, double y) onResizeEnd;
  final VoidCallback onDelete;
  final Widget content;

  @override
  State<BoardCard> createState() => _BoardCardState();
}

class _BoardCardState extends State<BoardCard> {
  Offset? _dragDelta;
  Offset? _grabCanvas;
  late double _startX;
  late double _startY;

  double? _rw;
  double? _rh;
  double? _rx;
  double? _ry;

  void _onPanStart(DragStartDetails d) {
    _grabCanvas = widget.toCanvas(d.globalPosition);
    _startX = widget.widget.x;
    _startY = widget.widget.y;
    _dragDelta = Offset.zero;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final grab = _grabCanvas;
    if (grab == null) return;
    final cur = widget.toCanvas(d.globalPosition);
    setState(() => _dragDelta = cur - grab);
  }

  void _onPanEnd(DragEndDetails _) {
    final off = _dragDelta;
    _dragDelta = null;
    _grabCanvas = null;
    if (off == null || (off.dx == 0 && off.dy == 0)) return;
    widget.onMoveEnd(_startX + off.dx, _startY + off.dy);
    setState(() {});
  }

  void _resizeLive(double nw, double nh, double nx, double ny) {
    setState(() {
      _rw = nw;
      _rh = nh;
      _rx = nx;
      _ry = ny;
    });
  }

  void _resizeCommit() {
    final rw = _rw, rh = _rh, rx = _rx, ry = _ry;
    _rw = _rh = _rx = _ry = null;
    if (rw == null || rh == null || rx == null || ry == null) return;
    widget.onResizeEnd(rw, rh, rx, ry);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.widget;
    final off = _dragDelta ?? Offset.zero;
    final scheme = Theme.of(context).colorScheme;
    final cw = _rw ?? w.w;
    final ch = _rh ?? w.h;
    final cx = _rx ?? (w.x + off.dx);
    final cy = _ry ?? (w.y + off.dy);
    return Positioned(
      left: cx,
      top: cy,
      width: cw,
      height: ch,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onSelect(
              HardwareKeyboard.instance.isShiftPressed),
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.selected
                        ? SocraTheme.ecoGreen
                        : scheme.outlineVariant.withValues(alpha: 0.6),
                    width: widget.selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.content,
                ),
              ),
              if (widget.selected) ...[
                Positioned(
                  top: 6,
                  right: 6,
                  child: _DeleteBtn(onTap: widget.onDelete),
                ),
                _CardHandle(
                  left: -7,
                  top: -7,
                  cursor: SystemMouseCursors.resizeUpLeft,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bw = _rw ?? w.w;
                    final bh = _rh ?? w.h;
                    final bx = _rx ?? w.x;
                    final by = _ry ?? w.y;
                    _resizeLive((bw - dx).clamp(140.0, 900.0),
                        (bh - dy).clamp(80.0, 800.0), bx + dx, by + dy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: cw / 2 - 7,
                  top: -7,
                  cursor: SystemMouseCursors.resizeUpDown,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bh = _rh ?? w.h;
                    final by = _ry ?? w.y;
                    _resizeLive(cw, (bh - dy).clamp(80.0, 800.0), cx, by + dy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: cw - 7,
                  top: -7,
                  cursor: SystemMouseCursors.resizeUpRight,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bw = _rw ?? w.w;
                    final bh = _rh ?? w.h;
                    final by = _ry ?? w.y;
                    _resizeLive((bw + dx).clamp(140.0, 900.0),
                        (bh - dy).clamp(80.0, 800.0), cx, by + dy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: -7,
                  top: ch / 2 - 7,
                  cursor: SystemMouseCursors.resizeLeftRight,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bw = _rw ?? w.w;
                    final bx = _rx ?? w.x;
                    _resizeLive(
                        (bw - dx).clamp(140.0, 900.0), ch, bx + dx, cy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: cw - 7,
                  top: ch / 2 - 7,
                  cursor: SystemMouseCursors.resizeLeftRight,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bw = _rw ?? w.w;
                    _resizeLive((bw + dx).clamp(140.0, 900.0), ch, cx, cy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: -7,
                  top: ch - 7,
                  cursor: SystemMouseCursors.resizeDownLeft,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bw = _rw ?? w.w;
                    final bh = _rh ?? w.h;
                    final bx = _rx ?? w.x;
                    _resizeLive((bw - dx).clamp(140.0, 900.0),
                        (bh + dy).clamp(80.0, 800.0), bx + dx, cy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: cw / 2 - 7,
                  top: ch - 7,
                  cursor: SystemMouseCursors.resizeUpDown,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bh = _rh ?? w.h;
                    _resizeLive(cw, (bh + dy).clamp(80.0, 800.0), cx, cy);
                  },
                  onEnd: _resizeCommit,
                ),
                _CardHandle(
                  left: cw - 7,
                  top: ch - 7,
                  cursor: SystemMouseCursors.resizeDownRight,
                  toCanvas: widget.toCanvas,
                  onUpdate: (dx, dy) {
                    final bw = _rw ?? w.w;
                    final bh = _rh ?? w.h;
                    _resizeLive((bw + dx).clamp(140.0, 900.0),
                        (bh + dy).clamp(80.0, 800.0), cx, cy);
                  },
                  onEnd: _resizeCommit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One resize handle. Deltas are canvas-space (absolute mapping), the card
/// previews transiently and commits once on release.
class _CardHandle extends StatefulWidget {
  const _CardHandle({
    required this.left,
    required this.top,
    required this.cursor,
    required this.onUpdate,
    required this.onEnd,
    required this.toCanvas,
  });

  final double left;
  final double top;
  final MouseCursor cursor;
  final void Function(double dx, double dy) onUpdate;
  final VoidCallback onEnd;
  final Offset Function(Offset global) toCanvas;

  @override
  State<_CardHandle> createState() => _CardHandleState();
}

class _CardHandleState extends State<_CardHandle> {
  Offset? _grab;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: MouseRegion(
        cursor: widget.cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _grab = widget.toCanvas(d.globalPosition),
          onPanEnd: (_) {
            _grab = null;
            widget.onEnd();
          },
          onPanUpdate: (d) {
            final grab = _grab;
            if (grab == null) return;
            final cur = widget.toCanvas(d.globalPosition);
            final delta = cur - grab;
            _grab = cur;
            widget.onUpdate(delta.dx, delta.dy);
          },
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: SocraTheme.ecoGreen, width: 2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBtn extends StatelessWidget {
  const _DeleteBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2), blurRadius: 6),
            ],
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

Map<String, dynamic> decodePayload(String s) {
  try {
    return jsonDecode(s) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}
