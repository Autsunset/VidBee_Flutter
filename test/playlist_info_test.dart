import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/models/playlist_info.dart';

void main() {
  test('PlaylistEntry 往返序列化', () {
    final e = PlaylistEntry(
      id: 'e1',
      title: 'T',
      url: 'u',
      index: 3,
      thumbnail: 'th',
    );
    final r = PlaylistEntry.fromJson(e.toJson());
    expect(r.id, 'e1');
    expect(r.title, 'T');
    expect(r.index, 3);
    expect(r.thumbnail, 'th');
  });

  group('PlaylistInfo.fromJson', () {
    test('往返保留 entries 与 entryCount', () {
      final p = PlaylistInfo(
        id: 'p',
        title: 'PL',
        entryCount: 2,
        entries: [
          PlaylistEntry(id: 'e1', title: 'a', url: 'u1', index: 0),
          PlaylistEntry(id: 'e2', title: 'b', url: 'u2', index: 1),
        ],
      );
      final r = PlaylistInfo.fromJson(p.toJson());
      expect(r.id, 'p');
      expect(r.entryCount, 2);
      expect(r.entries.length, 2);
      expect(r.entries.first.id, 'e1');
    });

    test('entryCount 缺失时回退为 entries 长度', () {
      final r = PlaylistInfo.fromJson({
        'id': 'p',
        'title': 'PL',
        'entries': [
          {'id': 'e1', 'title': 'a', 'url': 'u1', 'index': 0},
        ],
      });
      expect(r.entryCount, 1);
    });

    test('entries 缺失时为空列表且计数为 0', () {
      final r = PlaylistInfo.fromJson({'id': 'p', 'title': 'PL'});
      expect(r.entries, isEmpty);
      expect(r.entryCount, 0);
    });
  });
}
