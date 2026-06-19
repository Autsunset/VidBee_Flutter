import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/database/app_database.dart';
import 'package:vidbee_flutter/core/database/download_history_dao.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';

void main() {
  late AppDatabase db;
  late DownloadHistoryDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DownloadHistoryDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  DownloadTask task(String id, {String? playlistId}) => DownloadTask(
    id: id,
    url: 'https://e.com/$id',
    title: 'Title $id',
    type: DownloadType.video,
    status: DownloadStatus.completed,
    createdAt: 1000,
    playlistId: playlistId,
  );

  test('插入后可按 id 检索并保留字段', () async {
    await dao.insertDownloadHistory(task('a'));
    final all = await dao.getAllDownloadHistory();
    expect(all.length, 1);
    expect(all.first.id, 'a');
    expect(all.first.title, 'Title a');
    expect(all.first.status, DownloadStatus.completed);
  });

  test('getDownloadHistoryByPlaylistId 仅返回该歌单的项', () async {
    await dao.insertDownloadHistory(task('a', playlistId: 'PL1'));
    await dao.insertDownloadHistory(task('b', playlistId: 'PL2'));
    await dao.insertDownloadHistory(task('c', playlistId: 'PL1'));

    final pl1 = await dao.getDownloadHistoryByPlaylistId('PL1');
    expect(pl1.map((t) => t.id).toSet(), {'a', 'c'});
  });

  test('按 id / 歌单 / 全部删除', () async {
    await dao.insertDownloadHistory(task('a', playlistId: 'PL1'));
    await dao.insertDownloadHistory(task('b', playlistId: 'PL1'));
    await dao.insertDownloadHistory(task('c'));

    expect(await dao.deleteDownloadHistoryById('c'), 1);
    expect(
      (await dao.getAllDownloadHistory()).map((t) => t.id),
      isNot(contains('c')),
    );

    expect(await dao.deleteDownloadHistoryByPlaylistId('PL1'), 2);
    expect(await dao.getAllDownloadHistory(), isEmpty);
  });

  test('新库依据 @TableIndex 创建查询索引 (schemaVersion=2)', () async {
    expect(db.schemaVersion, 2);
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'index' AND tbl_name = 'download_history'",
        )
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'idx_download_history_downloaded_at',
        'idx_download_history_playlist_id',
      ]),
    );
  });
}
