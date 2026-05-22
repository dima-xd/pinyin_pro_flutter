# pinyin_pro_flutter

A professional Chinese pinyin conversion library for Flutter/Dart — a full port of [pinyin-pro](https://github.com/zh-lx/pinyin-pro) (TypeScript, v3.28.1).

> **Note:** This project was developed with AI assistance.

---

## Features

- Tone marks (symbols or numeric) and tone-free output
- Multi-reading (polyphonic) characters
- Tone sandhi (变调) for 一 and 不
- Surname mode (姓氏模式)
- Text-pinyin fuzzy matching
- HTML ruby markup generation
- Word segmentation with pinyin
- Custom dictionaries and overrides
- Traditional character support
- Phonetic components: initial (声母), final (韵母), head, body, tail

## Quick Start

```dart
import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';

pinyin('汉语拼音');                        // 'hàn yǔ pīn yīn'
pinyin('好好学习', options: PinyinOptions(toneType: ToneType.num));  // 'hao3 hao4 xue2 xi2'
pinyin('汉', options: PinyinOptions(multiple: true));               // 'hàn hán'
```

---

## API

### `pinyin(word, {options})`

Converts a Chinese string to pinyin.

```dart
// String output (default)
pinyin('汉语拼音');  // 'hàn yǔ pīn yīn'

// Array output
pinyin('汉语', options: PinyinOptions(returnType: PinyinReturnType.array));
// ['hàn', 'yǔ']

// Numeric tones
pinyin('拼音', options: PinyinOptions(toneType: ToneType.num));
// 'pin1 yin1'

// No tones
pinyin('拼音', options: PinyinOptions(toneType: ToneType.none));
// 'pin yin'

// Initial (声母) only
pinyin('拼音', options: PinyinOptions(pattern: PinyinPattern.initial));
// 'p y'

// Final (韵母) only
pinyin('拼音', options: PinyinOptions(pattern: PinyinPattern.final_));
// 'in in'

// First letter
pinyin('拼音', options: PinyinOptions(pattern: PinyinPattern.first));
// 'p y'

// Surname mode
pinyin('曾小贤', options: PinyinOptions(surname: SurnameMode.head));
// 'zēng xiǎo xián'

// Tone sandhi (变调)
pinyin('一路顺风', options: PinyinOptions(toneSandhi: true));  // 'yí lù shùn fēng'

// All data per character
pinyin('好', options: PinyinOptions(returnType: PinyinReturnType.all));
// [PinyinAllData(origin:'好', pinyin:'hǎo', initial:'h', final_:'ao', ...)]
```

**`PinyinOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `toneType` | `ToneType` | `symbol` | `symbol`, `num`, `none` |
| `pattern` | `PinyinPattern` | `pinyin` | `pinyin`, `num`, `initial`, `final_`, `first`, `finalHead`, `finalBody`, `finalTail` |
| `returnType` | `PinyinReturnType` | `string` | `string`, `array`, `all` |
| `separator` | `String` | `' '` | Syllable separator |
| `multiple` | `bool` | `false` | Return all readings (single char only) |
| `surname` | `SurnameMode` | `off` | `off`, `head`, `all` |
| `toneSandhi` | `bool` | `true` | Apply tone sandhi for 一/不 |
| `nonZh` | `NonZhMode` | `spaced` | `spaced`, `consecutive`, `removed` |
| `v` | `bool` | `false` | Replace ü with v |
| `traditional` | `bool` | `false` | Recognize traditional characters |
| `segmentit` | `TokenizationAlgorithm` | `maxProbability` | `maxProbability`, `reverseMaxMatch`, `minTokenization` |

---

### `matchPinyin(text, query, {options})`

Fuzzy-matches a pinyin query against Chinese text. Returns matched character indices, or `null` if no match.

```dart
matchPinyin('中文拼音', 'zwp');     // [0, 1, 2]
matchPinyin('中文拼音', 'zw');      // [0, 1]
matchPinyin('中文拼音', 'xyz');     // null
```

**`MatchOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `precision` | `MatchPrecision` | `first` | `first` (match first letter), `start` (match from start), `full` (full syllable) |
| `space` | `MatchSpace` | `ignore` | `ignore` or `preserve` spaces in query |

---

### `convertPinyin(input, {format, separator})`

Converts pinyin between numeric-tone, symbol-tone, and tone-free formats.

```dart
convertPinyin('pin1 yin1');                                   // 'pīn yīn'
convertPinyin('pīn yīn', format: ConvertFormat.symbolToNum); // 'pin1 yin1'
convertPinyin('pīn yīn', format: ConvertFormat.toneNone);    // 'pin yin'
convertPinyin(['pin1', 'yin1']);                              // ['pīn', 'yīn']
```

---

### `htmlPinyin(text, {options})`

Generates HTML with ruby pinyin annotations.

```dart
htmlPinyin('汉字');
// '<span class="py-result-item"><ruby>汉<rp>(</rp><rt>hàn</rt><rp>)</rp></ruby></span>...'
```

**`HtmlOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `toneType` | `ToneType` | `symbol` | Tone format |
| `noClass` | `bool` | `false` | Omit class attributes |
| `resultClass` | `String` | `'py-result-item'` | Class for each span |
| `pinyinClass` | `String` | `'py-pinyin-item'` | Class for `<rt>` |
| `nonZhClass` | `String` | `'py-non-zh-item'` | Class for non-Chinese spans |

---

### `polyphonic(text, {options})`

Returns all possible readings for each character.

```dart
polyphonic('好好学习');
// [['hǎo', 'hào'], ['hǎo', 'hào'], ['xué'], ['xí']]

polyphonic('好好学习', options: PolyphonicOptions(returnType: PolyphonicReturnType.string));
// ['hǎo hào', 'hǎo hào', 'xué', 'xí']
```

---

### `segmentPinyin(word, {options})`

Word-segmented pinyin with configurable output format.

```dart
segmentPinyin('我是中国人',
    options: SegmentOptions(format: OutputFormat.pinyinArray));
// [['wǒ'], ['shì'], ['zhōng', 'guó', 'rén']]

segmentPinyin('我是中国人',
    options: SegmentOptions(format: OutputFormat.allSegment));
// [SegmentItem(origin:'我', result:'wǒ'), ...]
```

**`OutputFormat` values:** `allSegment`, `allArray`, `allString`, `pinyinSegment`, `pinyinArray`, `pinyinString`, `zhSegment`, `zhArray`, `zhString`

---

### `customPinyin(config, {options})`

Overrides pinyin for specific words or characters.

```dart
// Override a word
customPinyin({'好学': 'hào xué'});
pinyin('好学生');  // 'hào xué shēng'

// Override with multiple readings (single char)
customPinyin({'好': 'hào'}, options: CustomPinyinOptions(multiple: CustomHandleType.add));

// Clear overrides
clearCustomDict();
clearCustomDict(CustomDictType.single);
clearCustomDict(CustomDictType.multiple);
```

---

### `addDict(dict, {options})` / `removeDict([name])`

Adds or removes a custom word dictionary for the AC automaton.

```dart
addDict({'术语': ['shù yǔ', 2e-5]},
    options: DictOptions(name: 'custom'));
pinyin('术语');  // 'shù yǔ'

removeDict('custom');
```

**`DictValue` formats:** `String`, `[String]`, `[String, double]`, `[String, double, String]`

**`DictHandleType`** (for single-char entries): `add`, `replace`, `ignore`

---

### Phonetic utilities

```dart
getInitialAndFinal('guang');   // (initial: 'g', final_: 'uang')
getFinalParts('guang');        // (head: 'u', body: 'a', tail: 'ng')
getNumOfTone('pīn yīn');      // '1 1'
getPinyinWithoutTone('pīn');  // 'pin'
getSingleWordPinyin('汉');     // 'hàn'
getAllPinyin('好');             // ['hǎo', 'hào']
```

---

## Origin

This library is a Dart/Flutter port of [pinyin-pro](https://github.com/zh-lx/pinyin-pro) by [zh-lx](https://github.com/zh-lx), a professional Chinese pinyin library for JavaScript/TypeScript. All core algorithms (Aho-Corasick automaton, maximum probability segmentation, tone sandhi rules) and dictionaries are ported from the original.