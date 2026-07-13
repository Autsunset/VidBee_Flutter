// 设置页面
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../../shared/constants/app_constants.dart';
import '../../shared/constants/languages.dart';
import '../../core/providers/service_providers.dart';
import '../../core/services/app_update_service.dart';
import '../../core/services/cookie_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/permission_helper.dart';
import '../../shared/i18n/app_localizations.dart';
import 'bilibili_login_page.dart';
import 'cookie_settings_section.dart';
import 'logs_page.dart';
import 'settings_section_header.dart';
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
  String _appVersionLabel = AppConstants.appVersion;
  bool _isUpdating = false;
  bool _isCheckingAppUpdate = false;
  bool _isDownloadingAppUpdate = false;
  double? _appUpdateProgress;
  AppReleaseInfo? _latestAppRelease;
  String? _cookieFilePath;

  String _locTemplate(String template, Map<String, Object> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadCookies();
    _loadCookieFilePath();
    _themeMode = ref.read(themeModeProvider);
    _initializeDownloadPath();
    _loadVersionInfo();
    _loadAppVersion();
    _loadSettings();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        // PackageInfo.version 是 CI 注入的正式 versionName；无注入时回退占位常量
        _appVersionLabel = info.version.isNotEmpty
            ? info.version
            : AppConstants.appVersion;
      });
    } catch (e) {
      AppLogger.error('加载应用版本失败', e);
    }
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
      final savedLanguage = prefs.getString('language');
      final languageCode = savedLanguage == null || savedLanguage.isEmpty
          ? ref.read(languageProvider)
          : resolveAppLanguageCode(savedLanguage);
      ref.read(languageProvider.notifier).state = languageCode;
      _language = getLanguageByCode(languageCode)?.nativeName ?? 'English';
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
    final loc = AppLocalizations.of(context)!;

    if (mounted) {
      setState(() {
        _isUpdating = true;
      });
    }

    try {
      final ytDlpService = ref.read(ytDlpServiceProvider);
      final result = await ytDlpService.updateYtDlp();

      if (mounted) {
        await _loadVersionInfo();
        if (!mounted) return;

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.version == null || result.version!.isEmpty
                    ? loc.updateYtDlpSuccess
                    : '${loc.updateYtDlpSuccess} (${result.version})',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          final message = result.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message == null || message.isEmpty
                    ? loc.updateYtDlpRetry
                    : '${loc.updateYtDlpRetry}: $message',
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.updateFailed}: $e'),
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

  Future<void> _checkForAppUpdate() async {
    if (_isCheckingAppUpdate || _isDownloadingAppUpdate) return;
    final loc = AppLocalizations.of(context)!;

    setState(() {
      _isCheckingAppUpdate = true;
      _appUpdateProgress = null;
    });

    try {
      final updateService = ref.read(appUpdateServiceProvider);
      final release = await updateService.checkForUpdate();
      if (!mounted) return;

      setState(() {
        _latestAppRelease = release;
      });

      if (!release.isUpdateAvailable) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.noUpdate)));
        return;
      }

      if (release.asset == null) {
        await _showNoCompatibleApkDialog(release);
        return;
      }

      final install = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.updateAvailable),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${loc.currentVersion}: ${release.currentVersion}'),
              Text('${loc.latestVersion}: ${release.latestVersion}'),
              const SizedBox(height: 8),
              Text('${loc.downloadPackage}: ${release.asset!.name}'),
              Text('${loc.size}: ${_formatBytes(release.asset!.size)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.system_update_alt),
              label: Text(loc.downloadAndInstall),
            ),
          ],
        ),
      );

      if (install == true) {
        await _downloadAndInstallAppUpdate(release);
      }
    } catch (e) {
      AppLogger.error('检查应用更新失败', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.updateFailed}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingAppUpdate = false;
        });
      }
    }
  }

  Future<void> _downloadAndInstallAppUpdate(AppReleaseInfo release) async {
    final loc = AppLocalizations.of(context)!;

    setState(() {
      _isDownloadingAppUpdate = true;
      _appUpdateProgress = 0;
    });

    try {
      final updateService = ref.read(appUpdateServiceProvider);
      final apk = await updateService.downloadReleaseAsset(
        release,
        onProgress: (receivedBytes, totalBytes) {
          if (!mounted || totalBytes == null || totalBytes == 0) return;
          setState(() {
            _appUpdateProgress = receivedBytes / totalBytes;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _appUpdateProgress = 1;
      });

      await updateService.installApk(apk.path);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.installPackageReady)));
    } on PlatformException catch (e) {
      AppLogger.error('安装应用更新失败', e);
      if (!mounted) return;
      if (e.code == 'INSTALL_PERMISSION_REQUIRED') {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.installPermissionRequired),
            content: Text(loc.installPermissionMessage),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.ok),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.updateFailed}: ${e.message ?? e.code}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('下载应用更新失败', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.updateFailed}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingAppUpdate = false;
          _appUpdateProgress = null;
        });
      }
    }
  }

  Future<void> _showNoCompatibleApkDialog(AppReleaseInfo release) async {
    final loc = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.noCompatibleApk),
        content: Text(
          '${loc.latestVersion}: ${release.latestVersion}\n${release.releaseName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: release.releaseUrl.isEmpty
                ? null
                : () async {
                    final uri = Uri.parse(release.releaseUrl);
                    Navigator.of(context).pop();
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
            child: Text(loc.openReleasePage),
          ),
        ],
      ),
    );
  }

  String _buildAppUpdateSubtitle(AppLocalizations loc) {
    if (_isDownloadingAppUpdate) {
      final progress = _appUpdateProgress;
      if (progress == null) return loc.updating;
      return '${loc.updating} ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%';
    }
    if (_isCheckingAppUpdate) return loc.checkingForUpdates;

    final release = _latestAppRelease;
    if (release == null) {
      return '${loc.currentVersion}: $_appVersionLabel';
    }
    if (release.isUpdateAvailable) {
      return '${loc.updateAvailable}: ${release.currentVersion} -> ${release.latestVersion}';
    }
    return '${loc.noUpdate}: ${release.currentVersion}';
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final fixed = unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(fixed)} ${units[unitIndex]}';
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
        _cookieFilePath = _cookieFilePathLabel(allPaths);
      });
    }
  }

  Future<void> _refreshCookieState() async {
    final cookies = await _cookieService.getAllCookies();
    final allPaths = await _cookieService.getAllCookieFilePaths();
    if (!mounted) return;
    setState(() {
      _cookies = cookies;
      _cookieFilePath = _cookieFilePathLabel(allPaths);
    });
  }

  String? _cookieFilePathLabel(Map<String, String> allPaths) {
    if (allPaths.isEmpty) return null;
    if (allPaths.length == 1) return allPaths.values.first;
    return _locTemplate(AppLocalizations.of(context)!.cookieImportedSummary, {
      'count': allPaths.length,
    });
  }

  /// 单独清理某个网站的 Cookie
  Future<void> _removeSingleCookie(String domain) async {
    final loc = AppLocalizations.of(context)!;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clear),
        content: Text(_locTemplate(loc.clearCookieConfirm, {'domain': domain})),
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
            content: Text(_locTemplate(loc.cookieCleared, {'domain': domain})),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 导入 Netscape 格式 Cookie 文件
  Future<void> _importCookieFile() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        dialogTitle: loc.selectCookieFile,
      );
      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      if (!mounted) return;
      final success = await _cookieService.importNetscapeCookieFile(filePath);

      if (!mounted) return;
      if (success) {
        await _refreshCookieState();
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
    final loc = AppLocalizations.of(context)!;
    // 先检查是否有管理存储权限
    final hasPermission =
        await PermissionHelper.checkManageExternalStoragePermission();
    if (!hasPermission) {
      if (!mounted) return;
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

    try {
      final selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: loc.selectDownloadDirectory,
      );

      if (selectedPath != null) {
        if (!mounted) return;
        ref.read(downloadPathProvider.notifier).state = selectedPath;
        // 保存下载路径
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('download_path', selectedPath);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _locTemplate(loc.downloadPathSaved, {'path': selectedPath}),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_locTemplate(loc.selectPathFailed, {'error': e})),
          ),
        );
      }
    }
  }

  /// 请求存储权限
  Future<void> _requestStoragePermission() async {
    final loc = AppLocalizations.of(context)!;
    final granted = await PermissionHelper.requestDownloadStoragePermission();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(granted ? loc.permissionGranted : loc.permissionDenied),
        ),
      );
    }
  }

  /// 请求通知权限
  Future<void> _requestNotificationPermission() async {
    final loc = AppLocalizations.of(context)!;
    final status = await Permission.notification.request();
    if (mounted) {
      if (status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.permissionGranted)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.permissionDenied)));
      }
    }
  }

  /// 一键登录 Bilibili
  Future<void> _loginBilibili(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const BilibiliLoginPage()),
    );

    if (result == true) {
      await _refreshCookieState();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _locTemplate(loc.loginSuccessWithSite, {'site': 'Bilibili'}),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 一键登录 YouTube
  Future<void> _loginYouTube(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
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
      await _refreshCookieState();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _locTemplate(loc.loginSuccessWithSite, {'site': 'YouTube'}),
            ),
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
        SettingsSectionHeader(loc.downloadSettings),
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
        SettingsSectionHeader(loc.defaultSettings),
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
        SettingsSectionHeader(loc.appearance),
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
        SettingsSectionHeader(loc.permissionManagement),
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: Text(loc.storagePermission),
          subtitle: Text(loc.storagePermission),
          trailing: const Icon(Icons.chevron_right),
          onTap: _requestStoragePermission,
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active_outlined),
          title: Text(loc.notificationSettings),
          subtitle: Text(loc.notificationSettings),
          trailing: const Icon(Icons.chevron_right),
          onTap: _requestNotificationPermission,
        ),

        // Cookie 管理
        const Divider(),
        SettingsSectionHeader(loc.cookieManagement),
        CookieSettingsSection(
          loc: loc,
          cookies: _cookies,
          cookieFilePath: _cookieFilePath,
          onImportCookieFile: _importCookieFile,
          onClearCookieFile: _clearCookieFile,
          onLoginBilibili: () => _loginBilibili(context),
          onLoginYouTube: () => _loginYouTube(context),
          onEditBilibiliCookie: () =>
              _showCookieDialog(context, 'bilibili.com'),
          onEditYouTubeCookie: () => _showCookieDialog(context, 'youtube.com'),
          onRemoveBilibiliCookie: () => _removeSingleCookie('bilibili.com'),
          onRemoveYouTubeCookie: () => _removeSingleCookie('youtube.com'),
          onAddOtherCookies: () => _showAddCookieDialog(context),
          onClearAllCookies: () => _showClearCookiesDialog(context),
        ),

        // 高级
        const Divider(),
        SettingsSectionHeader(loc.advanced),
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text(loc.logs),
          subtitle: Text(loc.logsSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const LogsPage())),
        ),
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
          leading: _isCheckingAppUpdate || _isDownloadingAppUpdate
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.system_update_alt_outlined),
          title: Text(loc.checkForUpdates),
          subtitle: Text(_buildAppUpdateSubtitle(loc)),
          trailing: _isCheckingAppUpdate || _isDownloadingAppUpdate
              ? null
              : const Icon(Icons.chevron_right),
          onTap: _isCheckingAppUpdate || _isDownloadingAppUpdate
              ? null
              : _checkForAppUpdate,
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
        SettingsSectionHeader(loc.about),
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: Text('${loc.about} VidBee_Flutter'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAboutDialog(context),
        ),
      ],
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
    final languages = getLanguageList();

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
                      _language = getLanguageByCode(value)?.nativeName ?? value;
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
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clearCache),
        content: Text(loc.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final cleared = await _clearAppCache();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    cleared ? loc.cacheCleared : loc.cacheClearFailed,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(loc.clearAction),
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
    final loc = AppLocalizations.of(context)!;
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
              loc.cookiePasteHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              _locTemplate(loc.cookieHowToGet, {'domain': domain}),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Cookie',
                hintText: loc.pasteCookieHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _cookieService.saveCookie(domain, controller.text);
                await _loadCookies();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _locTemplate(loc.cookieSavedForDomain, {
                          'domain': domain,
                        }),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showAddCookieDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final domainController = TextEditingController();
    final cookieController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.addCookie),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: domainController,
              decoration: InputDecoration(
                labelText: loc.domainLabel,
                hintText: loc.domainHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cookieController,
              decoration: InputDecoration(
                labelText: 'Cookie',
                hintText: loc.pasteCookieHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _locTemplate(loc.cookieSavedForDomain, {
                          'domain': domain,
                        }),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    ).whenComplete(() {
      domainController.dispose();
      cookieController.dispose();
    });
  }

  void _showClearCookiesDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clearAllCookies),
        content: Text(loc.clearAllCookiesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await _cookieService.clearAllCookies();
              await _loadCookies();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(loc.allCookiesCleared)));
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(loc.clearAction),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.about),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
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
                          '${loc.version} $_appVersionLabel',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(loc.appDescription),
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
                    Expanded(
                      child: Text(
                        AppConstants.githubUrl,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.close),
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
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _customUA);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.customUA),
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
                            loc.importantNote,
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
                        loc.bilibiliUaWarning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.customUaDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.commonUaExamples,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'User-Agent',
                    hintText: loc.pasteUaHint,
                    border: const OutlineInputBorder(),
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
            child: Text(loc.cancel),
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
              ).showSnackBar(SnackBar(content: Text(loc.uaRestoredDefault)));
            },
            child: Text(loc.restoreDefault),
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
              ).showSnackBar(SnackBar(content: Text(loc.uaSaved)));
            },
            child: Text(loc.save),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
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
