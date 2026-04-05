class VideoFormat {
  final String formatId;
  final String ext;
  final int? width;
  final int? height;
  final int? fps;
  final String? vcodec;
  final String? acodec;
  final int? filesize;
  final int? filesizeApprox;
  final String? formatNote;
  final int? tbr;
  final int? quality;
  final String? protocol;
  final String? language;
  final String? videoExt;
  final String? audioExt;

  VideoFormat({
    required this.formatId,
    required this.ext,
    this.width,
    this.height,
    this.fps,
    this.vcodec,
    this.acodec,
    this.filesize,
    this.filesizeApprox,
    this.formatNote,
    this.tbr,
    this.quality,
    this.protocol,
    this.language,
    this.videoExt,
    this.audioExt,
  });

  Map<String, dynamic> toJson() {
    return {
      'formatId': formatId,
      'ext': ext,
      'width': width,
      'height': height,
      'fps': fps,
      'vcodec': vcodec,
      'acodec': acodec,
      'filesize': filesize,
      'filesizeApprox': filesizeApprox,
      'formatNote': formatNote,
      'tbr': tbr,
      'quality': quality,
      'protocol': protocol,
      'language': language,
      'videoExt': videoExt,
      'audioExt': audioExt,
    };
  }

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      formatId: json['formatId'] as String? ?? json['format_id'] as String? ?? 'unknown',
      ext: json['ext'] as String? ?? 'unknown',
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      fps: (json['fps'] as num?)?.toInt(),
      vcodec: json['vcodec'] as String?,
      acodec: json['acodec'] as String?,
      filesize: (json['filesize'] as num?)?.toInt(),
      filesizeApprox: (json['filesizeApprox'] as num?)?.toInt() ?? (json['filesize_approx'] as num?)?.toInt(),
      formatNote: json['formatNote'] as String? ?? json['format_note'] as String?,
      tbr: (json['tbr'] as num?)?.toInt(),
      quality: (json['quality'] as num?)?.toInt(),
      protocol: json['protocol'] as String?,
      language: json['language'] as String?,
      videoExt: json['videoExt'] as String? ?? json['video_ext'] as String?,
      audioExt: json['audioExt'] as String? ?? json['audio_ext'] as String?,
    );
  }

  String get resolution {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return formatNote ?? 'Unknown';
  }

  String get displayName {
    final parts = <String>[];
    if (formatNote != null) parts.add(formatNote!);
    if (ext.isNotEmpty) parts.add(ext.toUpperCase());
    if (filesize != null) {
      parts.add(_formatFileSize(filesize!));
    }
    return parts.join(' • ');
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get hasVideo => vcodec != null && vcodec != 'none';
  bool get hasAudio => acodec != null && acodec != 'none';
}

class VideoInfo {
  final String id;
  final String title;
  final String? thumbnail;
  final int? duration;
  final String? extractorKey;
  final String? webpageUrl;
  final String? description;
  final int? viewCount;
  final String? uploader;
  final List<String>? tags;
  final List<VideoFormat> formats;

  VideoInfo({
    required this.id,
    required this.title,
    this.thumbnail,
    this.duration,
    this.extractorKey,
    this.webpageUrl,
    this.description,
    this.viewCount,
    this.uploader,
    this.tags,
    required this.formats,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'duration': duration,
      'extractorKey': extractorKey,
      'webpageUrl': webpageUrl,
      'description': description,
      'viewCount': viewCount,
      'uploader': uploader,
      'tags': tags,
      'formats': formats.map((f) => f.toJson()).toList(),
    };
  }

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      extractorKey: json['extractorKey'] as String? ?? json['extractor_key'] as String?,
      webpageUrl: json['webpageUrl'] as String? ?? json['webpage_url'] as String?,
      description: json['description'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? (json['view_count'] as num?)?.toInt(),
      uploader: json['uploader'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      formats: (json['formats'] as List<dynamic>?)
              ?.map((f) => VideoFormat.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get durationFormatted {
    if (duration == null) return '';
    final minutes = (duration! ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration! % 60).toString().padLeft(2, '0');
    if (duration! >= 3600) {
      final hours = (duration! ~/ 3600).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  List<VideoFormat> get videoFormats {
    return formats.where((f) => f.hasVideo).toList();
  }

  List<VideoFormat> get audioFormats {
    return formats.where((f) => f.hasAudio && !f.hasVideo).toList();
  }

  List<VideoFormat> get bestVideoFormats {
    final sorted = videoFormats
        .where((f) => f.height != null)
        .toList()
      ..sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
    final uniqueResolutions = <String, VideoFormat>{};
    for (final format in sorted) {
      final key = '${format.height}p';
      if (!uniqueResolutions.containsKey(key)) {
        uniqueResolutions[key] = format;
      }
    }
    return uniqueResolutions.values.toList();
  }

  VideoFormat? get bestAudioFormat {
    final sorted = audioFormats
        .where((f) => f.tbr != null)
        .toList()
      ..sort((a, b) => (b.tbr ?? 0).compareTo(a.tbr ?? 0));
    return sorted.firstOrNull;
  }
}
