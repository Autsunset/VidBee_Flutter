// Cookie 管理服务
import 'package:shared_preferences/shared_preferences.dart';

class CookieService {
  static final CookieService _instance = CookieService._internal();
  factory CookieService() => _instance;
  CookieService._internal();

  static const String _cookieKeyPrefix = 'cookie_';

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
      final highQualityFormats = ['80', '112', '116', '120', '125', '126', '127'];
      if (highQualityFormats.any((f) => formatId.contains(f))) {
        return true;
      }
    }
    
    return false;
  }
}
