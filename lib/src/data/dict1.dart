// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/data/dict1_raw.dart';

/// Mutable wrapper around the static [dict1Data] lookup table.
///
/// Supports runtime overrides so that [addDict] and [removeDict] can
/// temporarily change individual character readings.
class FastDict {
  final _overrides = <int, String>{};

  /// Returns the pinyin for [word] (single character only).
  ///
  /// Overrides take priority over the static dictionary. Returns null if
  /// the character is not found.
  String? get(String word) {
    if (word.isEmpty) return null;
    final code = word.codeUnitAt(0);
    if (_overrides.containsKey(code)) return _overrides[code];
    return dict1Data[word];
  }

  /// Adds or replaces the pinyin for single-character [word].
  void set(String word, String pinyin) {
    if (word.isNotEmpty) {
      _overrides[word.codeUnitAt(0)] = pinyin;
    }
  }

  /// Removes the runtime override for [word], restoring the static default.
  void remove(String word) {
    if (word.isNotEmpty) {
      _overrides.remove(word.codeUnitAt(0));
    }
  }
}

/// Global single-character pinyin dictionary.
final FastDict dict1 = FastDict();
