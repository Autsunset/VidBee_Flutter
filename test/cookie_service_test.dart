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

      expect(youtubePath, isNotNull);
      expect(bilibiliPath, isNotNull);
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
