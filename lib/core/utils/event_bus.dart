import 'package:event_bus/event_bus.dart';
import '../models/models.dart';

/// 全局事件总线实例
final eventBus = AppEventBus.instance;

class AppEventBus {
  static final EventBus _instance = EventBus();

  static EventBus get instance => _instance;

  static void fire(dynamic event) {
    _instance.fire(event);
  }

  static Stream<T> on<T>() {
    return _instance.on<T>();
  }
}

/// 任务更新事件
class TaskUpdatedEvent {
  final DownloadTask task;

  TaskUpdatedEvent({required this.task});
}

/// 下载进度更新事件
/// 注意：extractor 插件的进度回调只提供进度百分比与 ETA，不含速度/字节数。
class DownloadProgressEvent {
  final String taskId;
  final double progress;
  final int eta;

  DownloadProgressEvent({
    required this.taskId,
    required this.progress,
    required this.eta,
  });
}

/// 下载状态变化事件
class DownloadStatusChangedEvent {
  final String taskId;
  final DownloadStatus status;

  DownloadStatusChangedEvent({required this.taskId, required this.status});
}

/// 下载错误事件
class DownloadErrorEvent {
  final String taskId;
  final String error;

  DownloadErrorEvent({required this.taskId, required this.error});
}

/// 下载任务更新事件（保留向后兼容）
class DownloadTaskUpdatedEvent {
  final DownloadTask task;

  DownloadTaskUpdatedEvent(this.task);
}

/// 下载队列更新事件
class DownloadQueueUpdatedEvent {
  final List<DownloadTask> tasks;

  DownloadQueueUpdatedEvent(this.tasks);
}

/// 下载完成事件
class DownloadCompletedEvent {
  final DownloadTask task;

  DownloadCompletedEvent(this.task);
}

/// 历史记录更新事件
class HistoryUpdatedEvent {
  final List<DownloadTask> history;

  HistoryUpdatedEvent(this.history);
}
