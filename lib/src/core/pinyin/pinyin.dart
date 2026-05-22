// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/handle.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/middlewares.dart';

/// Configuration for the [pinyin] function.
class PinyinOptions {
  /// Tone display format. Defaults to [ToneType.symbol].
  final ToneType toneType;

  /// Which phonetic component to return. Defaults to [PinyinPattern.pinyin].
  final PinyinPattern pattern;

  /// Return format. Defaults to [PinyinReturnType.string].
  final PinyinReturnType returnType;

  /// Separator between syllables when [returnType] is string.
  final String separator;

  /// If true and input is a single character, return all readings.
  final bool multiple;

  /// Surname matching mode.
  final SurnameMode surname;

  /// Whether to apply tone sandhi (变调) for 一 and 不. Defaults to true.
  final bool toneSandhi;

  /// How to handle non-Chinese characters.
  final NonZhMode nonZh;

  /// Regex scope for [nonZh] processing.
  final RegExp? nonZhScope;

  /// Replace ü with v when tone is none.
  final bool v;

  /// Custom replacement character for ü (when [v] is true).
  final String? vChar;

  /// How y/w are treated as initials.
  final InitialPattern? initialPattern;

  /// Enable traditional character recognition.
  final bool traditional;

  /// Tokenization algorithm.
  final TokenizationAlgorithm segmentit;

  const PinyinOptions({
    this.toneType = ToneType.symbol,
    this.pattern = PinyinPattern.pinyin,
    this.returnType = PinyinReturnType.string,
    this.separator = ' ',
    this.multiple = false,
    this.surname = SurnameMode.off,
    this.toneSandhi = true,
    this.nonZh = NonZhMode.spaced,
    this.nonZhScope,
    this.v = false,
    this.vChar,
    this.initialPattern,
    this.traditional = false,
    this.segmentit = TokenizationAlgorithm.maxProbability,
  });

  PinyinOptions copyWith({
    ToneType? toneType,
    PinyinPattern? pattern,
    PinyinReturnType? returnType,
    String? separator,
    bool? multiple,
    SurnameMode? surname,
    bool? toneSandhi,
    NonZhMode? nonZh,
    RegExp? nonZhScope,
    bool? v,
    String? vChar,
    InitialPattern? initialPattern,
    bool? traditional,
    TokenizationAlgorithm? segmentit,
  }) {
    return PinyinOptions(
      toneType: toneType ?? this.toneType,
      pattern: pattern ?? this.pattern,
      returnType: returnType ?? this.returnType,
      separator: separator ?? this.separator,
      multiple: multiple ?? this.multiple,
      surname: surname ?? this.surname,
      toneSandhi: toneSandhi ?? this.toneSandhi,
      nonZh: nonZh ?? this.nonZh,
      nonZhScope: nonZhScope ?? this.nonZhScope,
      v: v ?? this.v,
      vChar: vChar ?? this.vChar,
      initialPattern: initialPattern ?? this.initialPattern,
      traditional: traditional ?? this.traditional,
      segmentit: segmentit ?? this.segmentit,
    );
  }
}

/// Converts a Chinese [word] to its pinyin representation.
///
/// The return type depends on [options.returnType]:
/// - [PinyinReturnType.string]: space-separated [String]
/// - [PinyinReturnType.array]: `List<String>`
/// - [PinyinReturnType.all]: `List<PinyinAllData>`
///
/// Example:
/// ```dart
/// pinyin('汉语拼音'); // 'hàn yǔ pīn yīn'
/// pinyin('汉语', options: PinyinOptions(returnType: PinyinReturnType.array));
/// // ['hàn', 'yǔ']
/// ```
dynamic pinyin(String word, {PinyinOptions options = const PinyinOptions()}) {
  if (word.isEmpty) {
    return switch (options.returnType) {
      PinyinReturnType.string => '',
      _ => <dynamic>[],
    };
  }

  var opts = options;

  // Surname mode shortcut.
  if (opts.surname == SurnameMode.off) {
    // already off — no change
  }

  // type: all forces pattern: pinyin
  if (opts.returnType == PinyinReturnType.all) {
    opts = opts.copyWith(pattern: PinyinPattern.pinyin);
  }

  // pattern: num forces toneType: none
  if (opts.pattern == PinyinPattern.num) {
    opts = opts.copyWith(toneType: ToneType.none);
  }

  final _list = List<SingleWordResult?>.filled(stringLength(word), null);

  var (:list, :matches) = getPinyin(
    word,
    _list,
    opts.surname,
    opts.segmentit,
    traditional: opts.traditional,
  );

  list = middlewareToneSandhi(list, opts.toneSandhi);
  list = middlewareNonZh(list, opts);

  final multipleResult = middlewareMultiple(word, opts);
  if (multipleResult != null) {
    list = multipleResult;
  }

  middlewarePattern(list, opts);
  middlewareToneType(list, opts);
  middlewareV(list, opts);

  return middlewareType(list, opts, word);
}
