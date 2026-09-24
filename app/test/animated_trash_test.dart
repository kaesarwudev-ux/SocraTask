import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socra_task/core/widgets/animated_trash.dart';

void main() {
  testWidgets('Hover swells red, opens the lid, tap fires',
      (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedTrashButton(
            tooltip: 'Delete thing',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Delete thing'), findsOneWidget);
    expect(find.byType(TrashBinIcon), findsOneWidget);

    // Hover with a mouse: red swell appears.
    final gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.moveTo(
        tester.getCenter(find.byType(AnimatedTrashButton)));
    await tester.pumpAndSettle();

    final swell = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(AnimatedTrashButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = swell.decoration! as BoxDecoration;
    expect(
      decoration.color,
      Theme.of(tester.element(find.byType(AnimatedTrashButton)))
          .colorScheme
          .error
          .withValues(alpha: 0.12),
    );

    await tester.tap(find.byType(AnimatedTrashButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
    await gesture.removePointer();
  });
}
