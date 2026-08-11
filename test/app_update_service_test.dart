import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:vidbee_flutter/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService', () {
    test('compares release versions without tag prefixes', () {
      expect(AppUpdateService.isNewerVersion('v1.0.13', '1.0.12'), isTrue);
      expect(AppUpdateService.isNewerVersion('v1.0.12', '1.0.12'), isFalse);
      expect(AppUpdateService.isNewerVersion('v1.0.12+13', '1.0.12'), isFalse);
    });

    test('selects APK asset matching supported ABI', () {
      final assets = [
        AppReleaseAsset(
          name: 'app-armeabi-v7a-release.apk',
          downloadUrl: 'https://example.com/armeabi.apk',
          size: 10,
        ),
        AppReleaseAsset(
          name: 'app-arm64-v8a-release.apk',
          downloadUrl: 'https://example.com/arm64.apk',
          size: 20,
        ),
      ];

      final asset = AppUpdateService.selectBestApkAsset(assets, ['arm64-v8a']);

      expect(asset?.name, 'app-arm64-v8a-release.apk');
    });

    test('falls back to universal APK asset', () {
      final assets = [
        AppReleaseAsset(
          name: 'app-release.apk',
          downloadUrl: 'https://example.com/universal.apk',
          size: 30,
        ),
      ];

      final asset = AppUpdateService.selectBestApkAsset(assets, ['arm64-v8a']);

      expect(asset?.name, 'app-release.apk');
    });

    test('rejects a truncated APK and removes the partial file', () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'vidbee_update_test_',
      );
      final client = _StreamClient(
        (_) async => http.StreamedResponse(
          Stream.value(<int>[1, 2, 3]),
          HttpStatus.ok,
          contentLength: 5,
        ),
      );
      final service = AppUpdateService(
        client: client,
        temporaryDirectoryProvider: () async => temporaryDirectory,
      );
      const asset = AppReleaseAsset(
        name: 'app-release.apk',
        downloadUrl: 'https://example.com/app-release.apk',
        size: 5,
      );
      const release = AppReleaseInfo(
        currentVersion: '1.0.0',
        latestVersion: '1.0.1',
        releaseName: '1.0.1',
        releaseUrl: 'https://example.com/release',
        isUpdateAvailable: true,
        asset: asset,
      );
      final partialFile = File('${temporaryDirectory.path}/${asset.name}');

      try {
        await expectLater(
          service.downloadReleaseAsset(release),
          throwsA(
            isA<HttpException>().having(
              (error) => error.message,
              'message',
              contains('received 3 of 5 bytes'),
            ),
          ),
        );
        expect(await partialFile.exists(), isFalse);
      } finally {
        service.dispose();
        if (await temporaryDirectory.exists()) {
          await temporaryDirectory.delete(recursive: true);
        }
      }
    });
  });
}

class _StreamClient extends http.BaseClient {
  _StreamClient(this._send);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _send;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _send(request);
}
