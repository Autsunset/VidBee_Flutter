// Cookie 管理服务
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class CookieService {
  static final CookieService _instance = CookieService._internal();
  factory CookieService() => _instance;
  CookieService._internal();

  static const String _cookieKeyPrefix = 'cookie_';
  static const String _cookieFilePathKey = 'cookie_file_path';

  /// 保存网站的 Cookie
  Future<void> saveCookie(String domain, String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cookieKeyPrefix$domain', cookie);
  }

  /// 获取网站的 Cookie
  Future<String?> getCookie(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_cookieKeyPrefix$domain');
  }

  /// 删除网站的 Cookie
  Future<void> removeCookie(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cookieKeyPrefix$domain');
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

  /// 清除所有 Cookie
  Future<void> clearAllCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_cookieKeyPrefix)) {
        await prefs.remove(key);
      }
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

  /// 检查格式是否需要登录
  /// Bilibili 的高清晰度格式通常需要登录
  bool formatRequiresLogin(String formatId, String domain) {
    // Bilibili 的高清晰度格式
    if (domain.contains('bilibili.com')) {
      // 1080p+ 格式需要登录
      final highQualityFormats = ['64', '80', '112', '116', '120', '125', '126', '127', '30280', '30232', '30216'];
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
          print('检查浏览器 $package 失败: $e');
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
  Future<Map<String, String>?> extractCookiesFromBrowser(String browserName) async {
    try {
      if (Platform.isAndroid) {
        // Android 下的 Cookie 提取
        // 注意：这需要 root 权限或者特殊的访问权限
        // 这里只是示例，实际实现需要更复杂的逻辑
        print('从 $browserName 提取 Cookie (Android)');
        // 实际实现需要访问浏览器的 Cookie 数据库
      } else if (Platform.isWindows) {
        // Windows 下的 Cookie 提取
        print('从 $browserName 提取 Cookie (Windows)');
        // 实际实现需要读取浏览器的 Cookie 文件
      }
      return null;
    } catch (e) {
      print('提取 Cookie 失败: $e');
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
      print('导出 Cookie 失败: $e');
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
      print('导入 Cookie 失败: $e');
      return false;
    }
  }

  /// 从 Netscape 格式 cookies.txt 文件导入 Cookie
  /// 标准格式：# Netscape HTTP Cookie File 开头，每行 7 列（Tab 分隔）
  /// 列：domain\tflag\tpath\tsecure\texpiry\tname\tvalue
  Future<bool> importNetscapeCookieFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('Cookie 文件不存在: $filePath');
        return false;
      }

      final content = await file.readAsString();
      final lines = content.split('\n');

      // 按 domain 分组，收集该 domain 下的所有 name=value
      final Map<String, List<String>> domainCookies = {};

      for (final rawLine in lines) {
        final line = rawLine.trim();
        // 跳过注释行和空行
        if (line.isEmpty || line.startsWith('#')) continue;

        final parts = line.split('\t');
        // Netscape 格式必须恰好有 7 列
        if (parts.length < 7) continue;

        var domain = parts[0].trim();
        // 有些工具导出的 domain 带前导点（.youtube.com），去除
        if (domain.startsWith('.')) {
          domain = domain.substring(1);
        }
        // 去除 www. 前缀
        if (domain.startsWith('www.')) {
          domain = domain.substring(4);
        }

        final name = parts[5].trim();
        final value = parts[6].trim();

        if (domain.isEmpty || name.isEmpty) continue;

        domainCookies.putIfAbsent(domain, () => []).add('$name=$value');
      }

      if (domainCookies.isEmpty) {
        print('未找到有效的 Cookie 条目');
        return false;
      }

      // 将解析结果按 domain 保存（合并为 "; " 分隔的格式）
      for (final entry in domainCookies.entries) {
        final cookieStr = entry.value.join('; ');
        await saveCookie(entry.key, cookieStr);
      }

      // 同时保存原始文件路径，供 yt-dlp 直接使用
      await setCookieFilePath(filePath);

      print('Netscape Cookie 文件导入成功，共解析 ${domainCookies.length} 个域名');
      return true;
    } catch (e) {
      print('导入 Netscape Cookie 文件失败: $e');
      return false;
    }
  }

  /// 获取已保存的 Cookie 文件路径（供 yt-dlp 使用）
  Future<String?> getCookieFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieFilePathKey);
  }

  /// 保存 Cookie 文件路径
  Future<void> setCookieFilePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieFilePathKey, path);
  }

  /// 清除已保存的 Cookie 文件路径（不删除实际文件）
  Future<void> clearCookieFile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieFilePathKey);
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

