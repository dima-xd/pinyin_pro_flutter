import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('toneSandhi (3.29.5)', () {
    tearDown(() => clearCustomDict(CustomDictType.pinyin));

    test('keeps third tones unchanged by default', () {
      expect(pinyinString('你好'), 'nǐ hǎo');
      expect(
        pinyinString('你好', options: const PinyinOptions(toneSandhi: true)),
        'nǐ hǎo',
      );
    });

    test('can disable 一 and 不 independently', () {
      expect(
        pinyinString('一把',
            options: const PinyinOptions(toneSandhi: ToneSandhiOptions(yi: false))),
        'yī bǎ',
      );
      expect(
        pinyinString('不是',
            options: const PinyinOptions(toneSandhi: ToneSandhiOptions(bu: false))),
        'bù shì',
      );
      expect(
        pinyinString('一把不是',
            options: const PinyinOptions(toneSandhi: ToneSandhiOptions(yi: false))),
        'yī bǎ bú shì',
      );
      expect(
        pinyinString('一把不是',
            options: const PinyinOptions(toneSandhi: ToneSandhiOptions(bu: false))),
        'yì bǎ bù shì',
      );
    });

    test('treats an empty options object as default 一/不 sandhi', () {
      expect(
        pinyinString('一把',
            options: const PinyinOptions(toneSandhi: ToneSandhiOptions())),
        'yì bǎ',
      );
      expect(
        pinyinString('你好',
            options: const PinyinOptions(toneSandhi: ToneSandhiOptions())),
        'nǐ hǎo',
      );
    });

    test('changes the first of two consecutive third tones when enabled', () {
      expect(
        pinyinString('你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'ní hǎo',
      );
      expect(
        pinyinString('你高',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'nǐ gāo',
      );
      expect(
        pinyinString('要不你走',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'yào bù ní zǒu',
      );
      expect(
        pinyinString('可以',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'ké yǐ',
      );
    });

    test('can combine independent flags', () {
      expect(
        pinyinString('一把好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(yi: false, thirdTone: true))),
        'yī bá hǎo',
      );
      expect(
        pinyinString('不是你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(bu: false, thirdTone: true))),
        'bù shì ní hǎo',
      );
    });

    test('supports each tone output format', () {
      expect(
        pinyinString('你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true),
                toneType: ToneType.num)),
        'ni2 hao3',
      );
      expect(
        pinyinString('你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true),
                toneType: ToneType.none)),
        'ni hao',
      );
      expect(
        pinyinArray('你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true),
                toneType: ToneType.num)),
        ['ni2', 'hao3'],
      );
    });

    test('keeps both third tones when tone sandhi is disabled', () {
      expect(
        pinyinString('你好', options: const PinyinOptions(toneSandhi: false)),
        'nǐ hǎo',
      );
    });

    test('does not apply across non-Chinese boundaries', () {
      expect(
        pinyinString('你，好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'nǐ ， hǎo',
      );
      expect(
        pinyinString('你a好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'nǐ a hǎo',
      );
    });

    test('handles separate pairs between punctuation boundaries', () {
      expect(
        pinyinString('你好，很好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'ní hǎo ， hén hǎo',
      );
    });

    test('keeps runs longer than two third tones unchanged', () {
      expect(
        pinyinString('我很好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'wǒ hěn hǎo',
      );
      expect(
        pinyinString('我想很好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'wǒ xiǎng hěn hǎo',
      );
      expect(
        pinyinString('展览馆',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'zhǎn lǎn guǎn',
      );
    });

    test('uses custom pinyin results for third-tone sandhi', () {
      customPinyin({'你好': 'wǒ hǎo'});

      expect(
        pinyinString('你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'wó hǎo',
      );
    });

    test('preserves existing tone sandhi for 一 and 不', () {
      expect(
        pinyinString('一把', options: const PinyinOptions(toneSandhi: true)),
        'yì bǎ',
      );
      expect(
        pinyinString('不想', options: const PinyinOptions(toneSandhi: true)),
        'bù xiǎng',
      );
      expect(
        pinyinString('一你好',
            options: const PinyinOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'yì ní hǎo',
      );
    });

    test('applies to segmentPinyin', () {
      expect(
        segmentPinyinString('你好',
            options: const SegmentOptions(
                toneSandhi: ToneSandhiOptions(thirdTone: true))),
        'ní hǎo',
      );
      expect(
        segmentAllString('你好',
                options: const SegmentOptions(
                    toneSandhi: ToneSandhiOptions(thirdTone: true)))
            .result,
        'ní hǎo',
      );
    });

    test('applies to htmlPinyin', () {
      final html = htmlPinyin('你好',
          options: const HtmlOptions(
              toneSandhi: ToneSandhiOptions(thirdTone: true)));

      expect(html, contains('>ní</rt>'));
      expect(html, contains('>hǎo</rt>'));
    });

    test('copyWith preserves object toneSandhi options', () {
      const options = PinyinOptions(
          toneSandhi: ToneSandhiOptions(yi: false, thirdTone: true));
      final copy = options.copyWith(toneType: ToneType.num);

      expect(copy.toneSandhi, isA<ToneSandhiOptions>());
      final sandhi = copy.toneSandhi as ToneSandhiOptions;
      expect(sandhi.yi, isFalse);
      expect(sandhi.bu, isTrue);
      expect(sandhi.thirdTone, isTrue);
    });
  });

  group('match v option (3.29.5)', () {
    test('v can be a custom replacement string', () {
      expect(
        matchPinyin('吕', 'lü', options: const MatchOptions(v: 'u')),
        [0],
      );
      expect(
        matchPinyin('绿色', 'luse', options: const MatchOptions(v: 'u')),
        [0, 1],
      );
      expect(
        matchPinyin('绿色', 'lvse', options: const MatchOptions(v: true)),
        [0, 1],
      );
      expect(matchPinyin('绿色', 'lüse'), [0, 1]);
    });

    test('keeps the longest path across shared prefixes', () {
      expect(
        matchPinyin('哈啊哈', 'haha',
            options: const MatchOptions(
                precision: MatchPrecision.start,
                lastPrecision: MatchPrecision.every)),
        [0, 1, 2],
      );
    });

    test('keeps the first path when lengths are equal', () {
      expect(
        matchPinyin('哈哈哈', 'hh',
            options: const MatchOptions(
                precision: MatchPrecision.first,
                lastPrecision: MatchPrecision.first)),
        [0, 1],
      );
      expect(
        matchPinyin('哈哈哈', 'haha',
            options: const MatchOptions(
                precision: MatchPrecision.every,
                lastPrecision: MatchPrecision.every)),
        [0, 1],
      );
    });

    test('keeps literal matches and skipped character indices', () {
      expect(
        matchPinyin('哈a哈a', 'haa',
            options: const MatchOptions(
                precision: MatchPrecision.start,
                lastPrecision: MatchPrecision.every)),
        [0, 1],
      );
      expect(matchPinyin('𠮷哈 空 哈', 'hh'), [2, 6]);
      expect(
        matchPinyin('哈 哈', 'hh',
            options: const MatchOptions(continuous: true)),
        [0, 2],
      );
    });

    test('returns a long path and rejects a final mismatch', () {
      final text = '汉' * 128;
      final query = 'h' * 128;
      expect(
        matchPinyin(text, query,
            options: const MatchOptions(
                precision: MatchPrecision.first,
                lastPrecision: MatchPrecision.first)),
        List<int>.generate(128, (index) => index),
      );
      expect(
        matchPinyin(text, '${query}z',
            options: const MatchOptions(precision: MatchPrecision.first)),
        isNull,
      );
    });

    test('strips precomposed and combining tone marks', () {
      expect(matchPinyin('阿哦额衣乌', 'āáǎà'), isNull);
      expect(matchPinyin('阿哦额衣乌', 'ōóǒò'), isNull);
      expect(matchPinyin('阿哦额衣乌', 'ēéěè'), isNull);
      expect(matchPinyin('阿哦额衣乌', 'īíǐì'), isNull);
      expect(matchPinyin('阿哦额衣乌', 'ūúǔù'), isNull);
      expect(matchPinyin('女', 'nv'), isNull);
      expect(matchPinyin('女', 'ǖǘǚǜ'), isNull);
      expect(matchPinyin('嗯', 'ń'), isNull);
      expect(matchPinyin('嗯', 'ň'), isNull);
      expect(matchPinyin('嗯', 'ǹ'), isNull);
      expect(matchPinyin('嗯', 'n'), [0]);
      expect(matchPinyin('嗯', 'n̄'), isNull);
      expect(matchPinyin('呣', 'ḿ'), isNull);
      expect(matchPinyin('呣', 'm̄'), isNull);
      expect(matchPinyin('呣', 'm̌'), isNull);
      expect(matchPinyin('呣', 'm̀'), isNull);
      expect(matchPinyin('呣', 'm'), [0]);
      expect(matchPinyin('欸', 'ế'), isNull);
      expect(matchPinyin('欸', 'ề'), isNull);
      expect(matchPinyin('欸', 'ê'), [0]);
      expect(matchPinyin('欸', 'ê̄'), isNull);
      expect(matchPinyin('欸', 'ê̌'), isNull);
      expect(matchPinyin('欸', 'êê'), isNull);

      expect(getPinyinWithoutTone('m̄'), 'm');
      expect(getPinyinWithoutTone('ḿ'), 'm');
      expect(getPinyinWithoutTone('m̌'), 'm');
      expect(getPinyinWithoutTone('m̀'), 'm');
      expect(getPinyinWithoutTone('n̄'), 'n');
      expect(getPinyinWithoutTone('ń'), 'n');
      expect(getPinyinWithoutTone('ň'), 'n');
      expect(getPinyinWithoutTone('ǹ'), 'n');
      expect(getPinyinWithoutTone('ê̄'), 'ê');
      expect(getPinyinWithoutTone('ế'), 'ê');
      expect(getPinyinWithoutTone('ê̌'), 'ê');
      expect(getPinyinWithoutTone('ề'), 'ê');
    });
  });

  group('custom pinyin updates (3.29.5)', () {
    tearDown(() => clearCustomDict(
        [CustomDictType.pinyin, CustomDictType.multiple, CustomDictType.polyphonic]));

    test('uses the latest value after several updates', () {
      customPinyin({'银行': 'yin hang'});
      customPinyin({'重庆': 'chong qing'});
      customPinyin({'银行': 'yin xing'});

      expect(pinyinString('银行重庆'), 'yin xing chong qing');
    });

    test('repeated updates keep working', () {
      for (var i = 0; i < 1000; i++) {
        customPinyin({'银行': 'yin hang', '重庆': 'chong qing'});
      }

      expect(pinyinString('银行重庆'), 'yin hang chong qing');
    });

    test('clears installed and pending words', () {
      final original = pinyinString('银行重庆');

      customPinyin({'银行': 'yin hang'});
      customPinyin({'重庆': 'chong qing'});
      clearCustomDict(CustomDictType.pinyin);

      expect(pinyinString('银行重庆'), original);
    });

    test('keeps custom suffix matches when a dictionary is added afterwards',
        () {
      customPinyin({'乙丙': 'yi bing'});
      addDict({'甲乙丙': 'jia yi bing'},
          options: const DictOptions(name: 'custom-build-order'));

      expect(pinyinString('乙丙'), 'yi bing');
      expect(pinyinString('甲乙丙'), 'jia yi bing');

      removeDict('custom-build-order');
    });
  });

  group('dictionary parity (3.29.5)', () {
    test('行长 uses zhǎng', () {
      expect(pinyinString('行长'), 'háng zhǎng');
    });

    test('一丁点儿 has an explicit dictionary reading', () {
      expect(pinyinString('一丁点儿'), 'yī dīng diǎn er');
    });
  });

  group('nonZhScope is stateless', () {
    test('repeated matches do not consume regex state', () {
      final scope = RegExp('[a-z]');
      expect(
        pinyinString('ab',
            options: PinyinOptions(
                nonZh: NonZhMode.removed, nonZhScope: scope)),
        '',
      );
      expect(
        pinyinString('ab',
            options: PinyinOptions(
                nonZh: NonZhMode.removed, nonZhScope: scope)),
        '',
      );
    });
  });
}
