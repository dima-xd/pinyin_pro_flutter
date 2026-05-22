// AUTO-GENERATED - do not edit manually.
// Source: pinyin-pro/lib/data/dict4.ts
// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';

/// 4-character word to pinyin mapping.
const Map<String, String> _dict4Data = {
  '了无生机': 'liǎo wú shēng jī',
  '有一说一': 'yǒu yī shuō yī',
  '独一无二': 'dú yī wú èr',
  '说一不二': 'shuō yī bù èr',
  '举一反三': 'jǔ yī fǎn sān',
  '数一数二': 'shǔ yī shǔ èr',
  '杀一儆百': 'shā yī jǐng bǎi',
  '丁一卯二': 'dīng yī mǎo èr',
  '丁一确二': 'dīng yī què èr',
  '不一而止': 'bù yī ér zhǐ',
  '无一幸免': 'wú yī xìng miǎn',
  '表里不一': 'biǎo lǐ bù yī',
  '良莠不一': 'liáng yǒu bù yī',
  '心口不一': 'xīn kǒu bù yī',
  '言行不一': 'yán xíng bù yī',
  '政令不一': 'zhèng lìng bù yī',
  '参差不一': 'cēn cī bù yī',
  '纷纷不一': 'fēn fēn bù yī',
  '毁誉不一': 'huǐ yù bù yī',
  '不一而三': 'bù yī ér sān',
  '百不一遇': 'bǎi bù yī yù',
  '言行抱一': 'yán xíng bào yī',
  '瑜百瑕一': 'yú bǎi xiá yī',
  '背城借一': 'bèi chéng jiè yī',
  '凭城借一': 'píng chéng jiè yī',
  '劝百讽一': 'quàn bǎi fěng yī',
  '群居和一': 'qún jū hé yī',
  '百不获一': 'bǎi bù huò yī',
  '百不失一': 'bǎi bù shī yī',
  '百无失一': 'bǎi wú shī yī',
  '万不失一': 'wàn bù shī yī',
  '万无失一': 'wàn wú shī yī',
  '合而为一': 'hé ér wéi yī',
  '合两为一': 'hé liǎng wéi yī',
  '合二为一': 'hé èr wéi yī',
  '天下为一': 'tiān xià wéi yī',
  '相与为一': 'xiāng yǔ wéi yī',
  '较若画一': 'jiào ruò huà yī',
  '较如画一': 'jiào rú huà yī',
  '斠若画一': 'jiào ruò huà yī',
  '言行若一': 'yán xíng ruò yī',
  '始终若一': 'shǐ zhōng ruò yī',
  '终始若一': 'zhōng shǐ ruò yī',
  '惟精惟一': 'wéi jīng wéi yī',
  '众多非一': 'zhòng duō fēi yī',
  '不能赞一': 'bù néng zàn yī',
  '问一答十': 'wèn yī dá shí',
  '一不扭众': 'yī bù niǔ zhòng',
  '一以贯之': 'yī yǐ guàn zhī',
  '一以当百': 'yī yǐ dāng bǎi',
  '百不当一': 'bǎi bù dāng yī',
  '十不当一': 'shí bù dāng yī',
  '以一警百': 'yǐ yī jǐng bǎi',
  '以一奉百': 'yǐ yī fèng bǎi',
  '以一持万': 'yǐ yī chí wàn',
  '以一知万': 'yǐ yī zhī wàn',
  '百里挑一': 'bǎi lǐ tiāo yī',
  '整齐划一': 'zhěng qí huà yī',
  '一来二去': 'yī lái èr qù',
  '一路公交': 'yī lù gōng jiāo',
  '一路汽车': 'yī lù qì chē',
  '一路巴士': 'yī lù bā shì',
  '朝朝朝落': 'zhāo cháo zhāo luò',
  '曲意逢迎': 'qū yì féng yíng',
  '一行不行': 'yì háng bù xíng',
  '行行不行': 'háng háng bù xíng',
};

/// Builds patterns for 4-character words in dict4.
List<Pattern> buildDict4Patterns() {
  return _dict4Data.entries.map((e) => Pattern(
    zh: e.key,
    pinyin: e.value,
    probability: kProbabilityDict * 4 * 4,
    length: 4,
    priority: kPriorityNormal,
    dict: 'dict4',
  )).toList();
}
