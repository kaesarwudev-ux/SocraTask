import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/flashcards/data/flashcard_repository.dart';
import 'package:socra_task/features/flashcards/presentation/import_dialog.dart';
import 'package:socra_task/features/tasks/data/task_providers.dart';

final _flashRepoProvider = Provider<FlashcardRepository>((ref) => FlashcardRepository(ref.watch(databaseProvider)));

class DeckEditorPage extends ConsumerStatefulWidget {
  const DeckEditorPage({this.deckId, super.key});
  final int? deckId;
  @override
  ConsumerState<DeckEditorPage> createState() => _DeckEditorPageState();
}

class _CardDraft {
  _CardDraft({this.id, required this.term, required this.def, this.imageTerm, this.imageDef, this.type = 'basic', this.highlights = '[]', this.options = '[]', this.answerIndex = -1});
  int? id;
  String term;
  String def;
  String? imageTerm;
  String? imageDef;
  String type; // basic|cloze|free|choice|tf
  String highlights; // JSON
  String options; // JSON
  int answerIndex;
  final termCtrl = TextEditingController();
  final defCtrl = TextEditingController();
  // for choice/TF
  List<TextEditingController> optionCtrls = List.generate(4, (_) => TextEditingController());
  void attach() {
    termCtrl.text = term;
    defCtrl.text = def;
    // hydrate options
    try {
      final o = _decodeList(options);
      for (var i = 0; i < 4; i++) {
        optionCtrls[i].text = i < o.length ? o[i] : (i == 0 ? 'Option 1' : i == 1 ? 'Option 2' : i == 2 ? 'Option 3' : 'Option 4');
      }
    } catch (_) {}
  }
  void disposeCtrls() {
    termCtrl.dispose();
    defCtrl.dispose();
    for (final c in optionCtrls) c.dispose();
  }
  static List<String> _decodeList(String s) {
    if (s.isEmpty || s == '[]') return [];
    try {
      final inner = s.substring(1, s.length - 1);
      if (inner.trim().isEmpty) return [];
      return inner.split(',').map((e) => e.trim().replaceAll(RegExp(r'^"|"$'), '')).toList();
    } catch (_) {
      return [];
    }
  }
}

class _DeckEditorPageState extends ConsumerState<DeckEditorPage> with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<_CardDraft> _cards = [];
  bool _loading = true;
  int? _expandedIndex;
  String? _expandedSide; // 'term' or 'def'
  final Map<int, TextEditingController> _searchCtrls = {};

  // Auto-save + shake + banner countdown
  Timer? _autosaveTimer;
  bool _isAutosaving = false;
  bool _hasUnsaved = false;
  DateTime? _lastSaved;
  int? _effectiveDeckId;
  bool _bannerVisible = false;
  int _bannerSeconds = 5;
  Timer? _bannerTimer;
  late final AnimationController _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _shakeAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 10, end: -6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _effectiveDeckId = widget.deckId;
    _titleCtrl.addListener(_markDirty);
    _descCtrl.addListener(_markDirty);
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(_flashRepoProvider);
    if (widget.deckId != null) {
      final decks = await repo.fetchDecks();
      final deck = decks.where((d) => d.id == widget.deckId).firstOrNull;
      if (deck != null) {
        _titleCtrl.text = deck.title;
        _descCtrl.text = deck.description;
      }
      final cards = await repo.fetchCards(widget.deckId!);
      for (final c in cards) {
        final d = _CardDraft(
          id: c.id,
          term: c.term,
          def: c.definition,
          imageTerm: c.imageTerm,
          imageDef: c.imageDef,
          type: c.type,
          highlights: c.highlights,
          options: c.options,
          answerIndex: c.answerIndex,
        )..attach();
        _attachCardListeners(d);
        _cards.add(d);
      }
    }
    if (_cards.isEmpty) {
      for (var i = 0; i < 2; i++) {
        final d = _CardDraft(term: '', def: '')..attach();
        _attachCardListeners(d);
        _cards.add(d);
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _bannerTimer?.cancel();
    _shakeCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _cards) {
      c.disposeCtrls();
    }
    for (final c in _searchCtrls.values) c.dispose();
    super.dispose();
  }

  void _showBanner() {
    _bannerTimer?.cancel();
    setState(() {
      _bannerVisible = true;
      _bannerSeconds = 6;
    });
    _bannerTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _bannerSeconds -= 1);
      if (_bannerSeconds <= 0) {
        t.cancel();
        setState(() => _bannerVisible = false);
      }
    });
  }

  void _hideBanner() {
    _bannerTimer?.cancel();
    setState(() => _bannerVisible = false);
  }

  void _markDirty() {
    if (_loading) return;
    setState(() => _hasUnsaved = true);
    _showBanner();
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 900), _performAutosave);
  }

  Future<void> _performAutosave() async {
    if (!_hasUnsaved || _isAutosaving) return;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return; // need title to create
    setState(() => _isAutosaving = true);
    try {
      final repo = ref.read(_flashRepoProvider);
      int deckId = _effectiveDeckId ?? await repo.createDeck(title: title, description: _descCtrl.text.trim());
      if (_effectiveDeckId == null) {
        _effectiveDeckId = deckId;
      } else {
        await repo.updateDeck(deckId, title: title, description: _descCtrl.text.trim());
        final existing = await repo.fetchCards(deckId);
        final keepIds = _cards.where((c) => c.id != null).map((c) => c.id!).toSet();
        for (final e in existing) {
          if (!keepIds.contains(e.id)) await repo.deleteCard(e.id);
        }
      }
      final orderedIds = <int>[];
      for (var i = 0; i < _cards.length; i++) {
        final c = _cards[i];
        // attach listeners if not yet
        c.termCtrl.removeListener(_markDirty);
        c.defCtrl.removeListener(_markDirty);
        c.termCtrl.addListener(_markDirty);
        c.defCtrl.addListener(_markDirty);
        for (final o in c.optionCtrls) {
          o.removeListener(_markDirty);
          o.addListener(_markDirty);
        }
        final term = c.termCtrl.text.trim();
        final def = c.defCtrl.text.trim();
        if (term.isEmpty && def.isEmpty && c.type == 'basic') continue;
        String opts = '[]';
        if (c.type == 'choice') {
          final list = c.optionCtrls.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
          opts = jsonEncode(list.isEmpty ? ['Option 1', 'Option 2'] : list);
        } else if (c.type == 'tf') {
          opts = jsonEncode(['True', 'False']);
        }
        if (c.id != null) {
          await repo.updateCard(c.id!,
              term: term.isEmpty ? c.term : term,
              def: def.isEmpty ? c.def : def,
              imageTerm: c.imageTerm,
              imageDef: c.imageDef,
              type: c.type,
              highlights: c.highlights,
              options: opts,
              answerIndex: c.answerIndex);
          orderedIds.add(c.id!);
        } else {
          final nid = await repo.createCard(deckId,
              term: term.isEmpty ? '(empty)' : term, def: def, position: i, type: c.type, highlights: c.highlights, options: opts, answerIndex: c.answerIndex);
          if (c.imageTerm != null || c.imageDef != null) await repo.updateCard(nid, imageTerm: c.imageTerm, imageDef: c.imageDef);
          c.id = nid;
          orderedIds.add(nid);
        }
      }
      await repo.reorderCards(deckId, orderedIds);
      setState(() {
        _hasUnsaved = false;
        _isAutosaving = false;
        _lastSaved = DateTime.now();
      });
    } catch (_) {
      setState(() => _isAutosaving = false);
    }
  }

  void _shake() {
    _shakeCtrl.forward(from: 0);
    if (_hasUnsaved) _showBanner();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      content: Row(children: [
        Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
        const SizedBox(width: 12),
        Expanded(child: Text('You have unsaved changes — saving now…', style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer))),
      ]),
      action: SnackBarAction(label: 'Save now', onPressed: _performAutosave),
      duration: const Duration(seconds: 3),
      showCloseIcon: true,
    ));
  }

  void _toggleImagePanel(int index, String side) {
    setState(() {
      if (_expandedIndex == index && _expandedSide == side) {
        _expandedIndex = null;
        _expandedSide = null;
      } else {
        _expandedIndex = index;
        _expandedSide = side;
        _searchCtrls.putIfAbsent(index, () => TextEditingController());
      }
    });
  }

  Future<void> _pickImage(int index, String side) async {
    final picked = await FilePicker.pickFiles(type: FileType.image);
    if (picked.isEmpty) return;
    final name = picked.single.name;
    setState(() {
      if (side == 'term') {
        _cards[index].imageTerm = name;
      } else {
        _cards[index].imageDef = name;
      }
    });
    _markDirty();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attached $name')));
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a title')));
      return;
    }
    final repo = ref.read(_flashRepoProvider);
    int deckId = widget.deckId ?? await repo.createDeck(title: title, description: _descCtrl.text.trim());
    if (widget.deckId != null) {
      await repo.updateDeck(deckId, title: title, description: _descCtrl.text.trim());
      // For edit, naive: delete missing cards and recreate? Simpler: delete all and recreate, keep ids for existing.
      final existing = await repo.fetchCards(deckId);
      final keepIds = _cards.where((c) => c.id != null).map((c) => c.id!).toSet();
      for (final e in existing) {
        if (!keepIds.contains(e.id)) await repo.deleteCard(e.id);
      }
    }
    // Upsert cards in order
    final orderedIds = <int>[];
    for (var i = 0; i < _cards.length; i++) {
      final c = _cards[i];
      final term = c.termCtrl.text.trim();
      final def = c.defCtrl.text.trim();
      if (term.isEmpty && def.isEmpty && c.type == 'basic') continue;
      // encode options
      String opts = '[]';
      if (c.type == 'choice') {
        final list = c.optionCtrls.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
        opts = jsonEncode(list.isEmpty ? ['Option 1', 'Option 2'] : list);
      } else if (c.type == 'tf') {
        opts = jsonEncode(['True', 'False']);
      }
      if (c.id != null) {
        await repo.updateCard(c.id!,
            term: term.isEmpty ? c.term : term,
            def: def.isEmpty ? c.def : def,
            imageTerm: c.imageTerm,
            imageDef: c.imageDef,
            type: c.type,
            highlights: c.highlights,
            options: opts,
            answerIndex: c.answerIndex);
        orderedIds.add(c.id!);
      } else {
        final nid = await repo.createCard(deckId,
            term: term.isEmpty ? '(empty)' : term,
            def: def,
            position: i,
            type: c.type,
            highlights: c.highlights,
            options: opts,
            answerIndex: c.answerIndex);
        if (c.imageTerm != null || c.imageDef != null) {
          await repo.updateCard(nid, imageTerm: c.imageTerm, imageDef: c.imageDef);
        }
        c.id = nid;
        orderedIds.add(nid);
      }
    }
    await repo.reorderCards(deckId, orderedIds);
    if (mounted) context.go('/flashcards');
  }

  Future<void> _import() async {
    final res = await showDialog<List<({String term, String def})>>(context: context, builder: (_) => const ImportDialog());
    if (res == null || res.isEmpty) return;
    setState(() {
      for (final r in res) {
        final d = _CardDraft(term: r.term, def: r.def)..attach();
        // also set controllers
        d.termCtrl.text = r.term;
        d.defCtrl.text = r.def;
        _attachCardListeners(d);
        _cards.add(d);
      }
    });
    _markDirty();
  }

  void _attachCardListeners(_CardDraft c) {
    c.termCtrl.addListener(_markDirty);
    c.defCtrl.addListener(_markDirty);
    for (final o in c.optionCtrls) o.addListener(_markDirty);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final saveLabel = _isAutosaving
        ? 'Saving…'
        : _hasUnsaved
            ? 'Unsaved'
            : _lastSaved != null
                ? 'Saved • ${_lastSaved!.hour.toString().padLeft(2, '0')}:${_lastSaved!.minute.toString().padLeft(2, '0')}'
                : 'Saved';
    return PopScope(
      canPop: !_hasUnsaved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _hasUnsaved) {
          _shake();
          _performAutosave();
        }
      },
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) => Transform.translate(offset: Offset(_shakeAnim.value, 0), child: child),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.deckId == null && _effectiveDeckId == null ? 'Create a new flashcard set' : 'Edit flashcard set'),
            backgroundColor: scheme.surface,
            actions: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _hasUnsaved ? scheme.errorContainer : SocraTheme.ecoGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (_isAutosaving) SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onSurfaceVariant)) else Icon(_hasUnsaved ? Icons.circle_outlined : Icons.check_circle, size: 14, color: _hasUnsaved ? scheme.onErrorContainer : SocraTheme.ecoGreen),
                    const SizedBox(width: 6),
                    Text(saveLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _hasUnsaved ? scheme.onErrorContainer : SocraTheme.ecoGreen)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Padding(padding: const EdgeInsets.only(right: 12), child: FilledButton(onPressed: _hasUnsaved ? () { _shake(); _performAutosave(); } : _save, child: Text(_effectiveDeckId == null ? 'Create' : 'Save'))),
            ],
          ),
          body: Stack(
            children: [
              ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 88), children: [
        // Title / Description
        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(hintText: 'Title', filled: true, fillColor: scheme.surfaceContainerLow, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          decoration: InputDecoration(hintText: 'Add a description...', filled: true, fillColor: scheme.surfaceContainerLow, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 16),
        // Toolbar
        Row(children: [
          FilledButton.tonalIcon(onPressed: _import, icon: const Icon(Icons.upload_outlined, size: 18), label: const Text('Import')),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.image_outlined, size: 18), label: const Text('Add diagram')),
          const Spacer(),
          const Icon(Icons.lightbulb_outline, size: 18),
          const SizedBox(width: 6),
          const Text('Suggestions'),
          const SizedBox(width: 8),
          Switch(value: true, onChanged: (_) {}),
        ]),
        const SizedBox(height: 20),
        // Cards
        for (var i = 0; i < _cards.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CardRow(
              index: i,
              draft: _cards[i],
              isTermExpanded: _expandedIndex == i && _expandedSide == 'term',
              isDefExpanded: _expandedIndex == i && _expandedSide == 'def',
              searchCtrl: _searchCtrls[i],
              onTermImageTap: () => _toggleImagePanel(i, 'term'),
              onDefImageTap: () => _toggleImagePanel(i, 'def'),
              onClosePanel: () => setState(() { _expandedIndex = null; _expandedSide = null; }),
              onUploadTerm: () => _pickImage(i, 'term'),
              onUploadDef: () => _pickImage(i, 'def'),
              onTypeChanged: (v) {
                setState(() {
                  if (v.startsWith('choice:')) {
                    _cards[i].type = 'choice';
                    _cards[i].answerIndex = int.tryParse(v.split(':')[1]) ?? _cards[i].answerIndex;
                  } else if (v.startsWith('tf:')) {
                    _cards[i].type = 'tf';
                    _cards[i].answerIndex = int.tryParse(v.split(':')[1]) ?? 0;
                  } else {
                    _cards[i].type = v;
                    if (v == 'tf' && _cards[i].answerIndex < 0) _cards[i].answerIndex = 0;
                    if (v == 'choice' && _cards[i].answerIndex < 0) _cards[i].answerIndex = 0;
                  }
                });
                _markDirty();
              },
              onAddHighlight: () {
                final sel = _cards[i].defCtrl.selection;
                if (!sel.isValid || sel.isCollapsed) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select text in definition first')));
                  return;
                }
                final txt = _cards[i].defCtrl.text.substring(sel.start, sel.end).trim();
                if (txt.isEmpty) return;
                setState(() {
                  final cur = jsonDecode(_cards[i].highlights.isEmpty ? '[]' : _cards[i].highlights) as List;
                  if (!cur.contains(txt)) cur.add(txt);
                  _cards[i].highlights = jsonEncode(cur);
                });
                _markDirty();
              },
              onRemoveHighlight: (h) {
                setState(() {
                  final cur = jsonDecode(_cards[i].highlights.isEmpty ? '[]' : _cards[i].highlights) as List;
                  cur.remove(h);
                  _cards[i].highlights = jsonEncode(cur);
                });
                _markDirty();
              },
              onDelete: () {
                setState(() {
                  _cards[i].disposeCtrls();
                  _cards.removeAt(i);
                  if (_expandedIndex == i) { _expandedIndex = null; _expandedSide = null; }
                  _searchCtrls.remove(i)?.dispose();
                });
                _markDirty();
              },
              onReorderUp: i == 0 ? null : () { setState(() { final t = _cards.removeAt(i); _cards.insert(i - 1, t); }); _markDirty(); },
              onReorderDown: i == _cards.length - 1 ? null : () { setState(() { final t = _cards.removeAt(i); _cards.insert(i + 1, t); }); _markDirty(); },
            ),
          ),
        Center(
          child: FilledButton.tonal(
              onPressed: () => setState(() {
                    final d = _CardDraft(term: '', def: '')..attach();
                    _attachCardListeners(d);
                    _cards.add(d);
                    _markDirty();
                  }),
              child: const Text('Add a card')),
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _save, style: FilledButton.styleFrom(backgroundColor: SocraTheme.ecoGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: Text(_effectiveDeckId == null ? 'Create' : 'Done'))),
              ]),
              // Save widget pops up — super clear, with countdown + cross — shakes with screen
              if (_hasUnsaved && _bannerVisible)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: child)),
                    child: Material(
                      elevation: 12,
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.error.withValues(alpha: 0.3), width: 1.5)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                          child: Row(children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: scheme.error, shape: BoxShape.circle), child: Icon(Icons.warning_amber_rounded, size: 20, color: scheme.onError)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(_isAutosaving ? 'Auto-saving…' : 'Unsaved changes', style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onErrorContainer)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: scheme.onErrorContainer.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.timer_outlined, size: 14, color: scheme.onErrorContainer),
                                      const SizedBox(width: 4),
                                      Text('${_bannerSeconds}s', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.onErrorContainer)),
                                    ]),
                                  ),
                                ]),
                                Text(_isAutosaving ? 'Hang tight — writing to disk' : 'Your deck isn’t saved yet • disappears in ${_bannerSeconds}s', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer)),
                              ]),
                            ),
                            FilledButton.icon(
                              onPressed: _performAutosave,
                              icon: const Icon(Icons.save_outlined, size: 16),
                              label: const Text('Save now'),
                              style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Dismiss',
                              icon: Icon(Icons.close, size: 20, color: scheme.onErrorContainer),
                              onPressed: _hideBanner,
                              style: IconButton.styleFrom(backgroundColor: scheme.onErrorContainer.withValues(alpha: 0.12)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.index,
    required this.draft,
    required this.onDelete,
    this.onReorderUp,
    this.onReorderDown,
    required this.isTermExpanded,
    required this.isDefExpanded,
    this.searchCtrl,
    required this.onTermImageTap,
    required this.onDefImageTap,
    required this.onClosePanel,
    required this.onUploadTerm,
    required this.onUploadDef,
    required this.onTypeChanged,
    required this.onAddHighlight,
    required this.onRemoveHighlight,
  });
  final int index;
  final _CardDraft draft;
  final VoidCallback onDelete;
  final VoidCallback? onReorderUp;
  final VoidCallback? onReorderDown;
  final bool isTermExpanded;
  final bool isDefExpanded;
  final TextEditingController? searchCtrl;
  final VoidCallback onTermImageTap;
  final VoidCallback onDefImageTap;
  final VoidCallback onClosePanel;
  final VoidCallback onUploadTerm;
  final VoidCallback onUploadDef;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onAddHighlight;
  final ValueChanged<String> onRemoveHighlight;

  List<String> _highlights() {
    try {
      final d = jsonDecode(draft.highlights);
      if (d is List) return d.map((e) => e.toString()).toList();
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isExpanded = isTermExpanded || isDefExpanded;
    final expandedSide = isTermExpanded ? 'term' : 'def';
    final highlights = _highlights();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + index * 40),
      curve: Curves.easeOutCubic,
      builder: (c, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child)),
      child: Container(
        decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(20)),
                  child: Text('${index + 1}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                // Familiar type switcher — like Gizmo/Quizlet, super clear
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _TypeChip(label: 'Basic', icon: Icons.flip, selected: draft.type == 'basic', onTap: () => onTypeChanged('basic')),
                      _TypeChip(label: 'Blank', icon: Icons.edit_note, selected: draft.type == 'cloze', onTap: () => onTypeChanged('cloze')),
                      _TypeChip(label: 'Free', icon: Icons.draw_outlined, selected: draft.type == 'free', onTap: () => onTypeChanged('free')),
                      _TypeChip(label: 'Choice', icon: Icons.list_alt, selected: draft.type == 'choice', onTap: () => onTypeChanged('choice')),
                      _TypeChip(label: 'T/F', icon: Icons.check_box_outlined, selected: draft.type == 'tf', onTap: () => onTypeChanged('tf')),
                    ]),
                  ),
                ),
                IconButton(icon: const Icon(Icons.drag_handle, size: 18), onPressed: onReorderUp),
                IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: onDelete),
              ]),
              const SizedBox(height: 12),
              // Per-type familiar fields
              if (draft.type == 'basic') ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _ImagePlaceholder(onTap: onTermImageTap, label: draft.imageTerm, selected: isTermExpanded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      TextField(controller: draft.termCtrl, decoration: InputDecoration(hintText: 'Enter term', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                      const SizedBox(height: 4),
                      Row(children: [Text('TERM', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)), const Spacer(), Text('CHOOSE LANGUAGE', style: TextStyle(fontSize: 10, color: SocraTheme.ecoGreen, fontWeight: FontWeight.w600))]),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      TextField(controller: draft.defCtrl, decoration: InputDecoration(hintText: 'Enter definition', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                      const SizedBox(height: 4),
                      Row(children: [Text('DEFINITION', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)), const Spacer(), Text('CHOOSE LANGUAGE', style: TextStyle(fontSize: 10, color: SocraTheme.ecoGreen, fontWeight: FontWeight.w600))]),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  _ImagePlaceholder(onTap: onDefImageTap, label: draft.imageDef, selected: isDefExpanded),
                ]),
              ] else if (draft.type == 'cloze' || draft.type == 'free') ...[
                // Gizmo-style: question + highlighted answer
                TextField(controller: draft.termCtrl, decoration: InputDecoration(hintText: draft.type == 'cloze' ? 'What is the …? (stem)' : 'Question', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                const SizedBox(height: 8),
                TextField(controller: draft.defCtrl, decoration: InputDecoration(hintText: 'Answer / definition to highlight', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                const SizedBox(height: 8),
                Row(children: [
                  FilledButton.tonalIcon(onPressed: onAddHighlight, icon: const Icon(Icons.highlight, size: 16), label: const Text('Highlight selection')),
                  const SizedBox(width: 8),
                  Text('Select text in definition, then Highlight', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ]),
                if (highlights.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: highlights.map((h) => Chip(label: Text(h, style: const TextStyle(fontSize: 12)), backgroundColor: SocraTheme.ecoGreen.withValues(alpha: 0.14), deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () => onRemoveHighlight(h))).toList()),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  _ImagePlaceholder(onTap: onTermImageTap, label: draft.imageTerm, selected: isTermExpanded),
                  const Spacer(),
                  _ImagePlaceholder(onTap: onDefImageTap, label: draft.imageDef, selected: isDefExpanded),
                ]),
              ] else if (draft.type == 'choice') ...[
                TextField(controller: draft.termCtrl, decoration: InputDecoration(hintText: 'Which of the following…?', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                for (var i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Radio<int>(value: i, groupValue: draft.answerIndex, onChanged: (v) => onTypeChanged('choice:$v')),
                      Expanded(child: TextField(controller: draft.optionCtrls[i], decoration: InputDecoration(hintText: 'Option ${i + 1}', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
                    ]),
                  ),
              ] else if (draft.type == 'tf') ...[
                TextField(controller: draft.termCtrl, decoration: InputDecoration(hintText: 'Statement is…', filled: true, fillColor: scheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: ChoiceChip(label: const Text('True'), selected: draft.answerIndex == 0, onSelected: (_) => onTypeChanged('tf:0'))),
                  const SizedBox(width: 12),
                  Expanded(child: ChoiceChip(label: const Text('False'), selected: draft.answerIndex == 1, onSelected: (_) => onTypeChanged('tf:1'))),
                ]),
              ],
            ]),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(expandedSide == 'term' ? 'Add a term image' : 'Add a definition image', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search Quizlet images',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: scheme.surface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              isDense: true,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or')),
                        FilledButton.tonalIcon(
                          onPressed: expandedSide == 'term' ? onUploadTerm : onUploadDef,
                          icon: const Icon(Icons.upload_outlined, size: 18),
                          label: const Text('Upload'),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(onPressed: onClosePanel, icon: const Icon(Icons.keyboard_arrow_up, size: 18), label: const Text('Close')),
                      ),
                    ]),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: selected ? Colors.white : null), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null))]),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: SocraTheme.ecoGreen,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _ImagePlaceholder extends StatefulWidget {
  const _ImagePlaceholder({required this.onTap, this.label, this.selected = false});
  final VoidCallback onTap;
  final String? label;
  final bool selected;
  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = widget.label != null && widget.label!.isNotEmpty;
    // Tertiary is the "not-green" matching accent (cream→sage→warm mauve in this seed).
    final tertiary = scheme.tertiary;
    final tertiaryContainer = scheme.tertiaryContainer;
    final bg = widget.selected
        ? SocraTheme.ecoGreen.withValues(alpha: 0.14)
        : _hovered
            ? tertiaryContainer
            : hasImage
                ? SocraTheme.ecoGreen.withValues(alpha: 0.10)
                : scheme.surface;
    final border = widget.selected
        ? SocraTheme.ecoGreen
        : _hovered
            ? tertiary
            : hasImage
                ? SocraTheme.ecoGreen.withValues(alpha: 0.5)
                : scheme.outlineVariant;
    final fg = widget.selected
        ? SocraTheme.ecoGreen
        : _hovered
            ? tertiary
            : hasImage
                ? SocraTheme.ecoGreen
                : scheme.onSurfaceVariant;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (v) => setState(() => _hovered = v),
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 72,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: widget.selected || _hovered ? 2 : 1),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                style: TextStyle(color: fg),
                child: Icon(hasImage ? Icons.check_circle_outline : Icons.image_outlined, size: 20, color: fg),
              ),
              const SizedBox(height: 2),
              Text(
                hasImage ? widget.label!.split('/').last.split('\\').last : 'Image',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: fg, fontWeight: hasImage || _hovered ? FontWeight.w600 : null),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
