// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/data/ac_tree.dart';
import 'package:pinyin_pro_flutter/src/data/dict1.dart';

const _customDictName = 'custom';

final _customDict = <String, String>{};
final _customMultipleDict = _FastDict();
final _customPolyphonicDict = _FastDict();

/// Lightweight dictionary that uses a List index for single-codeunit keys
/// and a Map for multi-character keys.
class _FastDict {
  final _byCode = <int, String>{};
  final _byWord = <String, String>{};

  String? get(String word) {
    if (word.length == 1) {
      return _byCode[word.codeUnitAt(0)];
    }
    return _byWord[word];
  }

  void set(String word, String pinyin) {
    if (word.length == 1) {
      _byCode[word.codeUnitAt(0)] = pinyin;
    } else {
      _byWord[word] = pinyin;
    }
  }

  void clear() {
    _byCode.clear();
    _byWord.clear();
  }
}

/// Options for [customPinyin].
class CustomPinyinOptions {
  /// How custom entries are applied to the multiple-readings dict.
  final CustomHandleType? multiple;

  /// How custom entries are applied to the polyphonic dict.
  final CustomHandleType? polyphonic;

  const CustomPinyinOptions({this.multiple, this.polyphonic});
}

/// Whether to add to or replace the existing dict entry.
enum CustomHandleType {
  add,
  replace,
}

/// Registers custom pinyin mappings.
///
/// [config] maps words/characters to space-separated pinyin strings.
///
/// Example:
/// ```dart
/// customPinyin({'燕': 'yān'});
/// customPinyin({'你好': 'nǐ hǎo'});
/// ```
void customPinyin(
  Map<String, String> config, {
  CustomPinyinOptions? options,
}) {
  final words = config.keys.toList()
    ..sort((a, b) => stringLength(b) - stringLength(a));

  for (final word in words) {
    _customDict[word] = config[word]!;
  }

  final patterns = _customDict.entries.map((e) => Pattern(
        zh: e.key,
        pinyin: e.value,
        probability: kProbabilityCustom + stringLength(e.key),
        length: stringLength(e.key),
        priority: kPriorityCustom,
        dict: _customDictName,
      )).toList();
  acTree.build(patterns);

  if (options?.multiple != null) {
    _addCustomConfigToDict(config, _customMultipleDict, options!.multiple!);
  }
  if (options?.polyphonic != null) {
    _addCustomConfigToDict(config, _customPolyphonicDict, options!.polyphonic!);
  }
}

void _addCustomConfigToDict(
  Map<String, String> config,
  _FastDict target,
  CustomHandleType handleType,
) {
  config.forEach((word, pinyins) {
    final chars = splitString(word);
    final pinyinParts = pinyins.split(' ');
    for (var i = 0; i < chars.length; i++) {
      final char = chars[i];
      final py = i < pinyinParts.length ? pinyinParts[i] : '';
      if (handleType == CustomHandleType.replace ||
          (handleType == CustomHandleType.add &&
              target.get(char) == null &&
              dict1.get(char) == null)) {
        target.set(char, py);
      } else {
        final existing = target.get(char) ?? dict1.get(char) ?? '';
        if (!existing.split(' ').contains(py)) {
          target.set(char, '$existing $py'.trim());
        }
      }
    }
  });
}

/// Dict type identifiers for [clearCustomDict].
enum CustomDictType { pinyin, multiple, polyphonic }

/// Clears the specified custom dict(s).
///
/// [dict] can be a single [CustomDictType] or a list of them.
void clearCustomDict(dynamic dict) {
  final types = dict is List
      ? List<CustomDictType>.from(dict)
      : [dict as CustomDictType];

  if (types.contains(CustomDictType.pinyin)) {
    _customDict.clear();
    acTree.removeDict(_customDictName);
  }
  if (types.contains(CustomDictType.multiple)) {
    _customMultipleDict.clear();
  }
  if (types.contains(CustomDictType.polyphonic)) {
    _customPolyphonicDict.clear();
  }
}

/// Returns the custom multiple-readings dictionary.
_FastDict getCustomMultipleDict() => _customMultipleDict;

/// Returns the custom polyphonic dictionary.
_FastDict getCustomPolyphonicDict() => _customPolyphonicDict;
