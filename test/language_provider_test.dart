import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/providers/service_providers.dart';

void main() {
  group('resolveAppLanguageCode', () {
    test('keeps supported language codes', () {
      expect(resolveAppLanguageCode('zh'), 'zh');
      expect(resolveAppLanguageCode('en'), 'en');
      expect(resolveAppLanguageCode('ja'), 'ja');
      expect(resolveAppLanguageCode('ko'), 'ko');
    });

    test('uses English for unsupported or missing language codes', () {
      expect(resolveAppLanguageCode('fr'), 'en');
      expect(resolveAppLanguageCode(null), 'en');
    });
  });
}
