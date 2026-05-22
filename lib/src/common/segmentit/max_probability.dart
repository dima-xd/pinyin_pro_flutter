library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

class _ProbabilityItem {
  double probability;
  int decimal; // exponent: actual value = probability * (1e-300)^decimal
  List<MatchPattern> patterns;
  MatchPattern? concatPattern;

  _ProbabilityItem({
    required this.probability,
    required this.decimal,
    required this.patterns,
    this.concatPattern,
  });
}

_ProbabilityItem _getMaxProbability(_ProbabilityItem? a, _ProbabilityItem b) {
  if (a == null) return b;
  if (a.decimal < b.decimal) return a;
  if (a.decimal == b.decimal) {
    return a.probability > b.probability ? a : b;
  }
  return b;
}

void _checkDecimal(_ProbabilityItem prob) {
  if (prob.probability < 1e-300) {
    prob.probability *= 1e300;
    prob.decimal += 1;
  }
}

int _getPatternDecimal(MatchPattern pattern) {
  if (pattern.priority == kPriorityCustom) {
    return -(pattern.length * pattern.length * 100);
  }
  if (pattern.priority == kPrioritySurname) {
    return -(pattern.length * pattern.length * 10);
  }
  return 0;
}

/// Maximum probability tokenization algorithm.
///
/// Selects the sequence of patterns that maximises the product of their
/// individual word-frequency probabilities.
List<MatchPattern> maxProbability(
    List<MatchPattern> patterns, int length) {
  final dp = List<_ProbabilityItem?>.filled(length, null);
  var patternIndex = patterns.length - 1;
  MatchPattern? pattern =
      patternIndex >= 0 ? patterns[patternIndex] : null;

  for (var i = length - 1; i >= 0; i--) {
    final suffixDP = i + 1 >= length
        ? _ProbabilityItem(
            probability: 1.0, decimal: 0, patterns: [])
        : dp[i + 1];

    while (pattern != null &&
        pattern.index + pattern.length - 1 == i) {
      final startIndex = pattern.index;
      final curDP = _ProbabilityItem(
        probability: pattern.probability * (suffixDP?.probability ?? 1.0),
        decimal: (suffixDP?.decimal ?? 0) + _getPatternDecimal(pattern),
        patterns: suffixDP?.patterns ?? [],
        concatPattern: pattern,
      );
      _checkDecimal(curDP);
      dp[startIndex] =
          _getMaxProbability(dp[startIndex], curDP);
      patternIndex--;
      pattern = patternIndex >= 0 ? patterns[patternIndex] : null;
    }

    final iDP = _ProbabilityItem(
      probability: kProbabilityUnknown * (suffixDP?.probability ?? 1.0),
      decimal: 0,
      patterns: suffixDP?.patterns ?? [],
    );
    _checkDecimal(iDP);
    dp[i] = _getMaxProbability(dp[i], iDP);

    if (dp[i]?.concatPattern != null) {
      dp[i]!.patterns =
          [...dp[i]!.patterns, dp[i]!.concatPattern!];
      dp[i]!.concatPattern = null;
      if (i + 1 < length) dp[i + 1] = null;
    }
  }
  return List<MatchPattern>.from(dp[0]?.patterns ?? []).reversed.toList();
}
