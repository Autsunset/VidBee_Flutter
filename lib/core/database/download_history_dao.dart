import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/models.dart';
import 'app_database.dart';

part 'download_history_dao.g.dart';

@DriftAccessor(tables: [DownloadHistory])
class DownloadHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadHistoryDaoMixin {
  DownloadHistoryDao(super.db);

  Future<int> insertDownloadHistory(DownloadTask task) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // 优先使用任务自身的完成/创建时间；避免把 0 写入后读出成 1970。
    final completedAt = (task.completedAt != null && task.completedAt! > 0)
        ? task.completedAt
        : now;
    final downloadedAt = task.createdAt > 0 ? task.createdAt : now;

    return into(downloadHistory).insertOnConflictUpdate(
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
        downloadedAt: Value(downloadedAt),
        completedAt: Value(completedAt),
        error: Value(task.error),
        ytDlpCommand: Value(task.ytDlpCommand),
        ytDlpLog: Value(task.ytDlpLog),
        description: Value(task.description),
        channel: Value(task.channel),
        uploader: Value(task.uploader),
        viewCount: Value(task.viewCount),
        tags: Value(task.tags != null ? jsonEncode(task.tags) : null),
        selectedFormat: Value(
          task.selectedFormat != null
              ? jsonEncode(task.selectedFormat!.toJson())
              : null,
        ),
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
    return _mapRowsSafely(rows);
  }

  Future<List<DownloadTask>> getDownloadHistoryByPlaylistId(
    String playlistId,
  ) async {
    final query = select(downloadHistory)
      ..where((t) => t.playlistId.equals(playlistId))
      ..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)]);
    final rows = await query.get();
    return _mapRowsSafely(rows);
  }

  /// 单行映射失败时跳过该行，避免整表历史加载把启动流程打崩。
  List<DownloadTask> _mapRowsSafely(List<DownloadHistoryData> rows) {
    final tasks = <DownloadTask>[];
    for (final row in rows) {
      try {
        tasks.add(_rowToTask(row));
      } catch (_) {
        // 脏数据跳过
      }
    }
    return tasks;
  }

  Future<int> deleteDownloadHistoryById(String id) async {
    return (delete(downloadHistory)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteDownloadHistoryByPlaylistId(String playlistId) async {
    return (delete(
      downloadHistory,
    )..where((t) => t.playlistId.equals(playlistId))).go();
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
      // 旧数据/脏数据可能含未知枚举值；必须有 orElse，否则启动加载历史时会整页崩溃。
      type: DownloadType.values.firstWhere(
        (e) => e.name == row.type,
        orElse: () => DownloadType.video,
      ),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => DownloadStatus.completed,
      ),
      // downloadedAt 为 0 时用当前时间兜底，避免 UI 显示 1970
      createdAt: row.downloadedAt > 0
          ? row.downloadedAt
          : DateTime.now().millisecondsSinceEpoch,
      completedAt: (row.completedAt != null && row.completedAt! > 0)
          ? row.completedAt
          : null,
      duration: (row.duration != null && row.duration! > 0) ? row.duration : null,
      fileSize: (row.fileSize != null && row.fileSize! > 0) ? row.fileSize : null,
      downloadPath: row.downloadPath,
      savedFileName: row.savedFileName,
      error: row.error,
      ytDlpCommand: row.ytDlpCommand,
      ytDlpLog: row.ytDlpLog,
      description: row.description,
      channel: row.channel,
      uploader: row.uploader,
      viewCount: row.viewCount,
      tags: _decodeStringList(row.tags),
      selectedFormat: _decodeSelectedFormat(row.selectedFormat),
      playlistId: row.playlistId,
      playlistTitle: row.playlistTitle,
      playlistIndex: row.playlistIndex,
      playlistSize: row.playlistSize,
    );
  }

  List<String>? _decodeStringList(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return null;
    }
  }

  VideoFormat? _decodeSelectedFormat(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return VideoFormat.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }
}
