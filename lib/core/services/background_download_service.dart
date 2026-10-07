import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Keeps Android execution alive until every download/merge has returned.
class BackgroundDownloadService {
  BackgroundDownloadService({
    MethodChannel channel = const MethodChannel(
      'com.vidbee.background_download',
    ),
    bool? isAndroid,
  }) : _channel = channel,
       _isAndroid = isAndroid ?? Platform.isAndroid {
    if (_isAndroid) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onTimeout' && _taskIds.isNotEmpty) {
          _timedOut = true;
          _timeouts.add(null);
        }
      });
    }
  }

  final MethodChannel _channel;
  final bool _isAndroid;
  final Set<String> _taskIds = {};
  final StreamController<void> _timeouts = StreamController<void>.broadcast();
  Future<void> _operation = Future<void>.value();
  bool _timedOut = false;

  Stream<void> get timeouts => _timeouts.stream;

  Future<void> acquire(String taskId) => _serialize(() async {
    if (_taskIds.contains(taskId)) return;
    if (_timedOut) {
      throw PlatformException(
        code: 'BACKGROUND_DOWNLOAD_TIMEOUT',
        message: 'Android background download time limit reached',
      );
    }
    if (_isAndroid && _taskIds.isEmpty) {
      // Native code acknowledges only after startForeground and the wake lock.
      await _channel.invokeMethod<void>('start');
    }
    _taskIds.add(taskId);
  });

  Future<void> release(String taskId) => _serialize(() async {
    if (!_taskIds.remove(taskId) || _taskIds.isNotEmpty) return;
    _timedOut = false;
    if (_isAndroid) await _channel.invokeMethod<void>('stop');
  });

  Future<void> _serialize(Future<void> Function() action) {
    final operation = _operation.then((_) => action());
    // A failed start must not poison subsequent retries or cleanup.
    _operation = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }
}
