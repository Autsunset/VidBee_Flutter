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

    _activeTasks.remove(task.id);

    // 保存到历史记录
    await _saveToHistory(task);
    await _persistIncompleteTasks();

    // 启动下一个任务
    _processQueue();
  }

  /// 保存到历史记录
  Future<void> _saveToHistory(DownloadTask task) async {
    // 如果 startDownload 已返回真实文件路径，则补充到历史记录中
    final resolvedPath = _resolvedFileNames.remove(task.id);
    final enrichedTask = resolvedPath != null
        ? task.copyWith(
            savedFileName:
                task.savedFileName ?? _fileNameFromPath(resolvedPath),
            downloadPath: resolvedPath,
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
    } else {
      // startDownload 返回了真实文件路径。完成事件可能已经（或尚未）触发，
      // 因此既写入活动任务，也尝试更新已落库的历史记录。
      final savedFileName = _fileNameFromPath(result);
      final activeTask = _activeTasks[task.id];
      if (activeTask != null) {
        _activeTasks[task.id] = activeTask.copyWith(
          savedFileName: savedFileName,
          downloadPath: result,
        );
      }
      _resolvedFileNames[task.id] = result;
      await _updateHistorySavedFile(task.id, result, savedFileName);
      await _persistIncompleteTasks();
    }
  }

  Future<void> _updateHistorySavedFile(
    String taskId,
    String path,
    String savedFileName,
  ) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final updated = await _historyService.updateSavedFile(
        taskId,
        path,
        savedFileName,
      );
      if (updated) return;
      if (!_completionHandledTaskIds.contains(taskId)) return;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  /// 从完整路径中提取文件名
  String _fileNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized.split('/');
    return segments.isEmpty ? path : segments.last;
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
    } catch (_) {
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
