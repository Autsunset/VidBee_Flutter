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
    'initialize restores pending tasks and records interrupted active tasks',
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

      expect(ytDlp.startedTaskIds, contains('pending'));
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
  }) async {}

  @override
  Future<void> cancelNotification(String taskId) async {}

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
