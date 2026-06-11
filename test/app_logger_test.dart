import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/utils/app_logger.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vidbee_logger_test_');
    await AppLogger.resetForTesting(logDirectoryPath: tempDir.path);
    await AppLogger.initialize();
  });

  tearDown(() async {
    await AppLogger.resetForTesting();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('writes logs and redacts sensitive values', () async {
    final before = DateTime.now().subtract(const Duration(minutes: 1));

    AppLogger.error('Cookie: SESSDATA=secret; token=abc123');
    await AppLogger.flush();

    final logs = await AppLogger.readLogs(
      from: before,
      to: DateTime.now().add(const Duration(minutes: 1)),
    );

    expect(logs, contains('[ERROR]'));
    expect(logs, contains('<redacted>'));
    expect(logs, isNot(contains('secret')));
    expect(logs, isNot(contains('abc123')));
  });
}
