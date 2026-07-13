import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/utils/url_utils.dart';

void main() {
  group('isValidHttpUrl', () {
    test('接受完整 http(s) URL', () {
      expect(isValidHttpUrl('https://b23.tv/wNsCzjk'), isTrue);
      expect(isValidHttpUrl('http://example.com/a'), isTrue);
    });

    test('拒绝空串与仅 scheme', () {
      expect(isValidHttpUrl(''), isFalse);
      expect(isValidHttpUrl('   '), isFalse);
      expect(isValidHttpUrl('https://'), isFalse);
      expect(isValidHttpUrl('http://'), isFalse);
      expect(isValidHttpUrl('not a url'), isFalse);
    });
  });

  group('normalizeVideoUrl', () {
    test('空输入返回空串，不补 https://', () {
      expect(normalizeVideoUrl(''), '');
      expect(normalizeVideoUrl('   '), '');
    });

    test('保留完整 URL', () {
      expect(
        normalizeVideoUrl('https://b23.tv/wNsCzjk'),
        'https://b23.tv/wNsCzjk',
      );
    });

    test('从分享文案中提取 b23 短链', () {
      final text = '我邻居可太可爱了 https://b23.tv/wNsCzjk 分享自B站';
      expect(normalizeVideoUrl(text), 'https://b23.tv/wNsCzjk');
    });

    test('BV 号补全', () {
      expect(
        normalizeVideoUrl('BV1xx411c7mD'),
        'https://www.bilibili.com/video/BV1xx411c7mD',
      );
    });

    test('YouTube 11 位 ID 补全', () {
      expect(
        normalizeVideoUrl('dQw4w9WgXcQ'),
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
    });

    test('移动端 bilibili 转桌面', () {
      expect(
        normalizeVideoUrl('https://m.bilibili.com/video/BV1xx411c7mD'),
        'https://www.bilibili.com/video/BV1xx411c7mD',
      );
    });
  });

  group('resolveDownloadUrl', () {
    test('优先使用解析时锁定的 URL', () {
      expect(
        resolveDownloadUrl(
          parsedUrl: 'https://b23.tv/wNsCzjk',
          webpageUrl: 'https://www.bilibili.com/video/BVxxx',
          inputText: '',
        ),
        'https://b23.tv/wNsCzjk',
      );
    });

    test('输入框被清空时不会变成 https://', () {
      expect(
        resolveDownloadUrl(
          parsedUrl: 'https://b23.tv/wNsCzjk',
          webpageUrl: null,
          inputText: '',
        ),
        'https://b23.tv/wNsCzjk',
      );
      expect(
        isValidHttpUrl(
          resolveDownloadUrl(
            parsedUrl: 'https://b23.tv/wNsCzjk',
            webpageUrl: null,
            inputText: '',
          ),
        ),
        isTrue,
      );
    });

    test('无 parsedUrl 时回退 webpageUrl', () {
      expect(
        resolveDownloadUrl(
          parsedUrl: null,
          webpageUrl: 'https://www.bilibili.com/video/BVxxx',
          inputText: '',
        ),
        'https://www.bilibili.com/video/BVxxx',
      );
    });

    test('无锁定 URL 时从输入框补全', () {
      expect(
        resolveDownloadUrl(
          parsedUrl: null,
          webpageUrl: null,
          inputText: 'https://b23.tv/abc',
        ),
        'https://b23.tv/abc',
      );
    });

    test('全部无效时不会产出可下载 URL', () {
      final url = resolveDownloadUrl(
        parsedUrl: 'https://',
        webpageUrl: '',
        inputText: '',
      );
      expect(isValidHttpUrl(url), isFalse);
    });
  });
}
