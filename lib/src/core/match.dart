// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/pinyin.dart';

const int _maxPinyinLength = 6;

/// Options for [matchPinyin].
class MatchOptions {
  /// Matching precision for each character. Defaults to [MatchPrecision.first].
  final MatchPrecision precision;

  /// Whether matched indices must be continuous. Defaults to false.
  final bool continuous;

  /// How spaces are treated. Defaults to [MatchSpace.ignore].
  final MatchSpace space;

  /// Precision for the last character. Defaults to [MatchPrecision.start].
  final MatchPrecision lastPrecision;

  /// Case-insensitive matching. Defaults to true.
  final bool insensitive;

  /// Replace ü with v before matching. Defaults to false.
  final bool v;

  const MatchOptions({
    this.precision = MatchPrecision.first,
    this.continuous = false,
    this.space = MatchSpace.ignore,
    this.lastPrecision = MatchPrecision.start,
    this.insensitive = true,
    this.v = false,
  });
}

/// Matching precision levels.
enum MatchPrecision {
  /// First letter of pinyin must match.
  first,

  /// Pinyin must start with the query.
  start,

  /// Every letter must match in order.
  every,

  /// Any letter may match (fuzzy).
  any,
}

/// Space handling during matching.
enum MatchSpace {
  /// Ignore spaces in the pinyin query.
  ignore,

  /// Preserve spaces as literal match targets.
  preserve,
}

/// Checks whether [text] (Chinese string) matches the [pinyinQuery].
///
/// Returns the list of matched character indices on success, or null on
/// failure. The indices refer to the original [text] (surrogate pairs are
/// expanded).
///
/// Example:
/// ```dart
/// matchPinyin('中文拼音', 'zwp'); // [0, 1, 2]
/// matchPinyin('中文拼音', 'zhongwenpin'); // [0, 1, 2]
/// ```
List<int>? matchPinyin(
  String text,
  String pinyinQuery, {
  MatchOptions options = const MatchOptions(),
}) {
  var opts = options;
  var query = pinyinQuery;

  if (opts.precision == MatchPrecision.any) {
    opts = MatchOptions(
      precision: MatchPrecision.any,
      lastPrecision: MatchPrecision.any,
      continuous: opts.continuous,
      space: opts.space,
      insensitive: opts.insensitive,
      v: opts.v,
    );
  }

  if (opts.v) {
    query = query.replaceAll('ü', 'v');
  }

  var t = text;
  if (opts.insensitive) {
    t = t.toLowerCase();
    query = query.toLowerCase();
  }

  if (opts.space == MatchSpace.ignore) {
    query = query.replaceAll(RegExp(r'\s'), '');
  }

  final result = opts.precision == MatchPrecision.any
      ? _matchAny(t, query, opts)
      : _matchAboveStart(t, query, opts);

  return _processDoubleUnicodeIndex(text, result);
}

int _getMatchLength(String p1, String p2) {
  var length = 0;
  for (var i = 0; i < p1.length; i++) {
    if (length < p2.length && p1[i] == p2[length]) {
      length++;
    }
  }
  return length;
}

List<int>? _matchAny(String text, String query, MatchOptions options) {
  var q = query;
  final result = <int>[];
  final words = splitString(text);
  final ignoreSpace = options.space == MatchSpace.ignore;

  for (var i = 0; i < words.length; i++) {
    if (ignoreSpace && words[i] == ' ') {
      result.add(i);
      continue;
    }
    if (q.isNotEmpty && words[i] == q[0]) {
      q = q.substring(1);
      result.add(i);
      continue;
    }
    final ps = (pinyin(words[i],
            options: PinyinOptions(
              toneType: ToneType.none,
              multiple: true,
              returnType: PinyinReturnType.array,
              v: options.v,
            )) as List)
        .cast<String>();

    var currentLength = 0;
    for (final p in ps) {
      final length = _getMatchLength(p, q);
      if (length > currentLength) currentLength = length;
    }
    if (currentLength > 0) {
      q = q.substring(currentLength);
      result.add(i);
    }
    if (q.isEmpty) break;
  }

  if (q.isNotEmpty) return null;

  var finalResult = result;
  if (options.continuous) {
    final isContinuous = result.asMap().entries.every(
        (e) => e.key == 0 || e.value == result[e.key - 1] + 1);
    if (!isContinuous) return null;
  }

  if (options.space == MatchSpace.ignore) {
    finalResult = finalResult.where((i) => words[i] != ' ').toList();
  }

  return finalResult.isEmpty ? null : finalResult;
}

List<int>? _matchAboveStart(
    String text, String query, MatchOptions options) {
  final words = splitString(text);
  // dp[i][j]: indices matched when processing words[0..i-1] and query[0..j-1].
  final dp = List.generate(
      words.length + 1, (_) => List<List<int>?>.filled(query.length + 1, null));

  for (var i = 0; i <= words.length; i++) {
    dp[i][0] = [];
  }
  for (var j = 0; j <= query.length; j++) {
    dp[0][j] = [];
  }

  for (var i = 1; i <= words.length; i++) {
    if (!options.continuous ||
        (options.space == MatchSpace.ignore && words[i - 1] == ' ')) {
      for (var j = 1; j <= query.length; j++) {
        dp[i][j - 1] = dp[i - 1][j - 1];
      }
    }

    for (var j = 1; j <= query.length; j++) {
      final prev = dp[i - 1][j - 1];
      if (prev == null) continue;
      if (j != 1 && prev.isEmpty) continue;

      final muls = (pinyin(words[i - 1],
              options: PinyinOptions(
                returnType: PinyinReturnType.array,
                toneType: ToneType.none,
                multiple: true,
                v: options.v,
              )) as List)
          .cast<String>();

      // Non-Chinese direct character match.
      if (j <= query.length && words[i - 1] == query[j - 1]) {
        final matches = [...prev, i - 1];
        if (dp[i][j] == null || matches.length > dp[i][j]!.length) {
          dp[i][j] = matches;
        }
        if (j == query.length) return dp[i][j];
      }

      // lastPrecision handling.
      if (query.length - j <= _maxPinyinLength) {
        final lastSlice = query.substring(j - 1);
        final last = muls.any((py) {
          switch (options.lastPrecision) {
            case MatchPrecision.any:
              return py.contains(lastSlice);
            case MatchPrecision.start:
              return py.startsWith(lastSlice);
            case MatchPrecision.first:
              return py.isNotEmpty && py[0] == lastSlice;
            case MatchPrecision.every:
              return py == lastSlice;
          }
        });
        if (last) return [...prev, i - 1];
      }

      final precision = options.precision;

      if (precision == MatchPrecision.start) {
        for (final py in muls) {
          var end = j;
          final matches = [...prev, i - 1];
          while (end <= query.length &&
              py.startsWith(query.substring(j - 1, end))) {
            if (dp[i][end] == null ||
                matches.length > dp[i][end]!.length) {
              dp[i][end] = matches;
            }
            end++;
          }
        }
      }

      if (precision == MatchPrecision.first) {
        if (muls.any((py) =>
            py.isNotEmpty && j <= query.length && py[0] == query[j - 1])) {
          final matches = [...prev, i - 1];
          if (dp[i][j] == null || matches.length > dp[i][j]!.length) {
            dp[i][j] = matches;
          }
        }
      }

      // Complete pinyin match.
      final completeMatch = muls.firstWhere(
          (py) =>
              j - 1 + py.length <= query.length &&
              py == query.substring(j - 1, j - 1 + py.length),
          orElse: () => '');
      if (completeMatch.isNotEmpty) {
        final matches = [...prev, i - 1];
        final endIndex = j - 1 + completeMatch.length;
        if (dp[i][endIndex] == null ||
            matches.length > dp[i][endIndex]!.length) {
          dp[i][endIndex] = matches;
        }
      }
    }
  }
  return null;
}

List<int>? _processDoubleUnicodeIndex(
    String text, List<int>? indexArray) {
  if (indexArray == null) return null;
  final result = <int>[];
  var doubleUnicodeCount = 0;
  final words = splitString(text);
  var k = 0;
  for (final curIndex in indexArray) {
    while (k <= curIndex) {
      if (words[k].length == 2) doubleUnicodeCount++;
      k++;
    }
    final realIndex = curIndex + doubleUnicodeCount;
    if (words[curIndex].length == 2) {
      result.addAll([realIndex - 1, realIndex]);
    } else {
      result.add(realIndex);
    }
  }
  return result;
}
