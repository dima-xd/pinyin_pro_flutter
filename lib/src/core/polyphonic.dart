// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/custom.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/handle.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/middlewares.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/pinyin.dart';
import 'package:pinyin_pro_flutter/src/data/dict1.dart';

/// Return type for [polyphonic].
enum PolyphonicReturnType {
  /// List of space-separated pinyin strings, one per character.
  string,

  /// List of lists of pinyin strings.
  array,

  /// List of lists of [PolyphonicAllData] objects.
  all,
}

/// Full info about one reading of a character from [polyphonic].
class PolyphonicAllData {
  final String origin;
  final String pinyin;
  final String initial;
  final String final_;
  final int num;
  final String first;
  final String finalHead;
  final String finalBody;
  final String finalTail;
  final bool isZh;
  final bool inZhRange;

  const PolyphonicAllData({
    required this.origin,
    required this.pinyin,
    required this.initial,
    required this.final_,
    required this.num,
    required this.first,
    required this.finalHead,
    required this.finalBody,
    required this.finalTail,
    required this.isZh,
    required this.inZhRange,
  });
}

/// Options for [polyphonic].
class PolyphonicOptions {
  final PolyphonicReturnType returnType;
  final ToneType toneType;
  final PinyinPattern pattern;
  final NonZhMode nonZh;
  final bool v;
  final InitialPattern? initialPattern;

  const PolyphonicOptions({
    this.returnType = PolyphonicReturnType.string,
    this.toneType = ToneType.symbol,
    this.pattern = PinyinPattern.pinyin,
    this.nonZh = NonZhMode.spaced,
    this.v = false,
    this.initialPattern,
  });
}

/// Returns all possible pinyin readings for each character in [text].
///
/// - [PolyphonicReturnType.string]: `List<String>` of space-joined readings
/// - [PolyphonicReturnType.array]: `List<List<String>>`
/// - [PolyphonicReturnType.all]: `List<List<PolyphonicAllData>>`
///
/// Example:
/// ```dart
/// polyphonic('睡着了', options: PolyphonicOptions(returnType: PolyphonicReturnType.array));
/// // [['shuì'], ['zháo', 'zhāo'], ['le', 'liǎo']]
/// ```
dynamic polyphonic(String text, {PolyphonicOptions options = const PolyphonicOptions()}) {
  if (text.isEmpty) return [];

  var opts = options;
  if (opts.returnType == PolyphonicReturnType.all) {
    opts = PolyphonicOptions(
      returnType: opts.returnType,
      toneType: opts.toneType,
      pattern: PinyinPattern.pinyin,
      nonZh: opts.nonZh,
      v: opts.v,
      initialPattern: opts.initialPattern,
    );
  }
  if (opts.pattern == PinyinPattern.num) {
    opts = PolyphonicOptions(
      returnType: opts.returnType,
      toneType: ToneType.none,
      pattern: opts.pattern,
      nonZh: opts.nonZh,
      v: opts.v,
      initialPattern: opts.initialPattern,
    );
  }

  var list = _getPolyphonicList(text);

  // nonZh
  final pinyinOpts = PinyinOptions(nonZh: opts.nonZh);
  list = middlewareNonZh(list, pinyinOpts);

  var doubleList = _getSplittedPolyphonicList(list);

  final innerOpts = PinyinOptions(
    pattern: opts.pattern,
    toneType: opts.toneType,
    v: opts.v,
    initialPattern: opts.initialPattern,
  );

  for (final inner in doubleList) {
    middlewarePattern(inner, innerOpts);
    middlewareToneType(inner, innerOpts);
    middlewareV(inner, innerOpts);
  }

  return doubleList.map((inner) => _handleType(inner, opts)).toList();
}

List<SingleWordResult> _getPolyphonicList(String text) {
  return splitString(text).map((char) {
    final customDict = getCustomPolyphonicDict();
    final py = customDict.get(char) ?? dict1.get(char) ?? char;
    return SingleWordResult(
      origin: char,
      result: py,
      isZh: py != char,
      originPinyin: py,
    );
  }).toList();
}

List<List<SingleWordResult>> _getSplittedPolyphonicList(
    List<SingleWordResult> list) {
  return list.map((item) {
    if (item.isZh) {
      return item.result
          .split(' ')
          .map((py) => SingleWordResult(
                origin: item.origin,
                result: py,
                isZh: true,
                originPinyin: py,
              ))
          .toList();
    } else {
      return [item];
    }
  }).toList();
}

dynamic _handleType(List<SingleWordResult> list, PolyphonicOptions options) {
  switch (options.returnType) {
    case PolyphonicReturnType.array:
      return list.map((item) => item.result).toSet().toList();
    case PolyphonicReturnType.all:
      return list.map((item) {
        final py = item.isZh ? item.result : '';
        final (:initial, :final_) =
            getInitialAndFinal(py, options.initialPattern);
        final (:head, :body, :tail) = getFinalParts(py);
        return PolyphonicAllData(
          origin: item.origin,
          pinyin: py,
          initial: initial,
          final_: final_,
          first: getFirstLetter(item.result, item.isZh),
          finalHead: head,
          finalBody: body,
          finalTail: tail,
          num: int.tryParse(getNumOfTone(item.originPinyin)) ?? 0,
          isZh: item.isZh,
          inZhRange: dict1.get(item.origin) != null,
        );
      }).toList();
    case PolyphonicReturnType.string:
      return list.map((item) => item.result).toSet().join(' ');
  }
}
