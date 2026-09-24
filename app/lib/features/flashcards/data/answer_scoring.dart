import 'dart:math' as math;

/// Huge fuzzy algorithm for free-answer grading.
/// User can manually override any result (see StudyPage override UI).
/// Pure Dart, no AI needed.

class AnswerScore {
  const AnswerScore({required this.score, required this.label, required this.details});
  /// 0.0 - 1.0
  final double score;
  /// correct | close | wrong
  final String label;
  /// explain diff
  final String details;
  bool get isCorrect => label == 'correct';
  bool get isClose => label == 'close';
  bool get isWrong => label == 'wrong';
}

/// Normalize: lower, trim, NFD strip diacritics, collapse ws, strip edges punctuation.
String _norm(String s) {
  var t = s.trim().toLowerCase();
  // strip diacritics via simple map for common latin
  const map = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c', 'ß': 'ss',
  };
  map.forEach((k, v) => t = t.replaceAll(k, v));
  t = t.replaceAll(RegExp(r'\s+'), ' ');
  // keep internal punctuation but trim edges: remove leading/trailing non-alnum
  t = t.replaceAll(RegExp(r'^[^a-z0-9]+|[^a-z0-9]+$'), '');
  // normalize numbers words? small map for 0-20
  const numWords = {
    'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
    'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9',
    'ten': '10', 'eleven': '11', 'twelve': '12', 'thirteen': '13',
    'fourteen': '14', 'fifteen': '15', 'sixteen': '16', 'seventeen': '17',
    'eighteen': '18', 'nineteen': '19', 'twenty': '20',
  };
  // also "don't" -> "do not", "can't" -> "cannot" handled via replace
  t = t.replaceAll("don't", "do not").replaceAll("can't", "cannot").replaceAll("won't", "will not");
  // word-level number normalize: split and map
  final parts = t.split(' ');
  for (var i = 0; i < parts.length; i++) {
    final w = parts[i];
    if (numWords.containsKey(w)) parts[i] = numWords[w]!;
  }
  t = parts.join(' ');
  return t;
}

int _lev(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final m = a.length, n = b.length;
  var prev = List<int>.generate(n + 1, (j) => j);
  var curr = List<int>.filled(n + 1, 0);
  for (var i = 1; i <= m; i++) {
    curr[0] = i;
    for (var j = 1; j <= n; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      curr[j] = math.min(curr[j - 1] + 1, math.min(prev[j] + 1, prev[j - 1] + cost));
    }
    final tmp = prev; prev = curr; curr = tmp;
  }
  return prev[n];
}

double _jaccard(String a, String b) {
  final sa = a.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toSet();
  final sb = b.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toSet();
  if (sa.isEmpty && sb.isEmpty) return 1.0;
  final inter = sa.intersection(sb).length;
  final union = sa.union(sb).length;
  return union == 0 ? 0 : inter / union;
}

/// Main entry: grade [user] vs [expected] (definition/answer).
AnswerScore gradeFreeAnswer(String user, String expected, {bool strict = false}) {
  final u = _norm(user);
  final e = _norm(expected);
  if (u.isEmpty && e.isEmpty) return const AnswerScore(score: 1, label: 'correct', details: 'Both empty');
  if (u.isEmpty) return AnswerScore(score: 0, label: 'wrong', details: 'No answer given. Expected “$expected”');
  if (u == e) return AnswerScore(score: 1, label: 'correct', details: 'Exact match');

  // token jaccard
  final j = _jaccard(u, e);
  // char-level levenshtein normalized
  final maxLen = math.max(u.length, e.length);
  final lev = maxLen == 0 ? 0 : _lev(u, e);
  final levScore = maxLen == 0 ? 1.0 : 1 - lev / maxLen;
  // word-level lev (join with space)
  final uw = u.split(' ').join(' ');
  final ew = e.split(' ').join(' ');
  final wLev = math.max(uw.length, ew.length) == 0 ? 1.0 : 1 - _lev(uw, ew) / math.max(uw.length, ew.length);

  // weighted
  var score = 0.45 * levScore + 0.35 * j + 0.20 * wLev;
  // bonus for substring containment (user typed shorter but correct core)
  if (e.contains(u) && u.length >= 3) score = math.max(score, 0.78);
  if (u.contains(e) && e.length >= 3) score = math.max(score, 0.88);

  // thresholds: strict tightens close band
  final closeMin = strict ? 0.82 : 0.75;
  final correctMin = strict ? 0.95 : 0.92;

  String label;
  String details;
  if (score >= correctMin) {
    label = 'correct';
    details = 'Great — ${(score * 100).round()}% match';
  } else if (score >= closeMin) {
    label = 'close';
    // explain diff: show what to fix
    final miss = _explain(u, e);
    details = 'Close ${(score * 100).round()}% — $miss. You can override to Correct if you meant it.';
  } else {
    label = 'wrong';
    details = 'Not quite (${(score * 100).round()}%). Expected “$expected”';
  }
  return AnswerScore(score: score, label: label, details: details);
}

String _explain(String u, String e) {
  if (u.length < e.length - 3) return 'too short, missing "${e.substring(u.length).trim()}"';
  if (e.length < u.length - 3) return 'extra "${_diffExtra(u, e)}"';
  return 'check spelling/punctuation';
}

String _diffExtra(String u, String e) {
  final ut = u.split(' ').toSet();
  final et = e.split(' ').toSet();
  final extra = ut.difference(et).take(2).join(', ');
  return extra.isEmpty ? u : extra;
}
