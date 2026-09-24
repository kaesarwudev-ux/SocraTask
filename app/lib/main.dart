import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/notifications/habit_notifications.dart';
import 'package:socra_task/core/router.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/core/theme/theme_mode_provider.dart';
import 'package:socra_task/features/habits/data/habit_providers.dart';

void main() {
  runApp(const ProviderScope(child: SocraTaskApp()));
}

/// One-shot bootstrap: arms habit reminder alarms from stored habits.
/// Runs once (cached future), safe on all platforms.
final _bootstrapProvider = FutureProvider((ref) async {
  await HabitNotifications.instance
      .rescheduleAll(ref.watch(habitRepositoryProvider));
});

class SocraTaskApp extends ConsumerWidget {
  const SocraTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    // ignore: unused_result
    ref.watch(_bootstrapProvider);
    return MaterialApp.router(
      title: 'SocraTask',
      debugShowCheckedModeBanner: false,
      theme: SocraTheme.light(),
      darkTheme: SocraTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
