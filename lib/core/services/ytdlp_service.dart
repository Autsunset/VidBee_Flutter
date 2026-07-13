// yt-dlp 服务封装
// 基于 extractor 插件实现的视频下载引擎

import 'dart:async';
import 'dart:io';
import 'package:extractor/extractor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_info.dart' as vidbee;
import '../models/download_task.dart' as vidbee;
import '../utils/app_logger.dart';
import '../utils/download_filename.dart';
import '../utils/event_bus.dart';
import '../utils/media_scanner.dart';
import '../utils/permission_helper.dart';
import 'cookie_service.dart';

/// yt-dlp 服务类
class YtDlpService {
  static final YtDlpService _instance = YtDlpService._internal();
  factory YtDlpService() => _instance;
  YtDlpService._internal();

  /// Bilibili 等站点强制使用的桌面端 UA，避免 yt-dlp 重定向到移动端导致解析失败
  static const String _desktopUA =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  static const String _prefLastYtDlpUpdateCheck = 'last_ytdlp_update_check';
  static const String _bundledYtDlpVersion = '2026.07.04';
  static const Duration _ytDlpUpdateCheckInterval = Duration(hours: 24);

  /// yt-dlp 自动更新的最大重试次数与每次重试间隔。
  static const int _ytDlpUpdateMaxRetries = 3;
  static const Duration _ytDlpUpdateRetryDelay = Duration(seconds: 2);

  /// 默认音频质量（0=最佳，9=最差），与设置页默认值保持一致。
  static const int _defaultAudioQuality = 3;

  final YoutubeDLFlutter _youtubeDL = YoutubeDLFlutter.instance;
  bool _isInitialized = false;
  final Map<String, StreamSubscription> _subscriptions = {};

  /// 初始化服务
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final result = await _youtubeDL.initialize(
        enableFFmpeg: true,
        enableAria2c: true,
      );

      if (result.success) {
        _isInitialized = true;
        _setupEventListeners();

        // 后台限频检查更新，避免启动和首次解析被网络更新阻塞。
        unawaited(_ensureYtDlpUpdatedIfNeeded());

        return true;
      } else {
        AppLogger.error('YtDlpService 初始化失败', result.errorMessage);
        return false;
      }
    } catch (e) {
      AppLogger.error('YtDlpService 初始化异常', e);
      return false;
    }
  }

  /// 限频后台检查 yt-dlp 更新。
  Future<void> _ensureYtDlpUpdatedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastChecked = prefs.getInt(_prefLastYtDlpUpdateCheck) ?? 0;
    if (now - lastChecked < _ytDlpUpdateCheckInterval.inMilliseconds) {
      return;
    }

    final versionInfo = await getVersionInfo();
    final currentVersion = versionInfo['yt-dlp'] ?? '';
    if (_isYtDlpVersionAtLeast(currentVersion, _bundledYtDlpVersion)) {
      await prefs.setInt(_prefLastYtDlpUpdateCheck, now);
      AppLogger.debug('当前 yt-dlp 已是随包新版 $currentVersion，跳过自动更新');
      return;
    }

    await prefs.setInt(_prefLastYtDlpUpdateCheck, now);
    await _updateYtDlpWithRetry();
  }

  /// 确保 yt-dlp 更新到最新版本（带重试机制）
  Future<void> _updateYtDlpWithRetry() async {
    for (int i = 0; i < _ytDlpUpdateMaxRetries; i++) {
      try {
        AppLogger.debug(
          '正在自动更新 yt-dlp (尝试 ${i + 1}/$_ytDlpUpdateMaxRetries)...',
        );
        final result = await _youtubeDL.updateYoutubeDL(
          channel: UpdateChannel.stable,
        );
        if (result.status == OperationStatus.success) {
          AppLogger.debug('yt-dlp 更新成功: ${result.version}');
          return;
        } else {
          AppLogger.error('yt-dlp 更新失败', result.errorMessage);
        }
      } catch (e) {
        AppLogger.error('第${i + 1}次更新 yt-dlp 出错', e);
      }
      // 等待后重试
      await Future.delayed(_ytDlpUpdateRetryDelay);
    }
    AppLogger.error('yt-dlp 自动更新失败，将使用内置版本');
  }

  /// 设置事件监听器
  void _setupEventListeners() {
    // 进度更新
    _subscriptions['progress'] = _youtubeDL.onProgress.listen((progress) {
      final event = DownloadProgressEvent(
        taskId: progress.processId,
        progress: progress.progress.toDouble(),
        eta: progress.eta.inSeconds,
      );
      eventBus.fire(event);
    });

    // 状态变化
    _subscriptions['state'] = _youtubeDL.onStateChanged.listen((state) {
      vidbee.DownloadStatus status;
      if (state.state == DownloadStateType.started) {
        status = vidbee.DownloadStatus.downloading;
      } else if (state.state == DownloadStateType.completed) {
        status = vidbee.DownloadStatus.completed;
      } else if (state.state == DownloadStateType.cancelled) {
        status = vidbee.DownloadStatus.cancelled;
      } else {
        status = vidbee.DownloadStatus.pending;
      }
      final event = DownloadStatusChangedEvent(
        taskId: state.processId,
        status: status,
      );
      eventBus.fire(event);
    });

    // 错误事件
    _subscriptions['error'] = _youtubeDL.onError.listen((error) {
      final event = DownloadErrorEvent(
        taskId: error.processId,
        error: error.error,
      );
      eventBus.fire(event);
    });
  }

  /// 构建 yt-dlp 请求选项（解析与下载共用）。
  ///
  /// 返回标准化后的 URL 及对应的命令行选项：
  /// - Bilibili 强制桌面端域名与 UA，并附加 Referer
  /// - 应用自定义 UA（若提供且有效）
  /// - 按域名查找并附加 Cookie 文件
  /// - 抖音/TikTok 启用浏览器指纹模拟
  Future<({String url, Map<String, String> options})> _buildRequestOptions(
    String url,
    String? customUA,
  ) async {
    final cookieService = CookieService();
    final options = <String, String>{};
    var effectiveUrl = url;
    var effectiveUA = customUA ?? '';

    final originalDomain = cookieService.extractDomain(effectiveUrl);
    final isBilibili = cookieService.isBilibiliDomain(originalDomain);
    if (isBilibili) {
      effectiveUrl = effectiveUrl.replaceFirst(
        'm.bilibili.com',
        'www.bilibili.com',
      );
      // Bilibili 必须使用桌面端 UA，否则 yt-dlp 会重定向到移动端导致解析失败
      if (!_isDesktopUA(effectiveUA)) {
        effectiveUA = _desktopUA;
        AppLogger.debug('Bilibili 强制使用桌面端 UA');
      } else {
        AppLogger.debug('Bilibili 使用用户设置的桌面端 UA');
      }
    }

    if (effectiveUA.isNotEmpty) {
      options['--user-agent'] = effectiveUA;
      if (!isBilibili) AppLogger.debug('使用自定义 UA');
    }

    // 按站点查找 Cookie 文件（Google 系等多域名站点会自动合并相关域名，
    // 避免按域名拆分导致登录态不完整，例如 YouTube 的 CookieMismatch）
    final cookieFilePath = await cookieService.getCookieFileForUrl(
      effectiveUrl,
    );
    if (cookieFilePath != null && cookieFilePath.isNotEmpty) {
      final cookieFile = File(cookieFilePath);
      if (await cookieFile.exists() && await cookieFile.length() > 0) {
        options['--cookies'] = cookieFilePath;
        AppLogger.debug('使用 Cookie 文件: $cookieFilePath');
      }
    }

    if (isBilibili) {
      options['--referer'] = 'https://www.bilibili.com';
    }

    if (effectiveUrl.contains('douyin.com') ||
        effectiveUrl.contains('tiktok.com')) {
      options['--extractor-args'] = 'generic:impersonate=chrome';
    }

    return (url: effectiveUrl, options: options);
  }

  /// 获取视频信息
  Future<vidbee.VideoInfo?> getVideoInfo(String url, {String? customUA}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      final request = await _buildRequestOptions(url, customUA);
      final effectiveUrl = request.url;
      final options = request.options;

      final domain = CookieService().extractDomain(effectiveUrl);

      // 使用 getVideoInfoWithOptions 传递自定义选项
      VideoInfo info;
      AppLogger.info('准备解析视频: domain=$domain, url=$effectiveUrl');
      if (options.isNotEmpty) {
        AppLogger.debug('解析选项已设置: ${options.keys.join(', ')}');
        info = await _youtubeDL.getVideoInfoWithOptions(effectiveUrl, options);
      } else {
        info = await _youtubeDL.getVideoInfo(effectiveUrl);
      }

      final converted = _convertToVidbeeVideoInfo(info);
      AppLogger.info(
        '视频解析成功: domain=$domain, formats=${converted.formats.length}, '
        'title=${converted.title}',
      );
      return converted;
    } catch (e, stackTrace) {
      AppLogger.error('获取视频信息失败: url=$url', e, stackTrace);
      return null;
    }
  }

  /// 开始下载
  Future<String?> startDownload(
    vidbee.DownloadTask task, {
    String? customUA,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      // 优先使用任务中的下载路径，如果没有则使用默认路径
      String downloadPath = task.downloadPath ?? '';

      if (downloadPath.isEmpty) {
        // 直接使用系统 Downloads 目录，这样其他应用也能看到。
        downloadPath = await PermissionHelper.getDefaultDownloadPath();
      }

      if (!await PermissionHelper.isDirectoryWritable(downloadPath)) {
        AppLogger.error('下载目录不可写，尝试使用备用目录', downloadPath);
        try {
          final appDir = await getExternalStorageDirectory();
          if (appDir == null) return null;

          downloadPath = '${appDir.path}/Download/VidBee';
          if (!await PermissionHelper.isDirectoryWritable(downloadPath)) {
            AppLogger.error('备用下载目录不可写', downloadPath);
            return null;
          }
          AppLogger.debug('使用备用下载目录: $downloadPath');
        } catch (e) {
          AppLogger.error('创建备用目录失败', e);
          return null;
        }
      }

      AppLogger.debug('开始下载: ${task.url}');
      AppLogger.debug('下载路径: $downloadPath');

      final prefs = await SharedPreferences.getInstance();
      final configuredAudioQuality =
          int.tryParse(
            prefs.getString('default_audio_quality') ?? '$_defaultAudioQuality',
          ) ??
          _defaultAudioQuality;

      // 确定下载格式
      String format;
      if (task.type == vidbee.DownloadType.audio) {
        // 音频下载：使用最佳音频
        format = 'bestaudio/best';
      } else if (task.selectedFormat != null) {
        // 视频下载：如果选择了格式，确保同时下载音频
        // 格式为：{视频格式}+bestaudio/best
        format = '${task.selectedFormat!.formatId}+bestaudio/best';
      } else {
        // 默认：最佳视频+最佳音频
        format = 'bestvideo+bestaudio/best';
      }

      AppLogger.debug('格式: $format');

      // 使用VidBee_前缀 + 视频标题作为文件名，既保留标题又避免问题
      final outputTemplate = 'VidBee_%(title)s.%(ext)s';
      AppLogger.debug('输出文件名: $outputTemplate');

      // 构建请求选项（与解析共用逻辑：Bilibili/UA/Cookie/Referer 等）
      final built = await _buildRequestOptions(task.url, customUA);
      final downloadUrl = built.url;
      final customOptions = built.options;

      final request = DownloadRequest(
        url: downloadUrl,
        outputPath: downloadPath,
        outputTemplate: outputTemplate,
        format: format,
        processId: task.id,
        embedThumbnail: true,
        embedMetadata: true,
        extractAudio: task.type == vidbee.DownloadType.audio,
        audioFormat: task.type == vidbee.DownloadType.audio ? 'mp3' : null,
        audioQuality: task.type == vidbee.DownloadType.audio
            ? configuredAudioQuality
            : null,
        customOptions: customOptions.isEmpty ? null : customOptions,
      );

      final result = await _youtubeDL.download(request);

      if (result.status == OperationStatus.success) {
        // 优先采用插件返回的真实输出路径；若其为空或仍是模板，则在下载目录中
        // 按 VidBee_<标题> 安全化匹配，失败再回退最近的 VidBee_* 文件。
        // 切勿把含 %(title)s 的模板路径写回任务/历史。
        final actualPath = await _resolveOutputPath(
          result.outputPath,
          downloadPath,
          task.title,
        );
        if (actualPath == null) {
          AppLogger.error(
            '下载成功但未能解析真实文件路径: '
            'pluginOutput=${result.outputPath}, title=${task.title}, '
            'dir=$downloadPath',
          );
          // 仍尝试扫描目录中最新的 VidBee 文件，尽量让相册能看到
          final fallback = await _findDownloadedFileByTitle(
            downloadPath,
            null,
          );
          if (fallback != null) {
            AppLogger.debug('回退扫描最新 VidBee 文件: $fallback');
            await MediaScanner.scanFile(fallback);
            return fallback;
          }
          return null;
        }
        AppLogger.debug('下载成功: $actualPath');

        // 通知系统媒体库扫描新文件（相册可见的关键步骤）
        await MediaScanner.scanFile(actualPath);

        return actualPath;
      } else {
        AppLogger.error('下载失败', result.errorMessage);
        return null;
      }
    } catch (e) {
      AppLogger.error('下载异常', e);
      return null;
    }
  }

  /// 解析下载产物的真实路径。
  ///
  /// 优先级：插件返回的真实路径 > 按标题安全化匹配 > null。
  /// 不再使用"目录中最新文件"的启发式，避免多任务并发写入同一目录时张冠李戴。
  /// 也绝不返回含 `%(...)` 的未展开模板。
  Future<String?> _resolveOutputPath(
    String? pluginOutputPath,
    String downloadPath,
    String? title,
  ) async {
    // 1. 插件已返回真实存在的文件路径（且不是未展开的模板）
    if (pluginOutputPath != null &&
        pluginOutputPath.isNotEmpty &&
        !isYtDlpTemplatePath(pluginOutputPath)) {
      final pluginFile = File(pluginOutputPath);
      if (await pluginFile.exists()) {
        return pluginOutputPath;
      }
      // 有时插件只回文件名，拼到下载目录再试
      final joined = '$downloadPath/${fileNameFromPath(pluginOutputPath)}';
      if (joined != pluginOutputPath && await File(joined).exists()) {
        return joined;
      }
    }

    // 2. 按 VidBee_<标题> 在下载目录中安全化匹配
    return _findDownloadedFileByTitle(downloadPath, title);
  }

  /// 在下载目录中按 VidBee_<标题> 查找已完成文件（安全化比对）。
  Future<String?> _findDownloadedFileByTitle(
    String downloadPath,
    String? title,
  ) async {
    try {
      final dir = Directory(downloadPath);
      if (!await dir.exists()) return null;

      final candidatePaths = <String>[];
      final modifiedMsByPath = <String, int>{};
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        if (entity.path.endsWith('.part') || entity.path.endsWith('.ytdl')) {
          continue;
        }
        candidatePaths.add(entity.path);
        final stat = await entity.stat();
        modifiedMsByPath[entity.path] = stat.modified.millisecondsSinceEpoch;
      }

      final matched = matchDownloadedFileByTitle(
        candidatePaths: candidatePaths,
        title: title,
        modifiedMsByPath: modifiedMsByPath,
      );
      if (matched == null) {
        AppLogger.debug(
          '按标题未匹配到下载文件: dir=$downloadPath, title=$title, '
          'candidates=${candidatePaths.length}',
        );
      }
      return matched;
    } catch (e) {
      AppLogger.error('查找下载文件失败', e);
      return null;
    }
  }

  /// 取消下载
  Future<bool> cancelDownload(String taskId) async {
    try {
      final cancelled = await _youtubeDL.cancelDownload(taskId);
      return cancelled;
    } catch (e) {
      AppLogger.error('取消下载失败', e);
      return false;
    }
  }

  /// 更新 yt-dlp
  Future<bool> updateYtDlp() async {
    try {
      final result = await _youtubeDL.updateYoutubeDL(
        channel: UpdateChannel.stable,
      );
      return result.status == OperationStatus.success;
    } catch (e) {
      AppLogger.error('更新 yt-dlp 失败', e);
      return false;
    }
  }

  /// 获取版本信息
  Future<Map<String, String>> getVersionInfo() async {
    try {
      final versionInfo = await _youtubeDL.getVersion();
      return {
        'yt-dlp': versionInfo.youtubeDlVersion ?? 'Unknown',
        'ffmpeg': versionInfo.ffmpegVersion ?? 'Unknown',
        'python': versionInfo.pythonVersion ?? 'Unknown',
      };
    } catch (e) {
      AppLogger.error('获取版本信息失败', e);
      return {};
    }
  }

  /// 诊断测试 - 用于排查解析问题
  Future<Map<String, dynamic>> diagnose(String url) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return {'success': false, 'error': '初始化失败'};
      }
    }

    final result = <String, dynamic>{};

    // 1. 获取 yt-dlp 版本
    try {
      final version = await getVersionInfo();
      result['version'] = version;
      AppLogger.debug('当前 yt-dlp 版本: ${version['yt-dlp']}');
    } catch (e) {
      result['version_error'] = e.toString();
    }

    // 2. 尝试解析视频
    try {
      AppLogger.debug('正在测试解析: $url');
      final info = await _youtubeDL.getVideoInfo(url);
      result['parse_success'] = true;
      result['title'] = info.title;
      result['duration'] = info.duration;
      result['uploader'] = info.uploader;
      result['formats_count'] = info.formats?.length ?? 0;
      AppLogger.debug('解析成功: ${info.title}');
    } catch (e) {
      result['parse_success'] = false;
      result['parse_error'] = e.toString();
      AppLogger.error('解析失败', e);
    }

    // 3. 检查是否需要更新
    try {
      final updateResult = await _youtubeDL.updateYoutubeDL(
        channel: UpdateChannel.stable,
      );
      result['update_status'] = updateResult.status.toString();
      result['update_version'] = updateResult.version;
      if (updateResult.status == OperationStatus.success) {
        AppLogger.debug('yt-dlp 已更新到: ${updateResult.version}');
      } else {
        AppLogger.error('yt-dlp 更新失败', updateResult.errorMessage);
        result['update_error'] = updateResult.errorMessage;
      }
    } catch (e) {
      result['update_error'] = e.toString();
      AppLogger.error('更新出错', e);
    }

    return result;
  }

  /// 转换为 VidBee VideoInfo 格式
  vidbee.VideoInfo _convertToVidbeeVideoInfo(VideoInfo info) {
    final formats =
        info.formats
            ?.where((f) => f != null)
            .map(
              (f) => vidbee.VideoFormat(
                formatId: f!.formatId ?? '',
                ext: f.ext ?? '',
                width: f.width,
                height: f.height,
                fps: f.fps,
                vcodec: f.vcodec,
                acodec: f.acodec,
                filesize: f.filesize,
                filesizeApprox: null,
                formatNote: f.formatNote,
                tbr: f.tbr,
                quality: null,
                protocol: null,
                language: null,
                videoExt: null,
                audioExt: null,
              ),
            )
            .toList() ??
        [];

    return vidbee.VideoInfo(
      id: info.id ?? '',
      title: info.title ?? '',
      thumbnail: info.thumbnail,
      duration: info.duration,
      extractorKey: null,
      webpageUrl: info.url,
      description: info.description,
      viewCount: info.viewCount,
      uploader: info.uploader,
      tags: null,
      formats: formats,
    );
  }

  bool _isYtDlpVersionAtLeast(String actual, String required) {
    final actualParts = _parseYtDlpDateVersion(actual);
    final requiredParts = _parseYtDlpDateVersion(required);
    if (actualParts == null || requiredParts == null) return false;

    for (var i = 0; i < requiredParts.length; i++) {
      if (actualParts[i] > requiredParts[i]) return true;
      if (actualParts[i] < requiredParts[i]) return false;
    }
    return true;
  }

  List<int>? _parseYtDlpDateVersion(String value) {
    final match = RegExp(r'(\d{4})\.(\d{2})\.(\d{2})').firstMatch(value);
    if (match == null) return null;
    return [
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    ];
  }

  /// 检查 UA 是否为桌面端 UA
  /// 返回 true 如果是 Windows、Mac 或 Linux 桌面端 UA
  bool _isDesktopUA(String ua) {
    if (ua.isEmpty) return false;
    final lowerUA = ua.toLowerCase();
    // 检查是否包含桌面端标识
    final desktopKeywords = [
      'windows nt',
      'macintosh',
      'mac os x',
      'linux x86_64',
      'linux i686',
      'x11; linux',
    ];
    // 检查是否包含移动端标识
    final mobileKeywords = [
      'mobile',
      'android',
      'iphone',
      'ipad',
      'ipod',
      'windows phone',
    ];
    // 如果包含桌面端标识且不包含移动端标识，认为是桌面端 UA
    final hasDesktop = desktopKeywords.any(
      (keyword) => lowerUA.contains(keyword),
    );
    final hasMobile = mobileKeywords.any(
      (keyword) => lowerUA.contains(keyword),
    );
    return hasDesktop && !hasMobile;
  }

  /// 清理资源
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
