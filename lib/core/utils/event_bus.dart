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
class DownloadProgressEvent {
  final String taskId;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final double speed;
  final int eta;

  DownloadProgressEvent({
    required this.taskId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speed,
    required this.eta,
  });
}

/// 下载状态变化事件
class DownloadStatusChangedEvent {
  final String taskId;
  final DownloadStatus status;

  DownloadStatusChangedEvent({
    required this.taskId,
    required this.status,
  });
}

/// 下载错误事件
class DownloadErrorEvent {
  final String taskId;
  final String error;

  DownloadErrorEvent({
    required this.taskId,
    required this.error,
  });
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

/// 订阅更新事件
class SubscriptionUpdatedEvent {
  final SubscriptionRule subscription;

  SubscriptionUpdatedEvent(this.subscription);
}

/// 设置更新事件
class SettingsUpdatedEvent {
  final AppSettings settings;

  SettingsUpdatedEvent(this.settings);
}
