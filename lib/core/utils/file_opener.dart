// 本地文件打开工具
// 通过 Android FileProvider + ACTION_VIEW 弹出系统应用选择器

import 'package:flutter/services.dart';
import 'app_logger.dart';

/// 打开本机已下载文件（视频/音频等），触发系统「用哪个应用打开」。
class FileOpener {
  static const MethodChannel _channel = MethodChannel('com.vidbee.file_opener');

  /// 打开 [filePath] 指向的本地文件。
  ///
  /// 成功返回 `true`；文件不存在或无可用应用时返回 `false`。
  static Future<bool> openFile(String filePath) async {
    if (filePath.isEmpty) return false;
    try {
      final result = await _channel.invokeMethod<bool>('openFile', {
        'filePath': filePath,
      });
      return result ?? true;
    } on PlatformException catch (e) {
      AppLogger.error('打开文件失败: ${e.code} ${e.message}', e);
      return false;
    } catch (e) {
      AppLogger.error('打开文件失败', e);
      return false;
    }
  }
}
