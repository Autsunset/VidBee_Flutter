// 历史记录页面
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/download_task.dart';
import '../../core/providers/providers.dart';
import '../../core/services/history_service.dart';
import '../../core/utils/file_opener.dart';
import '../../shared/i18n/app_localizations.dart';
import '../../shared/widgets/task_widgets.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late final HistoryService _historyService;
  StreamSubscription<List<DownloadTask>>? _historySubscription;
  List<DownloadTask> _history = [];

  @override
  void initState() {
    super.initState();
    _historyService = ref.read(historyServiceProvider);
    _history = _historyService.getHistory();
    _historySubscription = _historyService.historyStream.listen((history) {
      if (mounted) {
        setState(() {
          _history = history;
        });
      }
    });
    _initializeHistory();
  }

  Future<void> _initializeHistory() async {
    await _historyService.initialize();
    if (mounted) {
      setState(() {
        _history = _historyService.getHistory();
      });
    }
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_history.isEmpty) {
      return _buildEmptyState(context, loc);
    }

    return Column(
      children: [
        if (_history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showClearDialog(context, loc),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(loc.clearHistory),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _history.length,
            itemBuilder: (context, index) => HistoryTaskCard(
              key: ValueKey(_history[index].id),
              task: _history[index],
              onDelete: () => _deleteTask(_history[index].id),
              onTap: () => _showTaskDetails(context, _history[index]),
              loc: loc,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(loc.noHistory, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Future<void> _deleteTask(String taskId) async {
    await _historyService.removeFromHistory(taskId);
  }

  Future<void> _showClearDialog(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clearHistory),
        content: Text(loc.confirmClearHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(loc.clearAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
    }
  }

  void _showTaskDetails(BuildContext context, DownloadTask task) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      // 内容可能很长（标题/URL/路径/错误），允许 sheet 按内容升高并可滚动，
      // 避免底部 Open/Share/Close 被裁切或被系统手势条挡住。
      isScrollControlled: true,
      // 只处理 top/left/right；底部手势条由 sheet 内部自行 padding，
      // 避免 SafeArea 叠在 maxHeight 外把按钮顶出屏幕。
      useSafeArea: true,
      builder: (context) => TaskDetailsBottomSheet(
        task: task,
        loc: loc,
        onRetry: () => _retryTask(task),
        onOpen: () => _openSavedFile(task),
        onShare: () => _shareSavedFile(task),
      ),
    );
  }

  Future<void> _retryTask(DownloadTask task) async {
    final downloadService = ref.read(downloadServiceProvider);
    await downloadService.retryTask(task);
    ref.read(downloadTasksProvider.notifier).state = downloadService
        .getAllTasks();
    if (!mounted) return;
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.retryQueued)),
    );
  }

  Future<void> _openSavedFile(DownloadTask task) async {
    final path = await _resolveSavedFilePath(task);
    if (path == null) {
      _showFileUnavailable();
      return;
    }

    final opened = await FileOpener.openFile(path);
    if (!opened) _showFileUnavailable();
  }

  Future<void> _shareSavedFile(DownloadTask task) async {
    final path = await _resolveSavedFilePath(task);
    if (path == null) {
      _showFileUnavailable();
      return;
    }

    await Share.shareXFiles([XFile(path)], text: task.title);
  }

  /// 解析历史任务对应的真实本地文件路径。
  ///
  /// 优先用 [DownloadTask.downloadPath]（完成时通常是完整文件路径）；
  /// 若只是目录，则拼接 [DownloadTask.savedFileName]。
  Future<String?> _resolveSavedFilePath(DownloadTask task) async {
    final rawPath = task.downloadPath;
    final savedFileName = task.savedFileName;

    final candidates = <String>[];
    if (rawPath != null && rawPath.isNotEmpty) {
      candidates.add(rawPath);
      if (savedFileName != null &&
          savedFileName.isNotEmpty &&
          !rawPath.endsWith('/$savedFileName') &&
          !rawPath.endsWith('\\$savedFileName')) {
        final separator = rawPath.contains('\\') ? '\\' : '/';
        final joined = rawPath.endsWith(separator)
            ? '$rawPath$savedFileName'
            : '$rawPath$separator$savedFileName';
        candidates.add(joined);
      }
    }

    for (final candidate in candidates) {
      final file = File(candidate);
      if (await file.exists() &&
          (await file.stat()).type == FileSystemEntityType.file) {
        return file.path;
      }
    }
    return null;
  }

  void _showFileUnavailable() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.fileUnavailable)),
    );
  }
}

class HistoryTaskCard extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final AppLocalizations loc;

  const HistoryTaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onTap,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              TaskThumbnail(
                thumbnailUrl: task.thumbnail,
                width: 100,
                height: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? loc.unknownTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        TaskStatusChip(status: task.status, loc: loc),
                        const SizedBox(width: 8),
                        if (task.type == DownloadType.audio)
                          Chip(
                            label: Text(loc.audio),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskDetailsBottomSheet extends StatelessWidget {
  final DownloadTask task;
  final AppLocalizations loc;
  final VoidCallback onRetry;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const TaskDetailsBottomSheet({
    super.key,
    required this.task,
    required this.loc,
    required this.onRetry,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewPadding.bottom;
    // useSafeArea:true 已处理顶部；这里再预留 drag handle 与底部手势区，
    // 保证 ConstrainedBox 的总高度不会把操作按钮顶出可视区域。
    // 0.75 相对保守：长标题时上方滚动，按钮始终钉在 sheet 底部。
    final maxHeight = media.size.height * 0.75;

    // 注意：padding 必须在 ConstrainedBox 内部。
    // 若 padding/SafeArea 包在外面，会叠加在 maxHeight 之上导致底部裁切。
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      loc.taskDetails,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (task.title != null) ...[
                      Text(
                        loc.titleField,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(task.title!),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      loc.urlField,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(task.url),
                    const SizedBox(height: 16),
                    if (task.savedFileName != null &&
                        task.savedFileName!.isNotEmpty) ...[
                      Text(
                        loc.savedFile,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(task.savedFileName!),
                      if (task.downloadPath != null &&
                          task.downloadPath!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SelectableText(
                          task.downloadPath!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                    // 时间 / 时长 / 大小
                    ..._buildMetaRows(context, task, loc),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.typeField,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.type == DownloadType.video
                                    ? loc.video
                                    : loc.audio,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.statusField,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(_getStatusText(task.status, loc)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (task.error != null && task.error!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        loc.errorDetails,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        task.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 操作按钮固定在底部，不随详情滚动被裁切
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              overflowSpacing: 8,
              children: [
                if (task.status == DownloadStatus.completed) ...[
                  OutlinedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(loc.open),
                  ),
                  OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined),
                    label: Text(loc.share),
                  ),
                ],
                if (task.status == DownloadStatus.error ||
                    task.status == DownloadStatus.cancelled)
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.retry),
                  ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(DownloadStatus status, AppLocalizations loc) {
    switch (status) {
      case DownloadStatus.completed:
        return loc.completedTask;
      case DownloadStatus.error:
        return loc.failedTask;
      case DownloadStatus.cancelled:
        return loc.cancelledTask;
      default:
        return loc.unknown;
    }
  }

  /// 详情页元数据：下载时间 / 时长 / 大小。
  ///
  /// 时间优先 completedAt，其次 createdAt；两者都无效（<=0）时不展示，
  /// 避免把 epoch 0 渲染成 1970/01/01。
  List<Widget> _buildMetaRows(
    BuildContext context,
    DownloadTask task,
    AppLocalizations loc,
  ) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    final widgets = <Widget>[];

    final timeMs = _effectiveTimestampMs(task);
    if (timeMs != null) {
      widgets.addAll([
        Text(loc.downloadedTime, style: labelStyle),
        const SizedBox(height: 4),
        Text(_formatTimestamp(timeMs)),
        const SizedBox(height: 16),
      ]);
    }

    final durationText = _formatDuration(task.duration);
    final sizeText = _formatFileSize(task.fileSize);
    if (durationText != null || sizeText != null) {
      widgets.add(
        Row(
          children: [
            if (durationText != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.duration, style: labelStyle),
                    const SizedBox(height: 4),
                    Text(durationText),
                  ],
                ),
              ),
            if (sizeText != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.size, style: labelStyle),
                    const SizedBox(height: 4),
                    Text(sizeText),
                  ],
                ),
              ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  /// 取可用于展示的时间戳；0 / 负数视为无效。
  int? _effectiveTimestampMs(DownloadTask task) {
    final completed = task.completedAt;
    if (completed != null && completed > 0) return completed;
    if (task.createdAt > 0) return task.createdAt;
    return null;
  }

  String _formatTimestamp(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  /// 视频时长（秒）。null / <=0 不展示，避免 00:00。
  String? _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return null;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    if (h > 0) return '${two(h)}:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }

  /// 文件大小。null / <=0 不展示，避免 0B。
  String? _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return null;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
