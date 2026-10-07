import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/database/download_history_dao.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';
import 'package:vidbee_flutter/core/models/video_info.dart';
import 'package:vidbee_flutter/core/services/background_download_service.dart';
import 'package:vidbee_flutter/core/services/download_service.dart';
import 'package:vidbee_flutter/core/services/history_service.dart';
import 'package:vidbee_flutter/core/services/notification_service.dart';
import 'package:vidbee_flutter/core/services/ytdlp_service.dart';
import 'package:vidbee_flutter/core/utils/event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
    'missing output path corrects a premature completion event to error',
    () async {
      final ytDlp = FakeYtDlpService(
        onStart: (task) async {
          eventBus.fire(
            DownloadStatusChangedEvent(
              taskId: task.id,
              status: DownloadStatus.completed,
            ),
          );
          await Future<void>.delayed(Duration.zero);
          return null;
        },
      );
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
      );

      final added = await service.addTask(
        url: 'https://example.com/video/missing-output',
        title: 'Missing output',
      );

      await _waitFor(() async {
        final history = await dao.getAllDownloadHistory();
        return history.isNotEmpty &&
            history.single.status == DownloadStatus.error;
      });

      final history = await dao.getAllDownloadHistory();
      expect(history, hasLength(1));
      expect(history.single.id, added.id);
      expect(history.single.status, DownloadStatus.error);
      expect(history.single.error, '下载进程结束但没有返回输出文件');
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
    'completion releases slot before waiting for output path metadata',
    () async {
      final ytDlp = FakeYtDlpService(
        onStart: (_) => Completer<String?>().future,
      );
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: FakeNotificationService(),
      );
      service.setMaxConcurrentDownloads(1);

      final first = await service.addTask(
        url: 'https://example.com/video/first-completed',
        title: 'First completed',
      );
      await _waitFor(() => ytDlp.startedTaskIds.contains(first.id));
      final second = await service.addTask(
        url: 'https://example.com/video/second-after-completion',
        title: 'Second after completion',
      );
      expect(ytDlp.startedTaskIds, [first.id]);

      eventBus.fire(
        DownloadStatusChangedEvent(
          taskId: first.id,
          status: DownloadStatus.completed,
        ),
      );

      await _waitFor(() => ytDlp.startedTaskIds.contains(second.id));
      expect(ytDlp.startedTaskIds, [first.id, second.id]);
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

  test(
    'starts background protection before invoking the download engine',
    () async {
      final startup = Completer<void>();
      final output = Completer<String?>();
      final background = FakeBackgroundDownloadService(startup: startup.future);
      final ytDlp = FakeYtDlpService(onStart: (_) => output.future);
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final added = await service.addTask(
        url: 'https://example.com/video/start',
      );
      await _waitFor(() => background.acquired.contains(added.id));
      expect(ytDlp.startedTaskIds, isEmpty);

      startup.complete();
      await _waitFor(() => ytDlp.startedTaskIds.contains(added.id));
      expect(background.released, isEmpty);
      output.complete('/downloads/VidBee_Start.mp4');
      await _waitFor(() => background.released.contains(added.id));
    },
  );

  test(
    'keeps protection at 100 percent, through merging and early completion',
    () async {
      final output = Completer<String?>();
      final background = FakeBackgroundDownloadService();
      final service = DownloadService(
        ytDlpService: FakeYtDlpService(onStart: (_) => output.future),
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final added = await service.addTask(
        url: 'https://example.com/video/merge',
      );
      await _waitFor(() => background.acquired.contains(added.id));
      eventBus.fire(
        DownloadProgressEvent(taskId: added.id, progress: 100, eta: 0),
      );
      eventBus.fire(
        DownloadStatusChangedEvent(
          taskId: added.id,
          status: DownloadStatus.processing,
        ),
      );
      await _waitFor(
        () =>
            service.getActiveTasks().single.status == DownloadStatus.processing,
      );
      expect(background.released, isEmpty);
      eventBus.fire(
        DownloadStatusChangedEvent(
          taskId: added.id,
          status: DownloadStatus.completed,
        ),
      );
      await _waitFor(() => service.getActiveTasks().isEmpty);
      expect(background.released, isEmpty);
      output.complete('/downloads/VidBee_Merged.mp4');
      await _waitFor(() => background.released.contains(added.id));
    },
  );

  test(
    'queue handoff acquires the next task before releasing the previous one',
    () async {
      SharedPreferences.setMockInitialValues({
        'max_concurrent_downloads': 1,
        'enable_notification': false,
      });
      final outputs = [Completer<String?>(), Completer<String?>()];
      var index = 0;
      final background = FakeBackgroundDownloadService();
      final ytDlp = FakeYtDlpService(onStart: (_) => outputs[index++].future);
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final first = await service.addTask(
        url: 'https://example.com/video/first',
      );
      final second = await service.addTask(
        url: 'https://example.com/video/second',
      );
      await _waitFor(() => ytDlp.startedTaskIds.contains(first.id));
      expect(background.acquired, [first.id]);
      outputs[0].complete('/downloads/VidBee_First.mp4');
      await _waitFor(() => background.released.contains(first.id));
      expect(background.events.take(3), [
        'acquire:${first.id}',
        'acquire:${second.id}',
        'release:${first.id}',
      ]);
      // The user's optional progress-notification setting must not disable FGS.
      service.setNotificationsEnabled(false);
      expect(background.released, [first.id]);
      outputs[1].complete('/downloads/VidBee_Second.mp4');
      await _waitFor(() => background.released.contains(second.id));
    },
  );

  test('keeps protection until a slow history write finishes', () async {
    final historyWrite = Completer<void>();
    final output = Completer<String?>();
    var savingHistory = false;
    final dao = FakeDownloadHistoryDao(
      beforeInsert: () async {
        savingHistory = true;
        await historyWrite.future;
      },
    );
    final background = FakeBackgroundDownloadService();
    final service = DownloadService(
      ytDlpService: FakeYtDlpService(
        onStart: (task) {
          eventBus.fire(
            DownloadStatusChangedEvent(
              taskId: task.id,
              status: DownloadStatus.completed,
            ),
          );
          return output.future;
        },
      ),
      historyService: HistoryService(dao),
      notificationService: FakeNotificationService(),
      backgroundDownloadService: background,
    );
    addTearDown(service.dispose);
    final added = await service.addTask(
      url: 'https://example.com/video/history',
    );
    await _waitFor(() => background.acquired.contains(added.id));
    output.complete('/downloads/VidBee_History.mp4');
    await _waitFor(() => savingHistory);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(background.released, isEmpty);
    historyWrite.complete();
    await _waitFor(() => background.released.contains(added.id));
    expect(
      (await dao.getAllDownloadHistory()).single.status,
      DownloadStatus.completed,
    );
  });

  test('download exceptions release background protection', () async {
    final background = FakeBackgroundDownloadService();
    final dao = FakeDownloadHistoryDao();
    final service = DownloadService(
      ytDlpService: FakeYtDlpService(
        onStart: (_) => throw StateError('failed'),
      ),
      historyService: HistoryService(dao),
      notificationService: FakeNotificationService(),
      backgroundDownloadService: background,
    );
    addTearDown(service.dispose);
    final added = await service.addTask(url: 'https://example.com/video/error');
    await _waitFor(() => background.released.contains(added.id));
    expect(
      (await dao.getAllDownloadHistory()).single.status,
      DownloadStatus.error,
    );
  });

  test(
    'missing output during processing fails and releases protection',
    () async {
      final output = Completer<String?>();
      final background = FakeBackgroundDownloadService();
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: FakeYtDlpService(onStart: (_) => output.future),
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final added = await service.addTask(
        url: 'https://example.com/video/merge-error',
      );
      eventBus.fire(
        DownloadStatusChangedEvent(
          taskId: added.id,
          status: DownloadStatus.processing,
        ),
      );
      await _waitFor(
        () =>
            service.getActiveTasks().single.status == DownloadStatus.processing,
      );
      output.complete(null);
      await _waitFor(() => background.released.contains(added.id));
      expect(service.getActiveTasks(), isEmpty);
      expect(
        (await dao.getAllDownloadHistory()).single.status,
        DownloadStatus.error,
      );
    },
  );

  test(
    'failed foreground startup does not launch an unprotected download',
    () async {
      final background = FakeBackgroundDownloadService(failStart: true);
      final ytDlp = FakeYtDlpService();
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final added = await service.addTask(
        url: 'https://example.com/video/start-error',
      );
      await _waitFor(() => background.released.contains(added.id));
      expect(ytDlp.startedTaskIds, isEmpty);
      expect(
        (await dao.getAllDownloadHistory()).single.status,
        DownloadStatus.error,
      );
    },
  );

  test(
    'cancellation keeps protection until the native process exits',
    () async {
      final output = Completer<String?>();
      final background = FakeBackgroundDownloadService();
      final ytDlp = FakeYtDlpService(onStart: (_) => output.future);
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(FakeDownloadHistoryDao()),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final added = await service.addTask(
        url: 'https://example.com/video/cancel',
      );
      await _waitFor(() => ytDlp.startedTaskIds.contains(added.id));
      expect(await service.cancelTask(added.id), isTrue);
      expect(background.released, isEmpty);
      output.complete(null);
      await _waitFor(() => background.released.contains(added.id));
    },
  );

  test(
    'system timeout fails active work and leaves queued work pending',
    () async {
      SharedPreferences.setMockInitialValues({'max_concurrent_downloads': 1});
      final output = Completer<String?>();
      final background = FakeBackgroundDownloadService();
      final ytDlp = FakeYtDlpService(onStart: (_) => output.future);
      final dao = FakeDownloadHistoryDao();
      final service = DownloadService(
        ytDlpService: ytDlp,
        historyService: HistoryService(dao),
        notificationService: FakeNotificationService(),
        backgroundDownloadService: background,
      );
      addTearDown(service.dispose);
      final first = await service.addTask(
        url: 'https://example.com/video/timeout',
      );
      final second = await service.addTask(
        url: 'https://example.com/video/queued',
      );
      await _waitFor(() => ytDlp.startedTaskIds.contains(first.id));
      background.timeoutController.add(null);
      await _waitFor(() => service.getActiveTasks().isEmpty);
      expect(ytDlp.startedTaskIds, [first.id]);
      expect(service.getQueuedTasks().single.id, second.id);
      output.complete(null);
      await _waitFor(() => background.released.contains(first.id));
      expect(
        (await dao.getAllDownloadHistory()).single.status,
        DownloadStatus.error,
      );
    },
  );
}

class FakeBackgroundDownloadService implements BackgroundDownloadService {
  FakeBackgroundDownloadService({this.startup, this.failStart = false});

  final Future<void>? startup;
  final bool failStart;
  final acquired = <String>[];
  final released = <String>[];
  final events = <String>[];
  final timeoutController = StreamController<void>.broadcast();

  @override
  Stream<void> get timeouts => timeoutController.stream;

  @override
  Future<void> acquire(String taskId) async {
    acquired.add(taskId);
    events.add('acquire:$taskId');
    if (failStart) throw StateError('Cannot start foreground service');
    await startup;
  }

  @override
  Future<void> release(String taskId) async {
    released.add(taskId);
    events.add('release:$taskId');
  }
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

  final FutureOr<String?> Function(DownloadTask task)? onStart;
  final List<String> startedTaskIds = [];

  @override
  Future<bool> initialize() async => true;

  @override
  Future<String?> startDownload(DownloadTask task, {String? customUA}) async {
    startedTaskIds.add(task.id);
    final callback = onStart;
    if (callback == null) return Completer<String?>().future;
    return callback(task);
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
  FakeDownloadHistoryDao({this.beforeInsert});

  final Future<void> Function()? beforeInsert;
  final Map<String, DownloadTask> _history = {};

  @override
  Future<int> insertDownloadHistory(DownloadTask task) async {
    await beforeInsert?.call();
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
