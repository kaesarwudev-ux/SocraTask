import 'package:flutter/material.dart';
import 'package:socra_task/core/theme/app_theme.dart';
import 'package:socra_task/features/flashcards/data/flashcard_import.dart';

/// Socra-styled import dialog inspired by screenshot Image 1.
/// Not dark navy — uses Socra cream/ecoGreen Material 3.
class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});
  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _rawCtrl = TextEditingController();
  TermSeparator _termSep = TermSeparator.tab;
  CardSeparator _cardSep = CardSeparator.newline;
  final _customTermCtrl = TextEditingController();
  final _customCardCtrl = TextEditingController();

  List<({String term, String def})> get _preview => parseImport(
        _rawCtrl.text,
        termSep: _termSep,
        cardSep: _cardSep,
        customTerm: _customTermCtrl.text,
        customCard: _customCardCtrl.text,
      );

  @override
  void dispose() {
    _rawCtrl.dispose();
    _customTermCtrl.dispose();
    _customCardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = _preview;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
            child: Row(children: [
              Expanded(child: Text('Import your data.', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              Text('Copy and Paste your data here (from Word, Excel, Google Docs, etc.)', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 12),
              IconButton(tooltip: 'Close', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          // Text area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _rawCtrl,
              maxLines: 7,
              minLines: 7,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Word 1\tDefinition 1\nWord 2\tDefinition 2\nWord 3\tDefinition 3',
                hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Between term and definition
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Between term and definition', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _Radio<TermSeparator>(label: 'Tab', value: TermSeparator.tab, group: _termSep, onChanged: (v) => setState(() => _termSep = v)),
                  _Radio<TermSeparator>(label: 'Comma', value: TermSeparator.comma, group: _termSep, onChanged: (v) => setState(() => _termSep = v)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Radio<TermSeparator>(value: TermSeparator.custom, groupValue: _termSep, onChanged: (v) => setState(() => _termSep = v!)),
                    Expanded(
                      child: TextField(
                        controller: _customTermCtrl,
                        onChanged: (_) => setState(() {}),
                        enabled: _termSep == TermSeparator.custom,
                        decoration: InputDecoration(
                          hintText: 'Custom',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(width: 24),
              // Between cards
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Between cards', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _Radio<CardSeparator>(label: 'New line', value: CardSeparator.newline, group: _cardSep, onChanged: (v) => setState(() => _cardSep = v)),
                  _Radio<CardSeparator>(label: 'Semicolon', value: CardSeparator.semicolon, group: _cardSep, onChanged: (v) => setState(() => _cardSep = v)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Radio<CardSeparator>(value: CardSeparator.custom, groupValue: _cardSep, onChanged: (v) => setState(() => _cardSep = v!)),
                    Expanded(
                      child: TextField(
                        controller: _customCardCtrl,
                        onChanged: (_) => setState(() {}),
                        enabled: _cardSep == CardSeparator.custom,
                        decoration: InputDecoration(
                          hintText: 'Custom',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Preview', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: SocraTheme.ecoGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${preview.length} cards', style: const TextStyle(color: SocraTheme.ecoGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: preview.isEmpty
                    ? Text('Nothing to preview yet.', key: const ValueKey('empty'), style: Theme.of(context).textTheme.bodySmall)
                    : Container(
                        key: ValueKey(preview.length),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: scheme.outlineVariant)),
                        child: Column(
                          children: preview.take(3).map((p) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(children: [
                                  Expanded(child: Text(p.term, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_right_alt, size: 18)),
                                  Expanded(child: Text(p.def)),
                                ]),
                              )).toList(),
                        ),
                      ),
              ),
              if (preview.length > 3) Padding(padding: const EdgeInsets.only(top: 4), child: Text('+ ${preview.length - 3} more', style: Theme.of(context).textTheme.bodySmall)),
            ]),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel Import')),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: preview.isEmpty ? null : () => Navigator.pop(context, preview),
                child: const Text('Import'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Radio<T> extends StatelessWidget {
  const _Radio({required this.label, required this.value, required this.group, required this.onChanged});
  final String label;
  final T value;
  final T group;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(value),
      child: Row(children: [Radio<T>(value: value, groupValue: group, onChanged: (v) => onChanged(v as T)), Text(label)]),
    );
  }
}
