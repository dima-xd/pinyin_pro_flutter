library pinyin_pro_flutter;

/// Sparse list mapping char code → simplified character string.
final List<String?> _traditionalDict = [];

/// Registers a traditional→simplified character mapping.
///
/// [dict] maps traditional characters (keys) to their simplified equivalents
/// (values). This enables better pinyin recognition for traditional text.
///
/// Example:
/// ```dart
/// addTraditionalDict({'國': '国', '語': '语'});
/// ```
void addTraditionalDict(Map<String, String> dict) {
  dict.forEach((key, value) {
    final code = key.codeUnitAt(0);
    while (_traditionalDict.length <= code) {
      _traditionalDict.add(null);
    }
    _traditionalDict[code] = value;
  });
}

/// Returns the current traditional character mapping.
List<String?> getTraditionalDict() => _traditionalDict;
