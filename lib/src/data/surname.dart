// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/data/surname_raw.dart';

/// Cached single-character surname → pinyin map (lazy init).
Map<String, String>? _surnameCharMap;

/// Returns a map of single-character surnames to their surname readings.
Map<String, String> get surnameCharMap {
  return _surnameCharMap ??= getSurnameCharMap();
}
