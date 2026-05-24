// 通用 WebView 登录页面
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/services/cookie_service.dart';
import '../../core/utils/app_logger.dart';

class WebViewLoginPage extends StatefulWidget {
  final String title;
  final String loginUrl;
  final String domain;
  final String? successUrl;
  final List<String>? requiredCookies;
  final String? userAgent;

  const WebViewLoginPage({
    super.key,
    required this.title,
    required this.loginUrl,
    required this.domain,
    this.successUrl,
    this.requiredCookies,
    this.userAgent,
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
    _statusMessage = '正在清理旧 Cookie...';
    _clearWebViewCookiesAndInit();
  }

  /// 先清理 WebView Cookie，再初始化 WebView
  Future<void> _clearWebViewCookiesAndInit() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      AppLogger.debug('WebView Cookie 已清理，准备加载登录页面');
    } catch (e) {
      AppLogger.error('清理 WebView Cookie 失败', e);
    }
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        widget.userAgent ??
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
            AppLogger.error('WebView 加载错误');
            AppLogger.error('WebView 错误描述', error.description);
            AppLogger.error('WebView 错误码', error.errorCode);
            AppLogger.error('WebView 错误类型', error.errorType);
            AppLogger.error('WebView 错误 URL', error.url);

            if (mounted) {
              setState(() {
                _isLoading = false;
                String errorMsg = '加载失败';

                // 根据错误码提供更详细的错误信息
                switch (error.errorCode) {
                  case -1:
                    errorMsg = '未知错误';
                    break;
                  case -2:
                    errorMsg = '服务器未响应，请检查网络连接';
                    break;
                  case -6:
                    errorMsg = '连接被拒绝，服务器可能拒绝访问';
                    break;
                  case -7:
                    errorMsg = '连接超时，请检查网络';
                    break;
                  case -8:
                    errorMsg = '连接关闭';
                    break;
                  case -10:
                    errorMsg = '无法解析服务器名称，请检查 DNS 设置';
                    break;
                  case -11:
                    errorMsg = '无法连接到服务器';
                    break;
                  default:
                    errorMsg = '加载失败: ${error.description}';
                }

                _statusMessage = '$errorMsg (错误码: ${error.errorCode})';
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
      AppLogger.error('保存 Cookie 失败', e);
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
      AppLogger.error('获取 Cookie 失败', e);
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

                AppLogger.debug('手动保存 Cookie: 已获取 Cookie');

                if (cookieString.isNotEmpty) {
                  // 直接保存，不管有没有检测到登录状态
                  _loginDetected = true;
                  await _saveCookies(cookieString);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('未检测到 Cookie，请先在页面中登录')),
                    );
                  }
                }
              } catch (e) {
                AppLogger.error('获取 Cookie 失败', e);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('获取 Cookie 失败: $e')));
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
                ? Colors.green.withValues(alpha: 0.1)
                : _statusMessage.contains('失败')
                ? Colors.red.withValues(alpha: 0.1)
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
                    _loginDetected
                        ? Icons.check_circle
                        : _statusMessage.contains('失败')
                        ? Icons.error_outline
                        : Icons.info_outline,
                    size: 16,
                    color: _loginDetected
                        ? Colors.green
                        : _statusMessage.contains('失败')
                        ? Colors.red
                        : null,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                // 错误时显示重试按钮
                if (_statusMessage.contains('失败') ||
                    _statusMessage.contains('错误'))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _statusMessage = '正在重新加载...';
                      });
                      _controller.reload();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('重试'),
                  ),
              ],
            ),
          ),

          // WebView
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
