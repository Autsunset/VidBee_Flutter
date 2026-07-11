class AppConstants {
  static const String appName = 'VidBee_Flutter';
  // 正式版本号由 CI 从 git tag 注入到 Android versionName / PackageInfo.version。
  // 此字段仅作本地调试/未注入时的占位，UI 应优先用 PackageInfo。
  static const String appVersion = '2026.07.11.1';
  static const String githubUrl =
      'https://github.com/Autsunset/VidBee_Flutter';

  static const int defaultMaxConcurrentDownloads = 3;

  static const String dbName = 'vidbee.db';
}
