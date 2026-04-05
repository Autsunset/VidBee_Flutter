import 'download_task.dart';

class PlaylistEntry {
  final String id;
  final String title;
  final String url;
  final int index;
  final String? thumbnail;

  PlaylistEntry({
    required this.id,
    required this.title,
    required this.url,
    required this.index,
    this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'index': index,
      'thumbnail': thumbnail,
    };
  }

  factory PlaylistEntry.fromJson(Map<String, dynamic> json) {
    return PlaylistEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      index: json['index'] as int,
      thumbnail: json['thumbnail'] as String?,
    );
  }
}

class PlaylistInfo {
  final String id;
  final String title;
  final List<PlaylistEntry> entries;
  final int entryCount;

  PlaylistInfo({
    required this.id,
    required this.title,
    required this.entries,
    required this.entryCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'entries': entries.map((e) => e.toJson()).toList(),
      'entryCount': entryCount,
    };
  }

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) {
    return PlaylistInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => PlaylistEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      entryCount: json['entryCount'] as int? ?? (json['entries'] as List<dynamic>?)?.length ?? 0,
    );
  }
}

class PlaylistDownloadEntry {
  final String downloadId;
  final String entryId;
  final String title;
  final String url;
  final int index;

  PlaylistDownloadEntry({
    required this.downloadId,
    required this.entryId,
    required this.title,
    required this.url,
    required this.index,
  });

  Map<String, dynamic> toJson() {
    return {
      'downloadId': downloadId,
      'entryId': entryId,
      'title': title,
      'url': url,
      'index': index,
    };
  }

  factory PlaylistDownloadEntry.fromJson(Map<String, dynamic> json) {
    return PlaylistDownloadEntry(
      downloadId: json['downloadId'] as String,
      entryId: json['entryId'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      index: json['index'] as int,
    );
  }
}

class PlaylistDownloadResult {
  final String groupId;
  final String playlistId;
  final String playlistTitle;
  final DownloadType type;
  final int totalCount;
  final int startIndex;
  final int endIndex;
  final List<PlaylistDownloadEntry> entries;

  PlaylistDownloadResult({
    required this.groupId,
    required this.playlistId,
    required this.playlistTitle,
    required this.type,
    required this.totalCount,
    required this.startIndex,
    required this.endIndex,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'playlistId': playlistId,
      'playlistTitle': playlistTitle,
      'type': type.name,
      'totalCount': totalCount,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory PlaylistDownloadResult.fromJson(Map<String, dynamic> json) {
    return PlaylistDownloadResult(
      groupId: json['groupId'] as String,
      playlistId: json['playlistId'] as String,
      playlistTitle: json['playlistTitle'] as String,
      type: DownloadType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DownloadType.video,
      ),
      totalCount: json['totalCount'] as int,
      startIndex: json['startIndex'] as int,
      endIndex: json['endIndex'] as int,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => PlaylistDownloadEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
