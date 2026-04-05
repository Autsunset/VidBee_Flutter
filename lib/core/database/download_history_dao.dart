import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/models.dart';
import 'app_database.dart';

part 'download_history_dao.g.dart';

@DriftAccessor(tables: [DownloadHistory])
class DownloadHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadHistoryDaoMixin {
  DownloadHistoryDao(AppDatabase db) : super(db);

  Future<int> insertDownloadHistory(DownloadTask task) async {
    return into(downloadHistory).insert(
      DownloadHistoryCompanion(
        id: Value(task.id),
        url: Value(task.url),
        title: Value(task.title ?? ''),
        thumbnail: Value(task.thumbnail),
        type: Value(task.type.name),
        status: Value(task.status.name),
        downloadPath: Value(task.downloadPath),
        savedFileName: Value(task.savedFileName),
        fileSize: Value(task.fileSize),
        duration: Value(task.duration),
        downloadedAt: Value(DateTime.now().millisecondsSinceEpoch),
        completedAt: Value(task.completedAt),
        error: Value(task.error),
        ytDlpCommand: Value(task.ytDlpCommand),
        ytDlpLog: Value(task.ytDlpLog),
        description: Value(task.description),
        channel: Value(task.channel),
        uploader: Value(task.uploader),
        viewCount: Value(task.viewCount),
        tags: Value(task.tags != null ? jsonEncode(task.tags) : null),
        selectedFormat: Value(task.selectedFormat != null ? jsonEncode(task.selectedFormat!.toJson()) : null),
        playlistId: Value(task.playlistId),
        playlistTitle: Value(task.playlistTitle),
        playlistIndex: Value(task.playlistIndex),
        playlistSize: Value(task.playlistSize),
      ),
    );
  }

  Future<List<DownloadTask>> getAllDownloadHistory() async {
    final query = select(downloadHistory)
      ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)]);
    final rows = await query.get();
    return rows.map(_rowToTask).toList();
  }

  Future<List<DownloadTask>> getDownloadHistoryByPlaylistId(String playlistId) async {
    final query = select(downloadHistory)
      ..where((t) => t.playlistId.equals(playlistId))
      ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)]);
    final rows = await query.get();
    return rows.map(_rowToTask).toList();
  }

  Future<int> deleteDownloadHistoryById(String id) async {
    return (delete(downloadHistory)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteDownloadHistoryByPlaylistId(String playlistId) async {
    return (delete(downloadHistory)..where((t) => t.playlistId.equals(playlistId))).go();
  }

  Future<int> deleteAllDownloadHistory() async {
    return delete(downloadHistory).go();
  }

  DownloadTask _rowToTask(DownloadHistoryData row) {
    return DownloadTask(
      id: row.id,
      url: row.url,
      title: row.title,
      thumbnail: row.thumbnail,
      type: DownloadType.values.firstWhere((e) => e.name == row.type),
      status: DownloadStatus.values.firstWhere((e) => e.name == row.status),
      createdAt: row.downloadedAt,
      completedAt: row.completedAt,
      duration: row.duration,
      fileSize: row.fileSize,
      downloadPath: row.downloadPath,
      savedFileName: row.savedFileName,
      error: row.error,
      ytDlpCommand: row.ytDlpCommand,
      ytDlpLog: row.ytDlpLog,
      description: row.description,
      channel: row.channel,
      uploader: row.uploader,
      viewCount: row.viewCount,
      tags: row.tags != null ? List<String>.from(jsonDecode(row.tags!)) : null,
      selectedFormat: row.selectedFormat != null
          ? VideoFormat.fromJson(jsonDecode(row.selectedFormat!))
          : null,
      playlistId: row.playlistId,
      playlistTitle: row.playlistTitle,
      playlistIndex: row.playlistIndex,
      playlistSize: row.playlistSize,
    );
  }
}
