// AUTO-GENERATED - do not edit manually.
// Source: pinyin-pro/lib/data/special.ts
// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

/// Ordered list of pinyin initials (声母).
const List<String> kInitialList = [
  'zh',
  'ch',
  'sh',
  'z',
  'c',
  's',
  'b',
  'p',
  'm',
  'f',
  'd',
  't',
  'n',
  'l',
  'g',
  'k',
  'h',
  'j',
  'q',
  'x',
  'r',
  'y',
  'w',
  '',
];

/// Initials that require special ü handling (j, q, x).
const List<String> kSpecialInitialList = ['j', 'q', 'x'];

/// Finals that are remapped when preceded by j/q/x.
const List<String> kSpecialFinalList = [
  'uān',
  'uán',
  'uǎn',
  'uàn',
  'uan',
  'uē',
  'ué',
  'uě',
  'uè',
  'ue',
  'ūn',
  'ún',
  'ǔn',
  'ùn',
  'un',
  'ū',
  'ú',
  'ǔ',
  'ù',
  'u',
];

/// Map of finals to their ü equivalents after j/q/x.
const Map<String, String> kSpecialFinalMap = {
  'uān': 'üān',
  'uán': 'üán',
  'uǎn': 'üǎn',
  'uàn': 'üàn',
  'uan': 'üan',
  'uē': 'üē',
  'ué': 'üé',
  'uě': 'üě',
  'uè': 'üè',
  'ue': 'üe',
  'ūn': 'ǖn',
  'ún': 'ǘn',
  'ǔn': 'ǚn',
  'ùn': 'ǜn',
  'un': 'ün',
  'ū': 'ǖ',
  'ú': 'ǘ',
  'ǔ': 'ǚ',
  'ù': 'ǜ',
  'u': 'ü',
};

/// Finals that have a head (介音).
const List<String> kDoubleFinalList = [
  'ia',
  'ian',
  'iang',
  'iao',
  'ie',
  'iu',
  'iong',
  'ua',
  'uai',
  'uan',
  'uang',
  'ue',
  'ui',
  'uo',
  'üan',
  'üe',
  'van',
  've',
];

/// Characters that undergo tone sandhi (变调): 一, 不.
const List<String> kToneSandhiList = ['不', '一'];

/// Characters that are excluded from tone sandhi when they appear as suffix.
const Map<String, List<String>> kToneSandhiIgnoreSuffix = {
  '不': ['的', '而', '之', '后', '也', '还', '地'],
  '一': ['的', '而', '之', '后', '也', '还', '是'],
};

/// Tone sandhi mapping: character → {pinyin: [tones that trigger it]}.
const Map<String, Map<String, List<int>>> kToneSandhiMap = {
  '不': {
    'bú': [4],
  },
  '一': {
    'yí': [4],
    'yì': [1, 2, 3],
  },
};

/// Patterns for special number/symbol characters.
class PatternEntry {
  final String zh;
  final String pinyin;
  const PatternEntry({required this.zh, required this.pinyin});
}

// Number + word combinations for tone-sandhi disambiguation.
// Ported from genNumberDict() in special.ts.
const List<PatternEntry> _kPatternNumberDictEntries = [
  // Special fixed entries
  PatternEntry(zh: '零一', pinyin: 'líng yī'),
  PatternEntry(zh: '〇一', pinyin: 'líng yī'),
  PatternEntry(zh: '十一', pinyin: 'shí yī'),
  PatternEntry(zh: '一十', pinyin: 'yī shí'),
  PatternEntry(zh: '第一', pinyin: 'dì yī'),
  PatternEntry(zh: '一十一', pinyin: 'yī shí yī'),
  // 一 + word
  PatternEntry(zh: '一重', pinyin: 'yì chóng'),
  PatternEntry(zh: '一行', pinyin: 'yì háng'),
  PatternEntry(zh: '一斗', pinyin: 'yì dǒu'),
  PatternEntry(zh: '一更', pinyin: 'yì gēng'),
  // 二 + word
  PatternEntry(zh: '二重', pinyin: 'èr chóng'),
  PatternEntry(zh: '二行', pinyin: 'èr háng'),
  PatternEntry(zh: '二斗', pinyin: 'èr dǒu'),
  PatternEntry(zh: '二更', pinyin: 'èr gēng'),
  // 三 + word
  PatternEntry(zh: '三重', pinyin: 'sān chóng'),
  PatternEntry(zh: '三行', pinyin: 'sān háng'),
  PatternEntry(zh: '三斗', pinyin: 'sān dǒu'),
  PatternEntry(zh: '三更', pinyin: 'sān gēng'),
  // 四 + word
  PatternEntry(zh: '四重', pinyin: 'sì chóng'),
  PatternEntry(zh: '四行', pinyin: 'sì háng'),
  PatternEntry(zh: '四斗', pinyin: 'sì dǒu'),
  PatternEntry(zh: '四更', pinyin: 'sì gēng'),
  // 五 + word
  PatternEntry(zh: '五重', pinyin: 'wǔ chóng'),
  PatternEntry(zh: '五行', pinyin: 'wǔ háng'),
  PatternEntry(zh: '五斗', pinyin: 'wǔ dǒu'),
  PatternEntry(zh: '五更', pinyin: 'wǔ gēng'),
  // 六 + word
  PatternEntry(zh: '六重', pinyin: 'liù chóng'),
  PatternEntry(zh: '六行', pinyin: 'liù háng'),
  PatternEntry(zh: '六斗', pinyin: 'liù dǒu'),
  PatternEntry(zh: '六更', pinyin: 'liù gēng'),
  // 七 + word
  PatternEntry(zh: '七重', pinyin: 'qī chóng'),
  PatternEntry(zh: '七行', pinyin: 'qī háng'),
  PatternEntry(zh: '七斗', pinyin: 'qī dǒu'),
  PatternEntry(zh: '七更', pinyin: 'qī gēng'),
  // 八 + word
  PatternEntry(zh: '八重', pinyin: 'bā chóng'),
  PatternEntry(zh: '八行', pinyin: 'bā háng'),
  PatternEntry(zh: '八斗', pinyin: 'bā dǒu'),
  PatternEntry(zh: '八更', pinyin: 'bā gēng'),
  // 九 + word
  PatternEntry(zh: '九重', pinyin: 'jiǔ chóng'),
  PatternEntry(zh: '九行', pinyin: 'jiǔ háng'),
  PatternEntry(zh: '九斗', pinyin: 'jiǔ dǒu'),
  PatternEntry(zh: '九更', pinyin: 'jiǔ gēng'),
  // 十 + word
  PatternEntry(zh: '十重', pinyin: 'shí chóng'),
  PatternEntry(zh: '十行', pinyin: 'shí háng'),
  PatternEntry(zh: '十斗', pinyin: 'shí dǒu'),
  PatternEntry(zh: '十更', pinyin: 'shí gēng'),
  // 百 + word
  PatternEntry(zh: '百重', pinyin: 'bǎi chóng'),
  PatternEntry(zh: '百行', pinyin: 'bǎi háng'),
  PatternEntry(zh: '百斗', pinyin: 'bǎi dǒu'),
  PatternEntry(zh: '百更', pinyin: 'bǎi gēng'),
  // 千 + word
  PatternEntry(zh: '千重', pinyin: 'qiān chóng'),
  PatternEntry(zh: '千行', pinyin: 'qiān háng'),
  PatternEntry(zh: '千斗', pinyin: 'qiān dǒu'),
  PatternEntry(zh: '千更', pinyin: 'qiān gēng'),
  // 万 + word
  PatternEntry(zh: '万重', pinyin: 'wàn chóng'),
  PatternEntry(zh: '万行', pinyin: 'wàn háng'),
  PatternEntry(zh: '万斗', pinyin: 'wàn dǒu'),
  PatternEntry(zh: '万更', pinyin: 'wàn gēng'),
  // 亿 + word
  PatternEntry(zh: '亿重', pinyin: 'yì chóng'),
  PatternEntry(zh: '亿行', pinyin: 'yì háng'),
  PatternEntry(zh: '亿斗', pinyin: 'yì dǒu'),
  PatternEntry(zh: '亿更', pinyin: 'yì gēng'),
  // 单 + word
  PatternEntry(zh: '单重', pinyin: 'dān chóng'),
  PatternEntry(zh: '单行', pinyin: 'dān háng'),
  PatternEntry(zh: '单斗', pinyin: 'dān dǒu'),
  PatternEntry(zh: '单更', pinyin: 'dān gēng'),
  // 两 + word
  PatternEntry(zh: '两重', pinyin: 'liǎng chóng'),
  PatternEntry(zh: '两行', pinyin: 'liǎng háng'),
  PatternEntry(zh: '两斗', pinyin: 'liǎng dǒu'),
  PatternEntry(zh: '两更', pinyin: 'liǎng gēng'),
  // 双 + word
  PatternEntry(zh: '双重', pinyin: 'shuāng chóng'),
  PatternEntry(zh: '双行', pinyin: 'shuāng háng'),
  PatternEntry(zh: '双斗', pinyin: 'shuāng dǒu'),
  PatternEntry(zh: '双更', pinyin: 'shuāng gēng'),
  // 多 + word
  PatternEntry(zh: '多重', pinyin: 'duō chóng'),
  PatternEntry(zh: '多行', pinyin: 'duō háng'),
  PatternEntry(zh: '多斗', pinyin: 'duō dǒu'),
  PatternEntry(zh: '多更', pinyin: 'duō gēng'),
  // 几 + word
  PatternEntry(zh: '几重', pinyin: 'jǐ chóng'),
  PatternEntry(zh: '几行', pinyin: 'jǐ háng'),
  PatternEntry(zh: '几斗', pinyin: 'jǐ dǒu'),
  PatternEntry(zh: '几更', pinyin: 'jǐ gēng'),
  // 十一 + word
  PatternEntry(zh: '十一重', pinyin: 'shí yī chóng'),
  PatternEntry(zh: '十一行', pinyin: 'shí yī háng'),
  // 零一 + word
  PatternEntry(zh: '零一重', pinyin: 'líng yī chóng'),
  PatternEntry(zh: '零一行', pinyin: 'líng yī háng'),
];

List<Pattern> buildPatternNumberDict() {
  return _kPatternNumberDictEntries.map((e) => Pattern(
    zh: e.zh,
    pinyin: e.pinyin,
    probability: kProbabilityDict,
    length: e.zh.length,
    priority: kPriorityNormal,
    dict: 'special',
  )).toList();
}
