// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/core/pinyin/handle.dart';

/// Format for [convertPinyin].
enum ConvertFormat {
  /// Numeric tone → symbol tone: pin1 → pīn (default).
  numToSymbol,

  /// Symbol tone → numeric tone: pīn → pin1.
  symbolToNum,

  /// Remove all tones: pīn → pin.
  toneNone,
}

const _toneMap = {
  'a': ['a', 'ā', 'á', 'ǎ', 'à'],
  'o': ['o', 'ō', 'ó', 'ǒ', 'ò'],
  'e': ['e', 'ē', 'é', 'ě', 'è'],
  'ü': ['ü', 'ǖ', 'ǘ', 'ǚ', 'ǜ'],
  'v': ['ü', 'ǖ', 'ǘ', 'ǚ', 'ǜ'],
  'ui': ['ui', 'uī', 'uí', 'uǐ', 'uì'],
  'iu': ['iu', 'iū', 'iú', 'iǔ', 'iù'],
  'i': ['i', 'ī', 'í', 'ǐ', 'ì'],
  'u': ['u', 'ū', 'ú', 'ǔ', 'ù'],
  'n': ['n', 'n̄', 'ń', 'ň', 'ǹ'],
  'm': ['m', 'm̄', 'ḿ', 'm̌', 'm̀'],
  'ê': ['ê', 'ê̄', 'ế', 'ê̌', 'ề'],
};

/// Converts pinyin format between numeric-tone, symbol-tone, and no-tone.
///
/// [input] may be a [String] or `List<String>`.
/// Returns the same type as [input].
///
/// Example:
/// ```dart
/// convertPinyin('pin1 yin1'); // 'pīn yīn'
/// convertPinyin('pīn yīn', format: ConvertFormat.symbolToNum); // 'pin1 yin1'
/// convertPinyin('pīn yīn', format: ConvertFormat.toneNone); // 'pin yin'
/// ```
dynamic convertPinyin(
  dynamic input, {
  String separator = ' ',
  ConvertFormat format = ConvertFormat.numToSymbol,
}) {
  final isString = input is String;
  final List<String> parts = isString
      ? input.split(separator)
      : List<String>.from(input as List);

  final converted = parts.map((item) {
    switch (format) {
      case ConvertFormat.numToSymbol:
        return _formatNumToSymbol(item);
      case ConvertFormat.symbolToNum:
        return _formatSymbolToNum(item);
      case ConvertFormat.toneNone:
        return getPinyinWithoutTone(item);
    }
  }).toList();

  return isString ? converted.join(separator) : converted;
}

String _formatNumToSymbol(String pinyin) {
  // Handle erhua: dian3r → diǎnr
  var suffixR = '';
  var p = pinyin;
  if (p.length > 2 && p.endsWith('r')) {
    final secondToLast = int.tryParse(p[p.length - 2]);
    if (secondToLast != null && secondToLast >= 0 && secondToLast <= 4) {
      suffixR = 'r';
      p = p.substring(0, p.length - 1);
    }
  }

  final lastChar = int.tryParse(p.isNotEmpty ? p[p.length - 1] : '');
  if (lastChar != null && lastChar >= 0 && lastChar <= 4) {
    final base = p.substring(0, p.length - 1);
    for (final entry in _toneMap.entries) {
      if (base.contains(entry.key)) {
        return base.replaceFirst(
              entry.key, entry.value[lastChar]) +
            suffixR;
      }
    }
    return p + suffixR;
  }
  return p + suffixR;
}

String _formatSymbolToNum(String pinyin) {
  // Handle erhua: diǎnr → dian3r
  final erhuaReg = RegExp(r'^[eēéěè]r$');
  if (pinyin.endsWith('r') &&
      pinyin.length > 1 &&
      !erhuaReg.hasMatch(pinyin)) {
    final withoutR = pinyin.substring(0, pinyin.length - 1);
    final toneNum = getNumOfTone(withoutR);
    if (toneNum.isNotEmpty && toneNum != '0') {
      return '${getPinyinWithoutTone(withoutR)}${toneNum}r';
    }
  }
  return '${getPinyinWithoutTone(pinyin)}${getNumOfTone(pinyin)}';
}
