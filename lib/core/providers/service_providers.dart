import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../database/app_database.dart';
import '../database/subscription_dao.dart';
import '../database/settings_dao.dart';
import '../database/download_history_dao.dart';

final ytDlpServiceProvider = Provider<YtDlpService>((ref) {
  final service = YtDlpService();
  ref.onDispose(() => service.dispose());
  return service;
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  ref.watch(ytDlpServiceProvider);
  final service = DownloadService();
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

final subscriptionDaoProvider = Provider<SubscriptionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SubscriptionDao(db);
});

final settingsDaoProvider = Provider<SettingsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsDao(db);
});

final downloadHistoryDaoProvider = Provider<DownloadHistoryDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DownloadHistoryDao(db);
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final downloadPathProvider = StateProvider<String>((ref) {
  return '/storage/emulated/0/Download';
});
