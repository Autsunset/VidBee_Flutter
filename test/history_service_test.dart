import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/database/download_history_dao.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';
import 'package:vidbee_flutter/core/services/history_service.dart';

void main() {
  late FakeDownloadHistoryDao dao;
  late HistoryService service;

  setUp(() {
    dao = FakeDownloadHistoryDao();
    service = HistoryService(dao);
  });

  tearDown(() {
    service.dispose();
  });

  DownloadTask task(String id) {
    return DownloadTask(
      id: id,
      url: 'https://example.com/video/$id',
      title: 'Video $id',
      type: DownloadType.video,
      status: DownloadStatus.completed,
      createdAt: 1000,
    );
  }

  test('addToHistory persists task and broadcasts updated history', () async {
    final updates = <List<DownloadTask>>[];
    final subscription = service.historyStream.listen(updates.add);

    await service.initialize();
    await service.addToHistory(task('one'));
    await Future<void>.delayed(Duration.zero);

    final cachedHistory = service.getHistory();
    final persistedHistory = await dao.getAllDownloadHistory();

    expect(cachedHistory, hasLength(1));
    expect(cachedHistory.single.id, 'one');
    expect(persistedHistory, hasLength(1));
    expect(persistedHistory.single.id, 'one');
    expect(updates.last.single.id, 'one');

    await subscription.cancel();
  });

  test('removeFromHistory deletes task from cache and database', () async {
    await service.addToHistory(task('one'));
    await service.addToHistory(task('two'));

    await service.removeFromHistory('one');

    final cachedHistory = service.getHistory();
    final persistedHistory = await dao.getAllDownloadHistory();

    expect(cachedHistory.map((task) => task.id), ['two']);
    expect(persistedHistory.map((task) => task.id), ['two']);
  });

  test('clearHistory deletes all cached and persisted tasks', () async {
    await service.addToHistory(task('one'));
    await service.addToHistory(task('two'));

    await service.clearHistory();

    expect(service.getHistory(), isEmpty);
    expect(await dao.getAllDownloadHistory(), isEmpty);
  });

  test('updateSavedFile persists download path and file name', () async {
    await service.addToHistory(task('one'));

    await service.updateSavedFile(
      'one',
      '/storage/emulated/0/Download/VidBee_Clip.mp4',
      'VidBee_Clip.mp4',
      fileSize: 12345,
    );

    final cached = service.getHistory().single;
    final persisted = (await dao.getAllDownloadHistory()).single;

    expect(cached.savedFileName, 'VidBee_Clip.mp4');
    expect(cached.downloadPath, '/storage/emulated/0/Download/VidBee_Clip.mp4');
    expect(cached.fileSize, 12345);
    expect(persisted.savedFileName, 'VidBee_Clip.mp4');
    expect(persisted.fileSize, 12345);
  });

  test('addToHistory always stamps a positive completedAt', () async {
    final before = DateTime.now().millisecondsSinceEpoch;
    await service.addToHistory(task('one'));
    final after = DateTime.now().millisecondsSinceEpoch;

    final saved = service.getHistory().single;
    expect(saved.completedAt, isNotNull);
    expect(saved.completedAt!, greaterThan(0));
    expect(saved.completedAt!, greaterThanOrEqualTo(before));
    expect(saved.completedAt!, lessThanOrEqualTo(after));
  });

  test('updateSavedFile is a no-op for unknown task id', () async {
    await service.addToHistory(task('one'));

    await service.updateSavedFile('missing', '/path/file.mp4', 'file.mp4');

    expect(service.getHistory().single.savedFileName, isNull);
  });

  test('concurrent initialize calls share one database read', () async {
    final gate = Completer<void>();
    dao.readGate = gate;

    final first = service.initialize();
    final second = service.initialize();
    await Future<void>.delayed(Duration.zero);

    expect(dao.readCount, 1);
    gate.complete();
    await Future.wait([first, second]);
    expect(dao.readCount, 1);
  });
}

class FakeDownloadHistoryDao implements DownloadHistoryDao {
  final Map<String, DownloadTask> _history = {};
  Completer<void>? readGate;
  int readCount = 0;

  @override
  Future<int> insertDownloadHistory(DownloadTask task) async {
    _history[task.id] = task;
    return 1;
  }

  @override
  Future<List<DownloadTask>> getAllDownloadHistory() async {
    readCount++;
    await readGate?.future;
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
