// 下载页面
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/utils/event_bus.dart';
import '../../shared/i18n/app_localizations.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import '../../shared/widgets/task_widgets.dart';
import '../../shared/widgets/workspace_widgets.dart';
import 'add_url_dialog.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  StreamSubscription? _taskUpdateSubscription;
  Timer? _progressRefreshTimer;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeService();
    _setupEventListeners();
  }

  @override
  void dispose() {
    _taskUpdateSubscription?.cancel();
    _progressRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    final downloadService = ref.read(downloadServiceProvider);
    await downloadService.initialize();
    if (mounted) _refreshTasks();
  }

  void _setupEventListeners() {
    _taskUpdateSubscription = eventBus.on<TaskUpdatedEvent>().listen((event) {
      // 下载进度事件触发非常频繁；对其做节流，避免每帧重建整个列表。
      // 状态转换（开始/完成/错误/取消）则立即刷新。
      if (event.task.status == DownloadStatus.downloading) {
        _scheduleProgressRefresh();
      } else {
        _progressRefreshTimer?.cancel();
        _refreshTasks();
      }
    });
  }

  void _scheduleProgressRefresh() {
    if (_progressRefreshTimer?.isActive ?? false) return;
    _progressRefreshTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _refreshTasks();
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
    final isGlass = AppTheme.isLiquidGlass(context);

    if (isGlass) {
      final activeCount = tasks
          .where(
            (task) =>
                task.status == DownloadStatus.pending ||
                task.status == DownloadStatus.downloading ||
                task.status == DownloadStatus.processing,
          )
          .length;
      return ListView.builder(
        key: const PageStorageKey('downloads-list'),
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WorkspaceHeading(
                  title: loc.downloadWorkspace,
                  description: loc.downloadWorkspaceDescription,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: tasks.isEmpty
                      ? WorkspaceEmptyState(
                          icon: Icons.file_download_outlined,
                          title: loc.readyToDownload,
                          description: loc.readyToDownloadDescription,
                          action: FilledButton.icon(
                            onPressed: _showAddUrlDialog,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(loc.addDownload),
                          ),
                        )
                      : GlassSurface(
                          borderRadius: 24,
                          child: InkWell(
                            onTap: _showAddUrlDialog,
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(loc.pasteUrl)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.add_circle_outline_rounded),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 24, 30, 0),
                    child: Text(
                      '${loc.supportedSites}\nYouTube  /  Bilibili  /  Vimeo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.8,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            loc.activeDownloads,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$activeCount',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          final task = tasks[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DownloadTaskCard(
              key: ValueKey(task.id),
              task: task,
              onCancel: () => _cancelTask(task.id),
              loc: loc,
            ),
          );
        },
      );
    }

    if (tasks.isEmpty) {
      return _buildEmptyState(context, loc);
    }

    return ListView.builder(
      key: const PageStorageKey('downloads-list'),
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => DownloadTaskCard(
        key: ValueKey(tasks[index].id),
        task: tasks[index],
        onCancel: () => _cancelTask(tasks[index].id),
        loc: loc,
      ),
    );
  }

  void _showAddUrlDialog() {
    showDialog(context: context, builder: (context) => const AddUrlDialog());
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
    final isGlass = AppTheme.isLiquidGlass(context);
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isGlass)
                GlassTaskArtwork(task: task)
              else
                TaskThumbnail(thumbnailUrl: task.thumbnail),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? loc.unknownTitle,
                      style: isGlass
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TaskStatusChip(status: task.status, loc: loc),
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
            LinearProgressIndicator(
              value: (task.progress!.percent / 100).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
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
    );
    if (isGlass) {
      return GlassCard(
        margin: const EdgeInsets.only(bottom: 14),
        child: content,
      );
    }
    return Card(margin: const EdgeInsets.only(bottom: 12), child: content);
  }
}
