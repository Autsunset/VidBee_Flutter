// Cookie 管理服务
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// 仅在 Android/iOS 平台导入 WebView Cookie 管理
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_logger.dart';

class CookieService {
  static final CookieService _instance = CookieService._internal();
  factory CookieService() => _instance;
  CookieService._internal();

  static const String _cookieKeyPrefix = 'cookie_';
  static const String _cookieFilePathKey = 'cookie_file_path';
  static const String _cookieFilePathPrefix =
      'cookie_file_path_'; // 按域名存储 Cookie 文件路径

  /// 保存网站的 Cookie
  Future<void> saveCookie(String domain, String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedDomain = _normalizeDomain(domain);
    await prefs.setString('$_cookieKeyPrefix$normalizedDomain', cookie);
  }

  /// 获取网站的 Cookie
  Future<String?> getCookie(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedDomain = _normalizeDomain(domain);
    return prefs.getString('$_cookieKeyPrefix$normalizedDomain') ??
        prefs.getString('$_cookieKeyPrefix$domain');
  }

  /// 删除网站的 Cookie（包括 SharedPreferences 和 WebView CookieManager）
  /// 注意：WebView CookieManager 会清理所有 Cookie，因为 API 不支持按域名删除
  Future<void> removeCookie(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedDomain = _normalizeDomain(domain);
    await prefs.remove('$_cookieKeyPrefix$normalizedDomain');
    if (normalizedDomain != domain) {
      await prefs.remove('$_cookieKeyPrefix$domain');
    }

    // 清理 WebView CookieManager（会清理所有 Cookie）
    // 这是因为 WebView CookieManager API 不支持按域名删除
    await _clearWebViewCookies();
  }

  /// 检查是否有某个网站的 Cookie
  Future<bool> hasCookie(String domain) async {
    final cookie = await getCookie(domain);
    return cookie != null && cookie.isNotEmpty;
  }

  /// 获取所有保存的 Cookie
  Future<Map<String, String>> getAllCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final cookies = <String, String>{};

    for (final key in keys) {
      if (key.startsWith(_cookieKeyPrefix)) {
        final domain = key.substring(_cookieKeyPrefix.length);
        final cookie = prefs.getString(key);
        if (cookie != null) {
          cookies[domain] = cookie;
        }
      }
    }

    return cookies;
  }

  /// 清除所有 Cookie（包括 SharedPreferences 和 WebView CookieManager）
  Future<void> clearAllCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // 1. 清理 SharedPreferences 中的 Cookie
    for (final key in keys) {
      if (key.startsWith(_cookieKeyPrefix)) {
        await prefs.remove(key);
      }
    }

    // 2. 清理 WebView CookieManager 中的所有 Cookie
    await _clearWebViewCookies();
  }

  /// 清理 WebView CookieManager 中的所有 Cookie
  Future<void> _clearWebViewCookies() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      AppLogger.debug('WebView Cookie 已清理');
    } catch (e) {
      AppLogger.error('清理 WebView Cookie 失败', e);
    }
  }

  /// 从 URL 中提取域名
  String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      var host = uri.host;

      // 移除 www. 前缀
      if (host.startsWith('www.')) {
        host = host.substring(4);
      }

      return host;
    } catch (e) {
      return '';
    }
  }

  /// 返回用于查找 Cookie 的规范域名。
  String cookieLookupDomain(String domain) => _normalizeDomain(domain);

  /// 判断域名是否应按 Bilibili 处理。
  bool isBilibiliDomain(String domain) {
    final normalizedDomain = _normalizeDomain(domain);
    return normalizedDomain == 'bilibili.com' ||
        normalizedDomain.endsWith('.bilibili.com');
  }

  /// 检查格式是否需要登录
  /// Bilibili 的高清晰度格式通常需要登录
  bool formatRequiresLogin(String formatId, String domain) {
    // Bilibili 的高清晰度格式
    if (isBilibiliDomain(domain)) {
      // 1080p+ 格式需要登录
      final highQualityFormats = [
        '64',
        '80',
        '112',
        '116',
        '120',
        '125',
        '126',
        '127',
        '30280',
        '30232',
        '30216',
      ];
      if (highQualityFormats.any((f) => formatId.contains(f))) {
        return true;
      }
    }

    return false;
  }

  /// 检测已安装的浏览器
  Future<List<String>> detectBrowsers() async {
    final browsers = <String>[];

    if (Platform.isAndroid) {
      // 检查常见浏览器包名
      final browserPackages = [
        'com.android.chrome',
        'org.mozilla.firefox',
        'com.microsoft.emmx',
        'com.opera.browser',
        'com.uc.browser.en',
        'com.vivaldi.browser',
        'com.yandex.browser',
      ];

      for (final package in browserPackages) {
        try {
          final result = await Process.run('pm', ['list', 'packages', package]);
          if (result.stdout.toString().contains(package)) {
            browsers.add(_getBrowserName(package));
          }
        } catch (e) {
          AppLogger.error('检查浏览器 $package 失败', e);
        }
      }
    } else if (Platform.isWindows) {
      // Windows 下检查常见浏览器
      final browserPaths = [
        r'C:\Program Files\Google\Chrome\Application\chrome.exe',
        r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
        r'C:\Program Files\Mozilla Firefox\firefox.exe',
        r'C:\Program Files (x86)\Mozilla Firefox\firefox.exe',
        r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
      ];

      for (final path in browserPaths) {
        if (File(path).existsSync()) {
          browsers.add(_getWindowsBrowserName(path));
        }
      }
    }

    return browsers;
  }

  /// 从浏览器提取 Cookie
  Future<Map<String, String>?> extractCookiesFromBrowser(
    String browserName,
  ) async {
    try {
      if (Platform.isAndroid) {
        // Android 下的 Cookie 提取
        // 注意：这需要 root 权限或者特殊的访问权限
        // 这里只是示例，实际实现需要更复杂的逻辑
        AppLogger.debug('从 $browserName 提取 Cookie (Android)');
        // 实际实现需要访问浏览器的 Cookie 数据库
      } else if (Platform.isWindows) {
        // Windows 下的 Cookie 提取
        AppLogger.debug('从 $browserName 提取 Cookie (Windows)');
        // 实际实现需要读取浏览器的 Cookie 文件
      }
      return null;
    } catch (e) {
      AppLogger.error('提取 Cookie 失败', e);
      return null;
    }
  }

  /// 导出 Cookie 到文件
  Future<String?> exportCookies(String filePath) async {
    try {
      final cookies = await getAllCookies();
      final file = File(filePath);
      await file.writeAsString(_serializeCookies(cookies));
      return filePath;
    } catch (e) {
      AppLogger.error('导出 Cookie 失败', e);
      return null;
    }
  }

  /// 从文件导入 Cookie（旧格式：domain:value）
  Future<bool> importCookies(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final content = await file.readAsString();
      final cookies = _deserializeCookies(content);

      for (final entry in cookies.entries) {
        await saveCookie(entry.key, entry.value);
      }

      return true;
    } catch (e) {
      AppLogger.error('导入 Cookie 失败', e);
      return false;
    }
  }

  /// 从 Netscape 格式 cookies.txt 文件导入 Cookie
  /// 标准格式：# Netscape HTTP Cookie File 开头，每行 7 列（Tab 分隔）
  /// 列：domain\tflag\tpath\tsecure\texpiry\tname\tvalue
  ///
  /// 支持多网站：会按域名分别存储 Cookie 文件，不会互相覆盖
  Future<bool> importNetscapeCookieFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.debug('Cookie 文件不存在: $filePath');
        return false;
      }

      final content = await file.readAsString();
      final lines = content.split('\n');

      // 按 domain 分组，保留原始 Netscape 行（含 secure/path/expiry 等完整属性）。
      // 保留原始行至关重要：Google 的 __Secure-* 前缀 Cookie 规范要求 secure=TRUE
      // 才会被发送，若像旧实现那样统一重写为 secure=FALSE，会破坏登录态导致
      // accounts.google.com/CookieMismatch。
      final Map<String, List<String>> domainRawLines = {};

      for (final rawLine in lines) {
        final line = rawLine.trim();
        // 跳过注释行和空行
        if (line.isEmpty || line.startsWith('#')) continue;

        final parts = line.split('\t');
        // Netscape 格式必须至少有 7 列
        if (parts.length < 7) continue;

        var domain = parts[0].trim();
        // 有些工具导出的 domain 带前导点（.youtube.com），去除用于分组
        if (domain.startsWith('.')) {
          domain = domain.substring(1);
        }
        // 去除 www. 前缀
        if (domain.startsWith('www.')) {
          domain = domain.substring(4);
        }

        final name = parts[5].trim();

        if (domain.isEmpty || name.isEmpty) continue;

        domainRawLines.putIfAbsent(domain, () => []).add(line);
      }

      if (domainRawLines.isEmpty) {
        AppLogger.debug('未找到有效的 Cookie 条目');
        return false;
      }

      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();

      final totalCookieCount = domainRawLines.values.fold<int>(
        0,
        (sum, lines) => sum + lines.length,
      );

      // 将解析结果按 domain 分别保存
      for (final entry in domainRawLines.entries) {
        final domain = entry.key;
        final rawLines = entry.value;

        // 1. 保存到 SharedPreferences（name=value 形式，仅用于 UI 显示）
        final cookieStr = rawLines.map((line) {
          final p = line.split('\t');
          return '${p[5]}=${p[6]}';
        }).join('; ');
        await saveCookie(domain, cookieStr);

        // 2. 按域名保存为独立的 Cookie 文件（供 yt-dlp 使用）。
        //    直接写入原始行，保留 secure/path/expiry 等字段不被改写。
        final domainCookieFile = File('${directory.path}/cookies_$domain.txt');
        final buffer = StringBuffer();
        buffer.writeln('# Netscape HTTP Cookie File');
        buffer.writeln('# This file was generated by VidBee for $domain');
        buffer.writeln('# https://curl.haxx.se/rfc/cookie_spec.html');
        buffer.writeln();

        for (final line in rawLines) {
          buffer.writeln(line);
        }

        await domainCookieFile.writeAsString(buffer.toString());

        // 3. 保存该域名的 Cookie 文件路径
        await setCookieFilePathForDomain(domain, domainCookieFile.path);
      }

      // 同时保存原始文件路径（向后兼容）
      await setCookieFilePath(filePath);

      final focusedDomains = [
        'bilibili.com',
        'youtube.com',
        'douyin.com',
        'tiktok.com',
      ].where(domainRawLines.containsKey).join(', ');
      final focusedSummary = focusedDomains.isEmpty
          ? ''
          : '，包含重点域名: $focusedDomains';
      AppLogger.debug(
        'Netscape Cookie 文件导入成功: '
        '${domainRawLines.length} 个域名, $totalCookieCount 条 Cookie$focusedSummary',
      );
      return true;
    } catch (e) {
      AppLogger.error('导入 Netscape Cookie 文件失败', e);
      return false;
    }
  }

  /// 获取已保存的 Cookie 文件路径（供 yt-dlp 使用）
  /// 注意：此方法返回最后导入的 Cookie 文件路径，已废弃，请使用 getCookieFilePathForDomain
  @Deprecated('Use getCookieFilePathForDomain instead.')
  Future<String?> getCookieFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieFilePathKey);
  }

  /// 保存 Cookie 文件路径
  /// 注意：此方法会覆盖全局 Cookie 文件路径，已废弃，请使用 setCookieFilePathForDomain
  @Deprecated('Use setCookieFilePathForDomain instead.')
  Future<void> setCookieFilePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieFilePathKey, path);
  }

  /// 清除已保存的 Cookie 文件路径（不删除实际文件）
  /// 注意：此方法清除全局 Cookie 文件路径，已废弃，请使用 clearCookieFileForDomain
  @Deprecated('Use clearCookieFileForDomain instead.')
  Future<void> clearCookieFile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieFilePathKey);
  }

  // ==================== 按域名存储 Cookie 文件路径（新实现）====================

  /// 获取指定域名的 Cookie 文件路径
  Future<String?> getCookieFilePathForDomain(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    // 标准化域名（移除 www. 前缀）
    final normalizedDomain = _normalizeDomain(domain);
    return prefs.getString('$_cookieFilePathPrefix$normalizedDomain') ??
        prefs.getString('$_cookieFilePathPrefix$domain');
  }

  /// 返回解析某 URL 时应传给 yt-dlp 的 Cookie 文件路径。
  ///
  /// 对于需要多域名 Cookie 协同的站点（如 Google 系：YouTube 登录态分散在
  /// youtube.com / google.com / accounts.google.com），会合并相关域名的 Cookie
  /// 为一个临时文件，避免因按域名拆分存储导致认证不完整（表现为
  /// accounts.google.com/CookieMismatch）。其他站点按单域名精确查找。
  Future<String?> getCookieFileForUrl(String url) async {
    final domain = cookieLookupDomain(extractDomain(url));
    final related = _relatedCookieDomains(domain);
    if (related.length > 1) {
      final merged = await mergeCookieFilesForDomains(related);
      if (merged != null) return merged;
    }
    return getCookieFilePathForDomain(domain);
  }

  /// 返回与某域名共享登录态的相关域名列表，用于 Cookie 合并。
  List<String> _relatedCookieDomains(String domain) {
    // Google 系站点登录态跨多个 Google 域名共享
    const googleDomains = [
      'youtube.com',
      'google.com',
      'accounts.google.com',
      'googleusercontent.com',
    ];
    if (googleDomains.contains(domain)) {
      return googleDomains;
    }
    return [domain];
  }

  /// 保存指定域名的 Cookie 文件路径
  Future<void> setCookieFilePathForDomain(String domain, String path) async {
    final prefs = await SharedPreferences.getInstance();
    // 标准化域名（移除 www. 前缀）
    final normalizedDomain = _normalizeDomain(domain);
    await prefs.setString('$_cookieFilePathPrefix$normalizedDomain', path);
  }

  /// 清除指定域名的 Cookie 文件路径
  Future<void> clearCookieFileForDomain(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    // 标准化域名（移除 www. 前缀）
    final normalizedDomain = _normalizeDomain(domain);
    await prefs.remove('$_cookieFilePathPrefix$normalizedDomain');
  }

  /// 获取所有已保存的 Cookie 文件路径
  Future<Map<String, String>> getAllCookieFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final paths = <String, String>{};

    for (final key in keys) {
      if (key.startsWith(_cookieFilePathPrefix)) {
        final domain = key.substring(_cookieFilePathPrefix.length);
        final path = prefs.getString(key);
        if (path != null && path.isNotEmpty) {
          paths[domain] = path;
        }
      }
    }

    return paths;
  }

  /// 标准化域名（移除 www. 前缀）
  String _normalizeDomain(String domain) {
    var normalized = domain.toLowerCase().trim();
    if (normalized.startsWith('www.')) {
      normalized = normalized.substring(4);
    }
    if (normalized == 'b23.tv') {
      return 'bilibili.com';
    }
    // YouTube 短链 youtu.be 共享 youtube.com 的 Cookie，需归一到同一域名，
    // 否则解析短链时查不到导入的 youtube.com Cookie，触发"非机器人"验证。
    if (normalized == 'youtu.be') {
      return 'youtube.com';
    }
    return normalized;
  }

  /// 合并多个域名的 Cookie 文件为一个临时文件（供 yt-dlp 使用）
  Future<String?> mergeCookieFilesForDomains(List<String> domains) async {
    try {
      final allPaths = await getAllCookieFilePaths();
      final filesToMerge = <File>[];

      for (final domain in domains) {
        final normalizedDomain = _normalizeDomain(domain);
        // 查找匹配的域名
        for (final entry in allPaths.entries) {
          if (entry.key == normalizedDomain ||
              normalizedDomain.endsWith(entry.key) ||
              entry.key.endsWith(normalizedDomain)) {
            final file = File(entry.value);
            if (await file.exists()) {
              filesToMerge.add(file);
              break;
            }
          }
        }
      }

      if (filesToMerge.isEmpty) {
        return null;
      }

      // 如果只有一个文件，直接返回其路径
      if (filesToMerge.length == 1) {
        return filesToMerge.first.path;
      }

      // 合并多个文件
      final directory = await getApplicationDocumentsDirectory();
      final mergedFile = File('${directory.path}/merged_cookies.txt');
      final buffer = StringBuffer();
      buffer.writeln('# Netscape HTTP Cookie File');
      buffer.writeln('# This file was generated by VidBee (merged)');
      buffer.writeln();

      final Set<String> processedLines = {};
      for (final file in filesToMerge) {
        final content = await file.readAsString();
        final lines = content.split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          // 跳过注释行和空行，避免重复
          if (trimmed.isNotEmpty &&
              !trimmed.startsWith('#') &&
              !processedLines.contains(trimmed)) {
            buffer.writeln(trimmed);
            processedLines.add(trimmed);
          }
        }
      }

      await mergedFile.writeAsString(buffer.toString());
      return mergedFile.path;
    } catch (e) {
      AppLogger.error('合并 Cookie 文件失败', e);
      return null;
    }
  }

  /// 序列化 Cookie
  String _serializeCookies(Map<String, String> cookies) {
    final buffer = StringBuffer();
    for (final entry in cookies.entries) {
      buffer.writeln('${entry.key}:${entry.value}');
    }
    return buffer.toString();
  }

  /// 反序列化 Cookie
  Map<String, String> _deserializeCookies(String content) {
    final cookies = <String, String>{};
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.isNotEmpty) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0];
          final value = parts.sublist(1).join(':');
          cookies[key] = value;
        }
      }
    }
    return cookies;
  }

  /// 获取浏览器名称
  String _getBrowserName(String packageName) {
    final browserMap = {
      'com.android.chrome': 'Chrome',
      'org.mozilla.firefox': 'Firefox',
      'com.microsoft.emmx': 'Edge',
      'com.opera.browser': 'Opera',
      'com.uc.browser.en': 'UC Browser',
      'com.vivaldi.browser': 'Vivaldi',
      'com.yandex.browser': 'Yandex Browser',
    };
    return browserMap[packageName] ?? packageName;
  }

  /// 获取 Windows 浏览器名称
  String _getWindowsBrowserName(String path) {
    if (path.contains('chrome')) {
      return 'Chrome';
    } else if (path.contains('firefox')) {
      return 'Firefox';
    } else if (path.contains('edge')) {
      return 'Edge';
    }
    return 'Unknown';
  }
}
