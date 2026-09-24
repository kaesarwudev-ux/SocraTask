import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/features/calendar/presentation/bubble_placement.dart';

void main() {
  test('dodges above the block when it fits', () {
    // 1920x1080, block mid-grid, 560-tall bubble.
    final p = refineBubble(
      left: 640,
      top: 342,
      width: 640,
      height: 560,
      viewportHeight: 1080,
      avoid: const Rect.fromLTWH(570, 800, 330, 64),
    );
    expect(p.maxHeight, isNull);
    final rect = Rect.fromLTWH(640, p.top, 640, 560);
    expect(
        rect.overlaps(const Rect.fromLTWH(570, 800, 330, 64)), isFalse);
    expect(p.top + 560, lessThanOrEqualTo(1080 - 16));
  });

  test('caps height when the bubble fits nowhere whole', () {
    // The stuck case: tall bubble, block mid-screen, nothing fits whole.
    final p = refineBubble(
      left: 640,
      top: 342,
      width: 640,
      height: 560,
      viewportHeight: 1080,
      avoid: const Rect.fromLTWH(570, 590, 330, 64),
    );
    expect(p.maxHeight, isNotNull);
    final rect = Rect.fromLTWH(640, p.top, 640, p.maxHeight!);
    expect(
        rect.overlaps(const Rect.fromLTWH(570, 590, 330, 64)), isFalse);
    expect(p.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(1080 - 16));
  });

  test('no anchor leaves position clamped on-screen', () {
    final p = refineBubble(
      left: -50,
      top: 2000,
      width: 640,
      height: 400,
      viewportHeight: 600,
      avoid: null,
    );
    expect(p.maxHeight, isNull);
    expect(p.top, lessThanOrEqualTo(600 - 400 - 16));
  });

  test('tiny viewport with no room keeps overlap over clipping', () {
    final p = refineBubble(
      left: 80,
      top: 72,
      width: 640,
      height: 500,
      viewportHeight: 600,
      avoid: const Rect.fromLTWH(70, 300, 660, 64),
    );
    // above-space 220 vs below-space 220-ish: one side wins or it stays.
    final rect = Rect.fromLTWH(
        80, p.top, 640, p.maxHeight ?? 500);
    expect(rect.top, greaterThanOrEqualTo(0));
  });
}
