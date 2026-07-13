// 历史记录服务
import 'dart:async';
import '../database/download_history_dao.dart';
import '../models/download_task.dart';

/// 历史记录服务类
class HistoryService {
  HistoryService(this._downloadHistoryDao);

  final DownloadHistoryDao _downloadHistoryDao;

  final List<DownloadTask> _history = [];
  final StreamController<List<DownloadTask>> _historyController =
      StreamController.broadcast();
  bool _isInitialized = false;

  Stream<List<DownloadTask>> get historyStream => _historyController.stream;

  /// 初始化历史记录缓存
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final history = await _downloadHistoryDao.getAllDownloadHistory();
      _history
        ..clear()
        ..addAll(history);
    } catch (_) {
      // 历史加载失败不应阻止应用启动/下载服务初始化。
      // 保留空列表，后续写入仍可走 insertOnConflictUpdate。
      _history.clear();
    }
    _isInitialized = true;
    _notifyHistoryUpdated();
  }

  /// 添加到历史记录
  Future<void> addToHistory(DownloadTask task) async {
    await initialize();

    // 复制任务，避免修改原任务
    final historyTask = task.copyWith(
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _downloadHistoryDao.insertDownloadHistory(historyTask);

    _history.removeWhere((t) => t.id == historyTask.id);
    _history.insert(0, historyTask);
    _notifyHistoryUpdated();
  }

  /// 获取历史记录
  List<DownloadTask> getHistory() {
    return List.from(_history);
  }

  /// 从历史记录中删除
  Future<void> removeFromHistory(String taskId) async {
    await initialize();

    await _downloadHistoryDao.deleteDownloadHistoryById(taskId);
    _history.removeWhere((t) => t.id == taskId);
    _notifyHistoryUpdated();
  }

  /// 更新某条历史记录的已保存文件路径/文件名（若该记录已存在）
  Future<bool> updateSavedFile(
    String taskId,
    String downloadPath,
    String savedFileName, {
    int? fileSize,
  }) async {
    await initialize();

    final index = _history.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;

    final existing = _history[index];
    final updated = existing.copyWith(
      downloadPath: downloadPath,
      savedFileName: savedFileName,
      // 仅在拿到有效实测大小时覆盖，避免把已有值抹成 null
      fileSize: (fileSize != null && fileSize > 0)
          ? fileSize
          : existing.fileSize,
    );
    _history[index] = updated;
    await _downloadHistoryDao.insertDownloadHistory(updated);
    _notifyHistoryUpdated();
    return true;
  }

  /// 清空历史记录
  Future<void> clearHistory() async {
    await initialize();

    await _downloadHistoryDao.deleteAllDownloadHistory();
    _history.clear();
    _notifyHistoryUpdated();
  }

  /// 通知历史记录更新
  void _notifyHistoryUpdated() {
    _historyController.add(List.from(_history));
  }

  /// 清理资源
  void dispose() {
    _historyController.close();
  }
}
