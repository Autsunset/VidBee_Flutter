import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/models/download_task.dart';
import '../i18n/app_localizations.dart';

/// 任务缩略图：带占位与错误回退，下载页与历史页共用（尺寸可配）。
///
/// [thumbnailUrl] 为 null 时返回零尺寸占位，行为与原先的
/// `if (task.thumbnail != null) ...` 一致（外层间距不变）。
class TaskThumbnail extends StatelessWidget {
  const TaskThumbnail({
    super.key,
    required this.thumbnailUrl,
    this.width = 120,
    this.height = 68,
  });

  final String? thumbnailUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl;
    if (url == null) return const SizedBox.shrink();

    final fallbackColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: fallbackColor,
          child: Icon(
            Icons.videocam_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        placeholder: (context, url) =>
            Container(width: width, height: height, color: fallbackColor),
      ),
    );
  }
}

/// 任务状态标签，下载页与历史页共用。
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.status, required this.loc});

  final DownloadStatus status;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      DownloadStatus.pending => (Colors.orange, loc.pendingTask),
      DownloadStatus.downloading => (Colors.blue, loc.downloadingTask),
      DownloadStatus.processing => (Colors.purple, loc.processingTask),
      DownloadStatus.completed => (Colors.green, loc.completedTask),
      DownloadStatus.error => (Colors.red, loc.failedTask),
      DownloadStatus.cancelled => (Colors.grey, loc.cancelledTask),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
