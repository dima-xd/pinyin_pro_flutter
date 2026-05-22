// AUTO-GENERATED - do not edit manually.
// Source: pinyin-pro/lib/data/dict5.ts
// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

/// 5-character word to pinyin mapping.
const Map<String, String> _dict5Data = {
  '巴尔干半岛': 'bā ěr gàn bàn dǎo',
  '巴尔喀什湖': 'bā ěr kā shí hú',
  '不幸而言中': 'bú xìng ér yán zhòng',
  '布尔什维克': 'bù ěr shí wéi kè',
  '何乐而不为': 'hé lè ér bù wéi',
  '苛政猛于虎': 'kē zhèng měng yú hǔ',
  '蒙得维的亚': 'méng dé wéi dì yà',
  '民以食为天': 'mín yǐ shí wéi tiān',
  '事后诸葛亮': 'shì hòu zhū gě liàng',
  '物以稀为贵': 'wù yǐ xī wéi guì',
  '先下手为强': 'xiān xià shǒu wéi qiáng',
  '行行出状元': 'háng háng chū zhuàng yuan',
  '亚得里亚海': 'yà dé lǐ yà hǎi',
  '眼不见为净': 'yǎn bú jiàn wéi jìng',
  '竹筒倒豆子': 'zhú tǒng dào dòu zi',
};

/// Builds patterns for 5-character words in dict5.
List<Pattern> buildDict5Patterns() {
  return _dict5Data.entries.map((e) => Pattern(
    zh: e.key,
    pinyin: e.value,
    probability: kProbabilityDict * 5 * 5,
    length: 5,
    priority: kPriorityNormal,
    dict: 'dict5',
  )).toList();
}
