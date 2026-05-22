// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

/// Tone display format.
enum ToneType {
  /// Tone mark on vowel (default): ā á ǎ à
  symbol,

  /// Numeric suffix: a1 a2 a3 a4
  num,

  /// No tone mark: a
  none,
}

/// Which phonetic component to return.
enum PinyinPattern {
  /// Full pinyin (default).
  pinyin,

  /// Initial consonant (声母).
  initial,

  /// Final (韵母).
  final_,

  /// Tone number only.
  num,

  /// First letter of pinyin.
  first,

  /// Final head (韵头/介音).
  finalHead,

  /// Final body (韵腹).
  finalBody,

  /// Final tail (韵尾).
  finalTail,
}

/// How y/w are treated as initials.
enum InitialPattern {
  /// Treat y/w as initials (default).
  yw,

  /// Standard: y/w are not initials.
  standard,
}

/// Pinyin matching mode.
enum PinyinMode {
  /// Normal mode (default).
  normal,

  /// Surname mode — prioritize surname readings.
  surname,
}

/// Scope of surname matching.
enum SurnameMode {
  /// Disabled (default).
  off,

  /// Applies to entire string.
  all,

  /// Applies only to the first character.
  head,
}

/// How non-Chinese characters are handled.
enum NonZhMode {
  /// Add spaces between consecutive non-Chinese chars (default).
  spaced,

  /// Keep non-Chinese chars consecutive.
  consecutive,

  /// Remove non-Chinese chars from result.
  removed,
}

/// Return format for [pinyin] function.
enum PinyinReturnType {
  /// Space-separated string (default).
  string,

  /// List of pinyin strings.
  array,

  /// List of [PinyinAllData] objects.
  all,
}

/// Full information about a single character's pinyin.
class PinyinAllData {
  /// Original character.
  final String origin;

  /// Full pinyin with tone mark.
  final String pinyin;

  /// Initial consonant (声母).
  final String initial;

  /// Final (韵母).
  final String final_;

  /// Tone number (0–4).
  final int num;

  /// First letter of pinyin.
  final String first;

  /// Final head (韵头/介音).
  final String finalHead;

  /// Final body (韵腹).
  final String finalBody;

  /// Final tail (韵尾).
  final String finalTail;

  /// Whether the character is Chinese.
  final bool isZh;

  /// All possible readings of this character.
  final List<String> polyphonic;

  /// Whether the character is in the main dictionary.
  final bool inZhRange;

  /// The processed result based on options.
  final String result;

  const PinyinAllData({
    required this.origin,
    required this.pinyin,
    required this.initial,
    required this.final_,
    required this.num,
    required this.first,
    required this.finalHead,
    required this.finalBody,
    required this.finalTail,
    required this.isZh,
    required this.polyphonic,
    required this.inZhRange,
    required this.result,
  });

  @override
  String toString() => 'PinyinAllData(origin: $origin, pinyin: $pinyin)';
}

/// Internal intermediate result for a single character.
class SingleWordResult {
  String origin;
  String result;
  final bool isZh;
  String originPinyin;
  bool delete_;

  SingleWordResult({
    required this.origin,
    required this.result,
    required this.isZh,
    required this.originPinyin,
    this.delete_ = false,
  });
}

/// Output segment from [segment] function.
class SegmentItem {
  /// Original Chinese/non-Chinese text.
  final String origin;

  /// Pinyin result.
  final String result;

  const SegmentItem({required this.origin, required this.result});

  @override
  String toString() => 'SegmentItem(origin: $origin, result: $result)';
}
