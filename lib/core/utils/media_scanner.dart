// 媒体扫描工具
// 用于通知系统媒体库扫描新下载的文件

import 'package:flutter/services.dart';

/// 媒体扫描工具类
class MediaScanner {
  static const MethodChannel _channel = MethodChannel('com.vidbee.media_scanner');

  /// 扫描单个文件
  static Future<void> scanFile(String filePath) async {
    try {
      await _channel.invokeMethod('scanFile', {'filePath': filePath});
      print('媒体扫描成功: $filePath');
    } catch (e) {
      print('媒体扫描失败: $e');
    }
  }
}
