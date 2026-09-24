import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pure bubble placement math (no widgets): given the measured height,
/// docks clear of [avoid] (usually the tapped block) and inside the
/// viewport, capping the height with internal scroll as a last resort.
class BubblePlacement {
  const BubblePlacement({required this.top, this.maxHeight});

  final double top;

  /// When set, the bubble must additionally constrain its content to
  /// this height (it scrolls inside).
  final double? maxHeight;
}

BubblePlacement refineBubble({
  required double left,
  required double top,
  required double width,
  required double height,
  required double viewportHeight,
  required Rect? avoid,
}) {
  var t = top;
  double? cap;
  if (avoid != null &&
      avoid.width > 1 &&
      Rect.fromLTWH(left, t, width, height).overlaps(avoid)) {
    final aboveSpace = avoid.top - 8 - 72;
    final belowSpace = viewportHeight - 16 - (avoid.bottom + 8);
    if (aboveSpace >= height) {
      t = avoid.top - height - 8;
    } else if (belowSpace >= height) {
      t = avoid.bottom + 8;
    } else if (aboveSpace >= belowSpace && aboveSpace >= 200) {
      cap = aboveSpace;
      t = 72;
    } else if (belowSpace >= 200) {
      cap = belowSpace;
      t = avoid.bottom + 8;
    }
    // else: genuinely no room anywhere — keep overlapping over clipping.
  }
  final h = cap ?? height;
  t = math.min(math.max(t, 8.0), math.max(8.0, viewportHeight - h - 16));
  return BubblePlacement(top: t, maxHeight: cap);
}
