// 历史记录服务
import 'dart:async';
import '../models/download_task.dart';

/// 历史记录服务类
class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<DownloadTask> _history = [];
  final StreamController<List<DownloadTask>> _historyController =
      StreamController.broadcast();

  Stream<List<DownloadTask>> get historyStream => _historyController.stream;

  /// 添加到历史记录
  Future<void> addToHistory(DownloadTask task) async {
    // 复制任务，避免修改原任务
    final historyTask = task.copyWith(
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _history.insert(0, historyTask);
    _notifyHistoryUpdated();
    // TODO: 保存到数据库
  }

  /// 获取历史记录
  List<DownloadTask> getHistory() {
    return List.from(_history);
  }

  /// 从历史记录中删除
  Future<void> removeFromHistory(String taskId) async {
    _history.removeWhere((t) => t.id == taskId);
    _notifyHistoryUpdated();
    // TODO: 从数据库删除
  }

  /// 清空历史记录
  Future<void> clearHistory() async {
    _history.clear();
    _notifyHistoryUpdated();
    // TODO: 清空数据库
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
