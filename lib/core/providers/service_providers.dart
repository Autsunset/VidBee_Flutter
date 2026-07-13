import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../database/app_database.dart';
import '../database/download_history_dao.dart';

final ytDlpServiceProvider = Provider<YtDlpService>((ref) {
  final service = YtDlpService();
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  final service = AppUpdateService();
  ref.onDispose(service.dispose);
  return service;
});

final historyServiceProvider = Provider<HistoryService>((ref) {
  final dao = ref.watch(downloadHistoryDaoProvider);
  final service = HistoryService(dao);
  ref.onDispose(() => service.dispose());
  return service;
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final ytDlpService = ref.watch(ytDlpServiceProvider);
  final historyService = ref.watch(historyServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final service = DownloadService(
    ytDlpService: ytDlpService,
    historyService: historyService,
    notificationService: notificationService,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

final downloadTasksProvider = StateProvider<List<DownloadTask>>((ref) {
  return [];
});

final currentVideoInfoProvider = StateProvider<VideoInfo?>((ref) {
  return null;
});

final isLoadingVideoInfoProvider = StateProvider<bool>((ref) {
  return false;
});

final selectedFormatProvider = StateProvider<VideoFormat?>((ref) {
  return null;
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final downloadHistoryDaoProvider = Provider<DownloadHistoryDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DownloadHistoryDao(db);
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final downloadPathProvider = StateProvider<String>((ref) {
  // 注意：这里不能直接用 async，所以我们在 settings_page 的 _initializeDownloadPath 中处理
  return '/storage/emulated/0/Download';
});

const _supportedLanguageCodes = {'zh', 'en', 'ja', 'ko'};

/// Returns a supported app language, with English as the fallback.
String resolveAppLanguageCode(String? languageCode) {
  final normalizedCode = languageCode?.toLowerCase();
  return _supportedLanguageCodes.contains(normalizedCode)
      ? normalizedCode!
      : 'en';
}

final languageProvider = StateProvider<String>((ref) {
  return resolveAppLanguageCode(
    PlatformDispatcher.instance.locale.languageCode,
  );
});
