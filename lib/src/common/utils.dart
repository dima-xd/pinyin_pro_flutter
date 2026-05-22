library pinyin_pro_flutter;

/// Splits a string into a list of characters, treating surrogate pairs
/// (emoji, supplementary CJK) as single units.
List<String> splitString(String text) {
  final result = <String>[];
  var i = 0;
  final units = text.codeUnits;
  while (i < units.length) {
    final code = units[i];
    // High surrogate (U+D800–U+DBFF)
    if (code >= 0xD800 && code <= 0xDBFF && i + 1 < units.length) {
      final next = units[i + 1];
      if (next >= 0xDC00 && next <= 0xDFFF) {
        result.add(text.substring(i, i + 2));
        i += 2;
        continue;
      }
    }
    result.add(text.substring(i, i + 1));
    i++;
  }
  return result;
}

/// Returns the logical character length of [text], counting surrogate pairs
/// as one character.
int stringLength(String text) {
  var count = 0;
  var i = 0;
  final units = text.codeUnits;
  while (i < units.length) {
    final code = units[i];
    if (code >= 0xD800 && code <= 0xDBFF && i + 1 < units.length) {
      final next = units[i + 1];
      if (next >= 0xDC00 && next <= 0xDFFF) {
        count++;
        i += 2;
        continue;
      }
    }
    count++;
    i++;
  }
  return count;
}

/// Whether [codeUnit] is a high surrogate.
bool isHighSurrogate(int codeUnit) =>
    codeUnit >= 0xD800 && codeUnit <= 0xDBFF;

/// Whether [codeUnit] is a low surrogate.
bool isLowSurrogate(int codeUnit) =>
    codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
