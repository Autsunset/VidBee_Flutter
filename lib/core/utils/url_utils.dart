// URL 提取 / 补全工具（解析与下载共用，纯函数便于单测）

/// 判断是否为带 host 的 http(s) URL。
///
/// 用于拦截 `https://`、空串、缺 host 等无法下载的输入。
bool isValidHttpUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

/// 自动补全 / 从分享文本中提取视频 URL。
///
/// - 支持从「标题 + 链接」混合文本中提取
/// - 支持 BV/AV、YouTube ID 等简写
/// - 空输入返回空串（**不会**变成 `https://`）
String normalizeVideoUrl(String input) {
  input = input.trim();
  if (input.isEmpty) return '';

  final extractedUrl = extractVideoUrl(input);
  if (extractedUrl != null) {
    input = extractedUrl;
  }

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

  return 'https://$input';
}

/// 从文本中提取第一个视频相关 URL；找不到返回 null。
String? extractVideoUrl(String text) {
  final urlPatterns = [
    // Bilibili (支持 www 和移动端 m 域名)
    RegExp(r'https?://(?:www\.|m\.)?bilibili\.com/video/[^\s]+'),
    // Bilibili 短链
    RegExp(r'https?://b23\.tv/[^\s]+'),
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
      // 仅移除末尾的标点符号和空白字符，必须保留 ?v= 等查询参数，
      // 否则会把 youtube.com/watch?v=xxx 砍成 watch 导致解析失败
      url = url.replaceAll(RegExp(r'[.,;:!?\s]+$'), '');
      url = convertMobileToDesktopUrl(url);
      return url;
    }
  }

  return null;
}

/// 将移动端域名转换为桌面端域名。
String convertMobileToDesktopUrl(String url) {
  if (url.contains('m.bilibili.com')) {
    return url.replaceFirst('m.bilibili.com', 'www.bilibili.com');
  }
  if (url.contains('m.youtube.com')) {
    return url.replaceFirst('m.youtube.com', 'www.youtube.com');
  }
  return url;
}

/// 解析下载用 URL：优先使用「解析成功时锁定的 URL」，其次 yt-dlp 返回的
/// webpageUrl，最后才回退到输入框文本。避免用户在解析后清空输入框导致
/// 任务 URL 变成 `https://`。
String resolveDownloadUrl({
  required String? parsedUrl,
  String? webpageUrl,
  required String inputText,
}) {
  if (parsedUrl != null && isValidHttpUrl(parsedUrl)) {
    return parsedUrl.trim();
  }
  final webpage = webpageUrl?.trim();
  if (webpage != null && isValidHttpUrl(webpage)) {
    return webpage;
  }
  return normalizeVideoUrl(inputText);
}
