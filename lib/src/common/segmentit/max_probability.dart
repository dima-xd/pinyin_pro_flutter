library;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

class _ProbabilityItem {
  double probability;
  int decimal; // exponent: actual value = probability * (1e-300)^decimal
  final MatchPattern? pattern;
  final int nextIndex;

  _ProbabilityItem({
    required this.probability,
    required this.decimal,
    this.pattern,
    required this.nextIndex,
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
  final terminalDP = _ProbabilityItem(
    probability: 1.0,
    decimal: 0,
    nextIndex: length,
  );
  var patternIndex = patterns.length - 1;
  MatchPattern? pattern =
      patternIndex >= 0 ? patterns[patternIndex] : null;

  for (var i = length - 1; i >= 0; i--) {
    final suffixDP = i + 1 >= length ? terminalDP : dp[i + 1]!;
    final nextIndex = suffixDP.pattern != null ? i + 1 : suffixDP.nextIndex;

    while (pattern != null &&
        pattern.index + pattern.length - 1 == i) {
      final startIndex = pattern.index;
      final curDP = _ProbabilityItem(
        probability: pattern.probability * suffixDP.probability,
        decimal: suffixDP.decimal + _getPatternDecimal(pattern),
        pattern: pattern,
        nextIndex: nextIndex,
      );
      _checkDecimal(curDP);
      dp[startIndex] =
          _getMaxProbability(dp[startIndex], curDP);
      patternIndex--;
      pattern = patternIndex >= 0 ? patterns[patternIndex] : null;
    }

    final iDP = _ProbabilityItem(
      probability: kProbabilityUnknown * suffixDP.probability,
      decimal: 0,
      nextIndex: nextIndex,
    );
    _checkDecimal(iDP);
    dp[i] = _getMaxProbability(dp[i], iDP);
  }

  final result = <MatchPattern>[];
  var index = 0;
  while (index < length) {
    final item = dp[index];
    if (item == null) break;
    if (item.pattern != null) result.add(item.pattern!);
    index = item.nextIndex;
  }
  return result;
}
