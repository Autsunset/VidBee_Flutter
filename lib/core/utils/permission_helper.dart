// 权限请求工具类
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// 权限状态
enum PermissionStatusType {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

/// 权限帮助类
class PermissionHelper {
  /// 请求存储权限
  static Future<PermissionStatusType> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return _convertStatus(status);
  }

  /// 请求通知权限
  static Future<PermissionStatusType> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return _convertStatus(status);
  }

  /// 请求相机权限
  static Future<PermissionStatusType> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return _convertStatus(status);
  }

  /// 请求麦克风权限
  static Future<PermissionStatusType> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return _convertStatus(status);
  }

  /// 检查存储权限状态
  static Future<PermissionStatusType> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return _convertStatus(status);
  }

  /// 检查是否有公共下载目录写入能力。
  static Future<bool> checkManageExternalStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final hasManageAccess = await Permission.manageExternalStorage.isGranted;
    if (hasManageAccess) return true;

    return isDirectoryWritable('/storage/emulated/0/Download');
  }

  /// 请求下载目录写入权限。
  static Future<bool> requestDownloadStoragePermission() async {
    if (!Platform.isAndroid) return true;

    if (await checkManageExternalStoragePermission()) return true;

    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return isDirectoryWritable('/storage/emulated/0/Download');
    }

    return false;
  }

  /// 请求管理所有文件权限（打开系统设置）
  static Future<void> openManageExternalStorageSettings() async {
    await Permission.manageExternalStorage.request();
    if (!await checkManageExternalStoragePermission()) {
      await openAppSettings();
    }
  }

  /// 获取默认下载目录。
  static Future<String> getDefaultDownloadPath() async {
    if (Platform.isAndroid) return '/storage/emulated/0/Download';

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) return downloadsDir.path;

    final documentsDir = await getApplicationDocumentsDirectory();
    return '${documentsDir.path}/VidBee';
  }

  /// 检查目录是否可写，必要时创建目录。
  static Future<bool> isDirectoryWritable(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final testFile = File(
        '${dir.path}${Platform.pathSeparator}.vidbee_write_test_${DateTime.now().microsecondsSinceEpoch}',
      );
      await testFile.writeAsString('ok', flush: true);
      await testFile.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 检查通知权限状态
  static Future<PermissionStatusType> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return _convertStatus(status);
  }

  /// 打开应用设置
  static Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }

  /// 转换权限状态
  static PermissionStatusType _convertStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionStatusType.granted;
      case PermissionStatus.denied:
        return PermissionStatusType.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionStatusType.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionStatusType.restricted;
      case PermissionStatus.limited:
        return PermissionStatusType.limited;
      case PermissionStatus.provisional:
        return PermissionStatusType.denied;
    }
  }

  /// 显示权限请求对话框
  static Future<void> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onGranted,
    VoidCallback? onDenied,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDenied?.call();
            },
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onGranted();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }
}
