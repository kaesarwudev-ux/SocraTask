import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socra_task/core/widgets/app_shell.dart';
import 'package:socra_task/features/calendar/presentation/calendar_page.dart';
import 'package:socra_task/features/dashboard/presentation/dashboard_page.dart';
import 'package:socra_task/features/flashcards/presentation/deck_editor_page.dart';
import 'package:socra_task/features/flashcards/presentation/flashcards_page.dart';
import 'package:socra_task/features/flashcards/presentation/study_page.dart';
import 'package:socra_task/features/habits/presentation/habits_page.dart';
import 'package:socra_task/features/notes/presentation/notes_page.dart';
import 'package:socra_task/features/study_space/presentation/study_space_page.dart';
import 'package:socra_task/features/tasks/presentation/tasks_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study-space',
                builder: (context, state) => const StudySpacePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => TasksPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => NotesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => HabitsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/flashcards',
                builder: (context, state) => const FlashcardsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const DeckEditorPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => DeckEditorPage(deckId: int.parse(state.pathParameters['id']!)),
                    routes: [
                      GoRoute(
                        path: 'study',
                        builder: (context, state) => StudyPage(deckId: int.parse(state.pathParameters['id']!)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
