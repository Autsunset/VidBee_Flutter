// yt-dlp 服务封装
// 基于 extractor 插件实现的视频下载引擎

import 'dart:async';
import 'dart:io';
import 'package:extractor/extractor.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_info.dart' as vidbee;
import '../models/download_task.dart' as vidbee;
import '../utils/event_bus.dart';
import '../utils/media_scanner.dart';

/// yt-dlp 服务类
class YtDlpService {
  static final YtDlpService _instance = YtDlpService._internal();
  factory YtDlpService() => _instance;
  YtDlpService._internal();

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
        return true;
      } else {
        print('YtDlpService 初始化失败: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      print('YtDlpService 初始化异常: $e');
      return false;
    }
  }

  /// 设置事件监听器
  void _setupEventListeners() {
    // 进度更新
    _subscriptions['progress'] = _youtubeDL.onProgress.listen((progress) {
      final event = DownloadProgressEvent(
        taskId: progress.processId,
        progress: progress.progress.toDouble(),
        downloadedBytes: 0,
        totalBytes: 0,
        speed: 0,
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

  /// 获取视频信息
  Future<vidbee.VideoInfo?> getVideoInfo(String url) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      final info = await _youtubeDL.getVideoInfo(url);
      return _convertToVidbeeVideoInfo(info);
    } catch (e) {
      print('获取视频信息失败: $e');
      return null;
    }
  }

  /// 开始下载
  Future<String?> startDownload(vidbee.DownloadTask task) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      // 优先使用任务中的下载路径，如果没有则使用默认路径
      String downloadPath = task.downloadPath ?? '';
      
      if (downloadPath.isEmpty) {
        // 直接使用系统Downloads目录，这样其他应用也能看到
        downloadPath = '/storage/emulated/0/Download';
      }
      
      // 确保下载目录存在
      final dir = Directory(downloadPath);
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
          print('创建下载目录: $downloadPath');
        } catch (e) {
          print('创建下载目录失败: $e');
          // 尝试使用应用私有目录作为备用
          try {
            final appDir = await getExternalStorageDirectory();
            if (appDir != null) {
              downloadPath = '${appDir.path}/Download/VidBee';
              final backupDir = Directory(downloadPath);
              if (!await backupDir.exists()) {
                await backupDir.create(recursive: true);
              }
              print('使用备用下载目录: $downloadPath');
            }
          } catch (e2) {
            print('创建备用目录也失败: $e2');
            return null;
          }
        }
      }
      
      print('开始下载: ${task.url}');
      print('下载路径: $downloadPath');
      
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
      
      print('格式: $format');

      // 使用VidBee_前缀 + 视频标题作为文件名，既保留标题又避免问题
      final outputTemplate = 'VidBee_%(title)s.%(ext)s';
      print('输出文件名: $outputTemplate');

      final request = DownloadRequest(
        url: task.url,
        outputPath: downloadPath,
        outputTemplate: outputTemplate,
        format: format,
        processId: task.id,
        embedThumbnail: true,
        embedMetadata: true,
        extractAudio: task.type == vidbee.DownloadType.audio,
        audioFormat: task.type == vidbee.DownloadType.audio ? 'mp3' : null,
        audioQuality: task.type == vidbee.DownloadType.audio ? 0 : null,
      );

      final result = await _youtubeDL.download(request);

      if (result.status == OperationStatus.success) {
        // 插件返回的是模板字符串，需要查找实际文件
        final actualPath = await _findDownloadedFile(downloadPath, task.id);
        print('下载成功: ${actualPath ?? result.outputPath}');
        
        // 通知系统媒体库扫描新文件
        if (actualPath != null) {
          await MediaScanner.scanFile(actualPath);
        }
        
        return actualPath ?? result.outputPath;
      } else {
        print('下载失败: ${result.errorMessage}');
        return null;
      }
    } catch (e) {
      print('下载异常: $e');
      return null;
    }
  }

  /// 查找下载完成的文件
  Future<String?> _findDownloadedFile(String downloadPath, String processId) async {
    try {
      final dir = Directory(downloadPath);
      if (!await dir.exists()) {
        return null;
      }

      // 获取目录中所有文件
      final files = await dir.list().toList();
      
      // 找到最新的文件（按修改时间排序）
      final videoFiles = files
          .whereType<File>()
          .where((f) => !f.path.endsWith('.part') && !f.path.endsWith('.ytdl'))
          .toList();
      
      if (videoFiles.isEmpty) {
        return null;
      }

      // 按修改时间排序，返回最新的文件
      videoFiles.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return videoFiles.first.path;
    } catch (e) {
      print('查找下载文件失败: $e');
      return null;
    }
  }

  /// 取消下载
  Future<bool> cancelDownload(String taskId) async {
    try {
      final cancelled = await _youtubeDL.cancelDownload(taskId);
      return cancelled;
    } catch (e) {
      print('取消下载失败: $e');
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
      print('更新 yt-dlp 失败: $e');
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
      print('获取版本信息失败: $e');
      return {};
    }
  }

  /// 转换为 VidBee VideoInfo 格式
  vidbee.VideoInfo _convertToVidbeeVideoInfo(VideoInfo info) {
    final formats = info.formats
            ?.where((f) => f != null)
            .map((f) => vidbee.VideoFormat(
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
                ))
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

  /// 清理资源
  void dispose() {
    _subscriptions.values.forEach((sub) => sub.cancel());
    _subscriptions.clear();
  }
}
