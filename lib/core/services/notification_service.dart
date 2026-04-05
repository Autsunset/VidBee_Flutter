
// 通知服务
// 用于显示下载进度的通知显示

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/download_task.dart';

/// 通知服务类
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  /// 显示下载进度通知
  Future<void> showDownloadProgress({
    required String taskId,
    required String title,
    required int progress,
    String? speed,
    String? eta,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      '下载进度',
      channelDescription: '显示视频下载进度',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    String content = '${progress.toStringAsFixed(0)}%';
    if (speed != null) {
      content += ' • $speed';
    }
    if (eta != null) {
      content += ' • 剩余 $eta';
    }

    final notificationId = taskId.hashCode.abs() % 0x7FFFFFFF;

    await _notifications.show(
      notificationId,
      title,
      content,
      details,
    );
  }

  /// 显示下载完成通知
  Future<void> showDownloadComplete({
    required String taskId,
    required String title,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_complete_channel',
      '下载完成',
      channelDescription: '显示视频下载完成',
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final notificationId = taskId.hashCode.abs() % 0x7FFFFFFF;

    await _notifications.show(
      notificationId,
      '下载完成',
      title,
      details,
    );
  }

  /// 显示下载失败通知
  Future<void> showDownloadError({
    required String taskId,
    required String title,
    required String error,
  }) async {
    await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_error_channel',
      '下载失败',
      channelDescription: '显示视频下载失败',
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final notificationId = taskId.hashCode.abs() % 0x7FFFFFFF;

    await _notifications.show(
      notificationId,
      '下载失败',
      '$title: $error',
      details,
    );
  }

  /// 取消指定任务的通知
  Future<void> cancelNotification(String taskId) async {
    final notificationId = taskId.hashCode.abs() % 0x7FFFFFFF;
    await _notifications.cancel(notificationId);
  }
}
