import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socra_task/core/data/database.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/flashcards/data/answer_scoring.dart';
import 'package:socra_task/features/flashcards/data/flashcard_repository.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

final _flashRepoProvider = Provider<FlashcardRepository>((ref) => FlashcardRepository(ref.watch(databaseProvider)));

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({required this.deckId, super.key});
  final int deckId;
  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> with SingleTickerProviderStateMixin {
  List<FlashCard> _cards = [];
  int _idx = 0;
  bool _flipped = false;
  int _correct = 0;
  int _wrong = 0;
  late final AnimationController _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _flip = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeOutCubic);

  // per-card controllers & state — super familiar, one field per type
  final Map<int, TextEditingController> _typed = {};
  final Map<int, int?> _choicePick = {};
  final Map<int, AnswerScore> _graded = {};
  final Map<int, bool?> _overridden = {}; // null = auto, true/false = manual override

  String _search = '';
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(_flashRepoProvider);
    final c = await repo.fetchCards(widget.deckId);
    setState(() => _cards = c);
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    for (final c in _typed.values) c.dispose();
    super.dispose();
  }

  List<String> _opts(FlashCard c) {
    try {
      final d = jsonDecode(c.options);
      if (d is List) return d.map((e) => e.toString()).toList();
    } catch (_) {}
    return [];
  }

  List<String> _highlights(FlashCard c) {
    try {
      final d = jsonDecode(c.highlights);
      if (d is List) return d.map((e) => e.toString()).toList();
    } catch (_) {}
    return [];
  }

  String _clozeText(FlashCard c) {
    var t = c.definition;
    for (final h in _highlights(c)) {
      t = t.replaceAll(h, '____');
    }
    return t.isEmpty ? c.definition : t;
  }

  void _toggleFlip() {
    if (_currentType() != 'basic') return;
    setState(() => _flipped = !_flipped);
    if (_flipped) _flipCtrl.forward(); else _flipCtrl.reverse();
  }

  String _currentType() => _cards.isEmpty ? 'basic' : _cards[_idx].type;

  void _grade(bool correct) {
    if (_cards.isEmpty) return;
    final actual = _overridden[_idx] ?? correct;
    setState(() {
      if (actual) _correct++; else _wrong++;
      _flipped = false;
      _flipCtrl.value = 0;
      _showAnswer = false;
      _graded.remove(_idx);
      _overridden.remove(_idx);
      if (_idx < _filtered().length - 1) {
        _idx++;
      } else {
        _showDone();
      }
    });
  }

  void _submitTyped() {
    final c = _filtered()[_idx];
    final exp = _highlights(c).isNotEmpty ? _highlights(c).join(' ') : c.definition;
    final user = _typed[_idx]?.text ?? '';
    final sc = gradeFreeAnswer(user, exp);
    setState(() {
      _graded[_idx] = sc;
      _showAnswer = true;
    });
  }

  void _submitChoice() {
    final c = _filtered()[_idx];
    final pick = _choicePick[_idx];
    if (pick == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick an answer first')));
      return;
    }
    final correct = pick == c.answerIndex;
    final sc = AnswerScore(score: correct ? 1 : 0, label: correct ? 'correct' : 'wrong', details: correct ? 'Nice!' : 'Expected ${(_opts(c).length > c.answerIndex && c.answerIndex >= 0) ? _opts(c)[c.answerIndex] : c.definition}');
    setState(() {
      _graded[_idx] = sc;
      _showAnswer = true;
    });
  }

  void _showDone() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Set complete! 🎉'),
      content: Text('Correct: $_correct  •  Wrong: $_wrong\nYou can override any free-answer before grading — super friendly!'),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Review')), FilledButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text('Done'))],
    ));
  }

  List<FlashCard> _filtered() {
    if (_search.trim().isEmpty) return _cards;
    final q = _search.toLowerCase();
    return _cards.where((c) => c.term.toLowerCase().contains(q) || c.definition.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_cards.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Study')), body: const Center(child: Text('No cards yet. Add some first.')));
    }
    final filtered = _filtered();
    if (filtered.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.search_off, size: 48),
          const SizedBox(height: 12),
          Text('No matches for "$_search"', style: Theme.of(context).textTheme.titleSmall),
          TextButton(onPressed: () => setState(() => _search = ''), child: const Text('Clear search')),
        ])),
      );
    }
    final card = filtered[_idx.clamp(0, filtered.length - 1)];
    // map filtered idx to original _idx for controllers
    final realIdx = _cards.indexOf(card);
    // ensure controller exists
    _typed.putIfAbsent(realIdx, () => TextEditingController());
    final progress = (realIdx + 1) / _cards.length;
    final type = card.type;
    final graded = _graded[realIdx];
    final overridden = _overridden[realIdx];
    final effectiveCorrect = overridden ?? (graded?.isCorrect ?? false);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text('Study  ${realIdx + 1} / ${_cards.length} • ${card.type.toUpperCase()}'),
        backgroundColor: scheme.surface,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: LinearProgressIndicator(value: progress, backgroundColor: scheme.surfaceContainerHighest, color: SocraTheme.ecoGreen)),
        actions: [
          IconButton(tooltip: 'Search cards', icon: const Icon(Icons.search), onPressed: () async {
            final q = await showDialog<String>(context: context, builder: (c) {
              final ctrl = TextEditingController(text: _search);
              return AlertDialog(title: const Text('Search cards'), content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Type to filter…')), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, ctrl.text), child: const Text('Search'))]);
            });
            if (q != null) setState(() => _search = q);
          }),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space && type == 'basic') { _toggleFlip(); return KeyEventResult.handled; }
            if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              if (graded != null) _grade(true);
              else if (type == 'basic' && _flipped) _grade(true);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              if (graded != null) _grade(false);
              else if (type == 'basic' && _flipped) _grade(false);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter && (type == 'free' || type == 'cloze')) {
              if (graded == null) _submitTyped();
              else _grade(effectiveCorrect);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // Friendly type badge + hint
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: SocraTheme.ecoGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(type.toUpperCase(), style: const TextStyle(color: SocraTheme.ecoGreen, fontWeight: FontWeight.w700, fontSize: 11))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_hintFor(type, _flipped), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
                    ]),
                    const SizedBox(height: 16),
                    // Card renderer per type — super familiar like Gizmo + Quizlet
                    if (type == 'basic')
                      GestureDetector(
                        onTap: _toggleFlip,
                        child: AnimatedBuilder(
                          animation: _flip,
                          builder: (context, child) {
                            final isBack = _flip.value > 0.5;
                            final angle = _flip.value * math.pi;
                            final displayTerm = !isBack;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..setEntry(3, 2, 0.0015)..rotateY(angle),
                              child: Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(isBack ? math.pi : 0), child: _CardFace(text: displayTerm ? card.term : card.definition, hint: displayTerm ? 'Tap or Space to flip' : 'Definition', color: displayTerm ? scheme.surfaceContainerLow : SocraTheme.ecoGreen.withValues(alpha: 0.12))),
                            );
                          },
                        ),
                      )
                    else if (type == 'cloze')
                      _ClozeCard(card: card, controller: _typed[realIdx]!, graded: graded, clozeText: _clozeText(card), onSubmit: _submitTyped)
                    else if (type == 'free')
                      _FreeCard(card: card, controller: _typed[realIdx]!, graded: graded, onSubmit: _submitTyped)
                    else if (type == 'choice')
                      _ChoiceCard(card: card, options: _opts(card), picked: _choicePick[realIdx], graded: graded, onPick: (i) => setState(() => _choicePick[realIdx] = i), onSubmit: _submitChoice)
                    else if (type == 'tf')
                      _ChoiceCard(card: card, options: const ['True', 'False'], picked: _choicePick[realIdx], graded: graded, onPick: (i) => setState(() => _choicePick[realIdx] = i), onSubmit: _submitChoice)
                    ,
                    if (graded != null) ...[
                      const SizedBox(height: 16),
                      _ResultBanner(score: graded, overridden: overridden, onOverride: (v) => setState(() => _overridden[realIdx] = v)),
                    ],
                    const SizedBox(height: 12),
                    // Socra green highlights preview for cloze like Gizmo green words
                    if (type == 'cloze' && _highlights(card).isNotEmpty)
                      Wrap(spacing: 6, children: _highlights(card).map((h) => Chip(label: Text(h, style: const TextStyle(fontSize: 12)), backgroundColor: SocraTheme.ecoGreen.withValues(alpha: 0.14))).toList()),
                  ]),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              AnimatedSwitcher(duration: const Duration(milliseconds: 280), child: Row(key: ValueKey('${type}_$graded'), mainAxisAlignment: MainAxisAlignment.center, children: _controlsFor(type, graded, _flipped, scheme))),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                if (type == 'basic') {
                  return Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _grade(false), icon: const Icon(Icons.close, size: 18), label: const Text('Got wrong'), style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(onPressed: () => _grade(true), icon: const Icon(Icons.check, size: 18), label: const Text('Got correct'), style: FilledButton.styleFrom(backgroundColor: SocraTheme.ecoGreen))),
                  ]);
                }
                if (graded == null) {
                  return SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: type == 'choice' || type == 'tf' ? _submitChoice : _submitTyped, icon: const Icon(Icons.send, size: 18), label: Text(type == 'choice' || type == 'tf' ? 'Check answer' : 'Submit')));
                }
                return Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => _grade(false), icon: const Icon(Icons.close, size: 18), label: const Text('I was wrong'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton.icon(onPressed: () => _grade(true), icon: const Icon(Icons.check, size: 18), label: const Text('I was right'), style: FilledButton.styleFrom(backgroundColor: SocraTheme.ecoGreen))),
                ]);
              }),
              const SizedBox(height: 8),
              Text('Space flip • → correct/next • ← wrong • Enter submit  •  You can override any free-answer', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
    );
  }

  String _hintFor(String type, bool flipped) {
    switch (type) {
      case 'basic': return flipped ? 'Definition shown — grade yourself' : 'Flip to reveal';
      case 'cloze': return 'Fill the blank — green words are hidden';
      case 'free': return 'Type your answer — fuzzy match + manual override';
      case 'choice': return 'Pick the right option';
      case 'tf': return 'True or False?';
      default: return '';
    }
  }

  List<Widget> _controlsFor(String type, AnswerScore? graded, bool flipped, ColorScheme scheme) {
    if (graded != null) {
      return [_HintChip(icon: Icons.psychology, label: graded.label.toUpperCase(), color: graded.isCorrect ? SocraTheme.ecoGreen : graded.isClose ? Colors.orange : Colors.redAccent)];
    }
    if (type == 'basic') {
      return flipped ? [_HintChip(icon: Icons.arrow_back, label: '← Wrong', color: Colors.redAccent), const SizedBox(width: 16), _HintChip(icon: Icons.arrow_forward, label: 'Correct →', color: SocraTheme.ecoGreen)] : [_HintChip(icon: Icons.space_bar, label: 'Space to flip', color: scheme.onSurfaceVariant)];
    }
    if (type == 'free' || type == 'cloze') return [_HintChip(icon: Icons.keyboard, label: 'Type + Enter', color: scheme.onSurfaceVariant)];
    return [_HintChip(icon: Icons.touch_app, label: 'Tap an option', color: scheme.onSurfaceVariant)];
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.text, required this.hint, required this.color});
  final String text;
  final String hint;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 640,
      height: 360,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))], border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: Text(text, key: ValueKey(text), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
        const SizedBox(height: 16),
        Text(hint, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _ClozeCard extends StatelessWidget {
  const _ClozeCard({required this.card, required this.controller, required this.graded, required this.clozeText, required this.onSubmit});
  final FlashCard card;
  final TextEditingController controller;
  final AnswerScore? graded;
  final String clozeText;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(card.term, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: SocraTheme.ecoGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), child: Text(clozeText, style: Theme.of(context).textTheme.bodyLarge)),
        const SizedBox(height: 16),
        TextField(controller: controller, decoration: InputDecoration(hintText: 'Type the missing word(s)…', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onSubmitted: (_) => onSubmit()),
        if (graded != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(graded!.details, style: TextStyle(color: graded!.isCorrect ? SocraTheme.ecoGreen : graded!.isClose ? Colors.orange : Colors.redAccent, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _FreeCard extends StatelessWidget {
  const _FreeCard({required this.card, required this.controller, required this.graded, required this.onSubmit});
  final FlashCard card;
  final TextEditingController controller;
  final AnswerScore? graded;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(card.term, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Free answer — huge fuzzy check (typos, plurals, diacritics ok) + you can override', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        TextField(controller: controller, maxLines: 3, decoration: InputDecoration(hintText: 'Type your answer…', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onSubmitted: (_) => onSubmit()),
        if (graded != null) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: graded!.isCorrect ? SocraTheme.ecoGreen.withValues(alpha: 0.12) : graded!.isClose ? Colors.orange.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(graded!.label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, color: graded!.isCorrect ? SocraTheme.ecoGreen : graded!.isClose ? Colors.orange : Colors.redAccent)),
            Text(graded!.details),
            Text('Expected: ${card.definition}', style: Theme.of(context).textTheme.bodySmall),
          ])),
        ],
      ]),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.card, required this.options, required this.picked, required this.graded, required this.onPick, required this.onSubmit});
  final FlashCard card;
  final List<String> options;
  final int? picked;
  final AnswerScore? graded;
  final ValueChanged<int> onPick;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(card.term, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: graded == null ? () => onPick(i) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: graded != null && i == card.answerIndex ? SocraTheme.ecoGreen.withValues(alpha: 0.14) : picked == i ? scheme.tertiaryContainer : scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: graded != null && i == card.answerIndex ? SocraTheme.ecoGreen : picked == i ? scheme.tertiary : scheme.outlineVariant),
                ),
                child: Row(children: [
                  Icon(picked == i ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: graded != null && i == card.answerIndex ? SocraTheme.ecoGreen : null),
                  const SizedBox(width: 12),
                  Expanded(child: Text(options[i])),
                  if (graded != null && i == card.answerIndex) const Icon(Icons.check, size: 18, color: SocraTheme.ecoGreen),
                ]),
              ),
            ),
          ),
        if (graded != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(graded!.details, style: TextStyle(color: graded!.isCorrect ? SocraTheme.ecoGreen : Colors.redAccent, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.score, required this.overridden, required this.onOverride});
  final AnswerScore score;
  final bool? overridden;
  final ValueChanged<bool> onOverride;
  @override
  Widget build(BuildContext context) {
    final isOverridden = overridden != null;
    final effective = overridden ?? score.isCorrect;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: effective ? SocraTheme.ecoGreen.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: effective ? SocraTheme.ecoGreen : Colors.redAccent)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(effective ? Icons.check_circle : Icons.error_outline, color: effective ? SocraTheme.ecoGreen : Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Text(isOverridden ? (effective ? 'Overridden → Correct' : 'Overridden → Wrong') : score.label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, color: effective ? SocraTheme.ecoGreen : Colors.redAccent)),
          const Spacer(),
          Text('${(score.score * 100).round()}%'),
        ]),
        const SizedBox(height: 4),
        Text(score.details, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        // Manual override — super friendly and familiar
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => onOverride(false), icon: const Icon(Icons.close, size: 16), label: const Text('Mark wrong'), style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton.icon(onPressed: () => onOverride(true), icon: const Icon(Icons.check, size: 16), label: const Text('Mark correct'), style: FilledButton.styleFrom(backgroundColor: SocraTheme.ecoGreen))),
        ]),
        Text('You decide — algorithm is just a helper. Tap to override.', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12))]),
    );
  }
}
