enum TermSeparator { tab, comma, custom }
enum CardSeparator { newline, semicolon, custom }

/// Pure parser — no drift, easy to test. Mirrors the screenshot's
/// “Between term and definition” / “Between cards”.
List<({String term, String def})> parseImport(
  String raw, {
  required TermSeparator termSep,
  required CardSeparator cardSep,
  String customTerm = '',
  String customCard = '',
}) {
  String termDelim() {
    switch (termSep) {
      case TermSeparator.tab:
        return '\t';
      case TermSeparator.comma:
        return ',';
      case TermSeparator.custom:
        return customTerm;
    }
  }

  String cardDelim() {
    switch (cardSep) {
      case CardSeparator.newline:
        return '\n';
      case CardSeparator.semicolon:
        return ';';
      case CardSeparator.custom:
        return customCard;
    }
  }

  final tDelim = termDelim();
  final cDelim = cardDelim();
  if (raw.trim().isEmpty) return [];
  // Guard: empty custom delim would split per-character.
  if (tDelim.isEmpty || cDelim.isEmpty) return [];

  final rowTexts = cDelim == '\n'
      ? raw.split(RegExp(r'\r?\n'))
      : raw.split(cDelim);

  final out = <({String term, String def})>[];
  for (final row in rowTexts) {
    final r = row.trim();
    if (r.isEmpty) continue;
    // Term/def split: first occurrence of the term delim.
    final idx = r.indexOf(tDelim);
    if (idx < 0) continue;
    final term = r.substring(0, idx).trim();
    final def = r.substring(idx + tDelim.length).trim();
    if (term.isEmpty && def.isEmpty) continue;
    out.add((term: term, def: def));
  }
  return out;
}
