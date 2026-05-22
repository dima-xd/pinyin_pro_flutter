// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/ac_automaton.dart';
import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/custom.dart';
import 'package:pinyin_pro_flutter/src/core/traditional.dart';
import 'package:pinyin_pro_flutter/src/data/ac_tree.dart';
import 'package:pinyin_pro_flutter/src/data/dict1.dart';
import 'package:pinyin_pro_flutter/src/data/special.dart';
import 'package:pinyin_pro_flutter/src/data/surname.dart';

/// Returns the most common pinyin for a single Chinese character.
///
/// Falls back to returning [char] unchanged if not found.
String getSingleWordPinyin(String char) {
  final pinyin = dict1.get(char);
  if (pinyin == null) return char;
  return pinyin.split(' ')[0];
}

String _getTraditionalWords(String word) {
  final traditionalDict = getTraditionalDict();
  final result = StringBuffer();
  for (final key in splitString(word)) {
    if (key.length == 1) {
      final code = key.codeUnitAt(0);
      if (code < traditionalDict.length) {
        result.write(traditionalDict[code] ?? key);
      } else {
        result.write(key);
      }
    } else {
      result.write(key);
    }
  }
  return result.toString();
}

/// Populates [list] with [SingleWordResult] entries for each character of
/// [word], using the AC automaton to handle multi-char words.
({List<SingleWordResult> list, List<MatchPattern> matches}) getPinyin(
  String word,
  List<SingleWordResult?> list,
  SurnameMode surname,
  TokenizationAlgorithm segmentit, {
  bool? traditional,
}) {
  final searchWord =
      traditional == true ? _getTraditionalWords(word) : word;
  final matches = acTree.search(searchWord, surname, algorithm: segmentit);
  var matchIndex = 0;
  final zhChars = splitString(word);

  for (var i = 0; i < zhChars.length;) {
    final match = matchIndex < matches.length ? matches[matchIndex] : null;
    if (match != null && i == match.index) {
      if (match.length == 1 && match.priority <= kPriorityNormal) {
        final char = zhChars[i];
        match.zh = char;
        final pinyin = _processSpecialPinyin(
          char,
          i > 0 ? zhChars[i - 1] : null,
          i + 1 < zhChars.length ? zhChars[i + 1] : null,
        );
        list[i] = SingleWordResult(
          origin: char,
          result: pinyin,
          isZh: pinyin != char,
          originPinyin: pinyin,
        );
        i++;
        matchIndex++;
        continue;
      }
      final pinyins = match.pinyin.split(' ');
      if (traditional == true) {
        match.zh = zhChars.sublist(match.index, match.index + match.length).join();
      }
      for (var j = 0; j < match.length; j++) {
        final pinyinForChar = j < pinyins.length ? pinyins[j] : '';
        list[i + j] = SingleWordResult(
          origin: zhChars[j + match.index],
          result: pinyinForChar,
          isZh: true,
          originPinyin: pinyinForChar,
        );
      }
      i += match.length;
      matchIndex++;
    } else {
      final char = zhChars[i];
      final pinyin = _processSpecialPinyin(
        char,
        i > 0 ? zhChars[i - 1] : null,
        i + 1 < zhChars.length ? zhChars[i + 1] : null,
      );
      list[i] = SingleWordResult(
        origin: char,
        result: pinyin,
        isZh: pinyin != char,
        originPinyin: pinyin,
      );
      i++;
    }
  }

  return (
    list: list.whereType<SingleWordResult>().toList(),
    matches: matches,
  );
}

/// Removes tone marks from [pinyin], returning plain vowels.
String getPinyinWithoutTone(String pinyin) {
  return pinyin
      .replaceAll(RegExp('[\u0101\u00E1\u01CE\u00E0]'), 'a')
      .replaceAll(RegExp('[\u014D\u00F3\u01D2\u00F2]'), 'o')
      .replaceAll(RegExp('[\u0113\u00E9\u011B\u00E8]'), 'e')
      .replaceAll(RegExp('[\u012B\u00ED\u01D0\u00EC]'), 'i')
      .replaceAll(RegExp('[\u016B\u00FA\u01D4\u00F9]'), 'u')
      .replaceAll(RegExp('[\u01D6\u01D8\u01DA\u01DC]'), 'ü')
      .replaceAll(RegExp('[\u0144\u0148\u01F9]'), 'n')
      .replaceAll('\u1E3F', 'm')
      .replaceAll(RegExp('[\u1EBF\u1EC1]'), 'ê')
      .replaceAll(RegExp('[\u0304\u030C]'), '');
}

/// Returns all possible pinyin readings for [char].
List<String> getAllPinyin(String char, [SurnameMode surname = SurnameMode.off]) {
  final customMultipleDict = getCustomMultipleDict();
  List<String> pinyin;

  final dictEntry = dict1.get(char);
  pinyin = dictEntry != null ? dictEntry.split(' ') : [];

  final customEntry = customMultipleDict.get(char);
  if (customEntry != null) {
    pinyin = customEntry.split(' ');
  } else if (surname != SurnameMode.off) {
    final surnamePinyin = surnameCharMap[char];
    if (surnamePinyin != null) {
      pinyin = [surnamePinyin, ...pinyin.where((p) => p != surnamePinyin)];
    }
  }
  return pinyin;
}

/// Returns [SingleWordResult] entries for every reading of [word].
List<SingleWordResult> getMultiplePinyin(
    String word, [SurnameMode surname = SurnameMode.off]) {
  final pinyin = getAllPinyin(word, surname);
  if (pinyin.isNotEmpty) {
    return pinyin
        .map((v) => SingleWordResult(
              origin: word,
              result: v,
              isZh: true,
              originPinyin: v,
            ))
        .toList();
  } else {
    return [
      SingleWordResult(
        origin: word,
        result: word,
        isZh: false,
        originPinyin: word,
      ),
    ];
  }
}

/// Splits [pinyin] by spaces and returns the initial (声母) and final (韵母)
/// components joined by spaces.
({String initial, String final_}) getInitialAndFinal(
    String pinyin, [InitialPattern? initialPattern]) {
  final pinyinArr = pinyin.split(' ');
  final initialArr = <String>[];
  final finalArr = <String>[];

  for (var py in pinyinArr) {
    for (final init in kInitialList) {
      if (py.startsWith(init)) {
        var fin = py.substring(init.length);
        if (kSpecialInitialList.contains(init) &&
            kSpecialFinalList.contains(fin)) {
          fin = kSpecialFinalMap[fin] ?? fin;
        }
        initialArr.add(init);
        finalArr.add(fin);
        break;
      }
    }
  }

  if (initialPattern == InitialPattern.standard) {
    for (var i = 0; i < initialArr.length; i++) {
      if (initialArr[i] == 'y' || initialArr[i] == 'w') {
        initialArr[i] = '';
      }
    }
  }

  return (
    initial: initialArr.join(' '),
    final_: finalArr.join(' '),
  );
}

/// Returns the head, body, and tail components of the final (韵母).
({String head, String body, String tail}) getFinalParts(String pinyin) {
  final (:initial, :final_) = getInitialAndFinal(pinyin);
  String head = '', body = '', tail = '';
  final plain = getPinyinWithoutTone(final_);
  if (kDoubleFinalList.contains(plain)) {
    head = final_.isEmpty ? '' : final_[0];
    body = final_.length > 1 ? final_[1] : '';
    tail = final_.length > 2 ? final_.substring(2) : '';
  } else {
    body = final_.isEmpty ? '' : final_[0];
    tail = final_.length > 1 ? final_.substring(1) : '';
  }
  return (head: head, body: body, tail: tail);
}

/// Returns the tone number (0–4) for each syllable in [pinyin].
///
/// Returns empty string for non-tonal syllables.
///
/// Uses Unicode code-point escapes to avoid multi-codepoint characters
/// (e.g. n̄ = n + U+0304) being split inside character classes.
String getNumOfTone(String pinyin) {
  // Tone 1: ā ō ē ī ū ǖ (precomposed) or combining macron U+0304
  final tone1 = RegExp('[\u0101\u014D\u0113\u012B\u016B\u01D6\u0304]');
  // Tone 2: á ó é í ú ǘ ń ḿ ế
  final tone2 = RegExp('[\u00E1\u00F3\u00E9\u00ED\u00FA\u01D8\u0144\u1E3F\u1EBF]');
  // Tone 3: ǎ ǒ ě ǐ ǔ ǚ ň or combining caron U+030C
  final tone3 = RegExp('[\u01CE\u01D2\u011B\u01D0\u01D4\u01DA\u0148\u030C]');
  // Tone 4: à ò è ì ù ǜ ǹ ề
  final tone4 = RegExp('[\u00E0\u00F2\u00E8\u00EC\u00F9\u01DC\u01F9\u1EC1]');
  // Tone 0: unmarked vowel
  final tone0 = RegExp(r'[aoeiuüê]');
  final specialTone = RegExp(r'[nm]$');

  final toneNums = <String>[];
  for (final py in pinyin.split(' ')) {
    if (tone1.hasMatch(py)) {
      toneNums.add('1');
    } else if (tone2.hasMatch(py)) {
      toneNums.add('2');
    } else if (tone3.hasMatch(py)) {
      toneNums.add('3');
    } else if (tone4.hasMatch(py)) {
      toneNums.add('4');
    } else if (tone0.hasMatch(py)) {
      toneNums.add('0');
    } else if (specialTone.hasMatch(py)) {
      toneNums.add('0');
    } else {
      toneNums.add('');
    }
  }
  return toneNums.join(' ');
}

/// Converts tone-symbol pinyin to numeric-tone pinyin (e.g. hàn → han4).
String getPinyinWithNum(String pinyin, String originPinyin) {
  final pinyinArr = getPinyinWithoutTone(pinyin).split(' ');
  final toneNumArr = getNumOfTone(originPinyin).split(' ');
  final res = <String>[];
  for (var i = 0; i < pinyinArr.length; i++) {
    final tone = i < toneNumArr.length ? toneNumArr[i] : '';
    res.add('${pinyinArr[i]}$tone');
  }
  return res.join(' ');
}

/// Returns the first letter of [pinyin] for each space-separated syllable.
String getFirstLetter(String pinyin, bool isZh) {
  final arr = <String>[];
  for (final py in pinyin.split(' ')) {
    arr.add(isZh ? (py.isEmpty ? '' : py[0]) : py);
  }
  return arr.join(' ');
}

/// Processes tone sandhi (变调) for 一 and 不.
String? processToneSandhi(String cur, String? pre, String? next) {
  if (!kToneSandhiList.contains(cur)) {
    return getSingleWordPinyin(cur);
  }
  // Reduplication tone sandhi: sandwiched char becomes neutral tone.
  if (pre != null &&
      pre == next &&
      getSingleWordPinyin(pre) != pre) {
    return getPinyinWithoutTone(getSingleWordPinyin(cur));
  }
  if (next != null) {
    final ignoreSuffix = kToneSandhiIgnoreSuffix[cur];
    if (ignoreSuffix == null || !ignoreSuffix.contains(next)) {
      final nextPinyin = getSingleWordPinyin(next);
      if (nextPinyin != next) {
        final nextTone = int.tryParse(getNumOfTone(nextPinyin)) ?? -1;
        final pinyinMap = kToneSandhiMap[cur];
        if (pinyinMap != null) {
          for (final entry in pinyinMap.entries) {
            if (entry.value.contains(nextTone)) {
              return entry.key;
            }
          }
        }
      }
    }
  }
  return null;
}

String? _processToneSandhiLiao(String cur, String? pre) {
  if (cur == '了' && (pre == null || dict1.get(pre) == null)) {
    return 'liǎo';
  }
  return null;
}

String? _processReduplicationChar(String cur, String? pre) {
  if (cur == '々') {
    if (pre == null || dict1.get(pre) == null) {
      return 'tóng';
    } else {
      return dict1.get(pre)!.split(' ')[0];
    }
  }
  return null;
}

String _processSpecialPinyin(String cur, String? pre, String? next) {
  return _processReduplicationChar(cur, pre) ??
      _processToneSandhiLiao(cur, pre) ??
      processToneSandhi(cur, pre, next) ??
      getSingleWordPinyin(cur);
}
