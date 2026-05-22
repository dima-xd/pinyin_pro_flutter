// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/data/dict2.dart';
import 'package:pinyin_pro_flutter/src/data/dict3.dart';
import 'package:pinyin_pro_flutter/src/data/dict4.dart';
import 'package:pinyin_pro_flutter/src/data/dict5.dart';
import 'package:pinyin_pro_flutter/src/data/special.dart';
import 'package:pinyin_pro_flutter/src/data/surname_raw.dart';

AcAutomaton? _acTree;

/// Global AC automaton singleton, lazily initialized on first access.
///
/// Builds the trie from all built-in dictionaries:
/// dict5 → dict4 → dict3 → dict2 → PatternNumberDict → Surname patterns.
AcAutomaton get acTree {
  if (_acTree == null) {
    _acTree = AcAutomaton();
    _acTree!.build([
      ...buildDict5Patterns(),
      ...buildDict4Patterns(),
      ...buildDict3Patterns(),
      ...buildDict2Patterns(),
      ...buildPatternNumberDict(),
      ...buildSurnamePatterns(),
    ]);
  }
  return _acTree!;
}
