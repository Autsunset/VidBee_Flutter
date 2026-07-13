// 下载服务
// 管理下载任务队列和状态

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/download_task.dart';
import '../models/video_info.dart';
import 'ytdlp_service.dart';
import 'history_service.dart';
import 'notification_service.dart';
import '../utils/app_logger.dart';
import '../utils/download_filename.dart';
import '../utils/event_bus.dart';

/// 下载服务类
class DownloadService {
  DownloadService({
    required YtDlpService ytDlpService,
    required HistoryService historyService,
    required NotificationService notificationService,
  }) : _ytDlpService = ytDlpService,
       _historyService = historyService,
       _notificationService = notificationService;

  final YtDlpService _ytDlpService;
  final HistoryService _historyService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  final List<DownloadTask> _downloadQueue = [];
  final Map<String, DownloadTask> _activeTasks = {};
  // 下载成功后由 startDownload 返回的真实文件名，按 taskId 暂存，供历史记录使用
  final Map<String, String> _resolvedFileNames = {};
  int _maxConcurrentDownloads = 3;
  bool _notificationsEnabled = true;

  static const String _prefMaxConcurrent = 'max_concurrent_downloads';
  static const String _prefNotificationsEnabled = 'enable_notification';
  static const String _prefIncompleteTasks = 'incomplete_download_tasks';

  /// 去重集合 / 文件名缓存的最大保留条目数，防止长会话下无上限增长。
  /// 重复完成事件几乎与首次同时到达，保留最近若干条即足以去重。
  static const int _maxRetainedTaskIds = 256;

  /// 历史记录文件名回填的轮询重试次数与间隔。
  static const int _historyUpdateMaxAttempts = 5;
  static const Duration _historyUpdateRetryDelay = Duration(milliseconds: 20);

  StreamSubscription? _ytdlpProgressSubscription;
  StreamSubscription? _ytdlpStatusSubscription;
  StreamSubscription? _ytdlpErrorSubscription;

  bool _isInitialized = false;
  final Set<String> _completionHandledTaskIds = {};

  /// 初始化下载服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadPreferences();
    await _ytDlpService.initialize();
    await _historyService.initialize();
    await _restoreIncompleteTasks();
    _setupYtDlpEventListeners();
    _isInitialized = true;
    _processQueue();
  }

  /// 从 SharedPreferences 读取下载相关设置
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final maxConcurrent = prefs.getInt(_prefMaxConcurrent);
    if (maxConcurrent != null && maxConcurrent > 0) {
      _maxConcurrentDownloads = maxConcurrent;
    }
    _notificationsEnabled = prefs.getBool(_prefNotificationsEnabled) ?? true;
  }

  /// 更新最大并发下载数（设置变更时由设置页调用，立即生效）
  void setMaxConcurrentDownloads(int value) {
    if (value <= 0) return;
    _maxConcurrentDownloads = value;
    _processQueue();
  }

  /// 更新通知开关（设置变更时由设置页调用）
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
  }

  /// 设置 yt-dlp 事件监听器（直接来自 YtDlpService）
  void _setupYtDlpEventListeners() {
    // 监听下载状态变化
    _ytdlpStatusSubscription = eventBus.on<DownloadStatusChangedEvent>().listen(
      (event) {
        final task = _activeTasks[event.taskId];
        if (task != null) {
          final updatedTask = task.copyWith(status: event.status);
          _activeTasks[event.taskId] = updatedTask;
          _notifyTaskUpdate(updatedTask);
          unawaited(_persistIncompleteTasks());

          // 如果下载完成，保存到历史记录并显示完成通知
          if (event.status == DownloadStatus.completed) {
            if (_notificationsEnabled) {
              _notificationService.showDownloadComplete(
                taskId: task.id,
                title: task.title ?? '视频',
              );
            }
            unawaited(_onTaskComplete(updatedTask));
          } else if (event.status == DownloadStatus.cancelled) {
            // 取消下载时取消通知
            _notificationService.cancelNotification(task.id);
          }
        }
      },
    );

    // 监听下载错误
    _ytdlpErrorSubscription = eventBus.on<DownloadErrorEvent>().listen((event) {
      final task = _activeTasks[event.taskId];
      if (task != null) {
        final updatedTask = task.copyWith(
          status: DownloadStatus.error,
          error: event.error,
        );
        _activeTasks[event.taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);
        unawaited(_persistIncompleteTasks());

        // 显示错误通知
        if (_notificationsEnabled) {
          _notificationService.showDownloadError(
            taskId: task.id,
            title: task.title ?? '视频',
            error: event.error,
          );
        }

        unawaited(_onTaskComplete(updatedTask));
      }
    });

    // 监听下载进度
    _ytdlpProgressSubscription = eventBus.on<DownloadProgressEvent>().listen((
      event,
    ) {
      final task = _activeTasks[event.taskId];
      if (task != null) {
        final progress = DownloadProgress(
          percent: event.progress,
          eta: event.eta > 0 ? '${event.eta}s' : null,
        );
        final updatedTask = task.copyWith(progress: progress);
        _activeTasks[event.taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);

        // 更新下载进度通知
        if (_notificationsEnabled) {
          _notificationService.showDownloadProgress(
            taskId: task.id,
            title: task.title ?? '正在下载...',
            progress: event.progress.toInt(),
            speed: progress.currentSpeed,
            eta: progress.eta,
          );
        }
      }
    });
  }

  /// 通知任务更新
  void _notifyTaskUpdate(DownloadTask task) {
    eventBus.fire(TaskUpdatedEvent(task: task));
  }

  /// 任务完成处理
  Future<void> _onTaskComplete(DownloadTask task) async {
    if (!_completionHandledTaskIds.add(task.id)) return;
    _trimRetainedIds(_completionHandledTaskIds);

    _activeTasks.remove(task.id);

    // 保存到历史记录
    await _saveToHistory(task);
    await _persistIncompleteTasks();

    // 启动下一个任务
    _processQueue();
  }

  /// 保存到历史记录
  Future<void> _saveToHistory(DownloadTask task) async {
    // 如果 startDownload 已返回真实文件路径，则补充到历史记录中。
    // 绝不把 yt-dlp 未展开的模板路径（VidBee_%(title)s.%(ext)s）写入历史。
    final resolvedPath = _resolvedFileNames.remove(task.id);
    final usablePath =
        resolvedPath != null && !isYtDlpTemplatePath(resolvedPath)
        ? resolvedPath
        : null;
    final enrichedTask = usablePath != null
        ? task.copyWith(
            savedFileName:
                task.savedFileName ?? fileNameFromPath(usablePath),
            downloadPath: usablePath,
          )
        : task;
    await _historyService.addToHistory(enrichedTask);
  }

  /// 处理队列
  void _processQueue() {
    while (_activeTasks.length < _maxConcurrentDownloads &&
        _downloadQueue.isNotEmpty) {
      final task = _downloadQueue.removeAt(0);
      unawaited(_startTask(task));
    }
    unawaited(_persistIncompleteTasks());
  }

  /// 启动任务
  Future<void> _startTask(DownloadTask task) async {
    final updatedTask = task.copyWith(
      status: DownloadStatus.downloading,
      startedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _activeTasks[task.id] = updatedTask;
    _notifyTaskUpdate(updatedTask);
    await _persistIncompleteTasks();

    try {
      final result = await _ytDlpService.startDownload(updatedTask);
      if (result == null) {
        final currentTask = _activeTasks[task.id];
        if (currentTask != null &&
            currentTask.status == DownloadStatus.downloading) {
          final failedTask = currentTask.copyWith(
            status: DownloadStatus.error,
            error: currentTask.error ?? '下载进程结束但没有返回输出文件',
          );
          _activeTasks[task.id] = failedTask;
          _notifyTaskUpdate(failedTask);
          await _onTaskComplete(failedTask);
        }
      } else if (isYtDlpTemplatePath(result)) {
        // 防御：底层不应再返回模板路径；若仍返回则视为失败，避免污染历史。
        AppLogger.error('下载返回未展开的模板路径，忽略: $result');
        final currentTask = _activeTasks[task.id];
        if (currentTask != null &&
            currentTask.status == DownloadStatus.downloading) {
          final failedTask = currentTask.copyWith(
            status: DownloadStatus.error,
            error: '下载完成但未能解析真实文件名',
          );
          _activeTasks[task.id] = failedTask;
          _notifyTaskUpdate(failedTask);
          await _onTaskComplete(failedTask);
        }
      } else {
        // startDownload 返回了真实文件路径。完成事件可能已经（或尚未）触发，
        // 因此既写入活动任务，也尝试更新已落库的历史记录。
        final savedFileName = fileNameFromPath(result);
        final activeTask = _activeTasks[task.id];
        if (activeTask != null) {
          _activeTasks[task.id] = activeTask.copyWith(
            savedFileName: savedFileName,
            downloadPath: result,
          );
        }
        _resolvedFileNames[task.id] = result;
        _trimResolvedFileNames();
        await _updateHistorySavedFile(task.id, result, savedFileName);
        await _persistIncompleteTasks();
      }
    } catch (e, stackTrace) {
      // 防御性处理：startDownload 抛出未预期异常时，避免任务卡在 downloading
      // 状态而长期占用并发槽位，导致整个队列停摆。
      AppLogger.error('下载任务执行异常', e, stackTrace);
      final currentTask = _activeTasks[task.id];
      if (currentTask != null) {
        final failedTask = currentTask.copyWith(
          status: DownloadStatus.error,
          error: currentTask.error ?? '下载执行异常: $e',
        );
        _activeTasks[task.id] = failedTask;
        _notifyTaskUpdate(failedTask);
        await _onTaskComplete(failedTask);
      }
    }
  }

  Future<void> _updateHistorySavedFile(
    String taskId,
    String path,
    String savedFileName,
  ) async {
    for (var attempt = 0; attempt < _historyUpdateMaxAttempts; attempt++) {
      final updated = await _historyService.updateSavedFile(
        taskId,
        path,
        savedFileName,
      );
      if (updated) return;
      if (!_completionHandledTaskIds.contains(taskId)) return;
      await Future<void>.delayed(_historyUpdateRetryDelay);
    }
  }

  /// 淘汰最早写入的去重 ID（LinkedHashSet 保留插入顺序）。
  void _trimRetainedIds(Set<String> ids) {
    while (ids.length > _maxRetainedTaskIds) {
      ids.remove(ids.first);
    }
  }

  /// 淘汰最早写入的已解析文件名缓存（兜底，正常路径在写入历史时已移除）。
  void _trimResolvedFileNames() {
    while (_resolvedFileNames.length > _maxRetainedTaskIds) {
      _resolvedFileNames.remove(_resolvedFileNames.keys.first);
    }
  }

  /// 添加下载任务
  Future<DownloadTask> addTask({
    required String url,
    DownloadType type = DownloadType.video,
    VideoFormat? selectedFormat,
    String? title,
    String? thumbnail,
    String? channel,
    String? duration,
    int? fileSize,
    String? downloadPath,
  }) async {
    await initialize();

    final task = DownloadTask(
      id: _uuid.v4(),
      url: url,
      type: type,
      status: DownloadStatus.pending,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      selectedFormat: selectedFormat,
      title: title,
      thumbnail: thumbnail,
      channel: channel,
      duration: duration != null ? int.tryParse(duration) : null,
      fileSize: fileSize,
      downloadPath: downloadPath,
    );

    _downloadQueue.add(task);
    _notifyTaskUpdate(task);
    await _persistIncompleteTasks();
    _processQueue();

    return task;
  }

  /// 基于已有任务创建一次新的下载尝试。
  Future<DownloadTask> retryTask(DownloadTask sourceTask) async {
    await initialize();

    final task = DownloadTask(
      id: _uuid.v4(),
      url: sourceTask.url,
      type: sourceTask.type,
      status: DownloadStatus.pending,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      selectedFormat: sourceTask.selectedFormat,
      title: sourceTask.title,
      thumbnail: sourceTask.thumbnail,
      channel: sourceTask.channel,
      uploader: sourceTask.uploader,
      duration: sourceTask.duration,
      fileSize: sourceTask.fileSize,
      downloadPath: _retryDownloadPath(sourceTask),
      playlistId: sourceTask.playlistId,
      playlistTitle: sourceTask.playlistTitle,
      playlistIndex: sourceTask.playlistIndex,
      playlistSize: sourceTask.playlistSize,
    );

    _downloadQueue.add(task);
    _notifyTaskUpdate(task);
    await _persistIncompleteTasks();
    _processQueue();

    return task;
  }

  String? _retryDownloadPath(DownloadTask task) {
    final path = task.downloadPath;
    final savedFileName = task.savedFileName;
    if (path == null || path.isEmpty || savedFileName == null) return path;

    final normalizedPath = path.replaceAll('\\', '/');
    if (!normalizedPath.endsWith('/$savedFileName')) return path;

    final separatorIndex = normalizedPath.lastIndexOf('/');
    if (separatorIndex <= 0) return path;
    return path.substring(0, separatorIndex);
  }

  /// 取消任务
  Future<bool> cancelTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null) {
      final cancelled = await _ytDlpService.cancelDownload(taskId);
      if (cancelled) {
        final updatedTask = task.copyWith(status: DownloadStatus.cancelled);
        _activeTasks[taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);
        await _onTaskComplete(updatedTask);
      }
      return cancelled;
    }

    // 从队列中移除
    final queueIndex = _downloadQueue.indexWhere((t) => t.id == taskId);
    if (queueIndex != -1) {
      final task = _downloadQueue.removeAt(queueIndex);
      final updatedTask = task.copyWith(status: DownloadStatus.cancelled);
      _notifyTaskUpdate(updatedTask);
      await _persistIncompleteTasks();
      return true;
    }

    return false;
  }

  /// 获取所有活动任务
  List<DownloadTask> getActiveTasks() {
    return _activeTasks.values.toList();
  }

  /// 获取队列中的任务
  List<DownloadTask> getQueuedTasks() {
    return List.from(_downloadQueue);
  }

  /// 获取所有任务
  List<DownloadTask> getAllTasks() {
    return [..._activeTasks.values, ..._downloadQueue];
  }

  /// 恢复上次退出前尚未完成的任务。
  Future<void> _restoreIncompleteTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefIncompleteTasks);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final restoredQueue = <DownloadTask>[];
      final interruptedTasks = <DownloadTask>[];

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final task = DownloadTask.fromJson(item);
        switch (task.status) {
          case DownloadStatus.pending:
            restoredQueue.add(task);
            break;
          case DownloadStatus.downloading:
          case DownloadStatus.processing:
            interruptedTasks.add(
              task.copyWith(
                status: DownloadStatus.error,
                error: task.error ?? '应用关闭或下载进程中断',
              ),
            );
            break;
          case DownloadStatus.completed:
          case DownloadStatus.error:
          case DownloadStatus.cancelled:
            break;
        }
      }

      _downloadQueue
        ..clear()
        ..addAll(restoredQueue);

      for (final task in interruptedTasks) {
        await _saveToHistory(task);
      }
    } catch (e, stackTrace) {
      AppLogger.error('恢复未完成任务失败，已清空待恢复队列', e, stackTrace);
      await prefs.remove(_prefIncompleteTasks);
      return;
    }

    await _persistIncompleteTasks();
  }

  /// 持久化未完成任务，防止进程被杀后队列静默丢失。
  Future<void> _persistIncompleteTasks() async {
    final incompleteTasks = [
      ..._downloadQueue,
      ..._activeTasks.values.where(
        (task) =>
            task.status == DownloadStatus.pending ||
            task.status == DownloadStatus.downloading ||
            task.status == DownloadStatus.processing,
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    if (incompleteTasks.isEmpty) {
      await prefs.remove(_prefIncompleteTasks);
      return;
    }

    await prefs.setString(
      _prefIncompleteTasks,
      jsonEncode(incompleteTasks.map((task) => task.toJson()).toList()),
    );
  }

  /// 清理资源
  void dispose() {
    _ytdlpProgressSubscription?.cancel();
    _ytdlpStatusSubscription?.cancel();
    _ytdlpErrorSubscription?.cancel();
  }
}
