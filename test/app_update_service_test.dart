import 'package:flutter_test/flutter_test.dart';
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
  });
}
