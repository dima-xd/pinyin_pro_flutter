// ignore_for_file: lines_longer_than_80_chars
library;

import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/handle.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/middlewares.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/pinyin.dart';

/// Output format for [segmentPinyin].
enum OutputFormat {
  /// List of [SegmentItem] (default).
  allSegment,

  /// List of lists of [SegmentItem].
  allArray,

  /// Single [SegmentItem] with separator-joined values.
  allString,

  /// List of result strings (one per segment).
  pinyinSegment,

  /// List of lists of result strings.
  pinyinArray,

  /// Single joined result string.
  pinyinString,

  /// List of origin strings (one per segment).
  zhSegment,

  /// List of lists of origin strings.
  zhArray,

  /// Single joined origin string.
  zhString,
}

/// Options for [segmentPinyin].
class SegmentOptions {
  final ToneType toneType;
  final SurnameMode surname;
  final NonZhMode nonZh;
  final bool v;
  final String separator;
  final bool toneSandhi;
  final TokenizationAlgorithm segmentit;
  final OutputFormat format;
  final bool traditional;

  const SegmentOptions({
    this.toneType = ToneType.symbol,
    this.surname = SurnameMode.off,
    this.nonZh = NonZhMode.spaced,
    this.v = false,
    this.separator = ' ',
    this.toneSandhi = true,
    this.segmentit = TokenizationAlgorithm.maxProbability,
    this.format = OutputFormat.allSegment,
    this.traditional = false,
  });

  SegmentOptions copyWith({
    ToneType? toneType,
    SurnameMode? surname,
    NonZhMode? nonZh,
    bool? v,
    String? separator,
    bool? toneSandhi,
    TokenizationAlgorithm? segmentit,
    OutputFormat? format,
    bool? traditional,
  }) {
    return SegmentOptions(
      toneType: toneType ?? this.toneType,
      surname: surname ?? this.surname,
      nonZh: nonZh ?? this.nonZh,
      v: v ?? this.v,
      separator: separator ?? this.separator,
      toneSandhi: toneSandhi ?? this.toneSandhi,
      segmentit: segmentit ?? this.segmentit,
      format: format ?? this.format,
      traditional: traditional ?? this.traditional,
    );
  }
}

class _OriginSegment {
  final List<({String origin, String result})> items;
  final bool isZh;

  _OriginSegment({required this.items, required this.isZh});
}

/// Converts [word] to pinyin with word segmentation.
///
/// Returns type depends on [options.format]:
/// - [OutputFormat.allSegment]: `List<SegmentItem>`
/// - [OutputFormat.allArray]: `List<List<SegmentItem>>`
/// - [OutputFormat.allString]: `SegmentItem`
/// - [OutputFormat.pinyinSegment]: `List<String>`
/// - [OutputFormat.pinyinArray]: `List<List<String>>`
/// - [OutputFormat.pinyinString]: `String`
/// - [OutputFormat.zhSegment]: `List<String>`
/// - [OutputFormat.zhArray]: `List<List<String>>`
/// - [OutputFormat.zhString]: `String`
///
/// Example:
/// ```dart
/// segmentPinyin('我是中国人',
///     options: SegmentOptions(format: OutputFormat.pinyinArray));
/// ```
dynamic segmentPinyin(String word, {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return word;

  final surname = options.surname;
  final listBuffer = List<SingleWordResult?>.filled(stringLength(word), null);

  var (:list, :matches) = getPinyin(
    word,
    listBuffer,
    surname,
    options.segmentit,
    traditional: options.traditional,
  );

  list = middlewareToneSandhi(list, options.toneSandhi);

  final pinyinOpts = PinyinOptions(
    nonZh: options.nonZh,
    toneType: options.toneType,
    v: options.v,
  );
  list = middlewareNonZh(list, pinyinOpts);
  middlewareToneType(list, pinyinOpts);
  middlewareV(list, pinyinOpts);

  final segments = _middlewareSegment(list, matches);
  return _middlewareOutputFormat(segments, options);
}

List<_OriginSegment> _middlewareSegment(
    List<SingleWordResult> list, List<dynamic> matches) {
  final segments = <_OriginSegment>[];
  var i = 0;
  var j = 0;

  while (i < list.length && j < matches.length) {
    final match = matches[j];
    final item = list[i];

    if (match.zh.startsWith(item.origin)) {
      final start = i;
      final chars = splitString(match.zh as String);
      var cur = start + 1;
      while (cur < list.length &&
          cur - start < chars.length &&
          list[cur].origin == chars[cur - start]) {
        cur++;
      }
      final slice = list.sublist(start, cur);
      segments.add(_OriginSegment(
        items: slice
            .map((s) => (origin: s.origin, result: s.result))
            .toList(),
        isZh: true,
      ));
      i += cur - start;
      j++;
    } else {
      segments.add(_OriginSegment(
        items: [(origin: item.origin, result: item.result)],
        isZh: false,
      ));
      i++;
    }
  }

  while (i < list.length) {
    final item = list[i];
    segments.add(_OriginSegment(
      items: [(origin: item.origin, result: item.result)],
      isZh: false,
    ));
    i++;
  }

  return segments;
}

dynamic _middlewareOutputFormat(
    List<_OriginSegment> segments, SegmentOptions options) {
  final sep = options.separator;
  switch (options.format) {
    case OutputFormat.allSegment:
      return segments
          .map((s) => SegmentItem(
                origin: s.items.map((i) => i.origin).join(),
                result: s.items.map((i) => i.result).join(),
              ))
          .toList();

    case OutputFormat.allArray:
      return segments
          .map((s) => s.items
              .map((i) => SegmentItem(origin: i.origin, result: i.result))
              .toList())
          .toList();

    case OutputFormat.allString:
      final flat = segments.map((s) => SegmentItem(
            origin: s.items.map((i) => i.origin).join(),
            result: s.items.map((i) => i.result).join(),
          ));
      return SegmentItem(
        origin: flat.map((s) => s.origin).join(sep),
        result: flat.map((s) => s.result).join(sep),
      );

    case OutputFormat.pinyinSegment:
      return segments
          .map((s) => s.items.map((i) => i.result).join())
          .toList();

    case OutputFormat.pinyinArray:
      return segments
          .map((s) => s.items.map((i) => i.result).toList())
          .toList();

    case OutputFormat.pinyinString:
      return segments
          .map((s) => s.items.map((i) => i.result).join())
          .join(sep);

    case OutputFormat.zhSegment:
      return segments
          .map((s) => s.items.map((i) => i.origin).join())
          .toList();

    case OutputFormat.zhArray:
      return segments
          .map((s) => s.items.map((i) => i.origin).toList())
          .toList();

    case OutputFormat.zhString:
      return segments
          .map((s) => s.items.map((i) => i.origin).join())
          .join(sep);
  }
}

/// Segments [word] and returns one [SegmentItem] per segment.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.allSegment].
List<SegmentItem> segmentAllSegment(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return <SegmentItem>[];
  return (segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.allSegment),
  ) as List)
      .cast<SegmentItem>();
}

/// Segments [word] and returns nested [SegmentItem] lists.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.allArray].
List<List<SegmentItem>> segmentAllArray(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return <List<SegmentItem>>[];
  return (segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.allArray),
  ) as List)
      .map((inner) => List<SegmentItem>.from(inner as List))
      .toList();
}

/// Segments [word] and returns a single [SegmentItem].
///
/// Equivalent to [segmentPinyin] with [OutputFormat.allString].
SegmentItem segmentAllString(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return const SegmentItem(origin: '', result: '');
  return segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.allString),
  ) as SegmentItem;
}

/// Segments [word] and returns pinyin for each segment.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.pinyinSegment].
List<String> segmentPinyinSegment(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return <String>[];
  return (segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.pinyinSegment),
  ) as List)
      .cast<String>();
}

/// Segments [word] and returns nested pinyin lists.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.pinyinArray].
List<List<String>> segmentPinyinArray(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return <List<String>>[];
  return (segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.pinyinArray),
  ) as List)
      .map((inner) => List<String>.from(inner as List))
      .toList();
}

/// Segments [word] and returns a single pinyin string joined by
/// [SegmentOptions.separator] (a space by default).
///
/// Equivalent to [segmentPinyin] with [OutputFormat.pinyinString].
String segmentPinyinString(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  return segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.pinyinString),
  ) as String;
}

/// Segments [word] and returns the original text of each segment.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.zhSegment].
List<String> segmentZhSegment(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return <String>[];
  return (segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.zhSegment),
  ) as List)
      .cast<String>();
}

/// Segments [word] and returns nested original-text lists.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.zhArray].
List<List<String>> segmentZhArray(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  if (word.isEmpty) return <List<String>>[];
  return (segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.zhArray),
  ) as List)
      .map((inner) => List<String>.from(inner as List))
      .toList();
}

/// Segments [word] and returns the original text as a single string.
///
/// Equivalent to [segmentPinyin] with [OutputFormat.zhString].
String segmentZhString(String word,
    {SegmentOptions options = const SegmentOptions()}) {
  return segmentPinyin(
    word,
    options: options.copyWith(format: OutputFormat.zhString),
  ) as String;
}
