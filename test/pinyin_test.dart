// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter_test/flutter_test.dart';
import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';

Map<String, dynamic> _allDataToMap(PinyinAllData d) => {
      'origin': d.origin,
      'pinyin': d.pinyin,
      'initial': d.initial,
      'final': d.final_,
      'first': d.first,
      'finalHead': d.finalHead,
      'finalBody': d.finalBody,
      'finalTail': d.finalTail,
      'num': d.num,
      'isZh': d.isZh,
      'inZhRange': d.inZhRange,
      'polyphonic': d.polyphonic,
      'result': d.result,
    };

Map<String, dynamic> _polyAllDataToMap(PolyphonicAllData d) => {
      'origin': d.origin,
      'pinyin': d.pinyin,
      'initial': d.initial,
      'final': d.final_,
      'first': d.first,
      'finalHead': d.finalHead,
      'finalBody': d.finalBody,
      'finalTail': d.finalTail,
      'num': d.num,
      'isZh': d.isZh,
      'inZhRange': d.inZhRange,
    };

void _clearAllCustomDicts() {
  clearCustomDict(CustomDictType.pinyin);
  clearCustomDict(CustomDictType.multiple);
  clearCustomDict(CustomDictType.polyphonic);
  clearCustomDict([
    CustomDictType.pinyin,
    CustomDictType.multiple,
    CustomDictType.polyphonic,
  ]);
}

void main() {
  // ─── basic ────────────────────────────────────────────────────────────────
  group('basic', () {
    test('[basic]正常拼音字符串', () {
      expect(pinyin('汉语拼音'), equals('hàn yǔ pīn yīn'));
    });

    test('[basic]拼音+非汉字字符串', () {
      expect(pinyin('汉语拼音xxx.,'), equals('hàn yǔ pīn yīn x x x . ,'));
    });

    test('[basic]正常拼音数组', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals(['hàn', 'yǔ', 'pīn', 'yīn']),
      );
    });

    test('[basic]好好', () {
      expect(pinyin('好好学习'), equals('hǎo hào xué xí'));
    });

    test('[basic]拼音+非汉字数组', () {
      expect(
        pinyin('汉语拼音xxx.,',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals(['hàn', 'yǔ', 'pīn', 'yīn', 'x', 'x', 'x', '.', ',']),
      );
    });

    test('[basic]空字符串', () {
      expect(pinyin(''), equals(''));
    });

    test('[basic]空数组', () {
      expect(
        pinyin('',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals([]),
      );
    });

    test('[basic]正常拼音1', () {
      expect(
          pinyin('哈发生你看三零四'), equals('hā fā shēng nǐ kàn sān líng sì'));
    });

    test('[basic]正常拼音数组1', () {
      expect(
        pinyin('哈发生你看三零四',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals(['hā', 'fā', 'shēng', 'nǐ', 'kàn', 'sān', 'líng', 'sì']),
      );
    });
    // it.skip '[basic]test行不行'
  });

  // ─── pinyin-fn ────────────────────────────────────────────────────────────
  group('pinyinFn', () {
    test('[pinyin-fn]with space', () {
      expect(
        pinyin('测试..  ..',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals(['cè', 'shì', '.', '.', ' ', ' ', '.', '.']),
      );
    });

    // [pinyin-fn]not string type — Dart is type-safe, skip

    test('[pinyin-fn]empty string', () {
      expect(pinyin(''), equals(''));
      expect(
        pinyin('',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals([]),
      );
    });

    test('[pinyin-fn]origin', () {
      expect(pinyin('赵钱孙李吧'), equals('zhào qián sūn lǐ ba'));
    });

    test('[pinyin-fn]array', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals(['zhào', 'qián', 'sūn', 'lǐ', 'ba']),
      );
    });

    test('[pinyin-fn]right_pinyin', () {
      expect(pinyin('手下败将'), equals('shǒu xià bài jiàng'));
    });

    test('[pinyin-fn]left_pinyin', () {
      expect(pinyin('避难所'), equals('bì nàn suǒ'));
    });

    test('[pinyin-fn]long_text does not crash', () {
      final result = pinyin(
          '大海深处的一条美人鱼一直对大海之外的世界充满了好奇，她一直想要出去看看海之外的世界');
      expect(result, isNotEmpty);
    });
  });

  // ─── pattern with toneType ────────────────────────────────────────────────
  group('pattern with toneType', () {
    test('[tone-type]num_num字符串', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.num, toneType: ToneType.num)),
        equals('4 3 1 1'),
      );
    });

    test('[tone-type]num_num数组', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.num,
                toneType: ToneType.num,
                returnType: PinyinReturnType.array)),
        equals(['4', '3', '1', '1']),
      );
    });

    test('[tone-type]num_none字符串', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.num, toneType: ToneType.none)),
        equals('4 3 1 1'),
      );
    });

    test('[tone-type]num_none数组', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.num,
                toneType: ToneType.none,
                returnType: PinyinReturnType.array)),
        equals(['4', '3', '1', '1']),
      );
    });

    test('[tone-type]initial_num字符串', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.initial, toneType: ToneType.num)),
        equals('h4 y3 p1 y1'),
      );
    });

    test('[tone-type]initial_num数组', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.initial,
                toneType: ToneType.num,
                returnType: PinyinReturnType.array)),
        equals(['h4', 'y3', 'p1', 'y1']),
      );
    });

    test('[tone-type]final_num字符串', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.final_, toneType: ToneType.num)),
        equals('an4 u3 in1 in1'),
      );
    });

    test('[tone-type]final_num数组', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.final_,
                toneType: ToneType.num,
                returnType: PinyinReturnType.array)),
        equals(['an4', 'u3', 'in1', 'in1']),
      );
    });

    test('[tone-type]final_num多音字', () {
      expect(
        pinyin('好',
            options: const PinyinOptions(
                pattern: PinyinPattern.final_,
                toneType: ToneType.num,
                multiple: true)),
        equals('ao3 ao4'),
      );
    });

    test('[tone-type]final_num多音字数组', () {
      expect(
        pinyin('好',
            options: const PinyinOptions(
                pattern: PinyinPattern.final_,
                toneType: ToneType.num,
                multiple: true,
                returnType: PinyinReturnType.array)),
        equals(['ao3', 'ao4']),
      );
    });

    test('[tone-type]none', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(toneType: ToneType.none)),
        equals('zhao qian sun li ba'),
      );
    });

    test('[tone-type]num', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(toneType: ToneType.num)),
        equals('zhao4 qian2 sun1 li3 ba0'),
      );
    });

    test('[tone-type]nonZh', () {
      expect(
        pinyin(
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz',
            options: const PinyinOptions(
                toneType: ToneType.num, nonZh: NonZhMode.consecutive)),
        equals('ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz'),
      );
    });

    test('[tone-type]nonZh with consecutive', () {
      expect(
        pinyin('How are you? ',
            options: const PinyinOptions(
                toneType: ToneType.num, nonZh: NonZhMode.consecutive)),
        equals('How are you? '),
      );
    });
  });

  // ─── pattern ──────────────────────────────────────────────────────────────
  group('pattern', () {
    test('[pattern]num', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(pattern: PinyinPattern.num)),
        equals('4 3 1 1'),
      );
    });

    test('[pattern]num-array', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.num,
                returnType: PinyinReturnType.array)),
        equals(['4', '3', '1', '1']),
      );
    });

    test('[pattern]final', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals('àn ǔ īn īn'),
      );
    });

    test('[pattern]final-array', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.final_,
                returnType: PinyinReturnType.array)),
        equals(['àn', 'ǔ', 'īn', 'īn']),
      );
    });

    test('[pattern]initial', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(pattern: PinyinPattern.initial)),
        equals('h y p y'),
      );
    });

    test('[pattern]initial-yw', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.initial,
                initialPattern: InitialPattern.standard,
                returnType: PinyinReturnType.array)),
        equals(['h', '', 'p', '']),
      );
    });

    test('[pattern]initial-array', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                pattern: PinyinPattern.initial,
                returnType: PinyinReturnType.array)),
        equals(['h', 'y', 'p', 'y']),
      );
    });

    test('[pattern]num-all', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(pattern: PinyinPattern.num)),
        equals('4 2 1 3 0'),
      );
    });

    test('[pattern]num-array-2', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(
                pattern: PinyinPattern.num,
                returnType: PinyinReturnType.array)),
        equals(['4', '2', '1', '3', '0']),
      );
    });

    test('[pattern]initial-all', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(pattern: PinyinPattern.initial)),
        equals('zh q s l b'),
      );
    });

    test('[pattern]final-all', () {
      expect(
        pinyin('赵钱孙李吧',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals('ào ián ūn ǐ a'),
      );
    });

    test('[pattern]first-all', () {
      expect(
        pinyin('赵钱孙李额',
            options: const PinyinOptions(pattern: PinyinPattern.first)),
        equals('z q s l é'),
      );
      expect(
        pinyin('赵钱孙李very',
            options: const PinyinOptions(pattern: PinyinPattern.first)),
        equals('z q s l v e r y'),
      );
    });

    test('[pattern]first-all-none', () {
      expect(
        pinyin('赵钱孙李额',
            options: const PinyinOptions(
                pattern: PinyinPattern.first, toneType: ToneType.none)),
        equals('z q s l e'),
      );
    });

    test('[pattern]nonZh', () {
      expect(
        pinyin('a',
            options: const PinyinOptions(pattern: PinyinPattern.initial)),
        equals(''),
      );
      expect(
        pinyin('a',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals(''),
      );
      expect(
        pinyin('a',
            options: const PinyinOptions(pattern: PinyinPattern.finalHead)),
        equals(''),
      );
      expect(
        pinyin('a',
            options: const PinyinOptions(pattern: PinyinPattern.finalBody)),
        equals(''),
      );
      expect(
        pinyin('a',
            options: const PinyinOptions(pattern: PinyinPattern.finalTail)),
        equals(''),
      );
    });
  });

  // ─── pattern-mix-tone-type ────────────────────────────────────────────────
  group('toneType', () {
    test('[pattern-mix-tone-type]num', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(toneType: ToneType.num)),
        equals('han4 yu3 pin1 yin1'),
      );
    });

    test('[pattern-mix-tone-type]num-array', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                toneType: ToneType.num,
                returnType: PinyinReturnType.array)),
        equals(['han4', 'yu3', 'pin1', 'yin1']),
      );
    });

    test('[pattern-mix-tone-type]none', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(toneType: ToneType.none)),
        equals('han yu pin yin'),
      );
    });

    test('[pattern-mix-tone-type]none-嗯', () {
      expect(
        pinyin('阿斯蒂芬嗯',
            options: const PinyinOptions(
                pattern: PinyinPattern.first, toneType: ToneType.none)),
        equals('a s d f n'),
      );
    });

    test('[pattern-mix-tone-type]specials', () {
      expect(pinyin('嗯'), equals('ǹg'));
      expect(pinyin('哼'), equals('hēng'));
    });

    test('[pattern-mix-tone-type]none-array', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                toneType: ToneType.none,
                returnType: PinyinReturnType.array)),
        equals(['han', 'yu', 'pin', 'yin']),
      );
    });

    test('[pattern-mix-tone-type]symbol', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(toneType: ToneType.symbol)),
        equals('hàn yǔ pīn yīn'),
      );
    });

    test('[pattern-mix-tone-type]symbol-array', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                toneType: ToneType.symbol,
                returnType: PinyinReturnType.array)),
        equals(['hàn', 'yǔ', 'pīn', 'yīn']),
      );
    });

    test('[pattern-mix-tone-type]first with num', () {
      expect(
        pinyin('山西',
            options: const PinyinOptions(
                pattern: PinyinPattern.first, toneType: ToneType.num)),
        equals('s1 x1'),
      );
    });
  });

  // ─── all type ─────────────────────────────────────────────────────────────
  group('all', () {
    test('[all]test all', () {
      final result = (pinyin('汉语拼音',
              options:
                  const PinyinOptions(returnType: PinyinReturnType.all)) as List)
          .cast<PinyinAllData>()
          .map(_allDataToMap)
          .toList();

      expect(result, equals([
        {
          'origin': '汉', 'pinyin': 'hàn', 'initial': 'h', 'final': 'àn',
          'first': 'h', 'finalHead': '', 'finalBody': 'à', 'finalTail': 'n',
          'num': 4, 'isZh': true, 'inZhRange': true,
          'polyphonic': ['hàn'], 'result': 'hàn',
        },
        {
          'origin': '语', 'pinyin': 'yǔ', 'initial': 'y', 'final': 'ǔ',
          'first': 'y', 'finalHead': '', 'finalBody': 'ǔ', 'finalTail': '',
          'num': 3, 'isZh': true, 'inZhRange': true,
          'polyphonic': ['yǔ', 'yù'], 'result': 'yǔ',
        },
        {
          'origin': '拼', 'pinyin': 'pīn', 'initial': 'p', 'final': 'īn',
          'first': 'p', 'finalHead': '', 'finalBody': 'ī', 'finalTail': 'n',
          'num': 1, 'isZh': true, 'inZhRange': true,
          'polyphonic': ['pīn'], 'result': 'pīn',
        },
        {
          'origin': '音', 'pinyin': 'yīn', 'initial': 'y', 'final': 'īn',
          'first': 'y', 'finalHead': '', 'finalBody': 'ī', 'finalTail': 'n',
          'num': 1, 'isZh': true, 'inZhRange': true,
          'polyphonic': ['yīn'], 'result': 'yīn',
        },
      ]));
    });

    test('[all]test all with nonZh', () {
      final result = (pinyin('汉a𧒽音',
              options:
                  const PinyinOptions(returnType: PinyinReturnType.all)) as List)
          .cast<PinyinAllData>();

      expect(result[0].origin, equals('汉'));
      expect(result[0].pinyin, equals('hàn'));
      expect(result[0].isZh, isTrue);

      expect(result[1].origin, equals('a'));
      expect(result[1].pinyin, equals(''));
      expect(result[1].isZh, isFalse);
      expect(result[1].first, equals('a'));

      expect(result[2].origin, equals('𧒽'));
      expect(result[2].pinyin, equals(''));
      expect(result[2].isZh, isFalse);
      expect(result[2].first, equals('𧒽'));

      expect(result[3].origin, equals('音'));
      expect(result[3].pinyin, equals('yīn'));
    });

    test('[all]test all removeNonZh', () {
      final result = (pinyin('汉a𧒽音',
              options: const PinyinOptions(
                  returnType: PinyinReturnType.all,
                  nonZh: NonZhMode.removed)) as List)
          .cast<PinyinAllData>();

      expect(result.length, equals(2));
      expect(result[0].origin, equals('汉'));
      expect(result[1].origin, equals('音'));
    });

    test('[all]test all consecutive nonZh', () {
      final result = (pinyin('汉a𧒽音',
              options: const PinyinOptions(
                  returnType: PinyinReturnType.all,
                  nonZh: NonZhMode.consecutive)) as List)
          .cast<PinyinAllData>();

      expect(result.length, equals(3));
      expect(result[0].origin, equals('汉'));
      expect(result[1].origin, equals('a𧒽'));
      expect(result[1].isZh, isFalse);
      expect(result[2].origin, equals('音'));
    });

    test('[all]非中文：字母', () {
      final result = (pinyin('a',
              options: const PinyinOptions(
                  returnType: PinyinReturnType.all, multiple: true)) as List)
          .cast<PinyinAllData>();
      expect(result.length, equals(1));
      expect(result[0].pinyin, equals(''));
      expect(result[0].origin, equals('a'));
      expect(result[0].inZhRange, isFalse);
    });

    test('[all]非中文和中文混合', () {
      final result = (pinyin('a好',
              options: const PinyinOptions(
                  returnType: PinyinReturnType.all, multiple: true)) as List)
          .cast<PinyinAllData>();
      expect(result.length, equals(2));
      expect(result[1].pinyin, equals('hǎo'));
      expect(result[1].origin, equals('好'));
      expect(result[1].polyphonic.join(','), equals('hǎo,hào'));
    });
  });

  // ─── separator ────────────────────────────────────────────────────────────
  group('separator', () {
    test('[separator]分割符', () {
      expect(
        pinyin('汉语拼音', options: const PinyinOptions(separator: '-')),
        equals('hàn-yǔ-pīn-yīn'),
      );
    });
  });

  // ─── nonZh ────────────────────────────────────────────────────────────────
  group('nonZh', () {
    test('[nonZh]init', () {
      expect(pinyin('我very喜欢你'), equals('wǒ v e r y xǐ huan nǐ'));
    });

    test('[nonZh]spaced', () {
      expect(
        pinyin('我very喜欢你',
            options: const PinyinOptions(nonZh: NonZhMode.spaced)),
        equals('wǒ v e r y xǐ huan nǐ'),
      );
    });

    test('[nonZh]consecutive', () {
      expect(
        pinyin('我very喜欢你',
            options: const PinyinOptions(nonZh: NonZhMode.consecutive)),
        equals('wǒ very xǐ huan nǐ'),
      );
    });

    test('[nonZh]removed', () {
      expect(
        pinyin('我very喜欢你',
            options: const PinyinOptions(nonZh: NonZhMode.removed)),
        equals('wǒ xǐ huan nǐ'),
      );
    });

    test('[nonZh]has space', () {
      expect(pinyin('喜 欢'), equals('xǐ   huān'));
    });

    test('[nonZh]has space array', () {
      expect(
        pinyin('喜 欢',
            options: const PinyinOptions(returnType: PinyinReturnType.array)),
        equals(['xǐ', ' ', 'huān']),
      );
    });

    test('[nonZh]scope regexp', () {
      expect(
        pinyin('我very喜欢你，真的',
            options: PinyinOptions(
                nonZh: NonZhMode.consecutive,
                nonZhScope: RegExp(r'[a-zA-Z]'))),
        equals('wǒ very xǐ huan nǐ ， zhēn de'),
      );
    });
  });

  // ─── removeNonZh ──────────────────────────────────────────────────────────
  group('removeNonZh', () {
    test('[removeNonZh]mix', () {
      expect(
        pinyin('汉sa语2拼音',
            options: const PinyinOptions(nonZh: NonZhMode.removed)),
        equals('hàn yǔ pīn yīn'),
      );
    });

    test('[removeNonZh]none', () {
      expect(
        pinyin('saf21a',
            options: const PinyinOptions(nonZh: NonZhMode.removed)),
        equals(''),
      );
    });
  });

  // ─── multiple ─────────────────────────────────────────────────────────────
  group('multiple', () {
    test('[multiple]非单字', () {
      expect(
        pinyin('汉语拼音', options: const PinyinOptions(multiple: true)),
        equals('hàn yǔ pīn yīn'),
      );
    });

    test('[multiple]单字', () {
      expect(
        pinyin('好', options: const PinyinOptions(multiple: true)),
        equals('hǎo hào'),
      );
    });

    test('[multiple]去 tone 同音', () {
      expect(
        pinyin('好',
            options: const PinyinOptions(
                multiple: true, toneType: ToneType.none)),
        equals('hao'),
      );
    });

    test('[multiple]非单字数组', () {
      expect(
        pinyin('汉语拼音',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['hàn', 'yǔ', 'pīn', 'yīn']),
      );
    });

    test('[multiple]单字数组', () {
      expect(
        pinyin('好',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['hǎo', 'hào']),
      );
    });

    test('[multiple]非汉字：字母', () {
      expect(
        pinyin('a',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['a']),
      );
    });

    test('[multiple]非字符串：multiple: false', () {
      expect(
        pinyin('a',
            options: const PinyinOptions(
                multiple: false, returnType: PinyinReturnType.array)),
        equals(['a']),
      );
    });

    test('[multiple]汉字和非汉字混合：multiple: false', () {
      expect(
        pinyin('Bar好',
            options: const PinyinOptions(
                multiple: false, returnType: PinyinReturnType.array)),
        equals(['B', 'a', 'r', 'hǎo']),
      );
    });

    test('[multiple]非汉字：多个字母', () {
      expect(
        pinyin('Bar',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['B', 'a', 'r']),
      );
    });

    test('[multiple]非中国汉字：越南喃字', () {
      expect(
        pinyin('𠄼',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['𠄼']),
      );
    });

    test('[multiple]非中国汉字：多个越南喃字', () {
      expect(
        pinyin('𠄼𦒹',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['𠄼', '𦒹']),
      );
    });

    test('[multiple]非中国汉字和汉字混合', () {
      expect(
        pinyin('好𠄼𦒹。',
            options: const PinyinOptions(
                multiple: true, returnType: PinyinReturnType.array)),
        equals(['hǎo', '𠄼', '𦒹', '。']),
      );
    });

    test('[multiple]multiple+surname同时使用', () {
      expect(
        pinyin('能',
            options: const PinyinOptions(
                surname: SurnameMode.all, multiple: true)),
        equals('nài néng'),
      );
    });

    test('[multiple]multiple+surname同时使用,无surname', () {
      expect(
        pinyin('好',
            options: const PinyinOptions(
                surname: SurnameMode.all, multiple: true)),
        equals('hǎo hào'),
      );
    });

    test('[multiple]base', () {
      expect(
        pinyin('好', options: const PinyinOptions(multiple: true)),
        equals('hǎo hào'),
      );
    });

    test('[multiple]multiple+surname,多音字优先使用姓氏读音', () {
      expect(
        pinyin('数学家华罗庚',
            options: const PinyinOptions(
                surname: SurnameMode.all, multiple: true)),
        equals('shù xué jiā huà luó gēng'),
      );
    });
  });

  // ─── convert ──────────────────────────────────────────────────────────────
  group('convert', () {
    test('[convert]default', () {
      expect(convertPinyin('pin1 yin1'), equals('pīn yīn'));
    });

    test('[convert]separator', () {
      expect(convertPinyin('pin1-yin1', separator: '-'), equals('pīn-yīn'));
    });

    test('[convert]numToSymbol', () {
      expect(
        convertPinyin('pin1 yin1', format: ConvertFormat.numToSymbol),
        equals('pīn yīn'),
      );
    });

    test('[convert]symbolToNum', () {
      expect(
        convertPinyin('pīn yīn', format: ConvertFormat.symbolToNum),
        equals('pin1 yin1'),
      );
    });

    test('[convert]toneNone', () {
      expect(
        convertPinyin('pīn yīn', format: ConvertFormat.toneNone),
        equals('pin yin'),
      );
    });

    test('[convert]array', () {
      expect(convertPinyin(['pin1', 'yin1']), equals(['pīn', 'yīn']));
    });

    test('[convert]array others', () {
      expect(
          convertPinyin(['pin1', 'a', 'yin1']), equals(['pīn', 'a', 'yīn']));
    });

    test('[convert]string others', () {
      expect(convertPinyin('pin1 a   yin1'), equals('pīn a   yīn'));
    });

    test('[convert]v', () {
      expect(convertPinyin('lv4 se4'), equals('lǜ sè'));
    });

    // '[convert]format none' — invalid ConvertFormat in Dart, skipped

    test('[convert]numToSymbol abnormal', () {
      expect(
        convertPinyin('l2', format: ConvertFormat.numToSymbol),
        equals('l2'),
      );
    });

    test('[convert]numToSymbol iu', () {
      expect(
        convertPinyin('liu2', format: ConvertFormat.numToSymbol),
        equals('liú'),
      );
    });

    test('[convert]special tone', () {
      expect(
        convertPinyin('m̄ hm ê̄ ế ê̌ ề', format: ConvertFormat.symbolToNum),
        equals('m1 hm0 ê1 ê2 ê3 ê4'),
      );
    });

    test('[convert]erhua numToSymbol', () {
      expect(
        convertPinyin('yi4 dian3r', format: ConvertFormat.numToSymbol),
        equals('yì diǎnr'),
      );
    });

    test('[convert]erhua symbolToNum', () {
      expect(
        convertPinyin('yì diǎnr', format: ConvertFormat.symbolToNum),
        equals('yi4 dian3r'),
      );
    });

    test('[convert]erhua toneNone', () {
      expect(
        convertPinyin('yì diǎnr', format: ConvertFormat.toneNone),
        equals('yi dianr'),
      );
    });

    test('[convert]erhua numToSymbol hua1r', () {
      expect(
        convertPinyin('hua1r', format: ConvertFormat.numToSymbol),
        equals('huār'),
      );
    });

    test('[convert]erhua symbolToNum huār', () {
      expect(
        convertPinyin('huār', format: ConvertFormat.symbolToNum),
        equals('hua1r'),
      );
    });

    test('[convert]erhua does not affect er', () {
      expect(
        convertPinyin('ér', format: ConvertFormat.symbolToNum),
        equals('er2'),
      );
    });

    test('[convert]erhua numToSymbol does not affect er', () {
      expect(
        convertPinyin('er2', format: ConvertFormat.numToSymbol),
        equals('ér'),
      );
    });

    test('[convert]erhua numToSymbol array', () {
      expect(
        convertPinyin(['dian3r', 'hua1r']),
        equals(['diǎnr', 'huār']),
      );
    });
  });

  // ─── html ─────────────────────────────────────────────────────────────────
  group('html', () {
    test('[html]正常拼音', () {
      expect(
        htmlPinyin('汉语拼音'),
        equals(
          '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span><rp>(</rp><rt class="py-pinyin-item">hàn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">语</span><rp>(</rp><rt class="py-pinyin-item">yǔ</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">拼</span><rp>(</rp><rt class="py-pinyin-item">pīn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">音</span><rp>(</rp><rt class="py-pinyin-item">yīn</rt><rp>)</rp></ruby></span>',
        ),
      );
    });

    test('[html]不带音调', () {
      expect(
        htmlPinyin('汉语拼音',
            options: const HtmlOptions(toneType: ToneType.none)),
        equals(
          '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span><rp>(</rp><rt class="py-pinyin-item">han</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">语</span><rp>(</rp><rt class="py-pinyin-item">yu</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">拼</span><rp>(</rp><rt class="py-pinyin-item">pin</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">音</span><rp>(</rp><rt class="py-pinyin-item">yin</rt><rp>)</rp></ruby></span>',
        ),
      );
    });

    test('[html-non-chinese]带标点', () {
      expect(
        htmlPinyin('汉语，拼音'),
        equals(
          '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span><rp>(</rp><rt class="py-pinyin-item">hàn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">语</span><rp>(</rp><rt class="py-pinyin-item">yǔ</rt><rp>)</rp></ruby></span>'
          '，'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">拼</span><rp>(</rp><rt class="py-pinyin-item">pīn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">音</span><rp>(</rp><rt class="py-pinyin-item">yīn</rt><rp>)</rp></ruby></span>',
        ),
      );
    });

    test('[html-wrap-non-chinese]带标点包裹', () {
      expect(
        htmlPinyin('汉语，拼音',
            options: const HtmlOptions(wrapNonChinese: true)),
        equals(
          '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span><rp>(</rp><rt class="py-pinyin-item">hàn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">语</span><rp>(</rp><rt class="py-pinyin-item">yǔ</rt><rp>)</rp></ruby></span>'
          '<span class="py-non-chinese-item">，</span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">拼</span><rp>(</rp><rt class="py-pinyin-item">pīn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">音</span><rp>(</rp><rt class="py-pinyin-item">yīn</rt><rp>)</rp></ruby></span>',
        ),
      );
    });

    test('[html-custom-class]自定义类名', () {
      expect(
        htmlPinyin('汉语，拼音',
            options: const HtmlOptions(
              wrapNonChinese: true,
              resultClass: 'my-result',
              chineseClass: 'my-chinese',
              pinyinClass: 'my-pinyin',
              nonChineseClass: 'my-non-chinese',
            )),
        equals(
          '<span class="my-result"><ruby><span class="my-chinese">汉</span><rp>(</rp><rt class="my-pinyin">hàn</rt><rp>)</rp></ruby></span>'
          '<span class="my-result"><ruby><span class="my-chinese">语</span><rp>(</rp><rt class="my-pinyin">yǔ</rt><rp>)</rp></ruby></span>'
          '<span class="my-non-chinese">，</span>'
          '<span class="my-result"><ruby><span class="my-chinese">拼</span><rp>(</rp><rt class="my-pinyin">pīn</rt><rp>)</rp></ruby></span>'
          '<span class="my-result"><ruby><span class="my-chinese">音</span><rp>(</rp><rt class="my-pinyin">yīn</rt><rp>)</rp></ruby></span>',
        ),
      );
    });

    test('[html]customClassMap', () {
      expect(
        htmlPinyin('汉语拼音',
            options: const HtmlOptions(
              customClassMap: {
                'hightlight': ['汉', '拼'],
                'bold': ['音'],
              },
            )),
        equals(
          '<span class="py-result-item hightlight"><ruby><span class="py-chinese-item">汉</span><rp>(</rp><rt class="py-pinyin-item">hàn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">语</span><rp>(</rp><rt class="py-pinyin-item">yǔ</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item hightlight"><ruby><span class="py-chinese-item">拼</span><rp>(</rp><rt class="py-pinyin-item">pīn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item bold"><ruby><span class="py-chinese-item">音</span><rp>(</rp><rt class="py-pinyin-item">yīn</rt><rp>)</rp></ruby></span>',
        ),
      );
    });

    test('[html]非汉字：字母a', () {
      expect(htmlPinyin('a'), equals('a'));
    });

    test('[html]非中国汉字：𦒹', () {
      expect(htmlPinyin('𦒹'), equals('𦒹'));
    });

    test('[html]非中国汉字 + wrapNonChinese: true', () {
      expect(
        htmlPinyin('𦒹', options: const HtmlOptions(wrapNonChinese: true)),
        equals('<span class="py-non-chinese-item">𦒹</span>'),
      );
    });

    test('[html]非汉字和汉字混合', () {
      expect(
        htmlPinyin('汉字abc'),
        equals(
          '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span><rp>(</rp><rt class="py-pinyin-item">hàn</rt><rp>)</rp></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">字</span><rp>(</rp><rt class="py-pinyin-item">zì</rt><rp>)</rp></ruby></span>'
          'abc',
        ),
      );
    });

    test('[html]remove rp', () {
      expect(
        htmlPinyin('汉语，拼音', options: const HtmlOptions(rp: false)),
        equals(
          '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span><rt class="py-pinyin-item">hàn</rt></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">语</span><rt class="py-pinyin-item">yǔ</rt></ruby></span>'
          '，'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">拼</span><rt class="py-pinyin-item">pīn</rt></ruby></span>'
          '<span class="py-result-item"><ruby><span class="py-chinese-item">音</span><rt class="py-pinyin-item">yīn</rt></ruby></span>',
        ),
      );
    });
  });

  // ─── match ────────────────────────────────────────────────────────────────
  group('match', () {
    tearDown(_clearAllCustomDicts);

    test('[match]default', () {
      expect(matchPinyin('欢迎使用汉语拼音', 'hy'), equals([0, 1]));
    });

    test('[match]start and continuous', () {
      expect(
        matchPinyin('欢迎使用汉语拼音', 'yingshyon',
            options: const MatchOptions(
                precision: MatchPrecision.start, continuous: true)),
        equals([1, 2, 3]),
      );
    });

    test('[match]multiple1', () {
      expect(matchPinyin('会计', 'kj'), equals([0, 1]));
    });

    test('[match]multiple2', () {
      expect(matchPinyin('会计', 'huij'), equals([0, 1]));
    });

    test('[match]any', () {
      expect(
        matchPinyin('开会', 'kaiui',
            options: const MatchOptions(precision: MatchPrecision.any)),
        equals([0, 1]),
      );
    });

    test('[match]any&empty', () {
      expect(
        matchPinyin('开会', '',
            options: const MatchOptions(precision: MatchPrecision.any)),
        isNull,
      );
    });

    test('[match]any&continuous', () {
      expect(
        matchPinyin('开个大会', 'kaiui',
            options: const MatchOptions(
                precision: MatchPrecision.any, continuous: true)),
        isNull,
      );
    });

    test('[match]any&nonZh', () {
      expect(
        matchPinyin('开会', 'kaiuiaaaa',
            options: const MatchOptions(precision: MatchPrecision.any)),
        isNull,
      );
    });

    test('[match]any&space', () {
      expect(
        matchPinyin('开      会s  啊', 'kaiuisa',
            options: const MatchOptions(precision: MatchPrecision.any)),
        equals([0, 7, 8, 11]),
      );
    });

    test('[match]fail with sucess', () {
      expect(matchPinyin('开会', 'kaig'), isNull);
    });

    test('[match]fail', () {
      expect(matchPinyin('开会', 'l'), isNull);
    });

    test('[match]uncontinuous', () {
      expect(matchPinyin('汉语拼音', 'hanpin'), equals([0, 2]));
    });

    test('[match]basic', () {
      expect(matchPinyin('汉语拼音', 'hyupy'), equals([0, 1, 2, 3]));
    });

    test('[match]first & double unicode', () {
      expect(matchPinyin('𧒽测试', 'cs'), equals([2, 3]));
    });

    test('[match]start', () {
      expect(
        matchPinyin('欢迎使用汉语拼音', '欢yingshy',
            options: const MatchOptions(precision: MatchPrecision.start)),
        equals([0, 1, 2, 3]),
      );
    });

    test('[match]first&space', () {
      expect(matchPinyin('𧒽测 试', 'c s'), equals([2, 4]));
    });

    test('[match]first&space with custom', () {
      customPinyin({'𧒽': 'lei'},
          options: const CustomPinyinOptions(
              multiple: CustomHandleType.replace));
      expect(matchPinyin('𧒽测 试', 'l c s'), equals([0, 1, 2, 4]));
    });

    test('[match]nonZh match', () {
      expect(
        matchPinyin('测uuuuuuuuuu试', 'cuuuuuu'),
        equals([0, 1, 2, 3, 4, 5, 6]),
      );
    });

    test('[match]lastPrecision every fail', () {
      expect(
        matchPinyin('汉语拼音', 'hanyupinyi',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.every)),
        isNull,
      );
    });

    test('[match]lastPrecision every success', () {
      expect(
        matchPinyin('汉语拼音', 'hanyupinyin',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.every)),
        equals([0, 1, 2, 3]),
      );
    });

    test('[match]lastPrecision first fail', () {
      expect(
        matchPinyin('汉语拼音', 'hanyupinyi',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.first)),
        isNull,
      );
    });

    test('[match]lastPrecision first success', () {
      expect(
        matchPinyin('汉语拼音', 'hanyupiny',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.first)),
        equals([0, 1, 2, 3]),
      );
    });

    test('[match]lastPrecision any', () {
      expect(
        matchPinyin('汉语拼音', 'hanyupini',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.any)),
        equals([0, 1, 2, 3]),
      );
    });

    test('[match]lastPrecision ignore space', () {
      expect(
        matchPinyin('汉语 拼音', 'hanyu pini',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.any,
                space: MatchSpace.ignore)),
        equals([0, 1, 3, 4]),
      );
    });

    test('[match]lastPrecision preserve space', () {
      expect(
        matchPinyin('汉语 拼音', 'hanyu pini',
            options: const MatchOptions(
                lastPrecision: MatchPrecision.any,
                space: MatchSpace.preserve)),
        equals([0, 1, 2, 3, 4]),
      );
    });

    test('[match]precision preserve space', () {
      expect(
        matchPinyin('汉语 拼音', 'hanyu pini',
            options: const MatchOptions(
                precision: MatchPrecision.any,
                space: MatchSpace.preserve)),
        equals([0, 1, 2, 3, 4]),
      );
    });

    test('[match]precision not continuous', () {
      expect(
        matchPinyin('汉语 拼音', 'hanyu yin',
            options: const MatchOptions(
                precision: MatchPrecision.any,
                space: MatchSpace.preserve,
                continuous: true)),
        isNull,
      );
    });

    test('[match]precision continuous', () {
      expect(
        matchPinyin('汉语 拼音', 'hanyu pinyin',
            options: const MatchOptions(
                precision: MatchPrecision.any,
                space: MatchSpace.preserve,
                continuous: true)),
        equals([0, 1, 2, 3, 4]),
      );
    });

    // '[match]lastPrecision none' — invalid MatchPrecision in Dart, skipped

    test('[match]insensitive', () {
      expect(
        matchPinyin('汉语KK拼音', 'hanyukkpinyin'),
        equals([0, 1, 2, 3, 4, 5]),
      );
      expect(
        matchPinyin('汉语KK拼音', 'hanyukkpinyin',
            options: const MatchOptions(insensitive: false)),
        isNull,
      );
    });

    test('[match]v', () {
      expect(
        matchPinyin('我是吕布', 'woshilvbu',
            options: const MatchOptions(v: true)),
        equals([0, 1, 2, 3]),
      );
    });
  });

  // ─── customConfig ─────────────────────────────────────────────────────────
  group('customConfig', () {
    tearDown(_clearAllCustomDicts);

    test('[custom]custom none', () {
      customPinyin({});
      expect(pinyin('干一行行一行'), equals('gàn yì háng xíng yì háng'));
    });

    test('[custom]custom1', () {
      customPinyin({'能': 'nài'});
      expect(pinyin('我姓能'), equals('wǒ xìng nài'));
    });

    test('[custom]custom2', () {
      customPinyin({'好好': 'hào hǎo'});
      expect(pinyin('爱好好多'), equals('ài hào hǎo duō'));
    });

    test('[custom]custom3', () {
      customPinyin({'哈什玛': 'hà shén mǎ'});
      expect(pinyin('哈什玛'), equals('hà shén mǎ'));
    });

    test('[custom]custom4', () {
      customPinyin({'暴虎冯河': 'bào hǔ píng hé'});
      expect(pinyin('暴虎冯河'), equals('bào hǔ píng hé'));
    });

    test('[custom]custom>5', () {
      customPinyin({'干一行行一行': 'gàn yī háng xíng yī háng'});
      expect(pinyin('干一行行一行'), equals('gàn yī háng xíng yī háng'));
    });

    test('[custom]custom with surname', () {
      customPinyin({'乐嘉': 'lè jiā'});
      expect(
        pinyin('乐嘉啊',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('lè jiā a'),
      );
      expect(
        pinyin('啊乐嘉',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('a lè jiā'),
      );
      expect(
        pinyin('啊乐嘉是',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('a lè jiā shì'),
      );
    });

    test('[custom]customs', () {
      customPinyin({'好': 'hào', '好好': 'hào hǎo'});
      expect(pinyin('好好'), equals('hào hǎo'));
    });

    test('[custom]custom with multiple', () {
      customPinyin({'嗯': 'en'});
      expect(
        pinyin('嗯',
            options: const PinyinOptions(
                multiple: true,
                returnType: PinyinReturnType.array,
                nonZh: NonZhMode.removed,
                toneType: ToneType.num)),
        equals(['ng4', 'ng2', 'ng3']),
      );
    });

    test('[custom] ac high level', () {
      customPinyin({'银行': 'yin hang'});
      expect(pinyin('银行'), equals('yin hang'));
    });

    test('[custom] double unicode1', () {
      customPinyin({'𧒽': 'lei'});
      expect(
        pinyin('𧒽沙发𧒽𧒽𧒽算法是'),
        equals('lei shā fā lei lei lei suàn fǎ shì'),
      );
    });

    test('[custom] double unicode2', () {
      customPinyin({'𧒽𧒽': 'lei ke'});
      expect(
        pinyin('𧒽沙发𧒽𧒽𧒽算法是'),
        equals('𧒽 shā fā lei ke 𧒽 suàn fǎ shì'),
      );
    });

    test('[custom] length not match', () {
      customPinyin({'你好': 'nihao'});
      expect(
        pinyin('你好', options: const PinyinOptions(toneType: ToneType.none)),
        equals('nihao '),
      );
    });
  });

  // ─── custom for multiple ──────────────────────────────────────────────────
  group('custom for multiple', () {
    tearDown(_clearAllCustomDicts);

    test('[custom]custom multiple1', () {
      customPinyin({'你好': 'mi sao'},
          options:
              const CustomPinyinOptions(multiple: CustomHandleType.add));
      expect(
        pinyin('你', options: const PinyinOptions(multiple: true)),
        equals('nǐ mi'),
      );
    });

    test('[custom]custom multiple2', () {
      customPinyin({'你好': 'mi kao'},
          options:
              const CustomPinyinOptions(multiple: CustomHandleType.add));
      expect(
        pinyin('好', options: const PinyinOptions(multiple: true)),
        equals('hǎo hào kao'),
      );
    });

    test('[custom]custom multiple duplicated', () {
      customPinyin({'你好': 'mi hǎo'},
          options:
              const CustomPinyinOptions(multiple: CustomHandleType.add));
      expect(
        pinyin('好', options: const PinyinOptions(multiple: true)),
        equals('hǎo hào'),
      );
    });

    test('[custom]custom multiple replace', () {
      customPinyin({'你好': 'mi kao'},
          options: const CustomPinyinOptions(
              multiple: CustomHandleType.replace));
      expect(
        pinyin('好', options: const PinyinOptions(multiple: true)),
        equals('kao'),
      );
    });
  });

  // ─── custom for polyphonic ────────────────────────────────────────────────
  group('custom for polyphonic', () {
    tearDown(_clearAllCustomDicts);

    test('[custom]custom polyphonic1', () {
      customPinyin({'你好': 'mi kao'},
          options:
              const CustomPinyinOptions(polyphonic: CustomHandleType.add));
      expect(
        polyphonic('好好学习'),
        equals(['hǎo hào kao', 'hǎo hào kao', 'xué', 'xí']),
      );
    });
  });

  // ─── custom abnormal ──────────────────────────────────────────────────────
  group('custom abnormal', () {
    tearDown(_clearAllCustomDicts);

    test('[custom]custom abnormal1', () {
      customPinyin({'你好': 'nihao'},
          options:
              const CustomPinyinOptions(multiple: CustomHandleType.add));
      expect(pinyin('你好好学习'), equals('nihao  hào xué xí'));
    });
  });

  // ─── addDict ──────────────────────────────────────────────────────────────
  group('addDict', () {
    test('[addDict]string dict', () {
      addDict({'汉语拼音': 'hàn yǔ pīn yīn'});
      expect(pinyin('汉语拼音'), equals('hàn yǔ pīn yīn'));
      removeDict();
    });

    test('[addDict]array dict add then remove', () {
      addDict({'汉语拼音': 'hàn yǔ pīn yīn'},
          options: const DictOptions(name: 'arrayDict'));
      removeDict('arrayDict');
      expect(pinyin('汉语拼音'), isNotEmpty);
    });

    test('[addDict]dict handle add', () {
      addDict({'汉': ['yīn']},
          options: const DictOptions(
              name: 'handle-add', dict1: DictHandleType.add));
      expect(
        pinyin('汉', options: const PinyinOptions(multiple: true)),
        equals('hàn yīn'),
      );
      removeDict('handle-add');
    });

    test('[addDict]dict handle replace', () {
      addDict({'汉': ['yīn']},
          options: const DictOptions(
              name: 'handle-replace',
              dict1: DictHandleType.replace));
      expect(
        pinyin('汉', options: const PinyinOptions(multiple: true)),
        equals('yīn'),
      );
      removeDict('handle-replace');
    });

    test('[addDict]undefined dict', () {
      addDict({'䃜': 'yī'}, options: const DictOptions(name: 'handle-new'));
      expect(pinyin('䃜'), equals('yī'));
      removeDict('handle-new');
    });

    test('[addDict]unnamed dict', () {
      addDict({'䃜': 'yī'});
      expect(pinyin('䃜'), equals('yī'));
      removeDict();
    });

    test('[addDict]2 unicode dict', () {
      addDict({'𧒽': 'lei'},
          options: const DictOptions(name: 'double-unicode-dict'));
      expect(pinyin('𧒽'), equals('lei'));
      removeDict('double-unicode-dict');
    });
  });

  // ─── double unicode ───────────────────────────────────────────────────────
  group('double unicode', () {
    test('[double unicode]base', () {
      expect(pinyin('𧒽'), equals('𧒽'));
    });

    test('[double unicode]with pinyin', () {
      expect(pinyin('𧒽测试'), equals('𧒽 cè shì'));
    });

    test('[double unicode]dpdp', () {
      expect(pinyin('𧒽测试𧒽测试'), equals('𧒽 cè shì 𧒽 cè shì'));
    });

    test('[double unicode]dp consecutive', () {
      expect(
        pinyin('𧒽测试',
            options: const PinyinOptions(nonZh: NonZhMode.consecutive)),
        equals('𧒽 cè shì'),
      );
    });

    test('[double unicode]dpdpdp consecutive', () {
      expect(
        pinyin('测试a𧒽𧒽a测试a𧒽𧒽a测试',
            options: const PinyinOptions(nonZh: NonZhMode.consecutive)),
        equals('cè shì a𧒽𧒽a cè shì a𧒽𧒽a cè shì'),
      );
    });

    test('[double unicode]𬭬 with pinyin', () {
      expect(pinyin('测试𬭬𬭬测试𬭬测试'),
          equals('cè shì 𬭬 𬭬 cè shì 𬭬 cè shì'));
    });
  });

  // ─── external API ─────────────────────────────────────────────────────────
  group('external API', () {
    test('[external]initial and final', () {
      final result = getInitialAndFinal('guang');
      expect(result.initial, equals('g'));
      expect(result.final_, equals('uang'));
    });

    test('[external]getFinalParts', () {
      final result = getFinalParts('guang');
      expect(result.head, equals('u'));
      expect(result.body, equals('a'));
      expect(result.tail, equals('ng'));
    });

    test('[external]getNumOfTone', () {
      expect(getNumOfTone('hàn yǔ pīn yīn'), equals('4 3 1 1'));
    });
  });

  // ─── final pattern ────────────────────────────────────────────────────────
  group('final pattern', () {
    test('[final]head', () {
      expect(
        pinyin('广',
            options: const PinyinOptions(pattern: PinyinPattern.finalHead)),
        equals('u'),
      );
    });

    test('[final]body', () {
      expect(
        pinyin('广',
            options: const PinyinOptions(pattern: PinyinPattern.finalBody)),
        equals('ǎ'),
      );
    });

    test('[final]tail', () {
      expect(
        pinyin('广',
            options: const PinyinOptions(pattern: PinyinPattern.finalTail)),
        equals('ng'),
      );
    });

    test('[final]no head', () {
      expect(
        pinyin('敢',
            options: const PinyinOptions(pattern: PinyinPattern.finalHead)),
        equals(''),
      );
    });

    test('[final]no head body', () {
      expect(
        pinyin('敢',
            options: const PinyinOptions(pattern: PinyinPattern.finalBody)),
        equals('ǎ'),
      );
    });

    test('[final]no tail', () {
      expect(
        pinyin('哈',
            options: const PinyinOptions(pattern: PinyinPattern.finalTail)),
        equals(''),
      );
    });

    test('[final]special-un', () {
      expect(
        pinyin('群',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals('ǘn'),
      );
    });

    test('[final]special-u', () {
      expect(
        pinyin('局',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals('ǘ'),
      );
    });

    test('[final]special-uan', () {
      expect(
        pinyin('选',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals('üǎn'),
      );
    });

    test('[final]special-ue', () {
      expect(
        pinyin('却',
            options: const PinyinOptions(pattern: PinyinPattern.final_)),
        equals('üè'),
      );
    });
  });

  // ─── getNumOfTone ─────────────────────────────────────────────────────────
  group('getNumOfTone', () {
    test('[get-num-of-tone]no tone', () {
      expect(
        pinyin('赵钱孙李吧你b',
            options: const PinyinOptions(pattern: PinyinPattern.num)),
        equals('4 2 1 3 0 3 '),
      );
    });
  });

  // ─── getPinyin ────────────────────────────────────────────────────────────
  group('getPinyin', () {
    test('[get-pinyin]double symbol', () {
      expect(pinyin('aaaa'), equals('a a a a'));
    });

    test('[get-pinyin]length greater than 5', () {
      expect(pinyin('赵钱孙李吧你'), equals('zhào qián sūn lǐ ba nǐ'));
    });

    test('[get-pinyin]dict2', () {
      expect(pinyin('阿比让'), equals('ā bǐ ràng'));
    });
  });

  // ─── polyphonic ───────────────────────────────────────────────────────────
  group('polyphonic', () {
    tearDown(_clearAllCustomDicts);

    test('[polyphonic]normal', () {
      expect(
        polyphonic('好好学习'),
        equals(['hǎo hào', 'hǎo hào', 'xué', 'xí']),
      );
    });

    test('[polyphonic]array', () {
      expect(
        polyphonic('好好学习',
            options: const PolyphonicOptions(
                returnType: PolyphonicReturnType.array)),
        equals([
          ['hǎo', 'hào'],
          ['hǎo', 'hào'],
          ['xué'],
          ['xí'],
        ]),
      );
    });

    test('[polyphonic]all', () {
      final result = (polyphonic('好好学习',
              options: const PolyphonicOptions(
                  returnType: PolyphonicReturnType.all)) as List)
          .cast<List<PolyphonicAllData>>();

      expect(result.length, equals(4));

      final hao1 = _polyAllDataToMap(result[0][0]);
      expect(hao1['pinyin'], equals('hǎo'));
      expect(hao1['final'], equals('ǎo'));
      expect(hao1['finalBody'], equals('ǎ'));
      expect(hao1['finalHead'], equals(''));
      expect(hao1['finalTail'], equals('o'));
      expect(hao1['first'], equals('h'));
      expect(hao1['initial'], equals('h'));
      expect(hao1['isZh'], isTrue);
      expect(hao1['num'], equals(3));
      expect(hao1['inZhRange'], isTrue);
      expect(hao1['origin'], equals('好'));

      final hao2 = _polyAllDataToMap(result[0][1]);
      expect(hao2['pinyin'], equals('hào'));
      expect(hao2['num'], equals(4));

      final xue = _polyAllDataToMap(result[2][0]);
      expect(xue['origin'], equals('学'));
      expect(xue['pinyin'], equals('xué'));
      expect(xue['final'], equals('üé'));
      expect(xue['finalHead'], equals('ü'));

      final xi = _polyAllDataToMap(result[3][0]);
      expect(xi['origin'], equals('习'));
      expect(xi['pinyin'], equals('xí'));
    });

    // [polyphonic]type error — Dart type-safe, skipped

    test('[polyphonic]empty', () {
      expect(polyphonic(''), equals([]));
    });

    test('[polyphonic]nonzh', () {
      expect(
        polyphonic('好好学习s'),
        equals(['hǎo hào', 'hǎo hào', 'xué', 'xí', 's']),
      );
    });

    test('[polyphonic]removeNonZh', () {
      expect(
        polyphonic('好好学习s',
            options: const PolyphonicOptions(nonZh: NonZhMode.removed)),
        equals(['hǎo hào', 'hǎo hào', 'xué', 'xí']),
      );
    });

    test('[polyphonic]all&nonZh', () {
      final result = (polyphonic('好好学习s',
              options: const PolyphonicOptions(
                  returnType: PolyphonicReturnType.all)) as List)
          .cast<List<PolyphonicAllData>>();

      expect(result.length, equals(5));
      final s = result[4][0];
      expect(s.origin, equals('s'));
      expect(s.isZh, isFalse);
      expect(s.pinyin, equals(''));
    });

    test('[polyphonic]num', () {
      expect(
        polyphonic('好好学习',
            options:
                const PolyphonicOptions(pattern: PinyinPattern.num)),
        equals(['3 4', '3 4', '2', '2']),
      );
    });

    test('[polyphonic]toneType', () {
      expect(
        polyphonic('好好学习',
            options:
                const PolyphonicOptions(toneType: ToneType.none)),
        equals(['hao', 'hao', 'xue', 'xi']),
      );
    });

    test('[polyphonic]toneType&num', () {
      expect(
        polyphonic('好好学习',
            options:
                const PolyphonicOptions(toneType: ToneType.num)),
        equals(['hao3 hao4', 'hao3 hao4', 'xue2', 'xi2']),
      );
    });
  });

  // ─── segment format ───────────────────────────────────────────────────────
  // Note: complex sentence tests from segment.test.js require
  // addDict(completeDict) for correct word segmentation; those are omitted.
  group('segment format', () {
    test('[format]AllSegment returns List<SegmentItem>', () {
      final result = segmentPinyin('你好') as List<SegmentItem>;
      expect(result, isA<List<SegmentItem>>());
      expect(result.map((s) => s.origin).join(''), equals('你好'));
    });

    test('[format]AllArray returns List<List<SegmentItem>>', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.allArray)) as List<List<SegmentItem>>;
      expect(result, isA<List<List<SegmentItem>>>());
      expect(result.expand((s) => s).map((s) => s.origin).join(''),
          equals('你好'));
    });

    test('[format]AllString returns SegmentItem', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.allString)) as SegmentItem;
      expect(result, isA<SegmentItem>());
      expect(result.origin, contains('你'));
    });

    test('[format]AllString separator', () {
      final result = segmentPinyin('你好学',
          options: const SegmentOptions(
              format: OutputFormat.allString,
              separator: '/')) as SegmentItem;
      expect(result.origin, contains('/'));
    });

    test('[format]PinyinSegment returns List<String>', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.pinyinSegment)) as List<String>;
      expect(result, isA<List<String>>());
      expect(result, isNotEmpty);
    });

    test('[format]PinyinArray returns List<List<String>>', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.pinyinArray)) as List<List<String>>;
      expect(result, isA<List<List<String>>>());
    });

    test('[format]PinyinString returns String', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.pinyinString)) as String;
      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });

    test('[format]ZhSegment returns List<String>', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.zhSegment)) as List<String>;
      expect(result.join(''), equals('你好'));
    });

    test('[format]ZhArray returns List<List<String>>', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.zhArray)) as List<List<String>>;
      expect(result, isA<List<List<String>>>());
    });

    test('[format]ZhString returns String', () {
      final result = segmentPinyin('你好',
          options: const SegmentOptions(
              format: OutputFormat.zhString)) as String;
      expect(result, contains('你'));
    });

    test('[format]PinyinString final nonZh', () {
      final result = segmentPinyin('你好。',
          options: const SegmentOptions(
              format: OutputFormat.pinyinString)) as String;
      expect(result, endsWith('。'));
    });

    test('[format]surname mode', () {
      final result = segmentPinyin('曾小贤',
          options: const SegmentOptions(
              surname: SurnameMode.all,
              format: OutputFormat.pinyinString)) as String;
      expect(result, startsWith('zēng'));
    });
  });

  // ─── segmentit (requires complete dict) ───────────────────────────────────
  group('segmentit', skip: 'Requires complete dictionary', () {
    test('[segmentit]max-probability', () {
      expect(
        pinyin('小明硕士毕业于中国科学院计算所，后在日本京都大学深造'),
        equals(
          'xiǎo míng shuò shì bì yè yú zhōng guó kē xué yuàn jì suàn suǒ ， hòu zài rì běn jīng dū dà xué shēn zào',
        ),
      );
    });

    test('[segmentit]reverse-max-match', () {
      final result = pinyin(
        '小明硕士毕业于中国科学院计算所，后在日本京都大学深造',
        options: const PinyinOptions(
            segmentit: TokenizationAlgorithm.reverseMaxMatch),
      );
      expect(result, isNotEmpty);
    });

    test('[segmentit]min-tokenization', () {
      final result = pinyin(
        '小明硕士毕业于中国科学院计算所，后在日本京都大学深造',
        options: const PinyinOptions(
            segmentit: TokenizationAlgorithm.minTokenization),
      );
      expect(result, isNotEmpty);
    });
  });

  // ─── number (special.test.js) ─────────────────────────────────────────────
  group('number', () {
    test('[number]一行', () {
      expect(pinyin('一行'), equals('yì háng'));
    });

    test('[number]两行', () {
      expect(pinyin('两行'), equals('liǎng háng'));
    });

    test('[number]多重', () {
      expect(pinyin('多重'), equals('duō chóng'));
    });

    test('[number]一行人', () {
      expect(pinyin('一行人'), equals('yì xíng rén'));
    });

    test('[number]二百零一行', () {
      expect(pinyin('二百零一行'), equals('èr bǎi líng yī háng'));
    });

    test('[number]一九一零年', () {
      expect(pinyin('一九一零年'), equals('yī jiǔ yī líng nián'));
    });

    test('[number]一九一〇年', () {
      expect(pinyin('一九一〇年'), equals('yī jiǔ yī líng nián'));
    });

    test('[number]二〇一〇年', () {
      expect(pinyin('二〇一〇年'), equals('èr líng yī líng nián'));
    });

    test('[number]二〇〇一年', () {
      expect(pinyin('二〇〇一年'), equals('èr líng líng yī nián'));
    });
  });

  // ─── tone sandhi for 一 ───────────────────────────────────────────────────
  group('tone sandhi for 一', () {
    test('[special]一 alone', () {
      expect(pinyin('一'), equals('yī'));
    });

    test('[special]不 alone', () {
      expect(pinyin('不'), equals('bù'));
    });

    test('[special]一面', () {
      expect(pinyin('一面'), equals('yí miàn'));
    });

    test('[special]一枕黄粱', () {
      expect(pinyin('一枕黄粱'), equals('yì zhěn huáng liáng'));
    });

    test('[special]说一说', () {
      expect(pinyin('说一说'), equals('shuō yi shuō'));
    });

    test('[special]一会儿', () {
      expect(pinyin('一会儿'), equals('yí huì er'));
    });

    test('[special toneSandhi false]一会儿', () {
      expect(
        pinyin('一会儿', options: const PinyinOptions(toneSandhi: false)),
        equals('yī huì er'),
      );
    });

    test('[special]一地鸡毛', () {
      expect(
        pinyin('一地鸡毛', options: const PinyinOptions(toneSandhi: true)),
        equals('yí dì jī máo'),
      );
    });

    test('[special toneSandhi false]一地', () {
      expect(
        pinyin('一地', options: const PinyinOptions(toneSandhi: false)),
        equals('yī dì'),
      );
    });

    test('[special]一千一百一十一', () {
      expect(
        pinyin('一千一百一十一',
            options: const PinyinOptions(toneSandhi: true)),
        equals('yì qiān yì bǎi yī shí yī'),
      );
    });

    // it.skip '[special]十有一年而弃'

    test('[special]山一重水一重', () {
      expect(
        pinyin('山一重水一重',
            options: const PinyinOptions(toneSandhi: true)),
        equals('shān yì chóng shuǐ yì chóng'),
      );
    });

    test('[special]一重山水', () {
      expect(
        pinyin('一重山水', options: const PinyinOptions(toneSandhi: true)),
        equals('yì chóng shān shuǐ'),
      );
    });

    // it.skip '[special]一重集团'
    // it.skip '[special]中央一台'
    // it.skip '[special]上海一中'

    test('[special]一二三四五', () {
      expect(
        pinyin('一二三四五',
            options: const PinyinOptions(toneSandhi: true)),
        equals('yī èr sān sì wǔ'),
      );
    });

    test('[special]九一年', () {
      expect(
        pinyin('九一年', options: const PinyinOptions(toneSandhi: true)),
        equals('jiǔ yī nián'),
      );
    });

    test('[special]五月一号', () {
      expect(
        pinyin('五月一号', options: const PinyinOptions(toneSandhi: true)),
        equals('wǔ yuè yī hào'),
      );
    });

    // it.skip '[special]小月一口吃完了'

    test('[special]一路公交', () {
      expect(
        pinyin('一路公交', options: const PinyinOptions(toneSandhi: true)),
        equals('yī lù gōng jiāo'),
      );
    });

    test('[special]一路顺风', () {
      expect(
        pinyin('一路顺风', options: const PinyinOptions(toneSandhi: true)),
        equals('yí lù shùn fēng'),
      );
    });

    test('[special toneSandhi false]一路', () {
      expect(
        pinyin('一路', options: const PinyinOptions(toneSandhi: false)),
        equals('yī lù'),
      );
    });

    test('[special]一更天', () {
      expect(
        pinyin('一更天', options: const PinyinOptions(toneSandhi: true)),
        equals('yì gēng tiān'),
      );
    });

    test('[special]一声声一更更', () {
      expect(
        pinyin('一声声一更更',
            options: const PinyinOptions(toneSandhi: true)),
        equals('yì shēng shēng yì gēng gēng'),
      );
    });

    test('[special]风一更雪一更', () {
      expect(
        pinyin('风一更雪一更',
            options: const PinyinOptions(toneSandhi: true)),
        equals('fēng yì gēng xuě yì gēng'),
      );
    });

    test('[special toneSandhi false]一更', () {
      expect(
        pinyin('一更', options: const PinyinOptions(toneSandhi: false)),
        equals('yī gēng'),
      );
    });

    test('[special toneSandhi false]风一更一声声', () {
      expect(
        pinyin('风一更一声声',
            options: const PinyinOptions(toneSandhi: false)),
        equals('fēng yī gēng yī shēng shēng'),
      );
    });

    test('[special]有一说一', () {
      expect(
        pinyin('有一说一', options: const PinyinOptions(toneSandhi: true)),
        equals('yǒu yī shuō yī'),
      );
    });

    test('[special]得之一寸光', () {
      expect(
        pinyin('得之一寸光',
            options: const PinyinOptions(toneSandhi: true)),
        equals('dé zhī yī cùn guāng'),
      );
    });
  });

  // ─── tone sandhi for 不 ───────────────────────────────────────────────────
  group('tone sandhi for 不', () {
    test('[special]不甘', () {
      expect(pinyin('不甘'), equals('bù gān'));
    });

    test('[special]他说不！', () {
      expect(pinyin('他说不！'), equals('tā shuō bù ！'));
    });

    test('[special]要不你走', () {
      expect(pinyin('要不你走'), equals('yào bù nǐ zǒu'));
    });

    test('[special]不悦', () {
      expect(pinyin('不悦'), equals('bú yuè'));
    });

    test('[special]说不说', () {
      expect(pinyin('说不说'), equals('shuō bu shuō'));
    });
  });

  // ─── 交叉词语测试 ─────────────────────────────────────────────────────────
  group('交叉词语测试', () {
    test('[special]难为', () {
      expect(pinyin('难为'), equals('nán wéi'));
    });

    test('[special]曾经沧海难为水', () {
      expect(
          pinyin('曾经沧海难为水'), equals('céng jīng cāng hǎi nán wéi shuǐ'));
    });

    test('[special]以那次空难为例', () {
      expect(pinyin('以那次空难为例'), equals('yǐ nà cì kōng nàn wéi lì'));
    });

    test('[special]空难为何发生', () {
      expect(pinyin('空难为何发生'), equals('kōng nàn wèi hé fā shēng'));
    });
  });

  // ─── 绕口令 ───────────────────────────────────────────────────────────────
  group('绕口令', () {
    test('[special]绕口令1', () {
      expect(
        pinyin('校服上除了校徽别别别的，让你们别别别的别别别的你非得别别的'),
        equals(
          'xiào fú shàng chú le xiào huī bié biè bié de ， ràng nǐ men bié biè bié de bié biè bié de nǐ fēi děi biè bié de',
        ),
      );
    });

    test('[special]绕口令2', () {
      expect(
        pinyin('人要是行干一行行一行，一行行行行行，行行行干哪行都行'),
        equals(
          'rén yào shi xíng gàn yì háng xíng yì háng ， yì háng xíng xíng xíng xíng ， xíng xíng xíng gàn nǎ háng dōu xíng',
        ),
      );
    });

    test('[special]绕口令3', () {
      expect(
        pinyin('要是不行，干一行不行一行，一行不行行行不行，行行不行，干哪行都不行'),
        equals(
          'yào shi bù xíng ， gàn yì háng bù xíng yì háng ， yì háng bù xíng háng háng bù xíng ， háng háng bù xíng ， gàn nǎ háng dōu bù xíng',
        ),
      );
    });

    test('[special]了吧', () {
      expect(pinyin('了吧'), equals('liǎo ba'));
    });

    test('[special 々]々', () {
      expect(pinyin('天々向上，好々学习'),
          equals('tiān tiān xiàng shàng ， hǎo hǎo xué xí'));
      expect(pinyin('々々'), equals('tóng tóng'));
      expect(pinyin('々，々'), equals('tóng ， tóng'));
    });
  });

  // ─── toneSandhi option ────────────────────────────────────────────────────
  group('toneSandhi', () {
    test('[toneSandhi]不是 toneSandhi false', () {
      expect(
        pinyin('不是', options: const PinyinOptions(toneSandhi: false)),
        equals('bù shì'),
      );
    });
  });

  // ─── surname ──────────────────────────────────────────────────────────────
  group('surname', () {
    test('[surname]万俟', () {
      expect(
        pinyin('万俟', options: const PinyinOptions(surname: SurnameMode.all)),
        equals('mò qí'),
      );
    });

    test('[surname]我叫令狐冲', () {
      expect(
        pinyin('我叫令狐冲',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('wǒ jiào líng hú chōng'),
      );
    });

    test('[surname]曾令狐冲', () {
      expect(
        pinyin('曾令狐冲',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('zēng líng hú chōng'),
      );
    });

    test('[surname]我叫区中青', () {
      expect(
        pinyin('我叫区中青',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('wǒ jiào ōu zhōng qīng'),
      );
    });

    test('[surname]我叫覃晓旭', () {
      expect(
        pinyin('我叫覃晓旭',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('wǒ jiào qín xiǎo xù'),
      );
    });

    test('[surname]我叫朴岁植', () {
      expect(
        pinyin('我叫朴岁植',
            options: const PinyinOptions(surname: SurnameMode.all)),
        equals('wǒ jiào piáo suì zhí'),
      );
    });

    test('[surname]曾乐乐 head', () {
      expect(
        pinyin('曾乐乐',
            options: const PinyinOptions(surname: SurnameMode.head)),
        equals('zēng lè lè'),
      );
    });

    test('[surname]曾经沧海难为水好好学习乐 head', () {
      expect(
        pinyin('曾经沧海难为水好好学习乐',
            options: const PinyinOptions(surname: SurnameMode.head)),
        equals('zēng jīng cāng hǎi nán wèi shuǐ hǎo hǎo xué xí lè'),
      );
    });

    test('[surname]令狐冲 head', () {
      expect(
        pinyin('令狐冲',
            options: const PinyinOptions(surname: SurnameMode.head)),
        equals('líng hú chōng'),
      );
    });

    test('[surname]万俟英 head', () {
      expect(
        pinyin('万俟英',
            options: const PinyinOptions(surname: SurnameMode.head)),
        equals('mò qí yīng'),
      );
    });
  });

  // ─── traditional ──────────────────────────────────────────────────────────
  group('traditional', () {
    setUpAll(() {
      addTraditionalDict({'轉': '转', '盤': '盘'});
    });

    test('[traditional]轉盤 without traditional flag', () {
      expect(pinyin('轉盤'), equals('zhuǎn pán'));
    });

    test('[traditional]轉盤 html without traditional', () {
      final result = htmlPinyin('轉盤');
      expect(result, contains('zhuǎn'));
      expect(result, contains('pán'));
    });

    test('[traditional]pinyin with traditional flag', () {
      final result =
          pinyin('轉盤', options: const PinyinOptions(traditional: true));
      expect(result, isNotEmpty);
    });

    test('[traditional]一个🌛轉盤 with traditional', () {
      final result = pinyin('一个🌛轉盤',
          options: const PinyinOptions(traditional: true)) as String;
      expect(result, contains('gè'));
      expect(result, contains('🌛'));
    });
  });

  // ─── v ────────────────────────────────────────────────────────────────────
  group('v', () {
    test('[v]no v', () {
      expect(pinyin('吕布'), equals('lǚ bù'));
    });

    test('[v]no v toneType none', () {
      expect(
        pinyin('吕布', options: const PinyinOptions(toneType: ToneType.none)),
        equals('lü bu'),
      );
    });

    test('[v]v toneType none', () {
      expect(
        pinyin('吕布',
            options: const PinyinOptions(toneType: ToneType.none, v: true)),
        equals('lv bu'),
      );
    });

    test('[v]v with tone (no effect)', () {
      expect(
        pinyin('吕布', options: const PinyinOptions(v: true)),
        equals('lǚ bù'),
      );
    });

    test('[v]nonZh', () {
      expect(
        pinyin('吕布ü',
            options: const PinyinOptions(toneType: ToneType.none, v: true)),
        equals('lv bu ü'),
      );
    });

    test('[v]string vChar', () {
      expect(
        pinyin('吕和平',
            options: const PinyinOptions(
                toneType: ToneType.none, v: true, vChar: 'yu')),
        equals('lyu he ping'),
      );
    });
  });
}
