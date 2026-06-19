import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';
import 'package:vidbee_flutter/core/models/video_info.dart';

void main() {
  DownloadTask base() => DownloadTask(
    id: 'id1',
    url: 'https://e.com/v',
    type: DownloadType.video,
    status: DownloadStatus.pending,
    createdAt: 1000,
  );

  group('DownloadTask.copyWith', () {
    test('改变指定字段并保留其它', () {
      final t = base().copyWith(
        status: DownloadStatus.downloading,
        title: 'New',
      );
      expect(t.status, DownloadStatus.downloading);
      expect(t.title, 'New');
      expect(t.id, 'id1');
      expect(t.url, 'https://e.com/v');
      expect(t.createdAt, 1000);
    });

    test('不传参数则保持原值', () {
      final t = base().copyWith();
      expect(t.status, DownloadStatus.pending);
      expect(t.id, 'id1');
    });
  });

  group('DownloadTask.toJson/fromJson', () {
    test('往返保留各字段', () {
      final t = base().copyWith(
        title: 'T',
        status: DownloadStatus.completed,
        tags: ['a', 'b'],
        selectedFormat: VideoFormat(formatId: '137', ext: 'mp4'),
        progress: DownloadProgress(percent: 50),
        playlistId: 'PL',
        playlistIndex: 2,
      );
      final r = DownloadTask.fromJson(t.toJson());
      expect(r.id, 'id1');
      expect(r.title, 'T');
      expect(r.status, DownloadStatus.completed);
      expect(r.type, DownloadType.video);
      expect(r.tags, ['a', 'b']);
      expect(r.selectedFormat?.formatId, '137');
      expect(r.progress?.percent, 50);
      expect(r.playlistId, 'PL');
      expect(r.playlistIndex, 2);
    });

    test('未知 type/status 回退到默认值', () {
      final json = base().toJson()
        ..['type'] = 'bogus'
        ..['status'] = 'bogus';
      final r = DownloadTask.fromJson(json);
      expect(r.type, DownloadType.video);
      expect(r.status, DownloadStatus.pending);
    });
  });

  group('DownloadProgress', () {
    test('copyWith 与往返序列化', () {
      final p = DownloadProgress(
        percent: 12.5,
        eta: '10s',
      ).copyWith(percent: 80);
      expect(p.percent, 80);
      expect(p.eta, '10s');

      final r = DownloadProgress.fromJson(p.toJson());
      expect(r.percent, 80);
      expect(r.eta, '10s');
    });

    test('值相等与 hashCode', () {
      expect(
        DownloadProgress(percent: 50, eta: '5s'),
        DownloadProgress(percent: 50, eta: '5s'),
      );
      expect(
        DownloadProgress(percent: 50).hashCode,
        DownloadProgress(percent: 50).hashCode,
      );
      expect(
        DownloadProgress(percent: 50) == DownloadProgress(percent: 51),
        isFalse,
      );
    });
  });
}
