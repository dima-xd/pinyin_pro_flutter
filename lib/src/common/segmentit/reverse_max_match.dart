library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

bool _isIgnorablePattern(MatchPattern cur, MatchPattern pre) {
  if (pre.index + pre.length <= cur.index) return false;
  if (pre.priority > cur.priority) return false;
  if (pre.priority == cur.priority && pre.length > cur.length) return false;
  return true;
}

/// Reverse maximum match tokenization algorithm.
///
/// Iterates from right to left, always preferring the longest match.
List<MatchPattern> reverseMaxMatch(List<MatchPattern> patterns) {
  final filtered = <MatchPattern>[];
  var i = patterns.length - 1;
  while (i >= 0) {
    final index = patterns[i].index;
    var j = i - 1;
    while (j >= 0 && _isIgnorablePattern(patterns[i], patterns[j])) {
      j--;
    }
    if (j < 0 || patterns[j].index + patterns[j].length <= index) {
      filtered.add(patterns[i]);
    }
    i = j;
  }
  return filtered.reversed.toList();
}
