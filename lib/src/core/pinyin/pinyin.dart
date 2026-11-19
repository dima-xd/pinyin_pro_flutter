// ignore_for_file: lines_longer_than_80_chars
library;

import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/handle.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/middlewares.dart';

/// Fine-grained control over tone sandhi (变调).
///
/// Pass an instance as [PinyinOptions.toneSandhi] to control each rule
/// independently. A plain `bool` keeps the legacy behaviour: `true` enables
/// only 一/不 sandhi, `false` disables all sandhi.
///
/// Example:
/// ```dart
/// pinyin('你好', options: PinyinOptions(
///   toneSandhi: ToneSandhiOptions(thirdTone: true),
/// )); // 'ní hǎo'
/// ```
class ToneSandhiOptions {
  /// Whether to apply tone sandhi for 一. Defaults to true.
  final bool yi;

  /// Whether to apply tone sandhi for 不. Defaults to true.
  final bool bu;

  /// Whether to turn the first of exactly two consecutive third tones into
  /// the second tone (e.g. 你好 → ní hǎo). Defaults to false.
  final bool thirdTone;

  const ToneSandhiOptions({
    this.yi = true,
    this.bu = true,
    this.thirdTone = false,
  });
}

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

  /// Tone sandhi (变调) control. Defaults to `true`.
  ///
  /// - `true`: apply 一/不 sandhi only (legacy behaviour).
  /// - `false`: disable all sandhi.
  /// - [ToneSandhiOptions]: control 一, 不, and consecutive third tones
  ///   independently.
  final Object? toneSandhi;

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
    Object? toneSandhi,
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

  final zhChars = splitString(word);
  final listBuffer = List<SingleWordResult?>.filled(zhChars.length, null);

  var (:list, :matches) = getPinyin(
    word,
    listBuffer,
    opts.surname,
    opts.segmentit,
    traditional: opts.traditional,
    zhChars: zhChars,
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

/// Converts [word] to a pinyin [String] joined by
/// [PinyinOptions.separator] (a space by default).
///
/// Always uses [PinyinReturnType.string], regardless of
/// `options.returnType`.
///
/// ```dart
/// pinyinString('汉语拼音'); // 'hàn yǔ pīn yīn'
/// ```
String pinyinString(String word,
    {PinyinOptions options = const PinyinOptions()}) {
  return pinyin(
    word,
    options: options.copyWith(returnType: PinyinReturnType.string),
  ) as String;
}

/// Converts [word] to a list of pinyin syllables.
///
/// Always uses [PinyinReturnType.array], regardless of
/// `options.returnType`.
///
/// ```dart
/// pinyinArray('汉语'); // ['hàn', 'yǔ']
/// ```
List<String> pinyinArray(String word,
    {PinyinOptions options = const PinyinOptions()}) {
  return (pinyin(
    word,
    options: options.copyWith(returnType: PinyinReturnType.array),
  ) as List)
      .cast<String>();
}

/// Converts [word] to a list of [PinyinAllData] objects.
///
/// Always uses [PinyinReturnType.all], regardless of
/// `options.returnType`.
///
/// ```dart
/// pinyinAll('汉').first.pinyin; // 'hàn'
/// ```
List<PinyinAllData> pinyinAll(String word,
    {PinyinOptions options = const PinyinOptions()}) {
  return (pinyin(
    word,
    options: options.copyWith(returnType: PinyinReturnType.all),
  ) as List)
      .cast<PinyinAllData>();
}
