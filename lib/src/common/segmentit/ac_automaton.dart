// ignore_for_file: lines_longer_than_80_chars
library pinyin_pro_flutter;

import 'package:pinyin_pro_flutter/src/common/constants.dart';
import 'package:pinyin_pro_flutter/src/common/types.dart';
import 'package:pinyin_pro_flutter/src/common/utils.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/max_probability.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/min_tokenization.dart';
import 'package:pinyin_pro_flutter/src/common/segmentit/reverse_max_match.dart';

/// Tokenization algorithm used by [AcAutomaton.search].
enum TokenizationAlgorithm {
  /// Reverse maximum match (fastest, moderate accuracy).
  reverseMaxMatch,

  /// Maximum probability (moderate speed, high accuracy).
  maxProbability,

  /// Minimum tokenization count (moderate speed, high accuracy).
  minTokenization,
}

/// A pattern entry in the AC automaton.
class Pattern {
  String zh;
  String pinyin;
  double probability;
  int length;
  int priority;
  String dict;
  String? pos;
  _TrieNode? node;

  Pattern({
    required this.zh,
    required this.pinyin,
    required this.probability,
    required this.length,
    required this.priority,
    required this.dict,
    this.pos,
    this.node,
  });
}

/// A [Pattern] that matched at a specific index in the input.
class MatchPattern extends Pattern {
  final int index;

  MatchPattern({
    required this.index,
    required super.zh,
    required super.pinyin,
    required super.probability,
    required super.length,
    required super.priority,
    required super.dict,
    super.pos,
    super.node,
  });

  factory MatchPattern.from(Pattern p, int index) => MatchPattern(
        index: index,
        zh: p.zh,
        pinyin: p.pinyin,
        probability: p.probability,
        length: p.length,
        priority: p.priority,
        dict: p.dict,
        pos: p.pos,
        node: p.node,
      );
}

class _TrieNode {
  final Map<String, _TrieNode> children = {};
  _TrieNode? fail;
  final List<Pattern> patterns = [];
  final String prefix;
  final _TrieNode? parent;
  final String key;

  _TrieNode({
    required this.parent,
    this.prefix = '',
    this.key = '',
  });
}

/// Aho-Corasick automaton for efficient multi-pattern matching.
class AcAutomaton {
  final _TrieNode _root = _TrieNode(parent: null);
  final Map<String, Set<Pattern>> _dictMap = {};
  // queues[depth] = list of nodes at that depth (for BFS fail pointer build)
  final List<List<_TrieNode>> _queues = [];

  /// Builds the trie and fail pointers from [patternList].
  void build(List<Pattern> patternList) {
    _buildTrie(patternList);
    _buildFailPointers();
  }

  void _buildTrie(List<Pattern> patternList) {
    for (final pattern in patternList) {
      final chars = splitString(pattern.zh);
      var cur = _root;
      for (var i = 0; i < chars.length; i++) {
        final c = chars[i];
        if (!cur.children.containsKey(c)) {
          final prefix = chars.sublist(0, i).join('');
          final node = _TrieNode(parent: cur, prefix: prefix, key: c);
          cur.children[c] = node;
          _addNodeToQueues(node);
        }
        cur = cur.children[c]!;
      }
      _insertPattern(cur.patterns, pattern);
      pattern.node = cur;
      _addPatternToDictMap(pattern);
    }
  }

  void _buildFailPointers() {
    final queue = <_TrieNode>[];
    for (final q in _queues) {
      queue.addAll(q);
    }
    _queues.clear();

    var queueIndex = 0;
    while (queueIndex < queue.length) {
      final node = queue[queueIndex++];
      var failNode = node.parent?.fail;
      final key = node.key;

      while (failNode != null && !failNode.children.containsKey(key)) {
        failNode = failNode.fail;
      }
      if (failNode == null) {
        node.fail = _root;
      } else {
        node.fail = failNode.children[key];
      }
    }
  }

  void _addPatternToDictMap(Pattern pattern) {
    _dictMap.putIfAbsent(pattern.dict, () => {}).add(pattern);
  }

  void _addNodeToQueues(_TrieNode node) {
    final depth = stringLength(node.prefix);
    while (_queues.length <= depth) {
      _queues.add([]);
    }
    _queues[depth].add(node);
  }

  /// Inserts [pattern] into [patterns] list sorted by priority/probability.
  void _insertPattern(List<Pattern> patterns, Pattern pattern) {
    for (var i = patterns.length - 1; i >= 0; i--) {
      final existing = patterns[i];
      if (pattern.priority == existing.priority &&
          pattern.probability >= existing.probability) {
        if (i + 1 >= patterns.length) {
          patterns.add(existing);
        } else {
          patterns[i + 1] = existing;
        }
      } else if (pattern.priority > existing.priority) {
        if (i + 1 >= patterns.length) {
          patterns.add(existing);
        } else {
          patterns[i + 1] = existing;
        }
      } else {
        if (i + 1 >= patterns.length) {
          patterns.add(pattern);
        } else {
          patterns[i + 1] = pattern;
        }
        return;
      }
    }
    if (patterns.isEmpty) {
      patterns.add(pattern);
    } else {
      patterns[0] = pattern;
    }
  }

  /// Removes all patterns belonging to [dictName] from the automaton.
  void removeDict(String dictName) {
    final set = _dictMap[dictName];
    if (set == null) return;
    for (final pattern in set) {
      pattern.node?.patterns.remove(pattern);
    }
    _dictMap.remove(dictName);
  }

  /// Matches [text] against all patterns and returns raw hits.
  List<MatchPattern> match(String text, SurnameMode surname) {
    var cur = _root;
    final result = <MatchPattern>[];
    final chars = splitString(text);

    for (var i = 0; i < chars.length; i++) {
      final c = chars[i];

      while (cur != _root && !cur.children.containsKey(c)) {
        cur = cur.fail ?? _root;
      }

      if (cur.children.containsKey(c)) {
        cur = cur.children[c]!;
        final pattern = _findPattern(cur.patterns, surname, i);
        if (pattern != null) {
          result.add(MatchPattern.from(pattern, i - pattern.length + 1));
        }
        var failNode = cur.fail;
        while (failNode != null) {
          final fp = _findPattern(failNode.patterns, surname, i);
          if (fp != null) {
            result.add(MatchPattern.from(fp, i - fp.length + 1));
          }
          failNode = failNode.fail;
        }
      }
    }
    return result;
  }

  Pattern? _findPattern(
      List<Pattern> patterns, SurnameMode surname, int i) {
    for (final p in patterns) {
      if (surname == SurnameMode.off) {
        if (p.priority != kPrioritySurname) return p;
      } else if (surname == SurnameMode.head) {
        if (p.length - 1 - i == 0) return p;
      } else {
        return p;
      }
    }
    return null;
  }

  /// Matches and then applies the chosen [algorithm] to resolve overlaps.
  List<MatchPattern> search(
    String text,
    SurnameMode surname, {
    TokenizationAlgorithm algorithm = TokenizationAlgorithm.maxProbability,
  }) {
    final patterns = match(text, surname);
    switch (algorithm) {
      case TokenizationAlgorithm.reverseMaxMatch:
        return reverseMaxMatch(patterns);
      case TokenizationAlgorithm.minTokenization:
        return minTokenization(patterns, stringLength(text));
      case TokenizationAlgorithm.maxProbability:
        return maxProbability(patterns, stringLength(text));
    }
  }
}
