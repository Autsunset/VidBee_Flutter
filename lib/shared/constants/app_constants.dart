class AppConstants {
  static const String appName = 'VidBee_Flutter';
  static const String appVersion = '1.0.0';
  static const String githubUrl = 'https://github.com/Autsunset';

  static const int defaultMaxConcurrentDownloads = 3;
  static const String defaultSubscriptionFilenameTemplate = '%(uploader)s/%(title)s.%(ext)s';

  static const String dbName = 'vidbee.db';

  static const int maxTaskLogLength = 80000;

  static const List<String> supportedLanguages = [
    'en',
    'es',
    'ar',
    'id',
    'pt',
    'fr',
    'it',
    'zh',
    'zh-TW',
    'ko',
    'ja',
    'ru',
    'tr',
    'de',
  ];
}
