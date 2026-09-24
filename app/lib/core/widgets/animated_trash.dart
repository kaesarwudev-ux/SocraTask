import 'package:flutter/material.dart';

/// SocraTask's trash can, used for every delete/trash action app-wide:
/// straight walls, rounded base, and a detached lid hinged at the left
/// that kicks upward on hover while the icon warms to the active color.
class TrashBinIcon extends StatelessWidget {
  const TrashBinIcon({
    required this.hovered,
    required this.base,
    required this.active,
    super.key,
  });

  final bool hovered;
  final Color base;
  final Color active;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 180);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: hovered ? 1.0 : 0.0),
      duration: duration,
      builder: (context, t, _) {
        return CustomPaint(
          size: const Size(24, 24),
          painter: _TrashPainter(
            // Lid kicks upward around the left hinge.
            lidAngle: -0.5 * t,
            color: Color.lerp(base, active, t)!,
          ),
        );
      },
    );
  }
}

class _TrashPainter extends CustomPainter {
  _TrashPainter({required this.lidAngle, required this.color});

  final double lidAngle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body: straight vertical walls, same width top and bottom. Each
    // stroke ends in a round cap overlapping the next, so the joints
    // merge with no gaps; the caps double as rounded bottom corners.
    const wallBottom = 19.4;
    canvas.drawLine(
        Offset(8.2 * s, 10.2 * s), Offset(8.2 * s, wallBottom * s), stroke);
    canvas.drawLine(
        Offset(15.8 * s, 10.2 * s), Offset(15.8 * s, wallBottom * s), stroke);
    canvas.drawLine(
        Offset(8.2 * s, wallBottom * s),
        Offset(15.8 * s, wallBottom * s),
        stroke);

    // Detached lid: barely wider than the bin top, hinged at its left
    // end. Kicks upward on hover.
    canvas.save();
    canvas.translate(6 * s, 7.2 * s);
    canvas.rotate(lidAngle);
    canvas.translate(-6 * s, -7.2 * s);
    // Lid bar with only a slight overhang.
    canvas.drawLine(Offset(6 * s, 7.2 * s), Offset(18 * s, 7.2 * s), stroke);
    // Handle bump centered on the lid.
    canvas.drawLine(
        Offset(10.2 * s, 7.2 * s), Offset(10.2 * s, 4.8 * s), stroke);
    canvas.drawLine(
        Offset(10.2 * s, 4.8 * s), Offset(13.8 * s, 4.8 * s), stroke);
    canvas.drawLine(
        Offset(13.8 * s, 4.8 * s), Offset(13.8 * s, 7.2 * s), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrashPainter old) =>
      old.lidAngle != lidAngle || old.color != color;
}

/// Self-contained delete button: red swell + lid-flip trash icon on hover,
/// tooltip above, tap callback. Manages its own hover state.
class AnimatedTrashButton extends StatefulWidget {
  const AnimatedTrashButton({
    required this.tooltip,
    required this.onTap,
    super.key,
  });

  final String tooltip;
  final VoidCallback? onTap;

  @override
  State<AnimatedTrashButton> createState() =>
      _AnimatedTrashButtonState();
}

class _AnimatedTrashButtonState extends State<AnimatedTrashButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered
                ? scheme.error.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: TrashBinIcon(
              hovered: _hovered,
              base: scheme.onSurfaceVariant,
              active: scheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
