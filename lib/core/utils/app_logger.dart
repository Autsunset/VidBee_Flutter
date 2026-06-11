import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppLogger {
  const AppLogger._();

  static const int _retentionDays = 30;
  static const String _logFilePrefix = 'vidbee_';
  static const String _logFileExtension = '.log';

  static Directory? _logDirectory;
  static Directory? _overrideLogDirectory;
  static Future<void>? _initFuture;
  static Future<void> _writeChain = Future<void>.value();

  static Future<void> initialize() {
    _initFuture ??= _initialize().catchError((Object error) {
      if (kDebugMode) {
        debugPrint('AppLogger 初始化失败: $error');
      }
    });
    return _initFuture!;
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
    _log('DEBUG', message);
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
    _log('INFO', message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint(error == null ? message : '$message: $error');
    }
    final entry = error == null ? message : '$message: $error';
    _log('ERROR', entry, stackTrace);
  }

  static Future<String> readLogs({
    required DateTime from,
    required DateTime to,
  }) async {
    await initialize();
    await flush();
    if (_logDirectory == null || from.isAfter(to)) return '';

    final buffer = StringBuffer();
    for (final file in _logFilesForRange(from, to)) {
      if (!await file.exists()) continue;

      var includeCurrentEntry = false;
      final lines = await file.readAsLines();
      for (final line in lines) {
        final timestamp = _parseLineTimestamp(line);
        if (timestamp != null) {
          includeCurrentEntry =
              !timestamp.isBefore(from) && !timestamp.isAfter(to);
        }

        if (includeCurrentEntry) {
          buffer.writeln(line);
        }
      }
    }

    return buffer.toString().trimRight();
  }

  static Future<File> exportLogs({
    required DateTime from,
    required DateTime to,
  }) async {
    await initialize();

    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(documentsDir.path, 'log_exports'));
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File(
      p.join(
        exportDir.path,
        'vidbee_logs_${_fileTimestamp(from)}_${_fileTimestamp(to)}.txt',
      ),
    );
    final logs = await readLogs(from: from, to: to);
    final content = StringBuffer()
      ..writeln('VidBee logs')
      ..writeln('Range: ${_formatTimestamp(from)} - ${_formatTimestamp(to)}')
      ..writeln('Generated: ${_formatTimestamp(DateTime.now())}')
      ..writeln()
      ..write(logs.isEmpty ? 'No logs in selected range.' : logs);

    await file.writeAsString(content.toString(), flush: true);
    return file;
  }

  static Future<void> flush() async {
    await _writeChain;
  }

  @visibleForTesting
  static Future<void> resetForTesting({String? logDirectoryPath}) async {
    await flush();
    _initFuture = null;
    _logDirectory = null;
    _overrideLogDirectory = logDirectoryPath == null
        ? null
        : Directory(logDirectoryPath);
    _writeChain = Future<void>.value();
    if (_overrideLogDirectory != null &&
        !await _overrideLogDirectory!.exists()) {
      await _overrideLogDirectory!.create(recursive: true);
    }
  }

  static Future<void> _initialize() async {
    final logDirectory =
        _overrideLogDirectory ??
        Directory(
          p.join((await getApplicationDocumentsDirectory()).path, 'logs'),
        );
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }
    _logDirectory = logDirectory;
    await _cleanupOldLogs();
    await _writeEntryDirect(_formatEntry('INFO', '日志系统已启动'));
  }

  static void _log(String level, String message, [StackTrace? stackTrace]) {
    final entry = _formatEntry(level, message, stackTrace);
    _writeChain = _writeChain
        .then((_) async {
          await initialize();
          if (_logDirectory == null) return;
          await _writeEntryDirect(entry);
        })
        .catchError((Object error) {
          if (kDebugMode) {
            debugPrint('AppLogger 写入失败: $error');
          }
        });
  }

  static Future<void> _writeEntryDirect(String entry) async {
    final logDirectory = _logDirectory;
    if (logDirectory == null) return;
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    final file = _logFileForDate(DateTime.now());
    try {
      await file.writeAsString('$entry\n', mode: FileMode.append, flush: false);
    } on FileSystemException {
      if (!await logDirectory.exists()) {
        await logDirectory.create(recursive: true);
      }
      await file.writeAsString('$entry\n', mode: FileMode.append, flush: false);
    }
  }

  static Future<void> _cleanupOldLogs() async {
    final logDirectory = _logDirectory;
    if (logDirectory == null || !await logDirectory.exists()) return;

    final cutoff = DateTime.now().subtract(
      const Duration(days: _retentionDays),
    );
    await for (final entity in logDirectory.list()) {
      if (entity is! File) continue;
      final date = _dateFromLogFileName(p.basename(entity.path));
      if (date != null &&
          date.isBefore(DateTime(cutoff.year, cutoff.month, cutoff.day))) {
        try {
          await entity.delete();
        } catch (error) {
          if (kDebugMode) {
            debugPrint('删除旧日志失败: ${entity.path}: $error');
          }
        }
      }
    }
  }

  static List<File> _logFilesForRange(DateTime from, DateTime to) {
    final files = <File>[];
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      files.add(_logFileForDate(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return files;
  }

  static File _logFileForDate(DateTime date) {
    final logDirectory = _logDirectory!;
    return File(
      p.join(
        logDirectory.path,
        '$_logFilePrefix${_dateKey(date)}$_logFileExtension',
      ),
    );
  }

  static String _formatEntry(
    String level,
    String message, [
    StackTrace? stackTrace,
  ]) {
    final sanitizedMessage = _sanitize(message);
    final buffer = StringBuffer()
      ..write('[${_formatTimestamp(DateTime.now())}] ')
      ..write('[$level] ')
      ..write(sanitizedMessage);

    if (stackTrace != null) {
      buffer
        ..writeln()
        ..write(_sanitize(stackTrace.toString()));
    }
    return buffer.toString();
  }

  static String _sanitize(String value) {
    var result = value;
    result = result.replaceAllMapped(
      RegExp(r'\b(cookie|authorization)\s*:\s*[^\n]+', caseSensitive: false),
      (match) => '${match.group(1)}: <redacted>',
    );
    result = result.replaceAllMapped(
      RegExp(
        r'\b(SESSDATA|bili_jct|DedeUserID|sid|token|auth|password)=([^;&\s]+)',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}=<redacted>',
    );
    return result;
  }

  static DateTime? _parseLineTimestamp(String line) {
    final match = RegExp(
      r'^\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})\.(\d{3})\]',
    ).firstMatch(line);
    if (match == null) return null;

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
      int.parse(match.group(7)!),
    );
  }

  static DateTime? _dateFromLogFileName(String fileName) {
    final match = RegExp(
      r'^vidbee_(\d{4})-(\d{2})-(\d{2})\.log$',
    ).firstMatch(fileName);
    if (match == null) return null;

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}.'
        '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }

  static String _fileTimestamp(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')}_'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
