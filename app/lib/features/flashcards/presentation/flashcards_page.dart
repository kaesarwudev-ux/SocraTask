import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/core/widgets/socra_app_bar.dart';
import 'package:socra_task/features/flashcards/data/flashcard_repository.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

final _flashRepoProvider = Provider<FlashcardRepository>((ref) => FlashcardRepository(ref.watch(databaseProvider)));

final _decksProvider = StreamProvider<List<FlashDeck>>((ref) => ref.watch(_flashRepoProvider).watchDecks());

class FlashcardsPage extends ConsumerWidget {
  const FlashcardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(_decksProvider);
    return Scaffold(
      appBar: const SocraAppBar(title: 'Flashcards'),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'flash-create',
        onPressed: () => context.push('/flashcards/new'),
        icon: const Icon(Icons.add),
        label: const Text('Create set'),
      ),
      body: decks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const _Empty();
          return LayoutBuilder(builder: (context, c) {
            final cross = c.maxWidth > 900 ? 3 : c.maxWidth > 600 ? 2 : 1;
            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                childAspectRatio: 1.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final d = items[i];
                return _DeckCard(deck: d, index: i);
              },
            );
          });
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.style_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(height: 16),
        Text('No flashcard sets yet', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Create one or import from Word, Excel, or Google Docs.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => GoRouter.of(context).go('/flashcards/new'),
          icon: const Icon(Icons.add),
          label: const Text('Create set'),
        ),
      ]),
    );
  }
}

class _DeckCard extends ConsumerWidget {
  const _DeckCard({required this.deck, required this.index});
  final FlashDeck deck;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(_flashRepoProvider);
    final cardsAsync = ref.watch(_cardsProvider(deck.id));
    final scheme = Theme.of(context).colorScheme;
    final count = cardsAsync.valueOrNull?.length ?? 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.scale(scale: 0.92 + 0.08 * t, child: child)),
      child: Material(
        elevation: 1,
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/flashcards/${deck.id}'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: SocraTheme.ecoGreen.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
                  child: Text('$count cards', style: TextStyle(color: SocraTheme.ecoGreen, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
                const Spacer(),
                PopupMenuButton<String>(onSelected: (v) async {
                  if (v == 'delete') {
                    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete set?'), content: Text('Delete "${deck.title}"?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
                    if (ok == true) await repo.deleteDeck(deck.id);
                  } else if (v == 'study' && count > 0) {
                    context.push('/flashcards/${deck.id}/study');
                  }
                }, itemBuilder: (c) => [
                  if (count > 0) const PopupMenuItem(value: 'study', child: Text('Study')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ]),
              ]),
              const SizedBox(height: 12),
              Text(deck.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              if (deck.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(deck.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
              ],
              const Spacer(),
              Row(children: [
                FilledButton.tonalIcon(onPressed: () => context.push('/flashcards/${deck.id}'), icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Edit')),
                const SizedBox(width: 8),
                if (count > 0) FilledButton.icon(onPressed: () => context.push('/flashcards/${deck.id}/study'), icon: const Icon(Icons.play_arrow, size: 18), label: const Text('Study')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

final _cardsProvider = StreamProvider.family<List<FlashCard>, int>((ref, deckId) => ref.watch(_flashRepoProvider).watchCards(deckId));
