import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/services/cookie_service.dart';

void main() {
  late Directory tempDir;
  late CookieService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('vidbee_cookie_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
    service = CookieService();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'importNetscapeCookieFile stores cookies and per-domain files',
    () async {
      final source = File('${tempDir.path}/cookies.txt');
      await source.writeAsString('''
# Netscape HTTP Cookie File
.youtube.com	TRUE	/	FALSE	1893456000	SID	youtube-token
www.bilibili.com	FALSE	/	FALSE	1893456000	SESSDATA	bili-token
invalid line
''');

      final imported = await service.importNetscapeCookieFile(source.path);

      expect(imported, isTrue);
      expect(await service.getCookie('youtube.com'), 'SID=youtube-token');
      expect(await service.getCookie('bilibili.com'), 'SESSDATA=bili-token');

      final youtubePath = await service.getCookieFilePathForDomain(
        'youtube.com',
      );
      final bilibiliPath = await service.getCookieFilePathForDomain(
        'www.bilibili.com',
      );
      final bilibiliShortPath = await service.getCookieFilePathForDomain(
        'b23.tv',
      );

      expect(youtubePath, isNotNull);
      expect(bilibiliPath, isNotNull);
      expect(bilibiliShortPath, bilibiliPath);
      expect(await service.hasCookie('b23.tv'), isTrue);
      expect(service.cookieLookupDomain('b23.tv'), 'bilibili.com');
      expect(service.isBilibiliDomain('b23.tv'), isTrue);
      // YouTube 短链 youtu.be 应归一为 youtube.com，复用其 Cookie 与文件路径
      expect(await service.hasCookie('youtu.be'), isTrue);
      expect(service.cookieLookupDomain('youtu.be'), 'youtube.com');
      expect(
        await service.getCookieFilePathForDomain('youtu.be'),
        youtubePath,
      );
      expect(await File(youtubePath!).readAsString(), contains('SID'));
      expect(await File(bilibiliPath!).readAsString(), contains('SESSDATA'));
    },
  );

  test(
    'importNetscapeCookieFile rejects files without valid entries',
    () async {
      final source = File('${tempDir.path}/empty.txt');
      await source.writeAsString('# only comments\nnot\tenough\tcolumns');

      final imported = await service.importNetscapeCookieFile(source.path);

      expect(imported, isFalse);
      expect(await service.getAllCookies(), isEmpty);
    },
  );

  test(
    'importNetscapeCookieFile preserves cookie fields and merges Google domains',
    () async {
      // 用 \t 转义拼接，避免多行字符串中 tab 字符的歧义
      final source = File('${tempDir.path}/cookies.txt');
      await source.writeAsString([
        '# Netscape HTTP Cookie File',
        '.youtube.com\tTRUE\t/\tFALSE\t1893456000\tSID\tyoutube-token',
        '.youtube.com\tTRUE\t/\tTRUE\t1893456000\t__Secure-3PSID\tsecure-token',
        '.google.com\tTRUE\t/\tTRUE\t1893456000\tSID\tgoogle-token',
        'www.bilibili.com\tFALSE\t/\tFALSE\t1893456000\tSESSDATA\tbili-token',
      ].join('\n'));

      final imported = await service.importNetscapeCookieFile(source.path);
      expect(imported, isTrue);

      // secure 字段必须原样保留：__Secure-* 前缀 Cookie 要求 secure=TRUE，
      // 旧实现会统一改写为 FALSE 从而破坏 Google 登录态。
      final youtubePath = await service.getCookieFilePathForDomain(
        'youtube.com',
      );
      expect(youtubePath, isNotNull);
      final youtubeContent = await File(youtubePath!).readAsString();
      expect(youtubeContent, contains('__Secure-3PSID'));
      final secureLine = youtubeContent
          .split('\n')
          .firstWhere((l) => l.contains('__Secure-3PSID'));
      expect(secureLine.split('\t')[3], 'TRUE');
      final sidLine = youtubeContent
          .split('\n')
          .firstWhere((l) => l.contains('SID\tyoutube-token'));
      expect(sidLine.split('\t')[3], 'FALSE');

      // YouTube 解析时应合并 Google 系多域名 Cookie，避免登录态不完整
      final ytCookieFile = await service.getCookieFileForUrl(
        'https://www.youtube.com/watch?v=abc12345678',
      );
      expect(ytCookieFile, isNotNull);
      final mergedContent = await File(ytCookieFile!).readAsString();
      expect(mergedContent, contains('youtube-token'));
      expect(mergedContent, contains('google-token'));
    },
  );
}

class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;

  @override
  Future<String?> getApplicationSupportPath() async => path;

  @override
  Future<String?> getTemporaryPath() async => path;
}
