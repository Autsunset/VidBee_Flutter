// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_history_dao.dart';

// ignore_for_file: type=lint
mixin _$DownloadHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $DownloadHistoryTable get downloadHistory => attachedDatabase.downloadHistory;
  DownloadHistoryDaoManager get managers => DownloadHistoryDaoManager(this);
}

class DownloadHistoryDaoManager {
  final _$DownloadHistoryDaoMixin _db;
  DownloadHistoryDaoManager(this._db);
  $$DownloadHistoryTableTableManager get downloadHistory =>
      $$DownloadHistoryTableTableManager(
        _db.attachedDatabase,
        _db.downloadHistory,
      );
}
