// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/data/ac_tree.dart';
import 'package:pinyin_pro_flutter/src/data/dict1.dart';

const _defaultDictName = '_default';

/// Value formats for [addDict] entries.
///
/// Supported forms per word:
/// - `String` — just the pinyin
/// - `[String]` — [pinyin]
/// - `[String, double]` — [pinyin, probability]
/// - `[String, double, String]` — [pinyin, probability, pos]
typedef DictValue = dynamic;

/// Options for [addDict].
class DictOptions {
  /// Name for this dictionary (used with [removeDict]).
  final String? name;

  /// How to handle single-char entries that already exist in dict1.
  final DictHandleType dict1;

  const DictOptions({this.name, this.dict1 = DictHandleType.add});
}

/// How to handle single-character dict1 entries.
enum DictHandleType {
  /// Append the new pinyin to existing readings.
  add,

  /// Replace existing readings.
  replace,

  /// Don't modify dict1.
  ignore,
}

final _originDictMap = <String, Map<String, String>>{};

/// Adds a custom dictionary to the AC automaton.
///
/// [dict] maps words to their pinyin (see [DictValue] for supported formats).
/// [options] controls naming and dict1 handling.
///
/// Example:
/// ```dart
/// addDict({'术语': ['shù yǔ', 2e-5]}, options: DictOptions(name: 'custom'));
/// ```
void addDict(Map<String, DictValue> dict, {DictOptions? options}) {
  final dictName = options?.name ?? _defaultDictName;
  final dict1Handle = options?.dict1 ?? DictHandleType.add;
  final patterns = <Pattern>[];

  dict.forEach((word, value) {
    final String py;
    final double? prob;
    final String? pos;

    if (value is String) {
      py = value;
      prob = null;
      pos = null;
    } else if (value is List) {
      py = value[0] as String;
      prob = value.length > 1 ? (value[1] as num).toDouble() : null;
      pos = value.length > 2 ? value[2] as String : null;
    } else {
      return;
    }

    final wordLength = stringLength(word);
    if (wordLength == 1 && dict1Handle != DictHandleType.ignore) {
      _addToOriginDict(dictName, word, py, dict1Handle);
    }

    patterns.add(Pattern(
      zh: word,
      pinyin: py,
      probability: prob ?? (kProbabilityDict * wordLength * wordLength),
      length: wordLength,
      priority: kPriorityNormal,
      dict: dictName,
      pos: pos,
    ));
  });

  acTree.build(patterns);
}

/// Removes the dictionary named [dictName] from the AC automaton.
///
/// If [dictName] is null, removes the default dictionary.
void removeDict([String? dictName]) {
  final name = dictName ?? _defaultDictName;
  acTree.removeDict(name);
  _removeOriginDict(name);
}

void _addToOriginDict(
    String dict, String char, String py, DictHandleType handle) {
  _originDictMap.putIfAbsent(dict, () => {});
  final originDict = _originDictMap[dict]!;
  originDict.putIfAbsent(char, () => dict1.get(char) ?? '');

  if (handle == DictHandleType.add) {
    final existing = dict1.get(char);
    if (existing != null && !existing.split(' ').contains(py)) {
      dict1.set(char, '$existing $py');
    } else if (existing == null) {
      dict1.set(char, py);
    }
  } else if (handle == DictHandleType.replace) {
    dict1.set(char, py);
  }
}

void _removeOriginDict(String dict) {
  final originDict = _originDictMap[dict];
  if (originDict == null) return;
  originDict.forEach((char, py) {
    if (py.isEmpty) {
      dict1.remove(char);
    } else {
      dict1.set(char, py);
    }
  });
  originDict.clear();
}
