// Bilibili 登录页面
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/services/cookie_service.dart';

class BilibiliLoginPage extends StatefulWidget {
  const BilibiliLoginPage({super.key});

  @override
  State<BilibiliLoginPage> createState() => _BilibiliLoginPageState();
}

class _BilibiliLoginPageState extends State<BilibiliLoginPage> {
  WebViewController? _controller;
  final CookieService _cookieService = CookieService();
  bool _isLoading = true;
  String _statusMessage = '正在检查登录状态...';
  bool _loginDetected = false;
  bool _isControllerReady = false;
  bool _hasExistingCookie = false;

  @override
  void initState() {
    super.initState();
    _checkExistingCookie();
  }

  /// 检查是否已有保存的 Cookie
  Future<void> _checkExistingCookie() async {
    try {
      // 检查 SharedPreferences 和 Cookie 文件路径
      final hasCookie = await _cookieService.hasCookie('bilibili.com');
      final cookieFilePath = await _cookieService.getCookieFilePath();

      if (hasCookie && cookieFilePath != null && cookieFilePath.isNotEmpty) {
        // 检查文件是否存在
        final file = File(cookieFilePath);
        if (await file.exists()) {
          setState(() {
            _hasExistingCookie = true;
            _statusMessage = '已保存 Bilibili Cookie，如需重新登录请点击下方按钮';
            _isLoading = false;
          });
          return;
        }
      }

      // 没有有效 Cookie，进入登录流程
      _clearWebViewCookiesAndInit();
    } catch (e) {
      print('检查 Cookie 失败: $e');
      _clearWebViewCookiesAndInit();
    }
  }

  /// 先清理 WebView Cookie，再初始化 WebView
  Future<void> _clearWebViewCookiesAndInit() async {
    setState(() {
      _statusMessage = '正在清理旧 Cookie...';
    });
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      print('WebView Cookie 已清理，准备加载登录页面');
    } catch (e) {
      print('清理 WebView Cookie 失败: $e');
    }
    _initWebView();
  }

  void _initWebView() {
    // 桌面端 UA，Bilibili 必须使用桌面端 UA 才能正确提取 Cookie
    const desktopUA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(desktopUA)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _statusMessage = '正在加载...';
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
              _statusMessage = '请登录您的 Bilibili 账号';
            });

            // 检查是否已登录
            await _checkLoginStatus();
          },
          onNavigationRequest: (NavigationRequest request) {
            // 如果跳转到首页，说明登录成功
            if (request.url == 'https://www.bilibili.com/' ||
                request.url == 'https://www.bilibili.com') {
              _onLoginSuccess();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://passport.bilibili.com/login'));

    setState(() {
      _isControllerReady = true;
    });
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    if (_controller == null) return;

    try {
      // 获取 Cookie
      final cookies = await _controller!.runJavaScriptReturningResult(
        'document.cookie',
      );

      final cookieString = cookies.toString();

      // 检查是否有登录相关的 Cookie
      if (cookieString.contains('SESSDATA') && cookieString.contains('bili_jct')) {
        // 已登录
        if (!_loginDetected) {
          _loginDetected = true;
          await _saveCookies(cookieString);
        }
      }
    } catch (e) {
      print('检查登录状态失败: $e');
    }
  }

  /// 保存 Cookie（同时保存到 SharedPreferences 和导出为 Netscape 格式文件）
  Future<void> _saveCookies(String cookieString) async {
    try {
      // 清理 Cookie 字符串
      String cleanCookies = cookieString
          .replaceAll('"', '')
          .replaceAll('\\n', '')
          .trim();

      // 1. 保存到 SharedPreferences
      await _cookieService.saveCookie('bilibili.com', cleanCookies);

      // 2. 导出为 Netscape 格式文件（供 yt-dlp 使用）
      final cookieFilePath = await _exportNetscapeCookieFile(cleanCookies);
      if (cookieFilePath != null) {
        // 使用新的按域名存储方法
        await _cookieService.setCookieFilePathForDomain('bilibili.com', cookieFilePath);
        // 同时保存到通用路径（向后兼容）
        await _cookieService.setCookieFilePath(cookieFilePath);
        print('Cookie 文件已导出: $cookieFilePath');
      }

      if (mounted) {
        setState(() {
          _statusMessage = '✅ 登录成功！Cookie 已保存';
        });

        // 延迟后关闭页面
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
    } catch (e) {
      print('保存 Cookie 失败: $e');
      if (mounted) {
        setState(() {
          _statusMessage = '❌ 保存 Cookie 失败: $e';
        });
      }
    }
  }

  /// 导出 Netscape 格式 Cookie 文件
  Future<String?> _exportNetscapeCookieFile(String cookieString) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cookieFile = File('${directory.path}/cookies.txt');

      // 构建 Netscape 格式
      final buffer = StringBuffer();
      buffer.writeln('# Netscape HTTP Cookie File');
      buffer.writeln('# This file was generated by VidBee');
      buffer.writeln('# https://curl.haxx.se/rfc/cookie_spec.html');
      buffer.writeln();

      // 计算过期时间（30天后）
      final expiry = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000;

      // 解析 Cookie 字符串并写入
      final cookies = cookieString.split(';');
      for (final cookie in cookies) {
        final parts = cookie.trim().split('=');
        if (parts.length >= 2) {
          final name = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();
          if (name.isNotEmpty && value.isNotEmpty) {
            // Netscape 格式: domain	flag	path	secure	expiry	name	value
            // 同时添加 .bilibili.com 和 bilibili.com 两种域名格式
            buffer.writeln('.bilibili.com\tTRUE\t/\tFALSE\t$expiry\t$name\t$value');
            buffer.writeln('bilibili.com\tFALSE\t/\tFALSE\t$expiry\t$name\t$value');
          }
        }
      }

      // 添加一些 Bilibili 常用的子域名
      final subDomains = ['www.bilibili.com', 'passport.bilibili.com', 'api.bilibili.com'];
      for (final domain in subDomains) {
        for (final cookie in cookies) {
          final parts = cookie.trim().split('=');
          if (parts.length >= 2) {
            final name = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            if (name.isNotEmpty && value.isNotEmpty) {
              buffer.writeln('$domain\tFALSE\t/\tFALSE\t$expiry\t$name\t$value');
            }
          }
        }
      }

      await cookieFile.writeAsString(buffer.toString());
      print('Cookie 文件内容预览:\n${buffer.toString().substring(0, buffer.length > 500 ? 500 : buffer.length)}...');
      return cookieFile.path;
    } catch (e) {
      print('导出 Cookie 文件失败: $e');
      return null;
    }
  }

  /// 登录成功处理
  Future<void> _onLoginSuccess() async {
    if (_controller == null) return;

    try {
      // 获取所有 Cookie
      final cookies = await _controller!.runJavaScriptReturningResult(
        'document.cookie',
      );

      await _saveCookies(cookies.toString());
    } catch (e) {
      print('获取 Cookie 失败: $e');
    }
  }

  /// 清除已保存的 Cookie 并重新登录
  Future<void> _clearAndReLogin() async {
    // 删除 Cookie 文件
    final cookieFilePath = await _cookieService.getCookieFilePath();
    if (cookieFilePath != null && cookieFilePath.isNotEmpty) {
      try {
        final file = File(cookieFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('删除 Cookie 文件失败: $e');
      }
    }

    // 清除保存的 Cookie 和文件路径
    await _cookieService.removeCookie('bilibili.com');
    await _cookieService.setCookieFilePath('');

    setState(() {
      _hasExistingCookie = false;
      _isLoading = true;
    });
    _clearWebViewCookiesAndInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录 Bilibili'),
        actions: [
          if (!_hasExistingCookie)
            TextButton(
              onPressed: () async {
                await _checkLoginStatus();
                if (!_loginDetected) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('未检测到登录状态，请先登录')),
                    );
                  }
                }
              },
              child: const Text('检查登录'),
            ),
        ],
      ),
      body: _hasExistingCookie
          ? _buildExistingCookieView()
          : _buildLoginView(),
    );
  }

  /// 显示已有 Cookie 的界面
  Widget _buildExistingCookieView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              '已登录 Bilibili',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cookie 已保存，可以直接下载 Bilibili 视频',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('确定'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearAndReLogin,
              icon: const Icon(Icons.refresh),
              label: const Text('重新登录'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示登录界面
  Widget _buildLoginView() {
    return Column(
      children: [
        // 状态栏
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: _loginDetected
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  _loginDetected ? Icons.check_circle : Icons.info_outline,
                  size: 16,
                  color: _loginDetected ? Colors.green : null,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        // WebView
        Expanded(
          child: _isControllerReady && _controller != null
              ? WebViewWidget(controller: _controller!)
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在初始化 WebView...'),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
