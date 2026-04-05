enum OneClickQualityPreset {
  best,
  good,
  normal,
  bad,
  worst,
}

enum LanguageCode {
  en,
  es,
  ar,
  id,
  pt,
  fr,
  it,
  zh,
  zhTW,
  ko,
  ja,
  ru,
  tr,
  de,
}

class LanguageDefinition {
  final String flag;
  final String name;
  final String hreflang;

  LanguageDefinition({
    required this.flag,
    required this.name,
    required this.hreflang,
  });
}

final Map<LanguageCode, LanguageDefinition> languages = {
  LanguageCode.en: LanguageDefinition(
    flag: '🇺🇸',
    name: 'English',
    hreflang: 'en',
  ),
  LanguageCode.es: LanguageDefinition(
    flag: '🇪🇸',
    name: 'Español',
    hreflang: 'es',
  ),
  LanguageCode.ar: LanguageDefinition(
    flag: '🇸🇦',
    name: 'العربية',
    hreflang: 'ar',
  ),
  LanguageCode.id: LanguageDefinition(
    flag: '🇮🇩',
    name: 'Bahasa Indonesia',
    hreflang: 'id',
  ),
  LanguageCode.pt: LanguageDefinition(
    flag: '🇧🇷',
    name: 'Português',
    hreflang: 'pt-BR',
  ),
  LanguageCode.fr: LanguageDefinition(
    flag: '🇫🇷',
    name: 'Français',
    hreflang: 'fr',
  ),
  LanguageCode.it: LanguageDefinition(
    flag: '🇮🇹',
    name: 'Italiano',
    hreflang: 'it',
  ),
  LanguageCode.zh: LanguageDefinition(
    flag: '🇨🇳',
    name: '中文',
    hreflang: 'zh-CN',
  ),
  LanguageCode.zhTW: LanguageDefinition(
    flag: '🇹🇼',
    name: '繁體中文',
    hreflang: 'zh-TW',
  ),
  LanguageCode.ko: LanguageDefinition(
    flag: '🇰🇷',
    name: '한국어',
    hreflang: 'ko',
  ),
  LanguageCode.ja: LanguageDefinition(
    flag: '🇯🇵',
    name: '日本語',
    hreflang: 'ja',
  ),
  LanguageCode.ru: LanguageDefinition(
    flag: '🇷🇺',
    name: 'Русский',
    hreflang: 'ru',
  ),
  LanguageCode.tr: LanguageDefinition(
    flag: '🇹🇷',
    name: 'Türkçe',
    hreflang: 'tr',
  ),
  LanguageCode.de: LanguageDefinition(
    flag: '🇩🇪',
    name: 'Deutsch',
    hreflang: 'de',
  ),
};

const LanguageCode defaultLanguageCode = LanguageCode.en;

class AppSettings {
  final String downloadPath;
  final int maxConcurrentDownloads;
  final String browserForCookies;
  final String cookiesPath;
  final String proxy;
  final String configPath;
  final bool betaProgram;
  final LanguageCode language;
  final String theme;
  final bool oneClickDownload;
  final String oneClickDownloadType;
  final OneClickQualityPreset oneClickQuality;
  final bool closeToTray;
  final bool hideDockIcon;
  final bool launchAtLogin;
  final bool autoUpdate;
  final bool subscriptionOnlyLatestDefault;
  final bool enableAnalytics;
  final bool embedSubs;
  final bool embedThumbnail;
  final bool embedMetadata;
  final bool embedChapters;
  final bool shareWatermark;

  AppSettings({
    required this.downloadPath,
    required this.maxConcurrentDownloads,
    required this.browserForCookies,
    required this.cookiesPath,
    required this.proxy,
    required this.configPath,
    required this.betaProgram,
    required this.language,
    required this.theme,
    required this.oneClickDownload,
    required this.oneClickDownloadType,
    required this.oneClickQuality,
    required this.closeToTray,
    required this.hideDockIcon,
    required this.launchAtLogin,
    required this.autoUpdate,
    required this.subscriptionOnlyLatestDefault,
    required this.enableAnalytics,
    required this.embedSubs,
    required this.embedThumbnail,
    required this.embedMetadata,
    required this.embedChapters,
    required this.shareWatermark,
  });

  static const String defaultSubscriptionFilenameTemplate = '%(uploader)s/%(title)s.%(ext)s';

  factory AppSettings.defaults() {
    return AppSettings(
      downloadPath: '',
      maxConcurrentDownloads: 5,
      browserForCookies: 'none',
      cookiesPath: '',
      proxy: '',
      configPath: '',
      betaProgram: false,
      language: defaultLanguageCode,
      theme: 'system',
      oneClickDownload: false,
      oneClickDownloadType: 'video',
      oneClickQuality: OneClickQualityPreset.best,
      closeToTray: true,
      hideDockIcon: false,
      launchAtLogin: false,
      autoUpdate: true,
      subscriptionOnlyLatestDefault: true,
      enableAnalytics: true,
      embedSubs: true,
      embedThumbnail: false,
      embedMetadata: true,
      embedChapters: true,
      shareWatermark: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'maxConcurrentDownloads': maxConcurrentDownloads,
      'browserForCookies': browserForCookies,
      'cookiesPath': cookiesPath,
      'proxy': proxy,
      'configPath': configPath,
      'betaProgram': betaProgram,
      'language': language.name,
      'theme': theme,
      'oneClickDownload': oneClickDownload,
      'oneClickDownloadType': oneClickDownloadType,
      'oneClickQuality': oneClickQuality.name,
      'closeToTray': closeToTray,
      'hideDockIcon': hideDockIcon,
      'launchAtLogin': launchAtLogin,
      'autoUpdate': autoUpdate,
      'subscriptionOnlyLatestDefault': subscriptionOnlyLatestDefault,
      'enableAnalytics': enableAnalytics,
      'embedSubs': embedSubs,
      'embedThumbnail': embedThumbnail,
      'embedMetadata': embedMetadata,
      'embedChapters': embedChapters,
      'shareWatermark': shareWatermark,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      downloadPath: json['downloadPath'] as String? ?? '',
      maxConcurrentDownloads: json['maxConcurrentDownloads'] as int? ?? 5,
      browserForCookies: json['browserForCookies'] as String? ?? 'none',
      cookiesPath: json['cookiesPath'] as String? ?? '',
      proxy: json['proxy'] as String? ?? '',
      configPath: json['configPath'] as String? ?? '',
      betaProgram: json['betaProgram'] as bool? ?? false,
      language: LanguageCode.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => defaultLanguageCode,
      ),
      theme: json['theme'] as String? ?? 'system',
      oneClickDownload: json['oneClickDownload'] as bool? ?? false,
      oneClickDownloadType: json['oneClickDownloadType'] as String? ?? 'video',
      oneClickQuality: OneClickQualityPreset.values.firstWhere(
        (e) => e.name == json['oneClickQuality'],
        orElse: () => OneClickQualityPreset.best,
      ),
      closeToTray: json['closeToTray'] as bool? ?? true,
      hideDockIcon: json['hideDockIcon'] as bool? ?? false,
      launchAtLogin: json['launchAtLogin'] as bool? ?? false,
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      subscriptionOnlyLatestDefault: json['subscriptionOnlyLatestDefault'] as bool? ?? true,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      embedSubs: json['embedSubs'] as bool? ?? true,
      embedThumbnail: json['embedThumbnail'] as bool? ?? false,
      embedMetadata: json['embedMetadata'] as bool? ?? true,
      embedChapters: json['embedChapters'] as bool? ?? true,
      shareWatermark: json['shareWatermark'] as bool? ?? false,
    );
  }

  AppSettings copyWith({
    String? downloadPath,
    int? maxConcurrentDownloads,
    String? browserForCookies,
    String? cookiesPath,
    String? proxy,
    String? configPath,
    bool? betaProgram,
    LanguageCode? language,
    String? theme,
    bool? oneClickDownload,
    String? oneClickDownloadType,
    OneClickQualityPreset? oneClickQuality,
    bool? closeToTray,
    bool? hideDockIcon,
    bool? launchAtLogin,
    bool? autoUpdate,
    bool? subscriptionOnlyLatestDefault,
    bool? enableAnalytics,
    bool? embedSubs,
    bool? embedThumbnail,
    bool? embedMetadata,
    bool? embedChapters,
    bool? shareWatermark,
  }) {
    return AppSettings(
      downloadPath: downloadPath ?? this.downloadPath,
      maxConcurrentDownloads: maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      browserForCookies: browserForCookies ?? this.browserForCookies,
      cookiesPath: cookiesPath ?? this.cookiesPath,
      proxy: proxy ?? this.proxy,
      configPath: configPath ?? this.configPath,
      betaProgram: betaProgram ?? this.betaProgram,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      oneClickDownload: oneClickDownload ?? this.oneClickDownload,
      oneClickDownloadType: oneClickDownloadType ?? this.oneClickDownloadType,
      oneClickQuality: oneClickQuality ?? this.oneClickQuality,
      closeToTray: closeToTray ?? this.closeToTray,
      hideDockIcon: hideDockIcon ?? this.hideDockIcon,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      subscriptionOnlyLatestDefault: subscriptionOnlyLatestDefault ?? this.subscriptionOnlyLatestDefault,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      embedSubs: embedSubs ?? this.embedSubs,
      embedThumbnail: embedThumbnail ?? this.embedThumbnail,
      embedMetadata: embedMetadata ?? this.embedMetadata,
      embedChapters: embedChapters ?? this.embedChapters,
      shareWatermark: shareWatermark ?? this.shareWatermark,
    );
  }
}
