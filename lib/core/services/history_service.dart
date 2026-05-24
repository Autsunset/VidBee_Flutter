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

    final history = await _downloadHistoryDao.getAllDownloadHistory();
    _history
      ..clear()
      ..addAll(history);
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
