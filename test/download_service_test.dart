import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/database/download_history_dao.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';
import 'package:vidbee_flutter/core/models/video_info.dart';
import 'package:vidbee_flutter/core/services/download_service.dart';
import 'package:vidbee_flutter/core/services/history_service.dart';
import 'package:vidbee_flutter/core/services/notification_service.dart';
import 'package:vidbee_flutter/core/services/ytdlp_service.dart';
import 'package:vidbee_flutter/core/utils/event_bus.dart';

void main() {
  const incompleteTasksKey = 'incomplete_download_tasks';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  DownloadTask task(String id, DownloadStatus status) {
    return DownloadTask(
      id: id,
      url: 'https://example.com/video/$id',
      title: 'Video $id',
      type: DownloadType.video,
      status: status,
      createdAt: 1000,
    );
  }

  test(
    'initialize restores pending tasks without starting them and records interrupted active tasks',
    () async {
      final pending = task('pending', DownloadStatus.pending);
      final downloading = task('downloading', DownloadStatus.downloading);
      SharedPreferences.setMockInitialValues({
        incompleteTasksKey: jsonEncode([
          pending.toJson(),
          downloading.toJson(),
        ]),
        'max_concurrent_downloads': 1,
      });

      final ytDlp = FakeYtDlpService();
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
      );

      await service.initialize();
      await Future<void>.delayed(Duration.zero);

      expect(ytDlp.startedTaskIds, isEmpty);
      expect(service.getAllTasks().map((task) => task.id), contains('pending'));
      final history = await dao.getAllDownloadHistory();
      expect(history, hasLength(1));
      expect(history.single.id, 'downloading');
      expect(history.single.status, DownloadStatus.error);
      expect(history.single.error, '应用关闭或下载进程中断');
    },
  );

  test('retryTask queues a new task from a failed history item', () async {
    final source = task('failed', DownloadStatus.error).copyWith(
      selectedFormat: VideoFormat(formatId: '22', ext: 'mp4', height: 720),
      downloadPath: '/storage/emulated/0/Download/VidBee_Clip.mp4',
      savedFileName: 'VidBee_Clip.mp4',
      error: 'network failed',
    );
    final ytDlp = FakeYtDlpService();
    final service = DownloadService(
      ytDlpService: ytDlp,
      historyService: HistoryService(FakeDownloadHistoryDao()),
      notificationService: FakeNotificationService(),
    );

    final retried = await service.retryTask(source);
    await Future<void>.delayed(Duration.zero);

    expect(retried.id, isNot(source.id));
    expect(retried.url, source.url);
    expect(retried.selectedFormat?.formatId, '22');
    expect(retried.downloadPath, '/storage/emulated/0/Download');
    expect(ytDlp.startedTaskIds, contains(retried.id));
  });

  test(
    'completion event and returned output path produce one history row',
    () async {
      final ytDlp = FakeYtDlpService(
        onStart: (task) {
          eventBus.fire(
            DownloadStatusChangedEvent(
              taskId: task.id,
              status: DownloadStatus.completed,
            ),
          );
          return '/storage/emulated/0/Download/VidBee_Clip.mp4';
        },
      );
      final dao = FakeDownloadHistoryDao();
      final historyService = HistoryService(dao);
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: historyService,
        notificationService: FakeNotificationService(),
      );

      await service.addTask(
        url: 'https://example.com/video/clip',
        title: 'Clip',
      );

      await _waitFor(() async {
        final history = await dao.getAllDownloadHistory();
        return history.isNotEmpty && history.single.savedFileName != null;
      });

      final history = await dao.getAllDownloadHistory();
      expect(history, hasLength(1));
      expect(history.single.status, DownloadStatus.completed);
      expect(
        history.single.downloadPath,
        '/storage/emulated/0/Download/VidBee_Clip.mp4',
      );
      expect(history.single.savedFileName, 'VidBee_Clip.mp4');
    },
  );

  test(
    'returned output path completes task when completion event is lost',
    () async {
      final ytDlp = FakeYtDlpService(
        onStart: (_) => '/storage/emulated/0/Download/VidBee_Result.mp4',
      );
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
      );

      final added = await service.addTask(
        url: 'https://example.com/video/result',
        title: 'Result',
      );

      await _waitFor(
        () async => (await dao.getAllDownloadHistory()).isNotEmpty,
      );

      expect(service.getActiveTasks(), isEmpty);
      final history = await dao.getAllDownloadHistory();
      expect(history.single.id, added.id);
      expect(history.single.status, DownloadStatus.completed);
      expect(history.single.savedFileName, 'VidBee_Result.mp4');
      service.dispose();
    },
  );

  test(
    'cancelled event releases slot and starts the next queued task',
    () async {
      final ytDlp = FakeYtDlpService();
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
      );
      service.setMaxConcurrentDownloads(1);

      final first = await service.addTask(
        url: 'https://example.com/video/first',
        title: 'First',
      );
      final second = await service.addTask(
        url: 'https://example.com/video/second',
        title: 'Second',
      );
      expect(ytDlp.startedTaskIds, [first.id]);

      eventBus.fire(
        DownloadStatusChangedEvent(
          taskId: first.id,
          status: DownloadStatus.cancelled,
        ),
      );

      await _waitFor(() => ytDlp.startedTaskIds.contains(second.id));
      expect(
        service.getActiveTasks().map((task) => task.id),
        contains(second.id),
      );
      service.dispose();
    },
  );

  test(
    'duplicate progress callbacks update notification once per percent',
    () async {
      final notifications = FakeNotificationService();
      final service = DownloadService(
        ytDlpService: FakeYtDlpService(),
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: notifications,
      );

      final added = await service.addTask(
        url: 'https://example.com/video/progress',
        title: 'Progress',
      );
      eventBus.fire(
        DownloadProgressEvent(taskId: added.id, progress: 10.1, eta: 9),
      );
      eventBus.fire(
        DownloadProgressEvent(taskId: added.id, progress: 10.9, eta: 8),
      );
      eventBus.fire(
        DownloadProgressEvent(taskId: added.id, progress: 11.0, eta: 7),
      );

      await _waitFor(() => notifications.progressUpdates.length == 2);
      expect(notifications.progressUpdates, [10, 11]);
      service.dispose();
    },
  );

  test(
    'disabling notifications removes active progress notifications',
    () async {
      final notifications = FakeNotificationService();
      final service = DownloadService(
        ytDlpService: FakeYtDlpService(),
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: notifications,
      );

      final added = await service.addTask(
        url: 'https://example.com/video/notification',
        title: 'Notification',
      );
      service.setNotificationsEnabled(false);

      await _waitFor(() => notifications.cancelledTaskIds.contains(added.id));
      expect(notifications.cancelledTaskIds, [added.id]);
      service.dispose();
    },
  );
}

Future<void> _waitFor(FutureOr<bool> Function() condition) async {
  for (var i = 0; i < 20; i++) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition was not met');
}

class FakeYtDlpService implements YtDlpService {
  FakeYtDlpService({this.onStart});

  final String? Function(DownloadTask task)? onStart;
  final List<String> startedTaskIds = [];

  @override
  Future<bool> initialize() async => true;

  @override
  Future<String?> startDownload(DownloadTask task, {String? customUA}) async {
    startedTaskIds.add(task.id);
    return onStart?.call(task) ?? Completer<String?>().future;
  }

  @override
  Future<bool> cancelDownload(String taskId) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNotificationService implements NotificationService {
  final List<int> progressUpdates = [];
  final List<String> cancelledTaskIds = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showDownloadComplete({
    required String taskId,
    required String title,
  }) async {}

  @override
  Future<void> showDownloadError({
    required String taskId,
    required String title,
    required String error,
  }) async {}

  @override
  Future<void> showDownloadProgress({
    required String taskId,
    required String title,
    required int progress,
    String? speed,
    String? eta,
  }) async {
    progressUpdates.add(progress);
  }

  @override
  Future<void> cancelNotification(String taskId) async {
    cancelledTaskIds.add(taskId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDownloadHistoryDao implements DownloadHistoryDao {
  final Map<String, DownloadTask> _history = {};

  @override
  Future<int> insertDownloadHistory(DownloadTask task) async {
    _history[task.id] = task;
    return 1;
  }

  @override
  Future<List<DownloadTask>> getAllDownloadHistory() async {
    return _history.values.toList().reversed.toList();
  }

  @override
  Future<int> deleteDownloadHistoryById(String id) async {
    return _history.remove(id) == null ? 0 : 1;
  }

  @override
  Future<int> deleteAllDownloadHistory() async {
    final count = _history.length;
    _history.clear();
    return count;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
