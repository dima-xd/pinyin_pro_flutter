// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/pinyin.dart';

/// Options for [htmlPinyin].
class HtmlOptions {
  /// CSS class for the outer span of each character+pinyin pair.
  final String resultClass;

  /// CSS class for the pinyin `<rt>` tag.
  final String pinyinClass;

  /// CSS class for the Chinese character span.
  final String chineseClass;

  /// CSS class for non-Chinese character spans (only when [wrapNonChinese]).
  final String nonChineseClass;

  /// Whether to wrap non-Chinese chars in a span tag.
  final bool wrapNonChinese;

  /// Additional CSS classes for specific characters.
  /// Key = class name, value = list of characters that get this class.
  final Map<String, List<String>> customClassMap;

  /// Whether to include `<rp>(</rp>` tags. Defaults to true.
  final bool rp;

  final ToneType toneType;
  final bool toneSandhi;
  final SurnameMode surname;
  final bool traditional;
  final bool v;
  final TokenizationAlgorithm segmentit;

  const HtmlOptions({
    this.resultClass = 'py-result-item',
    this.chineseClass = 'py-chinese-item',
    this.pinyinClass = 'py-pinyin-item',
    this.nonChineseClass = 'py-non-chinese-item',
    this.wrapNonChinese = false,
    this.customClassMap = const {},
    this.rp = true,
    this.toneType = ToneType.symbol,
    this.toneSandhi = true,
    this.surname = SurnameMode.off,
    this.traditional = false,
    this.v = false,
    this.segmentit = TokenizationAlgorithm.maxProbability,
  });
}

/// Generates an HTML string with ruby annotations (pinyin over Chinese chars).
///
/// Example:
/// ```dart
/// htmlPinyin('汉字');
/// // '<span class="py-result-item"><ruby>...'
/// ```
String htmlPinyin(String text, {HtmlOptions options = const HtmlOptions()}) {
  final pinyinArray = (pinyin(
    text,
    options: PinyinOptions(
      returnType: PinyinReturnType.all,
      toneType: options.toneType,
      toneSandhi: options.toneSandhi,
      surname: options.surname,
      traditional: options.traditional,
      v: options.v,
      segmentit: options.segmentit,
    ),
  ) as List)
      .cast<PinyinAllData>();

  final buffer = StringBuffer();
  for (final item in pinyinArray) {
    var additionalClass = '';
    options.customClassMap.forEach((classname, chars) {
      if (chars.contains(item.origin)) {
        additionalClass += ' $classname';
      }
    });

    if (item.isZh) {
      final rp = options.rp ? '<rp>(</rp>' : '';
      final rpc = options.rp ? '<rp>)</rp>' : '';
      buffer.write(
        '<span class="${options.resultClass}$additionalClass">'
        '<ruby>'
        '<span class="${options.chineseClass}">${item.origin}</span>'
        '$rp'
        '<rt class="${options.pinyinClass}">${item.pinyin}</rt>'
        '$rpc'
        '</ruby>'
        '</span>',
      );
    } else {
      if (options.wrapNonChinese) {
        buffer.write(
          '<span class="${options.nonChineseClass}$additionalClass">'
          '${item.origin}'
          '</span>',
        );
      } else {
        buffer.write(item.origin);
      }
    }
  }
  return buffer.toString();
}
