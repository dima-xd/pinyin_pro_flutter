// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/handle.dart';
import 'package:pinyin_pro_flutter/src/core/pinyin/pinyin.dart';
import 'package:pinyin_pro_flutter/src/data/dict1.dart';

// ─── nonZh middleware ─────────────────────────────────────────────────────────

bool _isNonZhScope(String char, RegExp? scope) {
  if (scope != null) return scope.hasMatch(char);
  return true;
}

/// Filters or merges non-Chinese characters according to [options.nonZh].
List<SingleWordResult> middlewareNonZh(
    List<SingleWordResult> list, PinyinOptions options) {
  final nonZh = options.nonZh;
  if (nonZh == NonZhMode.removed) {
    return list
        .where((item) =>
            item.isZh ||
            !_isNonZhScope(item.origin, options.nonZhScope))
        .toList();
  } else if (nonZh == NonZhMode.consecutive) {
    for (var i = list.length - 2; i >= 0; i--) {
      final cur = list[i];
      final pre = list[i + 1];
      if (!cur.isZh &&
          !pre.isZh &&
          _isNonZhScope(cur.origin, options.nonZhScope) &&
          _isNonZhScope(pre.origin, options.nonZhScope)) {
        cur.origin += pre.origin;
        cur.result += pre.result;
        pre.delete_ = true;
      }
    }
    return list.where((item) => !item.delete_).toList();
  }
  return list;
}

// ─── multiple middleware ──────────────────────────────────────────────────────

/// When [options.multiple] is true and [word] is a single character, returns
/// all readings; otherwise returns null.
List<SingleWordResult>? middlewareMultiple(
    String word, PinyinOptions options) {
  if (stringLength(word) == 1 && options.multiple) {
    return getMultiplePinyin(word, options.surname);
  }
  return null;
}

// ─── pattern middleware ───────────────────────────────────────────────────────

/// Transforms [list] results according to [options.pattern].
void middlewarePattern(List<SingleWordResult> list, PinyinOptions options) {
  switch (options.pattern) {
    case PinyinPattern.pinyin:
      break;
    case PinyinPattern.num:
      for (final item in list) {
        item.result = item.isZh ? getNumOfTone(item.result) : '';
      }
    case PinyinPattern.initial:
      for (final item in list) {
        item.result = item.isZh
            ? getInitialAndFinal(item.result, options.initialPattern).initial
            : '';
      }
    case PinyinPattern.final_:
      for (final item in list) {
        item.result = item.isZh
            ? getInitialAndFinal(item.result, options.initialPattern).final_
            : '';
      }
    case PinyinPattern.first:
      for (final item in list) {
        item.result = getFirstLetter(item.result, item.isZh);
      }
    case PinyinPattern.finalHead:
      for (final item in list) {
        item.result = item.isZh ? getFinalParts(item.result).head : '';
      }
    case PinyinPattern.finalBody:
      for (final item in list) {
        item.result = item.isZh ? getFinalParts(item.result).body : '';
      }
    case PinyinPattern.finalTail:
      for (final item in list) {
        item.result = item.isZh ? getFinalParts(item.result).tail : '';
      }
  }
}

// ─── toneType middleware ──────────────────────────────────────────────────────

/// Converts tone symbols in [list] according to [options.toneType].
void middlewareToneType(List<SingleWordResult> list, PinyinOptions options) {
  switch (options.toneType) {
    case ToneType.symbol:
      break;
    case ToneType.none:
      for (final item in list) {
        if (item.isZh) item.result = getPinyinWithoutTone(item.result);
      }
    case ToneType.num:
      for (final item in list) {
        if (item.isZh) {
          item.result = getPinyinWithNum(item.result, item.originPinyin);
        }
      }
  }
}

// ─── v middleware ─────────────────────────────────────────────────────────────

/// Replaces ü with v (or [options.vChar]) in results when [options.v] is true.
void middlewareV(List<SingleWordResult> list, PinyinOptions options) {
  if (options.v) {
    final replacement = options.vChar ?? 'v';
    for (final item in list) {
      if (item.isZh) {
        item.result = item.result.replaceAll('ü', replacement);
      }
    }
  }
}

// ─── toneSandhi middleware ────────────────────────────────────────────────────

/// Handles tone sandhi (变调) for 一 and 不.
///
/// When [toneSandhi] is false, resets them to their base tones.
List<SingleWordResult> middlewareToneSandhi(
    List<SingleWordResult> list, bool toneSandhi) {
  if (!toneSandhi) {
    for (final item in list) {
      if (item.origin == '一') {
        item.result = item.originPinyin = 'yī';
      } else if (item.origin == '不') {
        item.result = item.originPinyin = 'bù';
      }
    }
  }
  return list;
}

// ─── type middleware ──────────────────────────────────────────────────────────

/// Formats [list] into the final return type according to [options.returnType].
dynamic middlewareType(
    List<SingleWordResult> list, PinyinOptions options, String word) {
  var processedList = list;
  if (options.multiple && stringLength(word) == 1) {
    var last = '';
    processedList = processedList.where((item) {
      final keep = item.result != last;
      last = item.result;
      return keep;
    }).toList();
  }

  switch (options.returnType) {
    case PinyinReturnType.array:
      return processedList.map((item) => item.result).toList();
    case PinyinReturnType.all:
      return processedList.map((item) {
        final py = item.isZh ? item.result : '';
        final (:initial, :final_) =
            getInitialAndFinal(py, options.initialPattern);
        final (:head, :body, :tail) = getFinalParts(py);
        final List<String> poly;
        if (py.isNotEmpty) {
          final others = getAllPinyin(item.origin, options.surname)
              .where((p) => p != py)
              .toList();
          poly = [py, ...others];
        } else {
          poly = [];
        }
        return PinyinAllData(
          origin: item.origin,
          pinyin: py,
          initial: initial,
          final_: final_,
          first: getFirstLetter(item.result, item.isZh),
          finalHead: head,
          finalBody: body,
          finalTail: tail,
          num: int.tryParse(getNumOfTone(item.originPinyin)) ?? 0,
          isZh: item.isZh,
          polyphonic: poly,
          inZhRange: dict1.get(item.origin) != null,
          result: item.result,
        );
      }).toList();
    case PinyinReturnType.string:
      return processedList
          .map((item) => item.result)
          .join(options.separator);
  }
}
