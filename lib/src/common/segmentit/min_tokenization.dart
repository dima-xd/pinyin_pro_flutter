library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

class _Tokenization {
  int count;
  List<MatchPattern> patterns;
  MatchPattern? concatPattern;

  _Tokenization({
    required this.count,
    required this.patterns,
    this.concatPattern,
  });
}

_Tokenization _getMinCount(_Tokenization? a, _Tokenization b) {
  if (a == null) return b;
  return a.count <= b.count ? a : b;
}

int _getPatternCount(MatchPattern pattern) {
  if (pattern.priority == kPriorityCustom) {
    return -(pattern.length * pattern.length * 100000);
  }
  if (pattern.priority == kPrioritySurname) {
    return -(pattern.length * pattern.length * 100);
  }
  return 1;
}

/// Minimum tokenization count algorithm.
///
/// Selects the sequence of patterns that minimises the total number of tokens.
List<MatchPattern> minTokenization(
    List<MatchPattern> patterns, int length) {
  final dp = List<_Tokenization?>.filled(length, null);
  var patternIndex = patterns.length - 1;
  MatchPattern? pattern =
      patternIndex >= 0 ? patterns[patternIndex] : null;

  for (var i = length - 1; i >= 0; i--) {
    final suffixDP = i + 1 >= length
        ? _Tokenization(count: 0, patterns: [])
        : dp[i + 1];

    while (pattern != null &&
        pattern.index + pattern.length - 1 == i) {
      final startIndex = pattern.index;
      final curDP = _Tokenization(
        count: _getPatternCount(pattern) + (suffixDP?.count ?? 0),
        patterns: suffixDP?.patterns ?? [],
        concatPattern: pattern,
      );
      dp[startIndex] = _getMinCount(dp[startIndex], curDP);
      patternIndex--;
      pattern = patternIndex >= 0 ? patterns[patternIndex] : null;
    }

    final iDP = _Tokenization(
      count: 1 + (suffixDP?.count ?? 0),
      patterns: suffixDP?.patterns ?? [],
    );
    dp[i] = _getMinCount(dp[i], iDP);

    if (dp[i]?.concatPattern != null) {
      dp[i]!.patterns = [...dp[i]!.patterns, dp[i]!.concatPattern!];
      dp[i]!.concatPattern = null;
      if (i + 1 < length) dp[i + 1] = null;
    }
  }
  return List<MatchPattern>.from(dp[0]?.patterns ?? []).reversed.toList();
}
