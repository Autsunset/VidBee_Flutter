// 设置页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../shared/constants/app_constants.dart';
import '../../core/providers/service_providers.dart';
import '../../core/services/cookie_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/permission_helper.dart';
import '../../shared/i18n/app_localizations.dart';
import 'bilibili_login_page.dart';
import 'webview_login_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _concurrentDownloads = 3;
  bool _enableNotification = true;
  String _videoQuality = '1080p';
  String _audioQuality = '3';
  ThemeMode _themeMode = ThemeMode.system;
  String _language = '简体中文';
  String _customUA = '';
  final CookieService _cookieService = CookieService();
  Map<String, String> _cookies = {};
  Map<String, String> _versionInfo = {};
  bool _isUpdating = false;
  String? _cookieFilePath;

  @override
  void initState() {
    super.initState();
    _loadCookies();
    _loadCookieFilePath();
    _themeMode = ref.read(themeModeProvider);
    _initializeDownloadPath();
    _loadVersionInfo();
    _loadSettings();
  }

  /// 加载保存的设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _concurrentDownloads = prefs.getInt('max_concurrent_downloads') ?? 3;
      _enableNotification = prefs.getBool('enable_notification') ?? true;
      _videoQuality = prefs.getString('default_video_quality') ?? '1080p';
      _audioQuality = prefs.getString('default_audio_quality') ?? '3';
      _customUA = prefs.getString('custom_ua') ?? '';
      // 加载语言设置
      final languageCode = prefs.getString('language') ?? 'zh';
      ref.read(languageProvider.notifier).state = languageCode;
      // 更新语言名称
      final languages = [
        {'code': 'zh', 'name': '简体中文'},
        {'code': 'en', 'name': 'English'},
        {'code': 'ja', 'name': '日本語'},
        {'code': 'ko', 'name': '한국어'},
      ];
      _language = languages.firstWhere(
        (l) => l['code'] == languageCode,
      )['name']!;
      // 下载路径从 provider 读取
    });
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('max_concurrent_downloads', _concurrentDownloads);
    await prefs.setBool('enable_notification', _enableNotification);
    await prefs.setString('default_video_quality', _videoQuality);
    await prefs.setString('default_audio_quality', _audioQuality);
    await prefs.setString('custom_ua', _customUA);
    // 下载路径在 provider 中已经处理
  }

  Future<void> _loadVersionInfo() async {
    try {
      final ytDlpService = ref.read(ytDlpServiceProvider);
      final versionInfo = await ytDlpService.getVersionInfo();
      if (mounted) {
        setState(() {
          _versionInfo = versionInfo;
        });
      }
    } catch (e) {
      AppLogger.error('加载版本信息失败', e);
    }
  }

  Future<void> _updateYtDlp() async {
    if (_isUpdating) return;

    if (mounted) {
      setState(() {
        _isUpdating = true;
      });
    }

    try {
      final ytDlpService = ref.read(ytDlpServiceProvider);
      final success = await ytDlpService.updateYtDlp();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('yt-dlp 更新成功！'),
              duration: Duration(seconds: 3),
            ),
          );
          await _loadVersionInfo();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('yt-dlp 更新失败，请稍后重试。'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _initializeDownloadPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('download_path');
    if (savedPath != null && savedPath.isNotEmpty) {
      // 如果有保存的路径，使用保存的路径
      ref.read(downloadPathProvider.notifier).state = savedPath;
    } else {
      // 否则使用默认路径
      ref.read(downloadPathProvider.notifier).state =
          await PermissionHelper.getDefaultDownloadPath();
    }
  }

  Future<void> _loadCookies() async {
    final cookies = await _cookieService.getAllCookies();
    if (mounted) {
      setState(() {
        _cookies = cookies;
      });
    }
  }

  /// 加载已保存的 Cookie 文件路径
  Future<void> _loadCookieFilePath() async {
    // 获取所有域名的 Cookie 文件路径
    final allPaths = await _cookieService.getAllCookieFilePaths();
    if (mounted) {
      setState(() {
        // 显示第一个路径，或者如果有多个，显示汇总信息
        if (allPaths.isEmpty) {
          _cookieFilePath = null;
        } else if (allPaths.length == 1) {
          _cookieFilePath = allPaths.values.first;
        } else {
          _cookieFilePath = '已导入 ${allPaths.length} 个网站的 Cookie';
        }
      });
    }
  }

  /// 单独清理某个网站的 Cookie
  Future<void> _removeSingleCookie(String domain) async {
    final loc = AppLocalizations.of(context)!;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clear),
        content: Text('确定要清理 $domain 的 Cookie 吗？清理后需要重新登录。'),
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
            child: Text(loc.ok),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cookieService.removeCookie(domain);
      // 同时清除该域名的 Cookie 文件路径
      await _cookieService.clearCookieFileForDomain(domain);
      await _loadCookies();
      await _loadCookieFilePath();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$domain Cookie 已清理'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 导入 Netscape 格式 Cookie 文件
  Future<void> _importCookieFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        dialogTitle: '选择 cookies.txt 文件',
      );
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      final success = await _cookieService.importNetscapeCookieFile(filePath);

      if (!mounted) return;
      if (success) {
        await _loadCookieFilePath();
        await _loadCookies();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.cookieFileImported),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.cookieFileImportFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 清除 Cookie 文件
  Future<void> _clearCookieFile() async {
    final loc = AppLocalizations.of(context)!;
    // 清除所有域名的 Cookie 文件路径
    final allPaths = await _cookieService.getAllCookieFilePaths();
    for (final domain in allPaths.keys) {
      await _cookieService.clearCookieFileForDomain(domain);
    }
    // 同时清除通用路径（向后兼容）
    await _cookieService.clearCookieFile();
    if (mounted) {
      setState(() {
        _cookieFilePath = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.cookieFileCleared)));
    }
  }

  /// 选择下载路径
  Future<void> _selectDownloadPath() async {
    // 先检查是否有管理存储权限
    final hasPermission =
        await PermissionHelper.checkManageExternalStoragePermission();
    if (!hasPermission) {
      if (!mounted) return;
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

    try {
      final selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择下载目录',
      );

      if (selectedPath != null) {
        if (!mounted) return;
        ref.read(downloadPathProvider.notifier).state = selectedPath;
        // 保存下载路径
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('download_path', selectedPath);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('下载路径已设置为: $selectedPath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择路径失败: $e')));
      }
    }
  }

  /// 请求存储权限
  Future<void> _requestStoragePermission() async {
    final granted = await PermissionHelper.requestDownloadStoragePermission();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(granted ? '存储权限已获取' : '存储权限被拒绝')));
    }
  }

  /// 请求通知权限
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      if (status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('通知权限已获取')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('通知权限被拒绝')));
      }
    }
  }

  /// 一键登录 Bilibili
  Future<void> _loginBilibili(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const BilibiliLoginPage()),
    );

    if (result == true) {
      await _loadCookies();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Bilibili 登录成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 一键登录 YouTube
  Future<void> _loginYouTube(BuildContext context) async {
    // 获取自定义UA
    final prefs = await SharedPreferences.getInstance();
    final customUA = prefs.getString('custom_ua') ?? '';
    if (!context.mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => WebViewLoginPage(
          title: 'YouTube',
          loginUrl: 'https://www.youtube.com/',
          domain: 'youtube.com',
          successUrl: 'https://www.youtube.com/',
          userAgent: customUA.isNotEmpty
              ? customUA
              : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        ),
      ),
    );

    if (result == true) {
      await _loadCookies();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ YouTube 登录成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadPath = ref.watch(downloadPathProvider);
    final loc = AppLocalizations.of(context)!;

    return ListView(
      children: [
        // 下载设置
        _buildSectionHeader(loc.downloadSettings),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(loc.downloadPath),
          subtitle: Text(downloadPath),
          trailing: const Icon(Icons.chevron_right),
          onTap: _selectDownloadPath,
        ),
        ListTile(
          leading: const Icon(Icons.download_done_outlined),
          title: Text(loc.concurrentDownloads),
          subtitle: Text('$_concurrentDownloads'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showConcurrentDownloadsDialog(context),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: Text(loc.enableNotification),
          value: _enableNotification,
          onChanged: (value) {
            setState(() {
              _enableNotification = value;
            });
            _saveSettings();
            ref.read(downloadServiceProvider).setNotificationsEnabled(value);
          },
        ),

        // 视频格式默认设置
        const Divider(),
        _buildSectionHeader(loc.defaultSettings),
        ListTile(
          leading: const Icon(Icons.video_library_outlined),
          title: Text(loc.videoQuality),
          subtitle: Text(_getQualityLabel(context, _videoQuality)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showVideoQualityDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.audiotrack_outlined),
          title: Text(loc.audioQuality),
          subtitle: Text(_getAudioQualityLabel(context, _audioQuality)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAudioQualityDialog(context),
        ),

        // 外观设置
        const Divider(),
        _buildSectionHeader(loc.appearance),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(loc.language),
          subtitle: Text(_language),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: Text(loc.themeMode),
          subtitle: Text(_getThemeLabel(context, _themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context),
        ),

        // 权限管理
        const Divider(),
        _buildSectionHeader(loc.permissionManagement),
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: Text(loc.storagePermission),
          subtitle: Text(
            loc.storagePermission,
          ), // loc doesn't have hint, using title maybe? no, just use "loc.storagePermission" as title + something else or write short version
          trailing: const Icon(Icons.chevron_right),
          onTap: _requestStoragePermission,
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: Text(loc.notificationSettings),
          subtitle: Text(
            loc.notificationSettings,
          ), // fallback to using the setting name
          trailing: const Icon(Icons.chevron_right),
          onTap: _requestNotificationPermission,
        ),

        // Cookie 管理
        const Divider(),
        _buildSectionHeader(loc.cookieManagement),

        // 📄 从文件导入 Cookie 卡片
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.file_open_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      loc.importCookieFile,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    // 帮助链接 - 跳转到 Cookie 使用指南
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://github.com/Autsunset/VidBee_Flutter/blob/main/COOKIES_GUIDE.md',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              loc.cookieHelp,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  loc.importCookieFileHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                // 当前文件路径或「未导入」
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _cookieFilePath != null
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: _cookieFilePath != null
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _cookieFilePath != null
                              ? '${loc.currentCookieFile}: ${_cookieFilePath!.split('/').last.split('\\').last}'
                              : loc.noCookieFile,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _importCookieFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(loc.importCookieFile),
                      ),
                    ),
                    if (_cookieFilePath != null) ...[
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _clearCookieFile,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(loc.clearCookieFile),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        // 一键登录 Bilibili
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Bilibili ${loc.login}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _loginBilibili(context),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(loc.login),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showCookieDialog(context, 'bilibili.com'),
                        icon: const Icon(Icons.edit),
                        label: Text(loc.manualCookieInput),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _cookies.containsKey('bilibili.com')
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: _cookies.containsKey('bilibili.com')
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _cookies.containsKey('bilibili.com')
                            ? loc.success
                            : loc.loginRequired,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _cookies.containsKey('bilibili.com')
                              ? Colors.green
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // 单独清理 Bilibili Cookie 的按钮
                    if (_cookies.containsKey('bilibili.com'))
                      TextButton.icon(
                        onPressed: () => _removeSingleCookie('bilibili.com'),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(loc.clear),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 一键登录 YouTube
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.login, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'YouTube ${loc.login}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _loginYouTube(context),
                        icon: const Icon(Icons.open_in_new),
                        label: Text(loc.login),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showCookieDialog(context, 'youtube.com'),
                        icon: const Icon(Icons.edit),
                        label: Text(loc.manualCookieInput),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _cookies.containsKey('youtube.com')
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: _cookies.containsKey('youtube.com')
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _cookies.containsKey('youtube.com')
                            ? loc.success
                            : loc.loginRequired,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _cookies.containsKey('youtube.com')
                              ? Colors.green
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // 单独清理 YouTube Cookie 的按钮
                    if (_cookies.containsKey('youtube.com'))
                      TextButton.icon(
                        onPressed: () => _removeSingleCookie('youtube.com'),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(loc.clear),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: Text(loc.addOtherCookies),
          subtitle: Text(loc.manualCookieInput),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAddCookieDialog(context),
        ),
        if (_cookies.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(loc.clearAll),
            subtitle: Text('${_cookies.length} Cookies'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearCookiesDialog(context),
          ),

        // 高级
        const Divider(),
        _buildSectionHeader(loc.advanced),
        ListTile(
          leading: _isUpdating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.update_outlined),
          title: Text(loc.updateYtDlp),
          subtitle: Text(
            _versionInfo.isEmpty
                ? loc.updateYtDlp
                : '${loc.version}: ${_versionInfo['yt-dlp']?.replaceFirst('yt-dlp ', '') ?? 'Unknown'}',
          ),
          trailing: _isUpdating ? null : const Icon(Icons.chevron_right),
          onTap: _isUpdating ? null : _updateYtDlp,
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined),
          title: Text(loc.clearCache),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showClearCacheDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: Text(loc.customUA),
          subtitle: Text(
            _customUA.isEmpty
                ? loc.systemDefault
                : _customUA.length > 30
                ? '${_customUA.substring(0, 30)}...'
                : _customUA,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCustomUADialog(context),
        ),

        // 关于
        const Divider(),
        _buildSectionHeader(loc.about),
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: Text('${loc.about} VidBee_Flutter'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showConcurrentDownloadsDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.concurrentDownloads),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return RadioGroup<int>(
              groupValue: _concurrentDownloads,
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() {
                    _concurrentDownloads = value;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [1, 2, 3, 4, 5].map((count) {
                  return RadioListTile<int>(
                    title: Text('$count'),
                    value: count,
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() {});
              _saveSettings();
              ref
                  .read(downloadServiceProvider)
                  .setMaxConcurrentDownloads(_concurrentDownloads);
              Navigator.of(context).pop();
            },
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showVideoQualityDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final qualities = [
      '2160p',
      '1440p',
      '1080p',
      '720p',
      '480p',
      '360p',
      'best',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.videoQuality),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return RadioGroup<String>(
              groupValue: _videoQuality,
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() {
                    _videoQuality = value;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: qualities.map((quality) {
                  return RadioListTile<String>(
                    title: Text(_getQualityLabel(context, quality)),
                    value: quality,
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() {});
              _saveSettings();
              Navigator.of(context).pop();
            },
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final qualities = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.audioQuality),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return RadioGroup<String>(
              groupValue: _audioQuality,
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() {
                    _audioQuality = value;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: qualities.map((quality) {
                  return RadioListTile<String>(
                    title: Text(
                      '$quality (${_getAudioQualityLabel(context, quality)})',
                    ),
                    value: quality,
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              setState(() {});
              _saveSettings();
              Navigator.of(context).pop();
            },
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languages = [
      {'code': 'zh', 'name': '简体中文'},
      {'code': 'en', 'name': 'English'},
      {'code': 'ja', 'name': '日本語'},
      {'code': 'ko', 'name': '한국어'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.language),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SizedBox(
              width: double.maxFinite,
              child: RadioGroup<String>(
                groupValue: ref.read(languageProvider),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      ref.read(languageProvider.notifier).state = value;
                      // 更新本地语言名称
                      _language = languages.firstWhere(
                        (l) => l['code'] == value,
                      )['name']!;
                    });
                  }
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    return RadioListTile<String>(
                      title: Text(lang['name']!),
                      value: lang['code']!,
                    );
                  },
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', ref.read(languageProvider));
              if (!context.mounted) return;
              setState(() {});
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${loc.languageChanged}: $_language')),
              );
            },
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.themeMode),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return RadioGroup<ThemeMode>(
              groupValue: _themeMode,
              onChanged: (value) {
                if (value != null) {
                  setDialogState(() {
                    _themeMode = value;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: themes.map((theme) {
                  return RadioListTile<ThemeMode>(
                    title: Text(_getThemeLabel(context, theme)),
                    value: theme,
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () async {
              ref.read(themeModeProvider.notifier).state = _themeMode;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('theme_mode', _themeMode.name);
              if (!context.mounted) return;
              setState(() {});
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${loc.themeChanged}: ${_getThemeLabel(context, _themeMode)}',
                  ),
                ),
              );
            },
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存吗？这不会删除已下载的视频。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final cleared = await _clearAppCache();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(cleared ? '缓存已清除' : '缓存清理失败')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  Future<bool> _clearAppCache() async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (e) {
            AppLogger.error('删除缓存项失败: ${entity.path}', e);
          }
        }
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final mergedCookies = File('${docsDir.path}/merged_cookies.txt');
      if (await mergedCookies.exists()) {
        await mergedCookies.delete();
      }

      return true;
    } catch (e) {
      AppLogger.error('清理缓存失败', e);
      return false;
    }
  }

  void _showCookieDialog(BuildContext context, String domain) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$domain Cookie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '请从浏览器中复制 Cookie 并粘贴到下方：',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '获取方法：\n1. 在浏览器中登录 $domain\n2. 按 F12 打开开发者工具\n3. 切换到 Network 标签\n4. 刷新页面\n5. 点击任意请求\n6. 在 Headers 中找到 Cookie',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Cookie',
                hintText: '粘贴 Cookie...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _cookieService.saveCookie(domain, controller.text);
                await _loadCookies();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$domain Cookie 已保存')));
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showAddCookieDialog(BuildContext context) {
    final domainController = TextEditingController();
    final cookieController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加 Cookie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: domainController,
              decoration: const InputDecoration(
                labelText: '域名',
                hintText: '例如：youtube.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cookieController,
              decoration: const InputDecoration(
                labelText: 'Cookie',
                hintText: '粘贴 Cookie...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (domainController.text.isNotEmpty &&
                  cookieController.text.isNotEmpty) {
                final domain = domainController.text;
                await _cookieService.saveCookie(domain, cookieController.text);
                await _loadCookies();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$domain Cookie 已保存')));
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showClearCookiesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有 Cookie'),
        content: const Text('确定要清除所有保存的 Cookie 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await _cookieService.clearAllCookies();
              await _loadCookies();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('所有 Cookie 已清除')));
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.download_for_offline, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '版本 ${AppConstants.appVersion}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('从全球几乎任何网站下载视频的 Android 应用'),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final uri = Uri.parse(AppConstants.githubUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.code, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.githubUrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 ${AppConstants.appName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _getQualityLabel(BuildContext context, String quality) {
    final loc = AppLocalizations.of(context)!;
    final labels = {
      '2160p': '4K (2160p)',
      '1440p': '2K (1440p)',
      '1080p': 'FHD (1080p)',
      '720p': 'HD (720p)',
      '480p': 'SD (480p)',
      '360p': 'LD (360p)',
      'best': loc.best,
    };
    return labels[quality] ?? quality;
  }

  String _getAudioQualityLabel(BuildContext context, String quality) {
    final loc = AppLocalizations.of(context)!;
    final labels = {
      '0': '${loc.best} (320Kbps)',
      '1': '${loc.good} (256Kbps)',
      '2': '${loc.good} (192Kbps)',
      '3': '${loc.normal} (160Kbps)',
      '4': '${loc.normal} (128Kbps)',
      '5': '${loc.low} (112Kbps)',
      '6': '${loc.low} (96Kbps)',
      '7': '${loc.veryLow} (80Kbps)',
      '8': '${loc.veryLow} (64Kbps)',
      '9': '${loc.veryLow} (48Kbps)',
    };
    return labels[quality] ?? quality;
  }

  String _getThemeLabel(BuildContext context, ThemeMode mode) {
    final loc = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return loc.systemDefault;
      case ThemeMode.light:
        return loc.lightMode;
      case ThemeMode.dark:
        return loc.darkMode;
    }
  }

  void _showCustomUADialog(BuildContext context) {
    final controller = TextEditingController(text: _customUA);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义 User-Agent'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 重要提示：Bilibili 必须使用桌面端 UA
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '重要提示',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bilibili 视频解析必须使用桌面端 UA（Windows/Mac），使用移动端 UA 会导致解析失败！',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '设置自定义的 User-Agent 字符串，用于某些需要特定 UA 的网站。留空则使用默认 UA。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '常见 UA 示例：\n'
                  '• 抖音电脑端：Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\n'
                  '• Chrome：Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0\n'
                  '• 手机端：Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'User-Agent',
                    hintText: '粘贴 User-Agent...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customUA = '';
              });
              _saveSettings();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已恢复默认 User-Agent')));
            },
            child: const Text('恢复默认'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _customUA = controller.text;
              });
              _saveSettings();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('User-Agent 已保存')));
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 获取应用文档目录
  Future<Directory> getApplicationDocumentsDirectory() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory()) ??
          (await getApplicationSupportDirectory());
    } else {
      // 修正: 递归调用修复为正确的获取目录逻辑
      final dir = await getExternalStorageDirectory();
      return dir ?? Directory.current;
    }
  }
}
