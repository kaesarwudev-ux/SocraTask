import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/theme/theme_mode_provider.dart';

/// Sun/moon switch for the app bar. Tooltip names the action so tests
/// and screen readers can find it.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final platform = MediaQuery.platformBrightnessOf(context);
    final effective =
        mode == ThemeMode.system ? platform : mode.toBrightness();
    final isDark = effective == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ref.read(themeModeProvider.notifier).state =
          isDark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

extension on ThemeMode {
  Brightness toBrightness() =>
      this == ThemeMode.dark ? Brightness.dark : Brightness.light;
}
