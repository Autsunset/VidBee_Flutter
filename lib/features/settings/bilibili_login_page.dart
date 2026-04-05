// Bilibili 登录页面
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/services/cookie_service.dart';

class BilibiliLoginPage extends StatefulWidget {
  const BilibiliLoginPage({super.key});

  @override
  State<BilibiliLoginPage> createState() => _BilibiliLoginPageState();
}

class _BilibiliLoginPageState extends State<BilibiliLoginPage> {
  late final WebViewController _controller;
  final CookieService _cookieService = CookieService();
  bool _isLoading = true;
  String _statusMessage = '正在加载登录页面...';
  bool _loginDetected = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    try {
      // 获取 Cookie
      final cookies = await _controller.runJavaScriptReturningResult(
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

  /// 保存 Cookie
  Future<void> _saveCookies(String cookieString) async {
    try {
      // 清理 Cookie 字符串
      String cleanCookies = cookieString
          .replaceAll('"', '')
          .replaceAll('\\n', '')
          .trim();
      
      await _cookieService.saveCookie('bilibili.com', cleanCookies);
      
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

  /// 登录成功处理
  Future<void> _onLoginSuccess() async {
    try {
      // 获取所有 Cookie
      final cookies = await _controller.runJavaScriptReturningResult(
        'document.cookie',
      );
      
      await _saveCookies(cookies.toString());
    } catch (e) {
      print('获取 Cookie 失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录 Bilibili'),
        actions: [
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
      body: Column(
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
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
