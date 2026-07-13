import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/utils/download_filename.dart';

void main() {
  group('isYtDlpTemplatePath', () {
    test('识别未展开模板', () {
      expect(isYtDlpTemplatePath('VidBee_%(title)s.%(ext)s'), isTrue);
      expect(
        isYtDlpTemplatePath('/storage/emulated/0/Download/VidBee_%(title)s.%(ext)s'),
        isTrue,
      );
      expect(isYtDlpTemplatePath(null), isFalse);
      expect(isYtDlpTemplatePath(''), isFalse);
      expect(isYtDlpTemplatePath('/a/VidBee_clip.mp4'), isFalse);
    });
  });

  group('sanitizeFilenameComponent', () {
    test('移除非法字符并保留其余内容', () {
      expect(
        sanitizeFilenameComponent('"我邻居可太可爱了"😂穿着I love bad boys'),
        '我邻居可太可爱了😂穿着I love bad boys',
      );
      expect(sanitizeFilenameComponent(r'a\b/c:d*e?f"g<h>i|j'), 'abcdefghij');
    });
  });

  group('matchDownloadedFileByTitle', () {
    test('匹配含引号/emoji 的 B 站标题（旧前缀截断会失败）', () {
      const title = '"我邻居可太可爱了"😂穿着I love bad boys送男友进警车这也太剧本了';
      // yt-dlp 去掉引号后的典型落盘名
      const real =
          '/storage/emulated/0/Download/VidBee_我邻居可太可爱了😂穿着I love bad boys送男友进警车这也太剧本了.mp4';
      final matched = matchDownloadedFileByTitle(
        candidatePaths: [
          '/storage/emulated/0/Download/other.mp4',
          real,
          '/storage/emulated/0/Download/VidBee_%(title)s.%(ext)s',
        ],
        title: title,
      );
      expect(matched, real);
    });

    test('忽略 .part 以外的无关文件与模板路径', () {
      final matched = matchDownloadedFileByTitle(
        candidatePaths: [
          '/d/VidBee_%(title)s.%(ext)s',
          '/d/readme.txt',
          '/d/VidBee_Hello World.mp4',
        ],
        title: 'Hello World',
      );
      expect(matched, '/d/VidBee_Hello World.mp4');
    });

    test('标题被 yt-dlp 截断时仍可匹配公共前缀', () {
      final matched = matchDownloadedFileByTitle(
        candidatePaths: [
          '/d/VidBee_这是一段很长的视频标题会被截断.mp4',
        ],
        title: '这是一段很长的视频标题会被截断并且后面还有更多文字',
      );
      expect(matched, '/d/VidBee_这是一段很长的视频标题会被截断.mp4');
    });

    test('多匹配时取修改时间最新的', () {
      final matched = matchDownloadedFileByTitle(
        candidatePaths: [
          '/d/VidBee_clip.mp4',
          '/d/VidBee_clip.webm',
        ],
        title: 'clip',
        modifiedMsByPath: {
          '/d/VidBee_clip.mp4': 100,
          '/d/VidBee_clip.webm': 200,
        },
      );
      expect(matched, '/d/VidBee_clip.webm');
    });

    test('无匹配返回 null，不回退到模板', () {
      final matched = matchDownloadedFileByTitle(
        candidatePaths: [
          '/d/VidBee_%(title)s.%(ext)s',
          '/d/other.mp4',
        ],
        title: '不存在的标题',
      );
      expect(matched, isNull);
    });

    test('空标题返回 null', () {
      expect(
        matchDownloadedFileByTitle(
          candidatePaths: ['/d/VidBee_a.mp4'],
          title: null,
        ),
        isNull,
      );
      expect(
        matchDownloadedFileByTitle(
          candidatePaths: ['/d/VidBee_a.mp4'],
          title: '???',
        ),
        isNull, // 全是非法字符，sanitize 后为空
      );
    });
  });

  group('fileNameFromPath / stripFileExtension', () {
    test('提取文件名与去扩展名', () {
      expect(
        fileNameFromPath(r'C:\Download\VidBee_a.mp4'),
        'VidBee_a.mp4',
      );
      expect(stripFileExtension('VidBee_a.b.mp4'), 'VidBee_a.b');
      expect(stripFileExtension('noext'), 'noext');
    });
  });
}
