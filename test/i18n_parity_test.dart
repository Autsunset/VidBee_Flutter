// i18n 一致性护栏。
//
// 本项目的国际化是手维护的（见 CLAUDE.md）：每个字符串需要在
// app_localizations.dart 里加一个 `_translate('key')` getter，并在 zh/en/ja/ko
// 四个 `_localizedValues` 映射里各加一条。任一处遗漏都会在运行时静默回退到
// 键名本身而不报错。本测试直接解析这些源文件，确保：
//   1. 四种语言的键集合完全一致；
//   2. AppLocalizations 用到的每个 getter 键在所有语言里都存在；
//   3. 没有任何语言映射里存在无人使用的“死键”。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _i18nDir = 'lib/shared/i18n';
const _languages = ['zh', 'en', 'ja', 'ko'];

/// 从某语言映射文件的 `_localizedValues` 中提取键集合。
/// 键形如行首的 `'someKey':`，值即便包含冒号也不会在行首，故不会误匹配。
Set<String> _mapKeys(String lang) {
  final content = File(
    '$_i18nDir/app_localizations_$lang.dart',
  ).readAsStringSync();
  return RegExp(
    r"^\s*'([a-zA-Z0-9_]+)'\s*:",
    multiLine: true,
  ).allMatches(content).map((m) => m.group(1)!).toSet();
}

/// 从 AppLocalizations 中提取 `_translate('key')` 实际用到的键集合。
Set<String> _getterKeys() {
  final content = File('$_i18nDir/app_localizations.dart').readAsStringSync();
  return RegExp(
    r"_translate\('([a-zA-Z0-9_]+)'\)",
  ).allMatches(content).map((m) => m.group(1)!).toSet();
}

void main() {
  test('四种语言的 i18n 键集合与中文(参考)完全一致', () {
    final reference = _mapKeys('zh');
    expect(reference, isNotEmpty, reason: '未能从 zh 映射中解析到任何键');

    for (final lang in _languages) {
      final keys = _mapKeys(lang);
      final missing = (reference.difference(keys).toList()..sort());
      final extra = (keys.difference(reference).toList()..sort());
      expect(missing, isEmpty, reason: '$lang 映射缺少键: $missing');
      expect(extra, isEmpty, reason: '$lang 映射多出键(其它语言缺失): $extra');
    }
  });

  test('每个 getter 用到的键在所有语言映射中都存在，且无死键', () {
    final getters = _getterKeys();
    expect(getters, isNotEmpty, reason: '未能解析到任何 _translate 键');

    for (final lang in _languages) {
      final missing = (getters.difference(_mapKeys(lang)).toList()..sort());
      expect(missing, isEmpty, reason: '$lang 映射缺少 getter 用到的键: $missing');
    }

    final dead = (_mapKeys('zh').difference(getters).toList()..sort());
    expect(dead, isEmpty, reason: '存在未被任何 getter 使用的死键: $dead');
  });
}
