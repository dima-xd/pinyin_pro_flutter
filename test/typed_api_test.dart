import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('typed pinyin API', () {
    test('pinyinString returns a string and forces string return type', () {
      expect(pinyinString('汉语拼音'), 'hàn yǔ pīn yīn');
      expect(
        pinyinString('汉语拼音',
            options:
                const PinyinOptions(returnType: PinyinReturnType.array)),
        'hàn yǔ pīn yīn',
      );
      expect(pinyinString(''), '');
    });

    test('pinyinString keeps separator and tone options', () {
      expect(
        pinyinString('汉语', options: const PinyinOptions(separator: '-')),
        'hàn-yǔ',
      );
      expect(
        pinyinString('汉语',
            options: const PinyinOptions(toneType: ToneType.num)),
        'han4 yu3',
      );
    });

    test('pinyinArray returns List<String> and forces array return type', () {
      expect(pinyinArray('汉语'), ['hàn', 'yǔ']);
      expect(
        pinyinArray('汉语',
            options: const PinyinOptions(returnType: PinyinReturnType.all)),
        ['hàn', 'yǔ'],
      );
      expect(pinyinArray(''), isEmpty);
    });

    test('pinyinAll returns List<PinyinAllData> and forces all return type', () {
      final all = pinyinAll('汉语',
          options: const PinyinOptions(returnType: PinyinReturnType.array));

      expect(all, hasLength(2));
      expect(all.first.origin, '汉');
      expect(all.first.pinyin, 'hàn');
      expect(pinyinAll(''), isEmpty);
    });
  });

  group('typed polyphonic API', () {
    test('polyphonicString returns one string per character', () {
      expect(polyphonicString('好好'), ['hǎo hào', 'hǎo hào']);
      expect(polyphonicString(''), isEmpty);
    });

    test('polyphonicString forces string return type and keeps tones', () {
      expect(
        polyphonicString('好',
            options: const PolyphonicOptions(
                returnType: PolyphonicReturnType.array)),
        ['hǎo hào'],
      );
      expect(
        polyphonicString('好',
            options: const PolyphonicOptions(toneType: ToneType.num)),
        ['hao3 hao4'],
      );
    });

    test('polyphonicArray returns nested lists', () {
      expect(
        polyphonicArray('好好'),
        [
          ['hǎo', 'hào'],
          ['hǎo', 'hào'],
        ],
      );
      expect(polyphonicArray(''), isEmpty);
    });

    test('polyphonicAll returns typed data and forces all return type', () {
      final all = polyphonicAll('好',
          options: const PolyphonicOptions(
              returnType: PolyphonicReturnType.string));

      expect(all, hasLength(1));
      expect(all.first, hasLength(2));
      expect(all.first.first.origin, '好');
      expect(all.first.first.pinyin, 'hǎo');
      expect(polyphonicAll(''), isEmpty);
    });
  });

  group('typed segment API', () {
    const text = '我是中国人';

    test('segmentAllSegment returns List<SegmentItem>', () {
      final result = segmentAllSegment(text);

      expect(result.map((item) => item.origin), ['我', '是', '中', '国', '人']);
      expect(result.map((item) => item.result), ['wǒ', 'shì', 'zhōng', 'guó', 'rén']);
    });

    test('segmentAllArray returns nested SegmentItem lists', () {
      final result = segmentAllArray(text);

      expect(result, hasLength(5));
      expect(result.map((items) => items.single.origin),
          ['我', '是', '中', '国', '人']);
    });

    test('segmentAllString returns one SegmentItem', () {
      final result = segmentAllString(text);

      expect(result.origin, '我 是 中 国 人');
      expect(result.result, 'wǒ shì zhōng guó rén');
    });

    test('segmentPinyinSegment returns pinyin per segment', () {
      expect(segmentPinyinSegment(text), ['wǒ', 'shì', 'zhōng', 'guó', 'rén']);
    });

    test('segmentPinyinArray returns nested pinyin lists', () {
      expect(
        segmentPinyinArray(text),
        [
          ['wǒ'],
          ['shì'],
          ['zhōng'],
          ['guó'],
          ['rén'],
        ],
      );
    });

    test('segmentPinyinString returns joined pinyin', () {
      expect(segmentPinyinString(text), 'wǒ shì zhōng guó rén');
    });

    test('segmentZhSegment returns origin strings per segment', () {
      expect(segmentZhSegment(text), ['我', '是', '中', '国', '人']);
    });

    test('segmentZhArray returns nested origin lists', () {
      expect(
        segmentZhArray(text),
        [
          ['我'],
          ['是'],
          ['中'],
          ['国'],
          ['人'],
        ],
      );
    });

    test('segmentZhString returns joined origin text', () {
      expect(segmentZhString(text), '我 是 中 国 人');
    });

    test('segment wrappers override format and keep other options', () {
      expect(
        segmentPinyinString(text,
            options: const SegmentOptions(format: OutputFormat.zhString)),
        'wǒ shì zhōng guó rén',
      );
      expect(
        segmentPinyinString(text,
            options: const SegmentOptions(separator: '-')),
        'wǒ-shì-zhōng-guó-rén',
      );
      expect(
        segmentPinyinArray(text,
            options: const SegmentOptions(toneType: ToneType.none)),
        [
          ['wo'],
          ['shi'],
          ['zhong'],
          ['guo'],
          ['ren'],
        ],
      );
    });

    test('segment wrappers return typed empty results for empty input', () {
      expect(segmentAllSegment(''), isEmpty);
      expect(segmentAllArray(''), isEmpty);
      final emptySegment = segmentAllString('');
      expect(emptySegment.origin, '');
      expect(emptySegment.result, '');
      expect(segmentPinyinSegment(''), isEmpty);
      expect(segmentPinyinArray(''), isEmpty);
      expect(segmentPinyinString(''), '');
      expect(segmentZhSegment(''), isEmpty);
      expect(segmentZhArray(''), isEmpty);
      expect(segmentZhString(''), '');
    });
  });

  group('options copyWith', () {
    test('PolyphonicOptions.copyWith replaces only the given fields', () {
      const original = PolyphonicOptions(
        toneType: ToneType.symbol,
        nonZh: NonZhMode.removed,
        v: true,
      );

      final copy = original.copyWith(toneType: ToneType.num);

      expect(copy.toneType, ToneType.num);
      expect(copy.nonZh, NonZhMode.removed);
      expect(copy.v, isTrue);
    });

    test('SegmentOptions.copyWith replaces only the given fields', () {
      const original = SegmentOptions(
        toneType: ToneType.symbol,
        separator: '-',
        traditional: true,
      );

      final copy = original.copyWith(format: OutputFormat.pinyinArray);

      expect(copy.format, OutputFormat.pinyinArray);
      expect(copy.toneType, ToneType.symbol);
      expect(copy.separator, '-');
      expect(copy.traditional, isTrue);
    });
  });
}
