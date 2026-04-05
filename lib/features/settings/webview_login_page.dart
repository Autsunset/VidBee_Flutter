// 通用 WebView 登录页面
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/services/cookie_service.dart';

class WebViewLoginPage extends StatefulWidget {
  final String title;
  final String loginUrl;
  final String domain;
  final String? successUrl;
  final List<String>? requiredCookies;

  const WebViewLoginPage({
    super.key,
    required this.title,
    required this.loginUrl,
    required this.domain,
    this.successUrl,
    this.requiredCookies,
  });

  @override
  State<WebViewLoginPage> createState() => _WebViewLoginPageState();
}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  late final WebViewController _controller;
  final CookieService _cookieService = CookieService();
  bool _isLoading = true;
  String _statusMessage = '正在加载登录页面...';
  bool _loginDetected = false;

  @override
  void initState() {
    super.initState();
    // 确保每次打开页面时都是全新状态
    _loginDetected = false;
    _isLoading = true;
    _statusMessage = '正在加载登录页面...';
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      )
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
              _statusMessage = '请登录您的 ${widget.title} 账号，登录后点击"检查登录"';
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView 加载错误: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _statusMessage = '加载失败: ${error.description}';
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // 如果跳转到指定的成功 URL，说明登录成功
            if (widget.successUrl != null && 
                (request.url == widget.successUrl || 
                 request.url.startsWith(widget.successUrl!))) {
              _onLoginSuccess();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.loginUrl));
  }

  /// 检查登录状态 - 仅在用户点击"检查登录"时调用
  Future<void> _checkLoginStatus() async {
    try {
      // 获取 Cookie
      final cookies = await _controller.runJavaScriptReturningResult(
        'document.cookie',
      );

      final cookieString = cookies.toString();

      print('获取到的 Cookie: $cookieString');

      if (cookieString.isNotEmpty) {
        // 直接保存，不管有没有检测到特定的登录 Cookie
        if (!_loginDetected) {
          _loginDetected = true;
          await _saveCookies(cookieString);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未检测到登录状态，请先登录')),
          );
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

      await _cookieService.saveCookie(widget.domain, cleanCookies);

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
        title: Text('登录 ${widget.title}'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                // 获取当前 Cookie
                final cookies = await _controller.runJavaScriptReturningResult(
                  'document.cookie',
                );
                final cookieString = cookies.toString();
                
                print('手动保存 Cookie: $cookieString');
                
                if (cookieString.isNotEmpty) {
                  // 直接保存，不管有没有检测到登录状态
                  _loginDetected = true;
                  await _saveCookies(cookieString);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('未检测到 Cookie，请先在页面中登录')),
                    );
                  }
                }
              } catch (e) {
                print('获取 Cookie 失败: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('获取 Cookie 失败: $e')),
                  );
                }
              }
            },
            child: const Text('保存 Cookie'),
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
