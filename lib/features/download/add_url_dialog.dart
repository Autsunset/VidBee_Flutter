// 添加 URL 对话框
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../core/services/cookie_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/permission_helper.dart';
import '../../shared/i18n/app_localizations.dart';

class AddUrlDialog extends ConsumerStatefulWidget {
  const AddUrlDialog({super.key});

  @override
  ConsumerState<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends ConsumerState<AddUrlDialog> {
  final _urlController = TextEditingController();
  bool _isAudioOnly = false;
  final CookieService _cookieService = CookieService();
  // 解析完成后缓存当前域名是否已有 Cookie，避免在格式列表中对每个 chip 反复异步查询
  bool _hasCookieForDomain = false;

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
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.addUrl),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: loc.pasteUrl,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.link_outlined),
                ),
                autofocus: true,
                maxLines: null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(loc.audioOnly),
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
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(loc.parsingVideo),
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
          child: Text(loc.cancel),
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
                : Text(loc.parse),
          )
        else
          FilledButton(
            onPressed: isLoading
                ? null
                : () => _startDownload(videoInfo, selectedFormat),
            child: Text(loc.download),
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
            child: CachedNetworkImage(
              imageUrl: videoInfo.thumbnail!,
              width: 120,
              height: 68,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 120,
                height: 68,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.videocam_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              placeholder: (context, url) => Container(
                width: 120,
                height: 68,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

  Widget _buildFormatSelector(
    VideoInfo videoInfo,
    VideoFormat? selectedFormat,
  ) {
    final formats = _isAudioOnly
        ? videoInfo.bestAudioFormats
        : videoInfo.bestVideoFormats;

    if (formats.isEmpty) {
      return Text(AppLocalizations.of(context)!.noAvailableFormat);
    }

    final url = _normalizeUrl(_urlController.text.trim());
    final domain = _cookieService.extractDomain(url);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isAudioOnly
              ? AppLocalizations.of(context)!.selectAudioQuality
              : AppLocalizations.of(context)!.selectVideoQuality,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.asMap().entries.map((entry) {
            final index = entry.key;
            final format = entry.value;
            final isSelected = selectedFormat?.formatId == format.formatId;
            // 对于 Bilibili，只有第一个（最高质量）格式需要登录
            final requiresLogin =
                _cookieService.isBilibiliDomain(domain) && index == 0;
            final isDisabled = requiresLogin && !_hasCookieForDomain;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getFormatLabel(format)),
                  if (requiresLogin) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _hasCookieForDomain ? Icons.verified : Icons.lock,
                      size: 14,
                      color: _hasCookieForDomain
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
                        ref.read(selectedFormatProvider.notifier).state =
                            format;
                      }
                    },
            );
          }).toList(),
        ),
        if (!_hasCookieForDomain && _cookieService.isBilibiliDomain(domain))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppLocalizations.of(context)!.highQualityRequiresLogin,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  String _getFormatLabel(VideoFormat format) {
    final parts = <String>[];

    // 优先显示分辨率或码率
    if (!format.hasVideo) {
      // 音频格式：优先显示比特率
      if (format.tbr != null) {
        parts.add('${format.tbr}k');
      } else if (format.formatNote != null) {
        parts.add(format.formatNote!);
      } else {
        parts.add('音频');
      }
    } else {
      // 视频格式：显示分辨率和比特率
      if (format.height != null && format.height! > 0) {
        parts.add('${format.height}p');
      } else if (format.width != null &&
          format.height != null &&
          format.width! > 0 &&
          format.height! > 0) {
        parts.add('${format.width}x${format.height}');
      } else if (format.formatNote != null) {
        parts.add(format.formatNote!);
      }
      // 添加比特率
      if (format.tbr != null) {
        parts.add('${format.tbr}k');
      }
    }

    if (format.ext.isNotEmpty) {
      parts.add(format.ext.toUpperCase());
    }

    if (format.filesize != null) {
      parts.add(_formatFileSize(format.filesize!));
    } else if (format.filesizeApprox != null) {
      parts.add(_formatFileSize(format.filesizeApprox!));
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
    AppLogger.info('用户开始解析 URL: $url');

    ref.read(isLoadingVideoInfoProvider.notifier).state = true;
    ref.read(currentVideoInfoProvider.notifier).state = null;
    ref.read(selectedFormatProvider.notifier).state = null;

    final ytDlpService = ref.read(ytDlpServiceProvider);
    // 获取自定义UA
    final prefs = await SharedPreferences.getInstance();
    final customUA = prefs.getString('custom_ua') ?? '';
    final defaultVideoQuality =
        prefs.getString('default_video_quality') ?? '1080p';
    final videoInfo = await ytDlpService.getVideoInfo(url, customUA: customUA);
    // 解析完成后一次性查询当前域名的 Cookie 状态，供格式列表复用
    final domain = _cookieService.extractDomain(url);
    final domainHasCookie = await _cookieService.hasCookie(domain);
    if (videoInfo != null) {
      AppLogger.info(
        '用户解析成功: domain=$domain, hasCookie=$domainHasCookie, '
        'formats=${videoInfo.formats.length}, title=${videoInfo.title}',
      );
    }

    if (mounted) {
      ref.read(isLoadingVideoInfoProvider.notifier).state = false;
      setState(() {
        _hasCookieForDomain = domainHasCookie;
      });
      if (videoInfo != null) {
        ref.read(currentVideoInfoProvider.notifier).state = videoInfo;
        // 根据默认质量设置预选格式
        final formats = _isAudioOnly
            ? videoInfo.bestAudioFormats
            : videoInfo.bestVideoFormats;
        if (formats.isNotEmpty) {
          ref.read(selectedFormatProvider.notifier).state = _isAudioOnly
              ? formats.first
              : _pickDefaultVideoFormat(formats, defaultVideoQuality);
        }
      } else {
        final hasCookie = await _cookieService.hasCookie(domain);
        AppLogger.error(
          '用户解析失败: domain=$domain, hasCookie=$hasCookie, url=$url',
        );
        if (!mounted) return;
        final loc = AppLocalizations.of(context)!;

        String errorMessage;
        if (domain.contains('douyin.com') || domain.contains('youtube.com')) {
          if (hasCookie) {
            errorMessage = loc.parseFailedExpired;
          } else {
            errorMessage = loc.parseFailedFresh;
          }
        } else if (_cookieService.isBilibiliDomain(domain)) {
          errorMessage = loc.parseFailedBilibili;
        } else {
          errorMessage = loc.parseFailedDefault;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 8),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// 根据默认视频质量设置，从已排序（从高到低）的格式列表中选择最合适的格式。
  /// 选择不超过目标高度的最高画质；若都高于目标，则退回到最低的一个，
  /// 'best' 或无法解析时直接用最高画质（列表首项）。
  VideoFormat _pickDefaultVideoFormat(
    List<VideoFormat> sortedFormats,
    String quality,
  ) {
    if (quality == 'best') return sortedFormats.first;

    final targetHeight = int.tryParse(quality.replaceAll('p', ''));
    if (targetHeight == null) return sortedFormats.first;

    // 列表已按高度从高到低排序，找到第一个 <= 目标高度的格式
    for (final format in sortedFormats) {
      final h = format.height;
      if (h != null && h > 0 && h <= targetHeight) {
        return format;
      }
    }

    // 没有任何格式 <= 目标高度，说明都是更高画质：选最低的那个（列表末项）
    return sortedFormats.last;
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
      // Bilibili (支持 www 和移动端 m 域名)
      RegExp(r'https?://(?:www\.|m\.)?bilibili\.com/video/[^\s]+'),
      // YouTube
      RegExp(r'https?://(?:www\.)?youtube\.com/watch\?v=[^\s]+'),
      RegExp(r'https?://(?:www\.)?youtube\.com/shorts/[^\s]+'),
      RegExp(r'https?://youtu\.be/[^\s]+'),
      // 抖音
      RegExp(r'https?://(?:www\.)?douyin\.com/[^\s]+'),
      RegExp(r'https?://v\.douyin\.com/[^\s]+'),
      // 通用 URL
      RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+'),
    ];

    for (final pattern in urlPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        var url = match.group(0) ?? '';
        // 移除末尾的标点符号和空白字符
        url = url.replaceAll(RegExp(r'[.,;:!?\s]+$'), '');
        // 移除查询参数中的多余部分（如果有）
        if (url.contains('?')) {
          url = url.split('?')[0];
        }
        // 将移动端域名转换为桌面端域名
        url = _convertMobileToDesktopUrl(url);
        AppLogger.debug('提取到的 URL: $url');
        return url;
      }
    }

    return null;
  }

  /// 将移动端 URL 转换为桌面端 URL
  String _convertMobileToDesktopUrl(String url) {
    // Bilibili 移动端域名转换
    if (url.contains('m.bilibili.com')) {
      return url.replaceFirst('m.bilibili.com', 'www.bilibili.com');
    }
    // YouTube 移动端域名转换
    if (url.contains('m.youtube.com')) {
      return url.replaceFirst('m.youtube.com', 'www.youtube.com');
    }
    return url;
  }

  Future<void> _startDownload(
    VideoInfo videoInfo,
    VideoFormat? selectedFormat,
  ) async {
    // 先检查是否有管理存储权限
    final hasPermission =
        await PermissionHelper.checkManageExternalStoragePermission();
    if (!hasPermission && mounted) {
      final loc = AppLocalizations.of(context)!;
      // 如果没有权限，提示用户去设置
      await PermissionHelper.showPermissionDialog(
        context,
        title: loc.needStoragePermission,
        message: loc.storagePermissionMessage,
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
    ref.read(downloadTasksProvider.notifier).state = downloadService
        .getAllTasks();

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
