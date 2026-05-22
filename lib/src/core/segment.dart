// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

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
  final _list = List<SingleWordResult?>.filled(stringLength(word), null);

  var (:list, :matches) = getPinyin(
    word,
    _list,
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
