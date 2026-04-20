// 历史记录页面
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/download_task.dart';
import '../../core/services/history_service.dart';
import '../../shared/i18n/app_localizations.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  StreamSubscription<List<DownloadTask>>? _historySubscription;
  List<DownloadTask> _history = [];

  @override
  void initState() {
    super.initState();
    _history = _historyService.getHistory();
    _historySubscription = _historyService.historyStream.listen((history) {
      if (mounted) {
        setState(() {
          _history = history;
        });
      }
    });
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
          Text(
            loc.noHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(String taskId) async {
    await _historyService.removeFromHistory(taskId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showClearDialog(BuildContext context, AppLocalizations loc) async {
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
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showTaskDetails(BuildContext context, DownloadTask task) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => TaskDetailsBottomSheet(task: task, loc: loc),
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
              if (task.thumbnail != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    task.thumbnail!,
                    width: 100,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                      width: 100,
                      height: 56,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
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
                        _buildStatusChip(context),
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

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String label;

    switch (task.status) {
      case DownloadStatus.completed:
        color = Colors.green;
        label = loc.completedTask;
        break;
      case DownloadStatus.error:
        color = Colors.red;
        label = loc.failedTask;
        break;
      case DownloadStatus.cancelled:
        color = Colors.grey;
        label = loc.cancelledTask;
        break;
      default:
        color = Colors.grey;
        label = loc.unknown;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class TaskDetailsBottomSheet extends StatelessWidget {
  final DownloadTask task;
  final AppLocalizations loc;

  const TaskDetailsBottomSheet({super.key, required this.task, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            Text(task.title!),
            const SizedBox(height: 16),
          ],
          Text(
            loc.urlField,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(task.url),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.typeField,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(task.type == DownloadType.video ? loc.video : loc.audio),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.statusField,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(_getStatusText(task.status, loc)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
          ),
        ],
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
}
