import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socra_task/core/data/database.dart';

/// Ink rendering (v2). Research applied:
/// - Excalidraw: static vs interactive layers separated; committed strokes
///   paint once, in-progress stroke paints on its own layer.
/// - Per-tool paint identity: pencil thin + translucent, brush wide +
///   pressure-variable, highlighter translucent wide square cap,
///   marker solid round.
/// - Quadratic-bezier smoothing so fast strokes are curves, not jaggies.

Paint paintForTool(String tool, Color color, double width, double opacity) {
  switch (tool) {
    case 'pencil':
      return Paint()
        ..color = color.withValues(alpha: opacity * 0.85)
        ..strokeWidth = width * 0.65
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
    case 'brush':
      return Paint()
        ..color = color.withValues(alpha: opacity * 0.92)
        ..strokeWidth = width * 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
    case 'highlighter':
      return Paint()
        ..color = color.withValues(alpha: 0.32)
        ..strokeWidth = width * 3.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.bevel
        ..isAntiAlias = true;
    default: // marker
      return Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
  }
}

Path smoothPath(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  if (pts.length < 3) {
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }
  for (var i = 1; i < pts.length - 1; i++) {
    final mid = Offset(
        (pts[i].dx + pts[i + 1].dx) / 2, (pts[i].dy + pts[i + 1].dy) / 2);
    path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
  }
  path.lineTo(pts.last.dx, pts.last.dy);
  return path;
}

Color parseHex(String hex, Color fallback) {
  try {
    return Color(int.parse(hex.replaceFirst('#', '0x')));
  } catch (_) {
    return fallback;
  }
}

String toHex(Color c) =>
    '#${c.value.toRadixString(16).padLeft(8, '0')}';

/// Committed strokes layer. Repaints ONLY when the stroke list identity
/// or the in-progress buffer changes (parent passes new lists).
class CommittedInk extends CustomPainter {
  CommittedInk(this.strokes);
  final List<BoardStroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      try {
        final raw = jsonDecode(s.pointsJson) as List;
        if (raw.length < 2) continue;
        final pts = raw
            .map((e) =>
                Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()))
            .toList();
        final pressures = raw
            .map((e) => e.length > 2 ? (e[2] as num).toDouble() : 1.0)
            .toList();
        if (s.tool == 'pencil' || s.tool == 'brush') {
          for (var i = 0; i < pts.length - 1; i++) {
            final w = s.width *
                (0.6 + 0.7 * pressures[i].clamp(0.2, 1.0)) *
                (s.tool == 'brush' ? 1.5 : 0.7);
            final paint =
                paintForTool(s.tool, parseHex(s.color, Colors.black), w, s.opacity);
            canvas.drawLine(pts[i], pts[i + 1], paint);
          }
        } else {
          final paint = paintForTool(
              s.tool, parseHex(s.color, Colors.black), s.width, s.opacity);
          canvas.drawPath(smoothPath(pts), paint);
        }
      } catch (_) {}
    }
  }

  @override
  bool shouldRepaint(covariant CommittedInk old) =>
      !identical(old.strokes, strokes);
}

/// In-progress stroke. Lives behind a ValueNotifier so pointer moves NEVER
/// rebuild the page — only this layer repaints (the old lag root cause).
class LiveInk extends CustomPainter {
  LiveInk(this.points, this.color, this.width, this.tool);
  final List<List<double>> points;
  final Color color;
  final double width;
  final String tool;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final pts = points.map((e) => Offset(e[0], e[1])).toList();
    final paint = paintForTool(tool, color, width, 1.0);
    canvas.drawPath(smoothPath(pts), paint);
  }

  @override
  bool shouldRepaint(covariant LiveInk old) =>
      !identical(old.points, points);
}
