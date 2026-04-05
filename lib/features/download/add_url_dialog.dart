// 添加 URL 对话框
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/services/cookie_service.dart';
import '../../core/utils/permission_helper.dart';

class AddUrlDialog extends ConsumerStatefulWidget {
  const AddUrlDialog({super.key});

  @override
  ConsumerState<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends ConsumerState<AddUrlDialog> {
  final _urlController = TextEditingController();
  bool _isAudioOnly = false;
  final CookieService _cookieService = CookieService();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingVideoInfoProvider);
    final videoInfo = ref.watch(currentVideoInfoProvider);
    final selectedFormat = ref.watch(selectedFormatProvider);

    return AlertDialog(
      title: const Text('添加视频 URL'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: '粘贴视频链接...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link_outlined),
                ),
                autofocus: true,
                maxLines: null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('仅下载音频'),
                value: _isAudioOnly,
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _isAudioOnly = value;
                        });
                      },
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('正在解析视频信息...'),
                    ],
                  ),
                ),
              ],
              if (videoInfo != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildVideoPreview(videoInfo),
                const SizedBox(height: 16),
                _buildFormatSelector(videoInfo, selectedFormat),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => _resetAndClose(),
          child: const Text('取消'),
        ),
        if (videoInfo == null)
          FilledButton(
            onPressed: isLoading ? null : _parseUrl,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('解析'),
          )
        else
          FilledButton(
            onPressed: isLoading ? null : () => _startDownload(videoInfo, selectedFormat),
            child: const Text('开始下载'),
          ),
      ],
    );
  }

  Widget _buildVideoPreview(VideoInfo videoInfo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (videoInfo.thumbnail != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              videoInfo.thumbnail!,
              width: 120,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 68,
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
                videoInfo.title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (videoInfo.uploader != null)
                Text(
                  videoInfo.uploader!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (videoInfo.duration != null)
                Text(
                  videoInfo.durationFormatted,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector(VideoInfo videoInfo, VideoFormat? selectedFormat) {
    final formats = _isAudioOnly ? videoInfo.audioFormats : videoInfo.bestVideoFormats;

    if (formats.isEmpty) {
      return const Text('没有可用的格式');
    }

    final url = _normalizeUrl(_urlController.text.trim());
    final domain = _cookieService.extractDomain(url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isAudioOnly ? '选择音频质量' : '选择视频质量',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.map((format) {
            final isSelected = selectedFormat?.formatId == format.formatId;
            final requiresLogin = _cookieService.formatRequiresLogin(format.formatId, domain);
            
            return FutureBuilder<bool>(
              future: _cookieService.hasCookie(domain),
              builder: (context, snapshot) {
                final hasCookie = snapshot.data ?? false;
                final isDisabled = requiresLogin && !hasCookie;
                
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getFormatLabel(format)),
                      if (requiresLogin) ...[
                        const SizedBox(width: 4),
                        Icon(
                          hasCookie ? Icons.verified : Icons.lock,
                          size: 14,
                          color: hasCookie 
                              ? Colors.green 
                              : Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: isDisabled
                      ? null
                      : (selected) {
                          if (selected) {
                            ref.read(selectedFormatProvider.notifier).state = format;
                          }
                        },
                );
              },
            );
          }).toList(),
        ),
        FutureBuilder<bool>(
          future: _cookieService.hasCookie(domain),
          builder: (context, snapshot) {
            final hasCookie = snapshot.data ?? false;
            if (!hasCookie && domain.contains('bilibili.com')) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '🔒 高清晰度需要登录，请在设置中添加 Cookie',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  String _getFormatLabel(VideoFormat format) {
    final parts = <String>[];
    
    // 优先显示分辨率或码率
    if (format.height != null && format.height! > 0) {
      parts.add('${format.height}p');
    } else if (format.width != null && format.height != null) {
      parts.add('${format.width}x${format.height}');
    } else if (format.tbr != null) {
      parts.add('${format.tbr}k');
    } else if (format.formatNote != null) {
      parts.add(format.formatNote!);
    }
    
    if (format.ext.isNotEmpty) {
      parts.add(format.ext.toUpperCase());
    }
    
    if (format.filesize != null) {
      parts.add(_formatFileSize(format.filesize!));
    }
    
    return parts.isEmpty ? format.formatId : parts.join(' • ');
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _parseUrl() async {
    var url = _urlController.text.trim();
    if (url.isEmpty) return;

    // 自动补全 URL
    url = _normalizeUrl(url);

    ref.read(isLoadingVideoInfoProvider.notifier).state = true;
    ref.read(currentVideoInfoProvider.notifier).state = null;
    ref.read(selectedFormatProvider.notifier).state = null;

    final ytDlpService = ref.read(ytDlpServiceProvider);
    final videoInfo = await ytDlpService.getVideoInfo(url);

    if (mounted) {
      ref.read(isLoadingVideoInfoProvider.notifier).state = false;
      if (videoInfo != null) {
        ref.read(currentVideoInfoProvider.notifier).state = videoInfo;
        // 默认选择第一个格式
        final formats = _isAudioOnly ? videoInfo.audioFormats : videoInfo.bestVideoFormats;
        if (formats.isNotEmpty) {
          ref.read(selectedFormatProvider.notifier).state = formats.first;
        }
      }
    }
  }

  /// 自动补全 URL
  String _normalizeUrl(String input) {
    // 先尝试从文本中提取 URL
    final extractedUrl = _extractUrl(input);
    if (extractedUrl != null) {
      input = extractedUrl;
    }

    // 如果已经是完整 URL，直接返回
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return input;
    }

    // Bilibili BV 号
    if (input.startsWith('BV') && input.length >= 10) {
      return 'https://www.bilibili.com/video/$input';
    }

    // Bilibili AV 号
    if (input.startsWith('av') || input.startsWith('AV')) {
      return 'https://www.bilibili.com/video/${input.toLowerCase()}';
    }

    // YouTube 视频 ID (11位字母数字)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(input)) {
      return 'https://www.youtube.com/watch?v=$input';
    }

    // YouTube Shorts ID
    if (input.startsWith('shorts/')) {
      return 'https://www.youtube.com/$input';
    }

    // 默认当作 URL（添加 https://）
    return 'https://$input';
  }

  /// 从文本中提取 URL
  String? _extractUrl(String text) {
    // 常见视频网站 URL 正则表达式
    final urlPatterns = [
      // Bilibili
      RegExp(r'https?://(?:www\.)?bilibili\.com/video/[^\s]+'),
      // YouTube
      RegExp(r'https?://(?:www\.)?youtube\.com/watch\?v=[^\s]+'),
      RegExp(r'https?://(?:www\.)?youtube\.com/shorts/[^\s]+'),
      RegExp(r'https?://youtu\.be/[^\s]+'),
      // 通用 URL
      RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+'),
    ];

    for (final pattern in urlPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        var url = match.group(0) ?? '';
        // 移除末尾的标点符号
        url = url.replaceAll(RegExp(r'[.,;:!?\s]+$'), '');
        return url;
      }
    }

    return null;
  }

  Future<void> _startDownload(VideoInfo videoInfo, VideoFormat? selectedFormat) async {
    // 先检查是否有管理存储权限
    final hasPermission = await PermissionHelper.checkManageExternalStoragePermission();
    if (!hasPermission && mounted) {
      // 如果没有权限，提示用户去设置
      await PermissionHelper.showPermissionDialog(
        context,
        title: '需要存储权限',
        message: '为了能保存视频到公共存储目录，需要授予"管理所有文件"权限。请在设置中开启此权限。',
        onGranted: () async {
          await PermissionHelper.openManageExternalStorageSettings();
        },
      );
      return;
    }

    final downloadService = ref.read(downloadServiceProvider);
    final downloadPath = ref.read(downloadPathProvider);
    
    // 使用补全后的 URL
    final url = _normalizeUrl(_urlController.text.trim());
    
    await downloadService.addTask(
      url: url,
      type: _isAudioOnly ? DownloadType.audio : DownloadType.video,
      selectedFormat: selectedFormat,
      title: videoInfo.title,
      thumbnail: videoInfo.thumbnail,
      channel: videoInfo.uploader,
      duration: videoInfo.duration?.toString(),
      fileSize: selectedFormat?.filesize,
      downloadPath: downloadPath,
    );

    // 刷新任务列表
    ref.read(downloadTasksProvider.notifier).state = downloadService.getAllTasks();

    if (mounted) {
      _resetAndClose();
    }
  }

  void _resetAndClose() {
    ref.read(isLoadingVideoInfoProvider.notifier).state = false;
    ref.read(currentVideoInfoProvider.notifier).state = null;
    ref.read(selectedFormatProvider.notifier).state = null;
    Navigator.of(context).pop();
  }
}
