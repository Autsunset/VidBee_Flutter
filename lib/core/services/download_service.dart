// 下载服务
// 管理下载任务队列和状态

import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/download_task.dart';
import '../models/video_info.dart';
import 'ytdlp_service.dart';
import 'history_service.dart';
import '../utils/event_bus.dart';

/// 下载服务类
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final YtDlpService _ytDlpService = YtDlpService();
  final HistoryService _historyService = HistoryService();
  final Uuid _uuid = const Uuid();
  
  final List<DownloadTask> _downloadQueue = [];
  final Map<String, DownloadTask> _activeTasks = {};
  final int _maxConcurrentDownloads = 3;

  StreamSubscription? _ytdlpProgressSubscription;
  StreamSubscription? _ytdlpStatusSubscription;
  StreamSubscription? _ytdlpErrorSubscription;

  bool _isInitialized = false;

  /// 初始化下载服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _ytDlpService.initialize();
    _setupYtDlpEventListeners();
    _isInitialized = true;
  }

  /// 设置 yt-dlp 事件监听器（直接来自 YtDlpService）
  void _setupYtDlpEventListeners() {
    // 监听下载状态变化
    eventBus.on<DownloadStatusChangedEvent>().listen((event) {
      final task = _activeTasks[event.taskId];
      if (task != null) {
        final updatedTask = task.copyWith(status: event.status);
        _activeTasks[event.taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);
        
        // 如果下载完成，保存到历史记录
        if (event.status == DownloadStatus.completed) {
          _onTaskComplete(updatedTask);
        }
      }
    });

    // 监听下载错误
    eventBus.on<DownloadErrorEvent>().listen((event) {
      final task = _activeTasks[event.taskId];
      if (task != null) {
        final updatedTask = task.copyWith(
          status: DownloadStatus.error,
          error: event.error,
        );
        _activeTasks[event.taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);
        _onTaskComplete(updatedTask);
      }
    });

    // 监听下载进度
    eventBus.on<DownloadProgressEvent>().listen((event) {
      final task = _activeTasks[event.taskId];
      if (task != null) {
        final progress = DownloadProgress(
          percent: event.progress,
          currentSpeed: event.speed > 0 ? '${event.speed} KB/s' : null,
          eta: event.eta > 0 ? '${event.eta}s' : null,
        );
        final updatedTask = task.copyWith(progress: progress);
        _activeTasks[event.taskId] = updatedTask;
        _notifyTaskUpdate(updatedTask);
      }
    });
  }

  /// 通知任务更新
  void _notifyTaskUpdate(DownloadTask task) {
    eventBus.fire(TaskUpdatedEvent(task: task));
  }

  /// 任务完成处理
  Future<void> _onTaskComplete(DownloadTask task) async {
    _activeTasks.remove(task.id);
    
    // 保存到历史记录
    await _saveToHistory(task);
    
    // 启动下一个任务
    _processQueue();
  }

  /// 保存到历史记录
  Future<void> _saveToHistory(DownloadTask task) async {
    await _historyService.addToHistory(task);
  }

  /// 处理队列
  void _processQueue() {
    while (_activeTasks.length < _maxConcurrentDownloads && _downloadQueue.isNotEmpty) {
      final task = _downloadQueue.removeAt(0);
      _startTask(task);
    }
  }

  /// 启动任务
  Future<void> _startTask(DownloadTask task) async {
    final updatedTask = task.copyWith(
      status: DownloadStatus.downloading,
      startedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _activeTasks[task.id] = updatedTask;
    _notifyTaskUpdate(updatedTask);

    final result = await _ytDlpService.startDownload(updatedTask);
    if (result == null) {
      final currentTask = _activeTasks[task.id];
      if (currentTask != null && currentTask.status == DownloadStatus.downloading) {
        final failedTask = currentTask.copyWith(status: DownloadStatus.error);
        _activeTasks[task.id] = failedTask;
        _onTaskComplete(failedTask);
        _notifyTaskUpdate(failedTask);
      }
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
        _onTaskComplete(updatedTask);
      }
      return cancelled;
    }

    // 从队列中移除
    final queueIndex = _downloadQueue.indexWhere((t) => t.id == taskId);
    if (queueIndex != -1) {
      final task = _downloadQueue.removeAt(queueIndex);
      final updatedTask = task.copyWith(status: DownloadStatus.cancelled);
      _notifyTaskUpdate(updatedTask);
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

  /// 清理资源
  void dispose() {
    _ytdlpProgressSubscription?.cancel();
    _ytdlpStatusSubscription?.cancel();
    _ytdlpErrorSubscription?.cancel();
    _ytDlpService.dispose();
  }
}
