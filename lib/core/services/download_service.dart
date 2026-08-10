// 下载服务
// 管理下载任务队列和状态

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
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

  final Queue<DownloadTask> _downloadQueue = ListQueue<DownloadTask>();
  final Map<String, DownloadTask> _activeTasks = {};
  // 下载成功后由 startDownload 返回的真实文件名，按 taskId 暂存，供历史记录使用
  final Map<String, String> _resolvedFileNames = {};
  final Map<String, int> _lastNotifiedProgress = {};
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

  /// 完成事件常早于 startDownload 返回真实路径；保存历史前短暂等待路径回填。
  static const int _resolvePathWaitAttempts = 50;
  static const Duration _resolvePathWaitDelay = Duration(milliseconds: 20);

  StreamSubscription? _ytdlpProgressSubscription;
  StreamSubscription? _ytdlpStatusSubscription;
  StreamSubscription? _ytdlpErrorSubscription;

  bool _isInitialized = false;
  Future<void>? _initializationFuture;
  Future<void>? _persistenceFuture;
  bool _persistenceRequested = false;
  final Set<String> _completionHandledTaskIds = {};

  /// 初始化下载服务
  ///
  /// 注意：这里**不**调用 `_ytDlpService.initialize()`。
  /// 该调用会触发 youtubedl-android 的 native 库初始化——解压随包的
  /// ffmpeg / aria2c / python 二进制（合计约 50MB）到设备存储。
  /// 在部分机型上这一步会发生 native 层崩溃（SIGSEGV，无法被 Dart
  /// 的 try/catch 拦截），表现为「打开即闪退」。
  /// 因此把 native 初始化推迟到真正需要时（首次解析 URL / 下载），
  /// 由 `YtDlpService.getVideoInfo`/`startDownload`/`getVersionInfo`
  /// 内部的懒加载触发，保证应用启动流程不再触碰 native 库。
  Future<void> initialize() {
    if (_isInitialized) return Future<void>.value();
    final currentInitialization = _initializationFuture;
    if (currentInitialization != null) return currentInitialization;

    final initialization = _initialize();
    _initializationFuture = initialization;
    return initialization.whenComplete(() {
      if (identical(_initializationFuture, initialization)) {
        _initializationFuture = null;
      }
    });
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    await _historyService.initialize();
    await _restoreIncompleteTasks();
    _setupYtDlpEventListeners();
    _isInitialized = true;
    // 不在启动时调用 _processQueue()：它会启动恢复出的 pending 任务，
    // 进而触发 native 初始化。若存在遗留 pending 任务且 native 初始化在该机型
    // 上崩溃，会形成「每次启动都恢复→启动任务→native 崩溃」的死循环。
    // pending 任务保留在队列中（UI 可见、可取消），等用户主动新增下载时再处理。
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
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    if (!value) {
      // 关闭开关时立即移除已有常驻进度通知，而不只是停止后续刷新。
      for (final taskId in _activeTasks.keys) {
        unawaited(_cancelNotification(taskId));
      }
      _lastNotifiedProgress.clear();
    }
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
              unawaited(_showDownloadCompleteNotification(task));
            }
            unawaited(_onTaskComplete(updatedTask));
          } else if (event.status == DownloadStatus.cancelled) {
            // 插件可能主动发出取消事件；必须释放并发槽位，不能只关闭通知。
            unawaited(_cancelNotification(task.id));
            unawaited(_onTaskComplete(updatedTask));
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
          unawaited(_showDownloadErrorNotification(task, event.error));
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
        final notificationProgress = event.progress.clamp(0, 100).toInt();
        if (_notificationsEnabled &&
            _lastNotifiedProgress[task.id] != notificationProgress) {
          // extractor 可能在同一整数百分比内回调数十次；通知栏无需同频刷新。
          _lastNotifiedProgress[task.id] = notificationProgress;
          unawaited(
            _showDownloadProgressNotification(
              task,
              notificationProgress,
              progress,
            ),
          );
        }
      }
    });
  }

  Future<void> _showDownloadProgressNotification(
    DownloadTask task,
    int progress,
    DownloadProgress details,
  ) async {
    try {
      await _notificationService.showDownloadProgress(
        taskId: task.id,
        title: task.title ?? '正在下载...',
        progress: progress,
        speed: details.currentSpeed,
        eta: details.eta,
      );
    } catch (e, stackTrace) {
      AppLogger.error('更新下载进度通知失败', e, stackTrace);
    }
  }

  Future<void> _showDownloadCompleteNotification(DownloadTask task) async {
    try {
      await _notificationService.showDownloadComplete(
        taskId: task.id,
        title: task.title ?? '视频',
      );
    } catch (e, stackTrace) {
      AppLogger.error('显示下载完成通知失败', e, stackTrace);
    }
  }

  Future<void> _showDownloadErrorNotification(
    DownloadTask task,
    String error,
  ) async {
    try {
      await _notificationService.showDownloadError(
        taskId: task.id,
        title: task.title ?? '视频',
        error: error,
      );
    } catch (e, stackTrace) {
      AppLogger.error('显示下载失败通知失败', e, stackTrace);
    }
  }

  Future<void> _cancelNotification(String taskId) async {
    try {
      await _notificationService.cancelNotification(taskId);
    } catch (e, stackTrace) {
      AppLogger.error('取消下载通知失败', e, stackTrace);
    }
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
    _lastNotifiedProgress.remove(task.id);

    // 保存到历史记录
    await _saveToHistory(task);
    await _persistIncompleteTasks();

    // 启动下一个任务
    _processQueue();
  }

  /// 保存到历史记录
  Future<void> _saveToHistory(DownloadTask task) async {
    // 只有成功任务才可能等待 startDownload 回填真实路径。错误/取消任务没有
    // 输出文件，若也轮询会让每个失败任务额外占用并发槽约 1 秒。
    final String? usablePath;
    if (task.status == DownloadStatus.completed) {
      usablePath = await _awaitResolvedPath(task.id);
    } else {
      usablePath = _peekResolvedPath(task.id);
      _resolvedFileNames.remove(task.id);
    }
    final fileSize = await _resolveFileSize(usablePath, task.fileSize);
    final completedAt = DateTime.now().millisecondsSinceEpoch;

    final enrichedTask = task.copyWith(
      completedAt: completedAt,
      // duration/fileSize 保留任务里已有的有效值；文件 size 优先用落盘实测
      fileSize: fileSize,
      savedFileName: usablePath != null
          ? (task.savedFileName ?? fileNameFromPath(usablePath))
          : task.savedFileName,
      // 仅在解析到真实文件路径时覆盖；避免把目录路径当最终文件路径展示
      downloadPath: usablePath ?? task.downloadPath,
    );
    await _historyService.addToHistory(enrichedTask);
  }

  /// 等待 startDownload 回填真实路径；超时则返回当前缓存（可能为 null）。
  Future<String?> _awaitResolvedPath(String taskId) async {
    for (var i = 0; i < _resolvePathWaitAttempts; i++) {
      final path = _peekResolvedPath(taskId);
      if (path != null) {
        _resolvedFileNames.remove(taskId);
        return path;
      }
      await Future<void>.delayed(_resolvePathWaitDelay);
    }
    final latePath = _peekResolvedPath(taskId);
    _resolvedFileNames.remove(taskId);
    return latePath;
  }

  String? _peekResolvedPath(String taskId) {
    final path = _resolvedFileNames[taskId];
    if (path == null || path.isEmpty || isYtDlpTemplatePath(path)) {
      return null;
    }
    return path;
  }

  /// 优先用落盘文件实测大小；失败再回退任务里已有的 filesize。
  Future<int?> _resolveFileSize(String? path, int? fallback) async {
    if (path != null && path.isNotEmpty && !isYtDlpTemplatePath(path)) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final size = await file.length();
          if (size > 0) return size;
        }
      } catch (e) {
        AppLogger.debug('读取下载文件大小失败: $path, $e');
      }
    }
    if (fallback != null && fallback > 0) return fallback;
    return fallback;
  }

  /// 处理队列
  void _processQueue() {
    while (_activeTasks.length < _maxConcurrentDownloads &&
        _downloadQueue.isNotEmpty) {
      final task = _downloadQueue.removeFirst();
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

        // 成功返回真实文件是比事件流更可靠的终态信号。部分设备偶发丢失
        // completed 事件时，主动收尾，避免任务永久占用并发槽位。
        final currentTask = _activeTasks[task.id];
        if (currentTask != null &&
            currentTask.status != DownloadStatus.completed &&
            currentTask.status != DownloadStatus.cancelled &&
            currentTask.status != DownloadStatus.error) {
          final completedTask = currentTask.copyWith(
            status: DownloadStatus.completed,
            savedFileName: savedFileName,
            downloadPath: result,
          );
          _activeTasks[task.id] = completedTask;
          _notifyTaskUpdate(completedTask);
          if (_notificationsEnabled) {
            unawaited(_showDownloadCompleteNotification(completedTask));
          }
          await _onTaskComplete(completedTask);
        }
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
    final fileSize = await _resolveFileSize(path, null);
    for (var attempt = 0; attempt < _historyUpdateMaxAttempts; attempt++) {
      final updated = await _historyService.updateSavedFile(
        taskId,
        path,
        savedFileName,
        fileSize: fileSize,
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
      if (cancelled && !_completionHandledTaskIds.contains(taskId)) {
        // cancelDownload 可能同步触发 cancelled 事件；重新读取当前任务，避免
        // 事件已收尾后又把旧任务塞回 activeTasks。
        final currentTask = _activeTasks[taskId];
        if (currentTask == null) return true;
        final updatedTask = currentTask.copyWith(
          status: DownloadStatus.cancelled,
        );
        _activeTasks[taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);
        await _onTaskComplete(updatedTask);
      }
      return cancelled;
    }

    // 从队列中移除
    DownloadTask? queuedTask;
    for (final task in _downloadQueue) {
      if (task.id == taskId) {
        queuedTask = task;
        break;
      }
    }
    if (queuedTask != null) {
      _downloadQueue.remove(queuedTask);
      final updatedTask = queuedTask.copyWith(status: DownloadStatus.cancelled);
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
        if (item is! Map) continue;
        try {
          final task = DownloadTask.fromJson(Map<String, dynamic>.from(item));
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
        } catch (e) {
          AppLogger.debug('跳过无法恢复的未完成任务条目: $e');
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
    _persistenceRequested = true;
    final currentPersistence = _persistenceFuture;
    if (currentPersistence != null) return currentPersistence;

    final persistence = _drainPersistenceRequests();
    _persistenceFuture = persistence;
    try {
      await persistence;
    } finally {
      if (identical(_persistenceFuture, persistence)) {
        _persistenceFuture = null;
      }
    }
  }

  /// 串行合并短时间内的写请求，避免状态事件并发覆盖较新的任务快照。
  Future<void> _drainPersistenceRequests() async {
    while (_persistenceRequested) {
      _persistenceRequested = false;
      await _writeIncompleteTasksSnapshot();
    }
  }

  Future<void> _writeIncompleteTasksSnapshot() async {
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
