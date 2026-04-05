// 权限请求工具类
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

  /// 检查是否有管理所有文件权限
  static Future<bool> checkManageExternalStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        // 对于Android，我们需要使用特殊方法检查
        // 这里简化处理，先尝试创建一个测试文件
        final testDir = Directory('/storage/emulated/0/Download/VidBee_test');
        try {
          await testDir.create(recursive: true);
          await testDir.delete();
          return true;
        } catch (e) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 请求管理所有文件权限（打开系统设置）
  static Future<void> openManageExternalStorageSettings() async {
    await openAppSettings();
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
