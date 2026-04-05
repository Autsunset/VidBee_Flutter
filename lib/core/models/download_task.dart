import 'video_info.dart';

enum DownloadType {
  video,
  audio,
}

enum DownloadStatus {
  pending,
  downloading,
  processing,
  completed,
  error,
  cancelled,
}

class DownloadProgress {
  final double percent;
  final String? currentSpeed;
  final String? eta;
  final String? downloaded;
  final String? total;

  DownloadProgress({
    required this.percent,
    this.currentSpeed,
    this.eta,
    this.downloaded,
    this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'currentSpeed': currentSpeed,
      'eta': eta,
      'downloaded': downloaded,
      'total': total,
    };
  }

  factory DownloadProgress.fromJson(Map<String, dynamic> json) {
    return DownloadProgress(
      percent: (json['percent'] as num).toDouble(),
      currentSpeed: json['currentSpeed'] as String?,
      eta: json['eta'] as String?,
      downloaded: json['downloaded'] as String?,
      total: json['total'] as String?,
    );
  }

  DownloadProgress copyWith({
    double? percent,
    String? currentSpeed,
    String? eta,
    String? downloaded,
    String? total,
  }) {
    return DownloadProgress(
      percent: percent ?? this.percent,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      eta: eta ?? this.eta,
      downloaded: downloaded ?? this.downloaded,
      total: total ?? this.total,
    );
  }
}

class DownloadTask {
  final String id;
  final String url;
  final String? title;
  final String? thumbnail;
  final DownloadType type;
  final DownloadStatus status;
  final int createdAt;
  final int? startedAt;
  final int? completedAt;
  final int? duration;
  final int? fileSize;
  final String? speed;
  final String? ytDlpCommand;
  final String? ytDlpLog;
  final String? downloadPath;
  final String? savedFileName;
  final String? description;
  final String? channel;
  final String? uploader;
  final int? viewCount;
  final List<String>? tags;
  final VideoFormat? selectedFormat;
  final String? playlistId;
  final String? playlistTitle;
  final int? playlistIndex;
  final int? playlistSize;
  final DownloadProgress? progress;
  final String? error;

  DownloadTask({
    required this.id,
    required this.url,
    this.title,
    this.thumbnail,
    required this.type,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.duration,
    this.fileSize,
    this.speed,
    this.ytDlpCommand,
    this.ytDlpLog,
    this.downloadPath,
    this.savedFileName,
    this.description,
    this.channel,
    this.uploader,
    this.viewCount,
    this.tags,
    this.selectedFormat,
    this.playlistId,
    this.playlistTitle,
    this.playlistIndex,
    this.playlistSize,
    this.progress,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'thumbnail': thumbnail,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'duration': duration,
      'fileSize': fileSize,
      'speed': speed,
      'ytDlpCommand': ytDlpCommand,
      'ytDlpLog': ytDlpLog,
      'downloadPath': downloadPath,
      'savedFileName': savedFileName,
      'description': description,
      'channel': channel,
      'uploader': uploader,
      'viewCount': viewCount,
      'tags': tags,
      'selectedFormat': selectedFormat?.toJson(),
      'playlistId': playlistId,
      'playlistTitle': playlistTitle,
      'playlistIndex': playlistIndex,
      'playlistSize': playlistSize,
      'progress': progress?.toJson(),
      'error': error,
    };
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      type: DownloadType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DownloadType.video,
      ),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.pending,
      ),
      createdAt: json['createdAt'] as int,
      startedAt: json['startedAt'] as int?,
      completedAt: json['completedAt'] as int?,
      duration: json['duration'] as int?,
      fileSize: json['fileSize'] as int?,
      speed: json['speed'] as String?,
      ytDlpCommand: json['ytDlpCommand'] as String?,
      ytDlpLog: json['ytDlpLog'] as String?,
      downloadPath: json['downloadPath'] as String?,
      savedFileName: json['savedFileName'] as String?,
      description: json['description'] as String?,
      channel: json['channel'] as String?,
      uploader: json['uploader'] as String?,
      viewCount: json['viewCount'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      selectedFormat: json['selectedFormat'] != null
          ? VideoFormat.fromJson(json['selectedFormat'] as Map<String, dynamic>)
          : null,
      playlistId: json['playlistId'] as String?,
      playlistTitle: json['playlistTitle'] as String?,
      playlistIndex: json['playlistIndex'] as int?,
      playlistSize: json['playlistSize'] as int?,
      progress: json['progress'] != null
          ? DownloadProgress.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }

  DownloadTask copyWith({
    String? id,
    String? url,
    String? title,
    String? thumbnail,
    DownloadType? type,
    DownloadStatus? status,
    int? createdAt,
    int? startedAt,
    int? completedAt,
    int? duration,
    int? fileSize,
    String? speed,
    String? ytDlpCommand,
    String? ytDlpLog,
    String? downloadPath,
    String? savedFileName,
    String? description,
    String? channel,
    String? uploader,
    int? viewCount,
    List<String>? tags,
    VideoFormat? selectedFormat,
    String? playlistId,
    String? playlistTitle,
    int? playlistIndex,
    int? playlistSize,
    DownloadProgress? progress,
    String? error,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      speed: speed ?? this.speed,
      ytDlpCommand: ytDlpCommand ?? this.ytDlpCommand,
      ytDlpLog: ytDlpLog ?? this.ytDlpLog,
      downloadPath: downloadPath ?? this.downloadPath,
      savedFileName: savedFileName ?? this.savedFileName,
      description: description ?? this.description,
      channel: channel ?? this.channel,
      uploader: uploader ?? this.uploader,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      playlistId: playlistId ?? this.playlistId,
      playlistTitle: playlistTitle ?? this.playlistTitle,
      playlistIndex: playlistIndex ?? this.playlistIndex,
      playlistSize: playlistSize ?? this.playlistSize,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}
