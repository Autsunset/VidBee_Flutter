// 下载页面
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/utils/event_bus.dart';
import '../../shared/i18n/app_localizations.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  StreamSubscription? _taskUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _setupEventListeners();
  }

  @override
  void dispose() {
    _taskUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeService() async {
    final downloadService = ref.read(downloadServiceProvider);
    await downloadService.initialize();
    _refreshTasks();
  }

  void _setupEventListeners() {
    _taskUpdateSubscription = eventBus.on<TaskUpdatedEvent>().listen((event) {
      _refreshTasks();
    });
  }

  void _refreshTasks() {
    final downloadService = ref.read(downloadServiceProvider);
    final tasks = downloadService.getAllTasks();
    ref.read(downloadTasksProvider.notifier).state = tasks;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(downloadTasksProvider);
    final loc = AppLocalizations.of(context)!;

    if (tasks.isEmpty) {
      return _buildEmptyState(context, loc);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => DownloadTaskCard(
        task: tasks[index],
        onCancel: () => _cancelTask(tasks[index].id),
        loc: loc,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(loc.noDownloads, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            loc.clickToAddDownload,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTask(String taskId) async {
    final downloadService = ref.read(downloadServiceProvider);
    await downloadService.cancelTask(taskId);
    _refreshTasks();
  }
}

class DownloadTaskCard extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback onCancel;
  final AppLocalizations loc;

  const DownloadTaskCard({
    super.key,
    required this.task,
    required this.onCancel,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (task.thumbnail != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      task.thumbnail!,
                      width: 120,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 68,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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
                        task.title ?? '未知标题',
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
              ],
            ),
            if (task.progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: task.progress!.percent / 100),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${task.progress!.percent.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (task.progress!.currentSpeed != null)
                    Text(
                      task.progress!.currentSpeed!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (task.progress!.eta != null)
                    Text(
                      'ETA: ${task.progress!.eta}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
            if (task.status == DownloadStatus.downloading ||
                task.status == DownloadStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(loc.cancel),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String label;

    switch (task.status) {
      case DownloadStatus.pending:
        color = Colors.orange;
        label = loc.pendingTask;
        break;
      case DownloadStatus.downloading:
        color = Colors.blue;
        label = loc.downloadingTask;
        break;
      case DownloadStatus.processing:
        color = Colors.purple;
        label = loc.processingTask;
        break;
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
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
