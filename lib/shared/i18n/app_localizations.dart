import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

/// 应用本地化类
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  String get appTitle => _translate('appTitle');
  String get addUrl => _translate('addUrl');
  String get download => _translate('download');
  String get history => _translate('history');
  String get settings => _translate('settings');
  String get pasteUrl => _translate('pasteUrl');
  String get audioOnly => _translate('audioOnly');
  String get parse => _translate('parse');
  String get cancel => _translate('cancel');
  String get downloadPath => _translate('downloadPath');
  String get selectPath => _translate('selectPath');
  String get concurrentDownloads => _translate('concurrentDownloads');
  String get enableNotification => _translate('enableNotification');
  String get videoQuality => _translate('videoQuality');
  String get audioQuality => _translate('audioQuality');
  String get themeMode => _translate('themeMode');
  String get language => _translate('language');
  String get about => _translate('about');
  String get version => _translate('version');
  String get updateYtDlp => _translate('updateYtDlp');
  String get login => _translate('login');
  String get logout => _translate('logout');
  String get customUA => _translate('customUA');
  String get save => _translate('save');
  String get ok => _translate('ok');
  String get error => _translate('error');
  String get success => _translate('success');
  String get loading => _translate('loading');
  String get noInternet => _translate('noInternet');
  String get parseFailed => _translate('parseFailed');
  String get downloadFailed => _translate('downloadFailed');
  String get downloadSuccess => _translate('downloadSuccess');
  String get pleaseWait => _translate('pleaseWait');
  String get settingsSaved => _translate('settingsSaved');
  String get loginSuccess => _translate('loginSuccess');
  String get loginFailed => _translate('loginFailed');
  String get cookiesSaved => _translate('cookiesSaved');
  String get cookiesExpired => _translate('cookiesExpired');
  String get enterUrl => _translate('enterUrl');
  String get selectFormat => _translate('selectFormat');
  String get downloadInProgress => _translate('downloadInProgress');
  String get downloadPaused => _translate('downloadPaused');
  String get downloadCancelled => _translate('downloadCancelled');
  String get downloadCompleted => _translate('downloadCompleted');
  String get delete => _translate('delete');
  String get clearAll => _translate('clearAll');
  String get clear => _translate('clear');
  String get confirmDelete => _translate('confirmDelete');
  String get yes => _translate('yes');
  String get no => _translate('no');
  String get networkError => _translate('networkError');
  String get storagePermission => _translate('storagePermission');
  String get permissionDenied => _translate('permissionDenied');
  String get permissionGranted => _translate('permissionGranted');
  String get retry => _translate('retry');
  String get skip => _translate('skip');
  String get next => _translate('next');
  String get previous => _translate('previous');
  String get search => _translate('search');
  String get filter => _translate('filter');
  String get sort => _translate('sort');
  String get refresh => _translate('refresh');
  String get share => _translate('share');
  String get open => _translate('open');
  String get rename => _translate('rename');
  String get move => _translate('move');
  String get copy => _translate('copy');
  String get details => _translate('details');
  String get size => _translate('size');
  String get duration => _translate('duration');
  String get quality => _translate('quality');
  String get format => _translate('format');
  String get resolution => _translate('resolution');
  String get bitrate => _translate('bitrate');
  String get codec => _translate('codec');
  String get channel => _translate('channel');
  String get uploaded => _translate('uploaded');
  String get views => _translate('views');
  String get likes => _translate('likes');
  String get comments => _translate('comments');
  String get description => _translate('description');
  String get relatedVideos => _translate('relatedVideos');
  String get playlist => _translate('playlist');
  String get subscribe => _translate('subscribe');
  String get unsubscribe => _translate('unsubscribe');
  String get notificationSettings => _translate('notificationSettings');
  String get appearance => _translate('appearance');
  String get behavior => _translate('behavior');
  String get network => _translate('network');
  String get advanced => _translate('advanced');
  String get help => _translate('help');
  String get feedback => _translate('feedback');
  String get terms => _translate('terms');
  String get privacy => _translate('privacy');
  String get license => _translate('license');
  String get contributors => _translate('contributors');
  String get donate => _translate('donate');
  String get rate => _translate('rate');
  String get shareApp => _translate('shareApp');
  String get checkForUpdates => _translate('checkForUpdates');
  String get updateAvailable => _translate('updateAvailable');
  String get noUpdate => _translate('noUpdate');
  String get updating => _translate('updating');
  String get updateFailed => _translate('updateFailed');
  String get updateSuccess => _translate('updateSuccess');
  String get restartApp => _translate('restartApp');
  String get webViewLogin => _translate('webViewLogin');
  String get manualCookieInput => _translate('manualCookieInput');
  String get enterCookies => _translate('enterCookies');
  String get detectLogin => _translate('detectLogin');
  String get loginRequired => _translate('loginRequired');
  String get loginToAccess => _translate('loginToAccess');
  String get cookiesExpiredMessage => _translate('cookiesExpiredMessage');
  String get cookieInputHint => _translate('cookieInputHint');
  String get cookieSaved => _translate('cookieSaved');
  String get cookieError => _translate('cookieError');
  String get customUAHint => _translate('customUAHint');
  String get restoreDefaultUA => _translate('restoreDefaultUA');
  String get uaSaved => _translate('uaSaved');
  String get languageChanged => _translate('languageChanged');
  String get themeChanged => _translate('themeChanged');
  String get pathChanged => _translate('pathChanged');
  String get qualityChanged => _translate('qualityChanged');
  String get downloadsChanged => _translate('downloadsChanged');
  String get notificationChanged => _translate('notificationChanged');
  String get ytDlpUpdated => _translate('ytDlpUpdated');
  String get ytDlpUpdateFailed => _translate('ytDlpUpdateFailed');
  String get ytDlpVersion => _translate('ytDlpVersion');
  String get ffmpegVersion => _translate('ffmpegVersion');
  String get pythonVersion => _translate('pythonVersion');
  String get systemDefault => _translate('systemDefault');
  String get lightMode => _translate('lightMode');
  String get darkMode => _translate('darkMode');
  String get best => _translate('best');
  String get good => _translate('good');
  String get normal => _translate('normal');
  String get low => _translate('low');
  String get veryLow => _translate('veryLow');
  String get audio => _translate('audio');
  String get video => _translate('video');
  String get all => _translate('all');
  String get today => _translate('today');
  String get yesterday => _translate('yesterday');
  String get thisWeek => _translate('thisWeek');
  String get thisMonth => _translate('thisMonth');
  String get older => _translate('older');

  String get downloadSettings => _translate('downloadSettings');
  String get defaultSettings => _translate('defaultSettings');
  String get permissionManagement => _translate('permissionManagement');
  String get cookieManagement => _translate('cookieManagement');
  String get clearCache => _translate('clearCache');
  String get addOtherCookies => _translate('addOtherCookies');
  String get noDownloads => _translate('noDownloads');
  String get clickToAddDownload => _translate('clickToAddDownload');
  String get pendingTask => _translate('pendingTask');
  String get downloadingTask => _translate('downloadingTask');
  String get processingTask => _translate('processingTask');
  String get completedTask => _translate('completedTask');
  String get failedTask => _translate('failedTask');
  String get cancelledTask => _translate('cancelledTask');

  String get noHistory => _translate('noHistory');
  String get clearHistory => _translate('clearHistory');
  String get confirmClearHistory => _translate('confirmClearHistory');
  String get taskDetails => _translate('taskDetails');
  String get unknownTitle => _translate('unknownTitle');
  String get titleField => _translate('titleField');
  String get urlField => _translate('urlField');
  String get savedFile => _translate('savedFile');
  String get typeField => _translate('typeField');
  String get statusField => _translate('statusField');
  String get close => _translate('close');
  String get unknown => _translate('unknown');
  String get parseFailedExpired => _translate('parseFailedExpired');
  String get parseFailedFresh => _translate('parseFailedFresh');
  String get parseFailedBilibili => _translate('parseFailedBilibili');
  String get parseFailedDefault => _translate('parseFailedDefault');
  String get needStoragePermission => _translate('needStoragePermission');
  String get storagePermissionMessage => _translate('storagePermissionMessage');
  String get parsingVideo => _translate('parsingVideo');
  String get noAvailableFormat => _translate('noAvailableFormat');
  String get selectVideoQuality => _translate('selectVideoQuality');
  String get selectAudioQuality => _translate('selectAudioQuality');
  String get highQualityRequiresLogin => _translate('highQualityRequiresLogin');
  String get importCookieFile => _translate('importCookieFile');
  String get importCookieFileHint => _translate('importCookieFileHint');
  String get cookieFileImported => _translate('cookieFileImported');
  String get cookieFileImportFailed => _translate('cookieFileImportFailed');
  String get cookieFileCleared => _translate('cookieFileCleared');
  String get noCookieFile => _translate('noCookieFile');
  String get cookieHelp => _translate('cookieHelp');
  String get currentCookieFile => _translate('currentCookieFile');
  String get clearCookieFile => _translate('clearCookieFile');
  String get retryQueued => _translate('retryQueued');
  String get fileUnavailable => _translate('fileUnavailable');
  String get errorDetails => _translate('errorDetails');
  String get cookieImportedSummary => _translate('cookieImportedSummary');
  String get clearCookieConfirm => _translate('clearCookieConfirm');
  String get cookieCleared => _translate('cookieCleared');
  String get selectCookieFile => _translate('selectCookieFile');
  String get selectDownloadDirectory => _translate('selectDownloadDirectory');
  String get downloadPathSaved => _translate('downloadPathSaved');
  String get selectPathFailed => _translate('selectPathFailed');
  String get updateYtDlpSuccess => _translate('updateYtDlpSuccess');
  String get updateYtDlpRetry => _translate('updateYtDlpRetry');
  String get loginSuccessWithSite => _translate('loginSuccessWithSite');

  String _translate(String key) {
    switch (locale.languageCode) {
      case 'zh':
        return AppLocalizationsZh().getLocalizedValue(key);
      case 'en':
        return AppLocalizationsEn().getLocalizedValue(key);
      case 'ja':
        return AppLocalizationsJa().getLocalizedValue(key);
      case 'ko':
        return AppLocalizationsKo().getLocalizedValue(key);
      default:
        return AppLocalizationsZh().getLocalizedValue(key);
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en', 'ja', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
