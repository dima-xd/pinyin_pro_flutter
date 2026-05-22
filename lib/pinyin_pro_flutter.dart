/// A professional Chinese pinyin conversion library for Flutter/Dart.
///
/// Ported from the TypeScript [pinyin-pro](https://github.com/zh-lx/pinyin-pro)
/// library (v3.28.x).
///
/// ## Quick start
///
/// ```dart
/// import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';
///
/// // Basic conversion
/// pinyin('汉语拼音'); // 'hàn yǔ pīn yīn'
///
/// // Array output
/// pinyin('汉语', options: PinyinOptions(returnType: PinyinReturnType.array));
/// // ['hàn', 'yǔ']
///
/// // Text-pinyin matching
/// matchPinyin('中文拼音', 'zwp'); // [0, 1, 2]
///
/// // HTML ruby markup
/// htmlPinyin('汉字'); // '<span class="py-result-item">...'
/// ```
library pinyin_pro_flutter;

// Types
export 'src/common/types.dart'
    show
        ToneType,
        PinyinPattern,
        InitialPattern,
        PinyinMode,
        SurnameMode,
        NonZhMode,
        PinyinReturnType,
        PinyinAllData,
        SingleWordResult,
        SegmentItem;

// Segmentit
export 'src/common/segmentit/ac_automaton.dart' show TokenizationAlgorithm;

// Core API
export 'src/core/pinyin/pinyin.dart' show PinyinOptions, pinyin;
export 'src/core/pinyin/handle.dart'
    show
        getInitialAndFinal,
        getFinalParts,
        getNumOfTone,
        getPinyinWithoutTone,
        getAllPinyin,
        getSingleWordPinyin;
export 'src/core/match.dart' show MatchOptions, MatchPrecision, MatchSpace, matchPinyin;
export 'src/core/convert.dart' show ConvertFormat, convertPinyin;
export 'src/core/html.dart' show HtmlOptions, htmlPinyin;
export 'src/core/polyphonic.dart'
    show
        PolyphonicReturnType,
        PolyphonicAllData,
        PolyphonicOptions,
        polyphonic;
export 'src/core/custom.dart'
    show CustomHandleType, CustomPinyinOptions, CustomDictType, customPinyin, clearCustomDict;
export 'src/core/dict.dart' show DictHandleType, DictOptions, addDict, removeDict;
export 'src/core/segment.dart' show OutputFormat, SegmentOptions, segmentPinyin;
export 'src/core/traditional.dart' show addTraditionalDict, getTraditionalDict;
