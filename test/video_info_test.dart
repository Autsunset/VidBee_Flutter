import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/models/video_info.dart';

void main() {
  group('VideoFormat.hasVideo / hasAudio', () {
    test('有视频编码即视为有视频', () {
      final f = VideoFormat(
        formatId: '137',
        ext: 'mp4',
        vcodec: 'avc1',
        width: 1920,
        height: 1080,
      );
      expect(f.hasVideo, isTrue);
    });

    test('无视频编码但有有效分辨率也视为有视频', () {
      final f = VideoFormat(
        formatId: 'x',
        ext: 'mp4',
        vcodec: 'none',
        height: 720,
      );
      expect(f.hasVideo, isTrue);
    });

    test('无编码无分辨率视为无视频', () {
      final f = VideoFormat(formatId: 'x', ext: 'm4a');
      expect(f.hasVideo, isFalse);
    });

    test('纯音频恒有音频', () {
      final f = VideoFormat(
        formatId: '140',
        ext: 'm4a',
        vcodec: 'none',
        acodec: 'mp4a',
      );
      expect(f.hasVideo, isFalse);
      expect(f.hasAudio, isTrue);
    });

    test('有视频但音频为 none 视为无音频', () {
      final f = VideoFormat(
        formatId: '137',
        ext: 'mp4',
        vcodec: 'avc1',
        acodec: 'none',
        width: 1920,
        height: 1080,
      );
      expect(f.hasAudio, isFalse);
    });
  });

  group('VideoFormat.resolution', () {
    test('视频显示 宽x高', () {
      final f = VideoFormat(
        formatId: '137',
        ext: 'mp4',
        vcodec: 'avc1',
        width: 1920,
        height: 1080,
      );
      expect(f.resolution, '1920x1080');
    });

    test('音频显示码率', () {
      final f = VideoFormat(
        formatId: '140',
        ext: 'm4a',
        vcodec: 'none',
        acodec: 'mp4a',
        tbr: 128,
      );
      expect(f.resolution, '128k');
    });
  });

  group('VideoFormat.fromJson 兼容 snake_case', () {
    test('读取 format_id / format_note / filesize_approx / video_ext', () {
      final f = VideoFormat.fromJson({
        'format_id': '137',
        'ext': 'mp4',
        'format_note': '1080p',
        'filesize_approx': 1234,
        'video_ext': 'mp4',
      });
      expect(f.formatId, '137');
      expect(f.formatNote, '1080p');
      expect(f.filesizeApprox, 1234);
      expect(f.videoExt, 'mp4');
    });

    test('缺失关键字段时回退默认值', () {
      final f = VideoFormat.fromJson({});
      expect(f.formatId, 'unknown');
      expect(f.ext, 'unknown');
    });
  });

  group('VideoInfo.durationFormatted', () {
    VideoInfo info(int? d) =>
        VideoInfo(id: '1', title: 't', duration: d, formats: []);

    test('null 返回空串', () => expect(info(null).durationFormatted, ''));
    test('不足一小时返回 mm:ss', () => expect(info(90).durationFormatted, '01:30'));
    test('超过一小时返回 hh:mm:ss', () {
      expect(info(3661).durationFormatted, '01:01:01');
    });
    test('整一小时分秒归零', () {
      expect(info(3600).durationFormatted, '01:00:00');
    });
  });

  group('VideoInfo 格式筛选', () {
    final video1080 = VideoFormat(
      formatId: '137',
      ext: 'mp4',
      vcodec: 'avc1',
      width: 1920,
      height: 1080,
    );
    final video720 = VideoFormat(
      formatId: '136',
      ext: 'mp4',
      vcodec: 'avc1',
      width: 1280,
      height: 720,
    );
    final video1080dup = VideoFormat(
      formatId: '137b',
      ext: 'mp4',
      vcodec: 'avc1',
      width: 1920,
      height: 1080,
      tbr: 100,
    );
    final audio = VideoFormat(
      formatId: '140',
      ext: 'm4a',
      vcodec: 'none',
      acodec: 'mp4a',
      tbr: 128,
    );
    final info = VideoInfo(
      id: '1',
      title: 't',
      formats: [video1080, video720, video1080dup, audio],
    );

    test('videoFormats 只含有视频的格式', () {
      expect(info.videoFormats.length, 3);
    });

    test('audioFormats 只含纯音频', () {
      expect(info.audioFormats, [audio]);
    });

    test('bestVideoFormats 按分辨率去重', () {
      final best = info.bestVideoFormats;
      final heights = best.map((f) => f.height).toSet();
      expect(heights, {1080, 720});
      expect(best.where((f) => f.height == 1080).length, 1);
    });

    test('bestAudioFormat 取码率最高者', () {
      expect(info.bestAudioFormat?.formatId, '140');
    });
  });

  test('VideoInfo toJson/fromJson 往返保留 formats', () {
    final info = VideoInfo(
      id: '1',
      title: 't',
      duration: 100,
      formats: [
        VideoFormat(
          formatId: '137',
          ext: 'mp4',
          vcodec: 'avc1',
          width: 1920,
          height: 1080,
        ),
      ],
    );
    final round = VideoInfo.fromJson(info.toJson());
    expect(round.id, '1');
    expect(round.duration, 100);
    expect(round.formats.length, 1);
    expect(round.formats.first.formatId, '137');
  });

  test('VideoFormat 值相等与 hashCode', () {
    final a = VideoFormat(
      formatId: '137',
      ext: 'mp4',
      width: 1920,
      height: 1080,
    );
    final b = VideoFormat(
      formatId: '137',
      ext: 'mp4',
      width: 1920,
      height: 1080,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == VideoFormat(formatId: '136', ext: 'mp4'), isFalse);
  });
}
