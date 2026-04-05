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
    // 如果是音频格式，显示比特率
    if (!hasVideo) {
      if (tbr != null) {
        return '${tbr}k';
      } else if (formatNote != null) {
        return formatNote!;
      } else {
        return '音频';
      }
    }
    // 如果是视频格式，显示分辨率
    if (width != null && height != null && width! > 0 && height! > 0) {
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

  bool get hasVideo {
    // 严格判断：必须有视频编码，或者有有效的分辨率（> 0）
    final hasValidCodec = vcodec != null && vcodec != 'none';
    final hasValidHeight = height != null && height! > 0;
    final hasValidWidth = width != null && width! > 0;
    
    // 如果没有视频编码，只看分辨率是否有效
    if (!hasValidCodec) {
      return hasValidHeight || hasValidWidth;
    }
    
    // 有视频编码，认为有视频
    return true;
  }
  
  bool get hasAudio {
    // 如果有音频编码，或者没有视频（纯音频），认为有音频
    return (acodec != null && acodec != 'none') || !hasVideo;
  }
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
    // 首先按高度排序，如果没有高度则按码率排序
    final sorted = videoFormats.toList()
      ..sort((a, b) {
        // 优先比较高度
        if (a.height != null && b.height != null) {
          return (b.height ?? 0).compareTo(a.height ?? 0);
        }
        // 如果一个有高度，一个没有，有高度的排前面
        if (a.height != null) return -1;
        if (b.height != null) return 1;
        // 都没有高度，比较码率
        return (b.tbr ?? 0).compareTo(a.tbr ?? 0);
      });
    
    // 去重，保留每个分辨率的最佳格式
    final uniqueFormats = <String, VideoFormat>{};
    for (final format in sorted) {
      String key;
      if (format.height != null) {
        key = '${format.height}p';
      } else if (format.tbr != null) {
        key = '${format.tbr}k';
      } else if (format.formatNote != null) {
        key = format.formatNote!;
      } else {
        key = format.formatId;
      }
      
      if (!uniqueFormats.containsKey(key)) {
        uniqueFormats[key] = format;
      }
    }
    return uniqueFormats.values.toList();
  }

  List<VideoFormat> get bestAudioFormats {
    // 按码率从高到低排序
    final sorted = audioFormats.toList()
      ..sort((a, b) {
        return (b.tbr ?? 0).compareTo(a.tbr ?? 0);
      });
    
    // 去重，保留每个码率的最佳格式
    final uniqueFormats = <String, VideoFormat>{};
    for (final format in sorted) {
      String key;
      if (format.tbr != null) {
        key = '${format.tbr}k';
      } else if (format.formatNote != null) {
        key = format.formatNote!;
      } else {
        key = format.formatId;
      }
      
      if (!uniqueFormats.containsKey(key)) {
        uniqueFormats[key] = format;
      }
    }
    return uniqueFormats.values.toList();
  }

  VideoFormat? get bestAudioFormat {
    final sorted = audioFormats
        .where((f) => f.tbr != null)
        .toList()
      ..sort((a, b) => (b.tbr ?? 0).compareTo(a.tbr ?? 0));
    return sorted.firstOrNull;
  }
}
