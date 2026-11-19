# pinyin_pro_flutter

A professional Chinese pinyin conversion library for Dart and Flutter — a full port of [pinyin-pro](https://github.com/zh-lx/pinyin-pro) (TypeScript, v3.29.5).

> **Note:** This project was developed with AI assistance.

---

## Features

- Tone marks (symbols or numeric) and tone-free output
- Multi-reading (polyphonic) characters
- Tone sandhi (变调) for 一 and 不, with opt-in consecutive third-tone sandhi
- Surname mode (姓氏模式)
- Text-pinyin fuzzy matching
- HTML ruby markup generation
- Word segmentation with pinyin
- Custom dictionaries and overrides
- Traditional character support (via `addTraditionalDict`)
- Phonetic components: initial (声母), final (韵母), head, body, tail
- Pure Dart: works in Flutter apps, Dart CLI tools, and servers

## Requirements

- Dart 3.0+
- Flutter 3.0+ (optional — the package itself has no Flutter dependency)

## Installation

For a Flutter project:

```bash
flutter pub add pinyin_pro_flutter
```

For a pure Dart project:

```bash
dart pub add pinyin_pro_flutter
```

## Quick Start

```dart
import 'package:pinyin_pro_flutter/pinyin_pro_flutter.dart';

pinyin('汉语拼音');                        // 'hàn yǔ pīn yīn'
pinyin('好好学习', options: PinyinOptions(toneType: ToneType.num));
// 'hao3 hao4 xue2 xi2'
pinyin('好', options: PinyinOptions(multiple: true)); // 'hǎo hào'
```

---

## API

### `pinyin(word, {options})`

Converts a Chinese string to pinyin.

The return type depends on `options.returnType`:

| `returnType` | Returns |
|---|---|
| `PinyinReturnType.string` (default) | `String` |
| `PinyinReturnType.array` | `List<String>` |
| `PinyinReturnType.all` | `List<PinyinAllData>` |

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
// 'īn īn'

// First letter
pinyin('拼音', options: PinyinOptions(pattern: PinyinPattern.first));
// 'p y'

// Surname mode
pinyin('曾小贤', options: PinyinOptions(surname: SurnameMode.head));
// 'zēng xiǎo xián'

// Tone sandhi (变调)
pinyin('一路顺风', options: PinyinOptions(toneSandhi: true));
// 'yí lù shùn fēng'

// Consecutive third-tone sandhi (opt-in)
pinyin('你好', options: PinyinOptions(
  toneSandhi: ToneSandhiOptions(thirdTone: true),
)); // 'ní hǎo'

// All data per character
pinyin('好', options: PinyinOptions(returnType: PinyinReturnType.all));
// [PinyinAllData(origin: '好', pinyin: 'hǎo', ...)]
```

#### Typed helpers

`pinyin()` returns `dynamic` because the result type depends on the options.
For statically typed code, use the helpers below. Each one forces the
corresponding return type and ignores `options.returnType`.

```dart
pinyinString('汉语拼音'); // 'hàn yǔ pīn yīn'
pinyinArray('汉语');      // ['hàn', 'yǔ']
pinyinAll('汉').first.pinyin; // 'hàn'
```

| Helper | Returns |
|---|---|
| `pinyinString(word, {options})` | `String` |
| `pinyinArray(word, {options})` | `List<String>` |
| `pinyinAll(word, {options})` | `List<PinyinAllData>` |

**`PinyinOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `toneType` | `ToneType` | `symbol` | `symbol`, `num`, `none` |
| `pattern` | `PinyinPattern` | `pinyin` | `pinyin`, `num`, `initial`, `final_`, `first`, `finalHead`, `finalBody`, `finalTail` |
| `returnType` | `PinyinReturnType` | `string` | `string`, `array`, `all` |
| `separator` | `String` | `' '` | Syllable separator |
| `multiple` | `bool` | `false` | Return all readings (single char only) |
| `surname` | `SurnameMode` | `off` | `off`, `head`, `all` |
| `toneSandhi` | `Object?` | `true` | `true`/`false`, or `ToneSandhiOptions` |
| `nonZh` | `NonZhMode` | `spaced` | `spaced`, `consecutive`, `removed` |
| `nonZhScope` | `RegExp?` | `null` | Regex scope for non-Chinese processing |
| `v` | `bool` | `false` | Replace ü with v |
| `vChar` | `String?` | `null` | Custom replacement character for ü |
| `initialPattern` | `InitialPattern?` | `null` | `yw` or `standard` handling of y/w |
| `traditional` | `bool` | `false` | Recognize traditional characters |
| `segmentit` | `TokenizationAlgorithm` | `maxProbability` | `maxProbability`, `reverseMaxMatch`, `minTokenization` |

**`ToneSandhiOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `yi` | `bool` | `true` | Apply 一 tone sandhi |
| `bu` | `bool` | `true` | Apply 不 tone sandhi |
| `thirdTone` | `bool` | `false` | Turn the first of exactly two consecutive third tones into the second tone |

```dart
pinyin('一把', options: PinyinOptions(
  toneSandhi: ToneSandhiOptions(yi: false),
)); // 'yī bǎ'

pinyin('一把不是', options: PinyinOptions(
  toneSandhi: ToneSandhiOptions(bu: false),
)); // 'yì bǎ bù shì'
```

A plain `bool` keeps the legacy semantics: `true` enables only 一/不 sandhi and `false` disables all sandhi.

---

### `matchPinyin(text, query, {options})`

Fuzzy-matches a pinyin query against Chinese text. Returns matched character indices, or `null` if no match.

```dart
matchPinyin('中文拼音', 'zwp');  // [0, 1, 2]
matchPinyin('中文拼音', 'zw');   // [0, 1]
matchPinyin('中文拼音', 'xyz');  // null

// Replace ü with a custom character while matching
matchPinyin('吕', 'lü', options: MatchOptions(v: 'u')); // [0]
```

**`MatchOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `precision` | `MatchPrecision` | `first` | `first`, `start`, `every`, `any` |
| `continuous` | `bool` | `false` | Require matched indices to be continuous |
| `space` | `MatchSpace` | `ignore` | `ignore` or `preserve` spaces in the query |
| `lastPrecision` | `MatchPrecision` | `start` | Precision used for the last character |
| `insensitive` | `bool` | `true` | Case-insensitive matching |
| `v` | `Object?` | `false` | `true` replaces ü with v; a string replaces ü with that string |

---

### `convertPinyin(input, {separator, format})`

Converts pinyin between numeric-tone, symbol-tone, and tone-free formats.
`input` may be a `String` or `List<String>`; the result has the same type.

```dart
convertPinyin('pin1 yin1');                                   // 'pīn yīn'
convertPinyin('pīn yīn', format: ConvertFormat.symbolToNum);  // 'pin1 yin1'
convertPinyin('pīn yīn', format: ConvertFormat.toneNone);     // 'pin yin'
convertPinyin(['pin1', 'yin1']);                              // ['pīn', 'yīn']
```

---

### `htmlPinyin(text, {options})`

Generates HTML with ruby pinyin annotations.

```dart
htmlPinyin('汉字');
// '<span class="py-result-item"><ruby><span class="py-chinese-item">汉</span>'
// '<rp>(</rp><rt class="py-pinyin-item">hàn</rt><rp>)</rp></ruby></span>...'
```

**`HtmlOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `resultClass` | `String` | `'py-result-item'` | Class for the outer span |
| `chineseClass` | `String` | `'py-chinese-item'` | Class for the Chinese character span |
| `pinyinClass` | `String` | `'py-pinyin-item'` | Class for the `<rt>` tag |
| `nonChineseClass` | `String` | `'py-non-chinese-item'` | Class for non-Chinese spans |
| `wrapNonChinese` | `bool` | `false` | Wrap non-Chinese characters in a span |
| `customClassMap` | `Map<String, List<String>>` | `{}` | Extra classes keyed by class name, per character |
| `rp` | `bool` | `true` | Include `<rp>(</rp>` fallback tags |
| `toneType` | `ToneType` | `symbol` | Tone format |
| `toneSandhi` | `Object?` | `true` | `true`/`false`, or `ToneSandhiOptions` |
| `surname` | `SurnameMode` | `off` | Surname matching mode |
| `traditional` | `bool` | `false` | Recognize traditional characters |
| `v` | `bool` | `false` | Replace ü with v |
| `segmentit` | `TokenizationAlgorithm` | `maxProbability` | Tokenization algorithm |

---

### `polyphonic(text, {options})`

Returns all possible readings for each character.

```dart
// Default: one string per character
polyphonic('好好'); // ['hǎo hào', 'hǎo hào']

// Nested lists
polyphonic('好', options: PolyphonicOptions(
  returnType: PolyphonicReturnType.array,
)); // [['hǎo', 'hào']]
```

#### Typed helpers

```dart
polyphonicString('好好'); // ['hǎo hào', 'hǎo hào']
polyphonicArray('好');    // [['hǎo', 'hào']]
polyphonicAll('好').first.first.pinyin; // 'hǎo'
```

| Helper | Returns |
|---|---|
| `polyphonicString(text, {options})` | `List<String>` |
| `polyphonicArray(text, {options})` | `List<List<String>>` |
| `polyphonicAll(text, {options})` | `List<List<PolyphonicAllData>>` |

**`PolyphonicOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `returnType` | `PolyphonicReturnType` | `string` | `string`, `array`, `all` |
| `toneType` | `ToneType` | `symbol` | Tone format |
| `pattern` | `PinyinPattern` | `pinyin` | Phonetic component to return |
| `nonZh` | `NonZhMode` | `spaced` | How to handle non-Chinese characters |
| `v` | `bool` | `false` | Replace ü with v |
| `initialPattern` | `InitialPattern?` | `null` | `yw` or `standard` handling of y/w |

---

### `segmentPinyin(word, {options})`

Word-segmented pinyin. The return type depends on `options.format`.

```dart
// Segment items (default)
segmentPinyin('我是中国人');
// [SegmentItem(origin: '我', result: 'wǒ'), SegmentItem(origin: '是', result: 'shì'), ...]

// Nested pinyin lists
segmentPinyin('我是中国人',
    options: SegmentOptions(format: OutputFormat.pinyinArray));
// [['wǒ'], ['shì'], ['zhōng'], ['guó'], ['rén']]
```

**`OutputFormat` values:** `allSegment`, `allArray`, `allString`, `pinyinSegment`, `pinyinArray`, `pinyinString`, `zhSegment`, `zhArray`, `zhString`

#### Typed helpers

Each helper forces the corresponding `OutputFormat`:

| Helper | `OutputFormat` | Returns |
|---|---|---|
| `segmentAllSegment(word, {options})` | `allSegment` | `List<SegmentItem>` |
| `segmentAllArray(word, {options})` | `allArray` | `List<List<SegmentItem>>` |
| `segmentAllString(word, {options})` | `allString` | `SegmentItem` |
| `segmentPinyinSegment(word, {options})` | `pinyinSegment` | `List<String>` |
| `segmentPinyinArray(word, {options})` | `pinyinArray` | `List<List<String>>` |
| `segmentPinyinString(word, {options})` | `pinyinString` | `String` |
| `segmentZhSegment(word, {options})` | `zhSegment` | `List<String>` |
| `segmentZhArray(word, {options})` | `zhArray` | `List<List<String>>` |
| `segmentZhString(word, {options})` | `zhString` | `String` |

```dart
segmentPinyinArray('我是中国人');
// [['wǒ'], ['shì'], ['zhōng'], ['guó'], ['rén']]
segmentPinyinString('我是中国人'); // 'wǒ shì zhōng guó rén'
```

**`SegmentOptions`**

| Option | Type | Default | Description |
|---|---|---|---|
| `toneType` | `ToneType` | `symbol` | Tone format |
| `surname` | `SurnameMode` | `off` | Surname matching mode |
| `nonZh` | `NonZhMode` | `spaced` | How to handle non-Chinese characters |
| `v` | `bool` | `false` | Replace ü with v |
| `separator` | `String` | `' '` | Separator used by `*String` formats |
| `toneSandhi` | `Object?` | `true` | `true`/`false`, or `ToneSandhiOptions` |
| `segmentit` | `TokenizationAlgorithm` | `maxProbability` | Tokenization algorithm |
| `format` | `OutputFormat` | `allSegment` | Output format |
| `traditional` | `bool` | `false` | Recognize traditional characters |

---

### `customPinyin(config, {options})`

Overrides pinyin for specific words or characters.

```dart
// Override a word
customPinyin({'好学': 'hào xué'});
pinyin('好学生'); // 'hào xué shēng'

// Add a reading for a single character
customPinyin({'好': 'hào'},
    options: CustomPinyinOptions(multiple: CustomHandleType.add));

// Clear overrides
clearCustomDict(CustomDictType.pinyin);
clearCustomDict([CustomDictType.multiple, CustomDictType.polyphonic]);
```

**`CustomDictType` values:** `pinyin`, `multiple`, `polyphonic`
**`CustomHandleType` values:** `add`, `replace`

---

### `addDict(dict, {options})` / `removeDict([name])`

Adds or removes a custom word dictionary for the AC automaton.

```dart
addDict({'术语': 'shù yǔ'}, options: DictOptions(name: 'custom'));
pinyin('术语'); // 'shù yǔ'

addDict({'术语': ['shù yǔ', 2e-5]}, options: DictOptions(name: 'custom'));

removeDict('custom');
```

**`DictValue` formats:** `String`, `[String]`, `[String, double]`, `[String, double, String]`

**`DictHandleType`** (for single-character entries): `add`, `replace`, `ignore`

---

### `addTraditionalDict(dict)`

Registers traditional → simplified character mappings, enabling pinyin recognition for traditional text when `traditional: true` is set.

```dart
addTraditionalDict({'國': '国', '語': '语'});
pinyin('中國', options: PinyinOptions(traditional: true)); // 'zhōng guó'
```

---

### Phonetic utilities

```dart
final parts = getInitialAndFinal('guang');
parts.initial; // 'g'
parts.final_;  // 'uang'

getFinalParts('guang');     // (head: 'u', body: 'a', tail: 'ng')
getNumOfTone('pīn yīn');    // '1 1'
getPinyinWithoutTone('pīn'); // 'pin'
getSingleWordPinyin('汉');   // 'hàn'
getAllPinyin('好');          // ['hǎo', 'hào']
```

---

## Origin

This library is a Dart/Flutter port of [pinyin-pro](https://github.com/zh-lx/pinyin-pro) by [zh-lx](https://github.com/zh-lx), a professional Chinese pinyin library for JavaScript/TypeScript. The port tracks upstream v3.29.5. All core algorithms (Aho-Corasick automaton, maximum probability segmentation, tone sandhi rules) and dictionaries are ported from the original.
