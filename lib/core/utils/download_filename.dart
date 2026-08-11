// 下载产物文件名解析（纯函数，便于单测）
//
// yt-dlp 常把 outputTemplate（如 VidBee_%(title)s.%(ext)s）原样返回；
// 实际落盘名还会对 \ / : * ? " < > | 等字符做替换/删除。
// 这里统一做"安全化后再比对"，避免标题含引号/emoji 时匹配失败，
// 从而把模板路径写进历史记录。

/// 判断路径是否仍是未展开的 yt-dlp 输出模板。
bool isYtDlpTemplatePath(String? path) {
  if (path == null || path.isEmpty) return false;
  return path.contains('%(');
}

/// 去掉路径中的目录，只留文件名。
String fileNameFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final segments = normalized.split('/');
  return segments.isEmpty ? path : segments.last;
}

/// 去掉最后一个扩展名（`a.b.mp4` → `a.b`）。
String stripFileExtension(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot <= 0) return fileName;
  return fileName.substring(0, dot);
}

/// 与 yt-dlp 文件名规则对齐的"安全化"：移除常见非法字符并压缩空白。
///
/// 不在首个非法字符处截断——否则标题以 `"` / `?` 开头时前缀为空，
/// 会导致永远匹配不到真实文件。
String sanitizeFilenameComponent(String input) {
  return input
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// 从候选文件路径中，按 `VidBee_<title>` 规则选出最可能的下载产物。
///
/// [candidatePaths] 应为下载目录中的文件完整路径（调用方已过滤目录 / .part / .ytdl）。
/// [modifiedMsByPath] 可选：路径 → 修改时间毫秒，用于同匹配时取最新。
/// 返回匹配到的完整路径；找不到返回 null（**不会**返回含 `%(...)` 的模板）。
///
/// 匹配顺序：
/// 1. 标题安全化后与文件名主体比对
/// 2. 仅当调用方明确设置 [allowNewestFallback] 时，才回退到最近修改的
///    `VidBee_*` 文件。并发下载场景不得启用该回退。
String? matchDownloadedFileByTitle({
  required List<String> candidatePaths,
  required String? title,
  String filePrefix = 'VidBee_',
  Map<String, int>? modifiedMsByPath,
  bool allowNewestFallback = false,
}) {
  if (candidatePaths.isEmpty) return null;

  final vidbeePaths = <String>[];
  for (final path in candidatePaths) {
    if (isYtDlpTemplatePath(path)) continue;
    final name = fileNameFromPath(path);
    if (!name.startsWith(filePrefix)) continue;
    vidbeePaths.add(path);
  }
  if (vidbeePaths.isEmpty) return null;

  final titleSan = sanitizeFilenameComponent(title ?? '');
  if (titleSan.isNotEmpty) {
    final matches = <String>[];
    for (final path in vidbeePaths) {
      final name = fileNameFromPath(path);
      final stem = stripFileExtension(name).substring(filePrefix.length);
      final stemSan = sanitizeFilenameComponent(stem);
      if (stemSan.isEmpty) continue;
      if (_titleMatchesStem(titleSan, stemSan)) {
        matches.add(path);
      }
    }
    if (matches.isNotEmpty) {
      return _pickNewest(matches, modifiedMsByPath);
    }
  }

  if (!allowNewestFallback) return null;
  return _pickNewest(vidbeePaths, modifiedMsByPath);
}

String? _pickNewest(List<String> paths, Map<String, int>? modifiedMsByPath) {
  if (paths.isEmpty) return null;
  if (paths.length == 1 || modifiedMsByPath == null) return paths.first;
  final sorted = List<String>.from(paths)
    ..sort((a, b) {
      final am = modifiedMsByPath[a] ?? 0;
      final bm = modifiedMsByPath[b] ?? 0;
      return bm.compareTo(am);
    });
  return sorted.first;
}

/// 标题与文件名主体是否足够相似。
///
/// yt-dlp 可能截断过长标题，或微调空白，因此用双向 startsWith +
/// 公共前缀长度兜底，而不是要求完全相等。
bool _titleMatchesStem(String titleSan, String stemSan) {
  if (titleSan == stemSan) return true;
  if (stemSan.startsWith(titleSan) || titleSan.startsWith(stemSan)) {
    return true;
  }

  final common = _commonPrefixLength(titleSan, stemSan);
  // 至少 8 个字符的公共前缀，或覆盖较短一方的全部内容
  final minLen = titleSan.length < stemSan.length
      ? titleSan.length
      : stemSan.length;
  if (minLen == 0) return false;
  if (common >= minLen) return true;
  return common >= 8;
}

int _commonPrefixLength(String a, String b) {
  final n = a.length < b.length ? a.length : b.length;
  var i = 0;
  while (i < n && a[i] == b[i]) {
    i++;
  }
  return i;
}
