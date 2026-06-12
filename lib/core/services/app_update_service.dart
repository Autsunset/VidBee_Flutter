import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/app_logger.dart';

class AppReleaseAsset {
  const AppReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  factory AppReleaseAsset.fromJson(Map<String, dynamic> json) {
    return AppReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      size: json['size'] as int? ?? 0,
    );
  }

  final String name;
  final String downloadUrl;
  final int size;
}

class AppReleaseInfo {
  const AppReleaseInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseUrl,
    required this.isUpdateAvailable,
    required this.asset,
  });

  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseUrl;
  final bool isUpdateAvailable;
  final AppReleaseAsset? asset;
}

class AppUpdateService {
  AppUpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const _channel = MethodChannel('com.vidbee.app_update');
  static const _latestReleaseApi =
      'https://api.github.com/repos/Autsunset/VidBee_Flutter/releases/latest';

  final http.Client _client;

  Future<AppReleaseInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final supportedAbis = await getSupportedAbis();
    final response = await _client.get(
      Uri.parse(_latestReleaseApi),
      headers: const {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'GitHub release request failed: ${response.statusCode}',
        uri: Uri.parse(_latestReleaseApi),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String? ?? '';
    final assetsJson = json['assets'] as List<dynamic>? ?? const [];
    final assets = assetsJson
        .whereType<Map<String, dynamic>>()
        .map(AppReleaseAsset.fromJson)
        .toList();
    final asset = selectBestApkAsset(assets, supportedAbis);

    return AppReleaseInfo(
      currentVersion: packageInfo.version,
      latestVersion: normalizeVersion(tagName),
      releaseName: json['name'] as String? ?? tagName,
      releaseUrl: json['html_url'] as String? ?? '',
      isUpdateAvailable: isNewerVersion(tagName, packageInfo.version),
      asset: asset,
    );
  }

  Future<List<String>> getSupportedAbis() async {
    try {
      final result = await _channel.invokeListMethod<String>(
        'getSupportedAbis',
      );
      return result ?? const [];
    } catch (e) {
      AppLogger.error('获取设备 ABI 失败', e);
      return const [];
    }
  }

  Future<File> downloadReleaseAsset(
    AppReleaseInfo release, {
    void Function(int receivedBytes, int? totalBytes)? onProgress,
  }) async {
    final asset = release.asset;
    if (asset == null || asset.downloadUrl.isEmpty) {
      throw StateError('No compatible APK asset found');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${asset.name}');
    if (await file.exists()) {
      await file.delete();
    }

    final request = http.Request('GET', Uri.parse(asset.downloadUrl));
    final response = await _client.send(request);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'APK download failed: ${response.statusCode}',
        uri: Uri.parse(asset.downloadUrl),
      );
    }

    final totalBytes = response.contentLength;
    var receivedBytes = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in response.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        onProgress?.call(receivedBytes, totalBytes);
      }
    } catch (e) {
      await sink.close();
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
    await sink.close();

    AppLogger.info('应用更新安装包下载完成: ${file.path}');
    return file;
  }

  Future<void> installApk(String filePath) async {
    await _channel.invokeMethod<void>('installApk', {'filePath': filePath});
  }

  void dispose() {
    _client.close();
  }

  static AppReleaseAsset? selectBestApkAsset(
    List<AppReleaseAsset> assets,
    List<String> supportedAbis,
  ) {
    final apkAssets = assets
        .where((asset) => asset.name.toLowerCase().endsWith('.apk'))
        .where((asset) => asset.downloadUrl.isNotEmpty)
        .toList();
    if (apkAssets.isEmpty) return null;

    for (final abi in supportedAbis) {
      final normalizedAbi = abi.toLowerCase();
      for (final asset in apkAssets) {
        if (asset.name.toLowerCase().contains(normalizedAbi)) {
          return asset;
        }
      }
    }

    for (final asset in apkAssets) {
      if (!_containsKnownAbi(asset.name)) {
        return asset;
      }
    }

    return supportedAbis.isEmpty ? apkAssets.first : null;
  }

  static bool isNewerVersion(String latest, String current) {
    final latestParts = _parseVersionParts(latest);
    final currentParts = _parseVersionParts(current);
    final length = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;

    for (var i = 0; i < length; i++) {
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }

  static String normalizeVersion(String version) {
    return version
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first
        .split('-')
        .first;
  }

  static List<int> _parseVersionParts(String version) {
    final normalized = normalizeVersion(version);
    if (normalized.isEmpty) return const [0];
    return normalized
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }

  static bool _containsKnownAbi(String name) {
    final normalizedName = name.toLowerCase();
    return normalizedName.contains('arm64-v8a') ||
        normalizedName.contains('armeabi-v7a') ||
        normalizedName.contains('x86_64');
  }
}
