import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/app_logger.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late DateTime _from;
  late DateTime _to;
  String _logs = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, now.day);
    _to = now;
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await AppLogger.readLogs(from: _from, to: _to);
      if (!mounted) return;
      setState(() {
        _logs = logs;
      });
    } catch (error, stackTrace) {
      AppLogger.error('读取日志失败', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('读取日志失败: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final current = isStart ? _from : _to;
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (selectedTime == null) return;

    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
      isStart ? 0 : 59,
      isStart ? 0 : 999,
    );

    setState(() {
      if (isStart) {
        _from = selected;
        if (_from.isAfter(_to)) {
          _to = _from.add(const Duration(minutes: 5));
        }
      } else {
        _to = selected;
        if (_to.isBefore(_from)) {
          _from = _to.subtract(const Duration(minutes: 5));
        }
      }
    });
    await _loadLogs();
  }

  Future<void> _copyLogs() async {
    final text = _logs.isEmpty ? '选定时间范围内没有日志。' : _logs;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('日志已复制')));
  }

  Future<void> _exportLogs() async {
    try {
      final file = await AppLogger.exportLogs(from: _from, to: _to);
      await Share.shareXFiles([XFile(file.path)], text: 'VidBee 日志');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('日志文件已生成: ${file.path}')));
    } catch (error, stackTrace) {
      AppLogger.error('导出日志失败', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出日志失败: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('日志'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: _isLoading ? null : _loadLogs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: colorScheme.surface,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.play_arrow_outlined),
                  title: const Text('开始时间'),
                  subtitle: Text(_formatDateTime(_from)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () => _pickDateTime(isStart: true),
                ),
                ListTile(
                  leading: const Icon(Icons.stop_outlined),
                  title: const Text('结束时间'),
                  subtitle: Text(_formatDateTime(_to)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () => _pickDateTime(isStart: false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLogPreview(context),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _copyLogs,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('复制'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _exportLogs,
                  icon: const Icon(Icons.ios_share_outlined),
                  label: const Text('导出文件'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogPreview(BuildContext context) {
    if (_logs.isEmpty) {
      return const Center(child: Text('选定时间范围内没有日志'));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: SelectableText(
          _logs,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            height: 1.35,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
