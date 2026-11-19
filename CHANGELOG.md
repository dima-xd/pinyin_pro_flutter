# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-11-19

Synchronized with upstream [pinyin-pro](https://github.com/zh-lx/pinyin-pro)
v3.29.5. No breaking changes.

### Added

- `ToneSandhiOptions` with `yi`, `bu`, and `thirdTone` flags for fine-grained
  tone sandhi control.
- Opt-in consecutive third-tone sandhi: `你好` → `ní hǎo` when
  `ToneSandhiOptions(thirdTone: true)` is used.
- String replacement support for `MatchOptions.v`, e.g.
  `MatchOptions(v: 'u')` replaces `ü` with `u` while matching.

### Changed

- `toneSandhi` now accepts either a `bool` or `ToneSandhiOptions` in
  `PinyinOptions`, `SegmentOptions`, and `HtmlOptions`. A plain `bool` keeps
  the previous behavior.
- `MatchOptions.v` now accepts `bool` or `String` instead of only `bool`.
- `customPinyin` now batches rebuilds and replaces previous custom patterns
  instead of accumulating them across repeated updates.
- Updated pinyin, segment, match, and dictionary behavior to match upstream
  pinyin-pro v3.29.5.

### Fixed

- `getPinyinWithoutTone` now handles syllabic `n`/`m` and `ê` with combining
  tone marks (`n̄`, `ń`, `ň`, `ǹ`, `m̄`, `ḿ`, `m̌`, `m̀`, `ê̄`, `ế`, `ê̌`, `ề`).
- Corrected the dictionary reading of `行长` to `háng zhǎng`.
- Added the missing `一丁点儿` dictionary entry (`yī dīng diǎn er`).
- Repeated `customPinyin` updates no longer accumulate stale custom patterns.

### Performance

- Added a fast path to `splitString` for strings without surrogate pairs.
- Optimized Aho-Corasick construction and matching with depth tracking,
  direct child lookup, and deferred custom-dictionary rebuilds.
- Reworked maximum-probability segmentation to use backpointers, reducing
  allocations during tokenization.
- Reduced per-character pinyin overhead by avoiding redundant string splits,
  lazily building special-case processors, and reusing character buffers.

[1.1.0]: https://github.com/dima-xd/pinyin_pro_flutter/releases/tag/v1.1.0
