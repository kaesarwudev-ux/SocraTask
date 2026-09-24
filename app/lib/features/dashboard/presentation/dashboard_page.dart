import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/widgets/socra_app_bar.dart';
import 'package:socra_task/core/widgets/theme_toggle.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

/// Dashboard per `prompt.md` §3.1: stat widgets first, then the
/// empty-state CTA. Never blank.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider);
    final open =
        tasks.valueOrNull?.where((t) => !t.done).length ?? 0;
    final done =
        tasks.valueOrNull?.where((t) => t.done).length ?? 0;
    return Scaffold(
      appBar: const SocraAppBar(
        title: 'Dashboard',
        actions: [ThemeToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$open open',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text('tasks to do'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$done done',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Text('tasks completed'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Icon(Icons.dashboard_outlined, size: 64),
          const SizedBox(height: 16),
          const Center(child: Text('Your day at a glance')),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: () {},
              child: const Text('Add first task'),
            ),
          ),
        ],
      ),
    );
  }
}
