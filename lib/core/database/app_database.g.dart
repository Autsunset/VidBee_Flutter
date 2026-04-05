// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DownloadHistoryTable extends DownloadHistory
    with TableInfo<$DownloadHistoryTable, DownloadHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadPathMeta = const VerificationMeta(
    'downloadPath',
  );
  @override
  late final GeneratedColumn<String> downloadPath = GeneratedColumn<String>(
    'download_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedFileNameMeta = const VerificationMeta(
    'savedFileName',
  );
  @override
  late final GeneratedColumn<String> savedFileName = GeneratedColumn<String>(
    'saved_file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<int> downloadedAt = GeneratedColumn<int>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ytDlpCommandMeta = const VerificationMeta(
    'ytDlpCommand',
  );
  @override
  late final GeneratedColumn<String> ytDlpCommand = GeneratedColumn<String>(
    'yt_dlp_command',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ytDlpLogMeta = const VerificationMeta(
    'ytDlpLog',
  );
  @override
  late final GeneratedColumn<String> ytDlpLog = GeneratedColumn<String>(
    'yt_dlp_log',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploaderMeta = const VerificationMeta(
    'uploader',
  );
  @override
  late final GeneratedColumn<String> uploader = GeneratedColumn<String>(
    'uploader',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewCountMeta = const VerificationMeta(
    'viewCount',
  );
  @override
  late final GeneratedColumn<int> viewCount = GeneratedColumn<int>(
    'view_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscriptionIdMeta = const VerificationMeta(
    'subscriptionId',
  );
  @override
  late final GeneratedColumn<String> subscriptionId = GeneratedColumn<String>(
    'subscription_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedFormatMeta = const VerificationMeta(
    'selectedFormat',
  );
  @override
  late final GeneratedColumn<String> selectedFormat = GeneratedColumn<String>(
    'selected_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playlistTitleMeta = const VerificationMeta(
    'playlistTitle',
  );
  @override
  late final GeneratedColumn<String> playlistTitle = GeneratedColumn<String>(
    'playlist_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playlistIndexMeta = const VerificationMeta(
    'playlistIndex',
  );
  @override
  late final GeneratedColumn<int> playlistIndex = GeneratedColumn<int>(
    'playlist_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playlistSizeMeta = const VerificationMeta(
    'playlistSize',
  );
  @override
  late final GeneratedColumn<int> playlistSize = GeneratedColumn<int>(
    'playlist_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    thumbnail,
    type,
    status,
    downloadPath,
    savedFileName,
    fileSize,
    duration,
    downloadedAt,
    completedAt,
    error,
    ytDlpCommand,
    ytDlpLog,
    description,
    channel,
    uploader,
    viewCount,
    tags,
    origin,
    subscriptionId,
    selectedFormat,
    playlistId,
    playlistTitle,
    playlistIndex,
    playlistSize,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('download_path')) {
      context.handle(
        _downloadPathMeta,
        downloadPath.isAcceptableOrUnknown(
          data['download_path']!,
          _downloadPathMeta,
        ),
      );
    }
    if (data.containsKey('saved_file_name')) {
      context.handle(
        _savedFileNameMeta,
        savedFileName.isAcceptableOrUnknown(
          data['saved_file_name']!,
          _savedFileNameMeta,
        ),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('yt_dlp_command')) {
      context.handle(
        _ytDlpCommandMeta,
        ytDlpCommand.isAcceptableOrUnknown(
          data['yt_dlp_command']!,
          _ytDlpCommandMeta,
        ),
      );
    }
    if (data.containsKey('yt_dlp_log')) {
      context.handle(
        _ytDlpLogMeta,
        ytDlpLog.isAcceptableOrUnknown(data['yt_dlp_log']!, _ytDlpLogMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('uploader')) {
      context.handle(
        _uploaderMeta,
        uploader.isAcceptableOrUnknown(data['uploader']!, _uploaderMeta),
      );
    }
    if (data.containsKey('view_count')) {
      context.handle(
        _viewCountMeta,
        viewCount.isAcceptableOrUnknown(data['view_count']!, _viewCountMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('subscription_id')) {
      context.handle(
        _subscriptionIdMeta,
        subscriptionId.isAcceptableOrUnknown(
          data['subscription_id']!,
          _subscriptionIdMeta,
        ),
      );
    }
    if (data.containsKey('selected_format')) {
      context.handle(
        _selectedFormatMeta,
        selectedFormat.isAcceptableOrUnknown(
          data['selected_format']!,
          _selectedFormatMeta,
        ),
      );
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    }
    if (data.containsKey('playlist_title')) {
      context.handle(
        _playlistTitleMeta,
        playlistTitle.isAcceptableOrUnknown(
          data['playlist_title']!,
          _playlistTitleMeta,
        ),
      );
    }
    if (data.containsKey('playlist_index')) {
      context.handle(
        _playlistIndexMeta,
        playlistIndex.isAcceptableOrUnknown(
          data['playlist_index']!,
          _playlistIndexMeta,
        ),
      );
    }
    if (data.containsKey('playlist_size')) {
      context.handle(
        _playlistSizeMeta,
        playlistSize.isAcceptableOrUnknown(
          data['playlist_size']!,
          _playlistSizeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      downloadPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_path'],
      ),
      savedFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_file_name'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      ytDlpCommand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yt_dlp_command'],
      ),
      ytDlpLog: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yt_dlp_log'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      ),
      uploader: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploader'],
      ),
      viewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}view_count'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      subscriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_id'],
      ),
      selectedFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_format'],
      ),
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      ),
      playlistTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_title'],
      ),
      playlistIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_index'],
      ),
      playlistSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_size'],
      ),
    );
  }

  @override
  $DownloadHistoryTable createAlias(String alias) {
    return $DownloadHistoryTable(attachedDatabase, alias);
  }
}

class DownloadHistoryData extends DataClass
    implements Insertable<DownloadHistoryData> {
  final String id;
  final String url;
  final String title;
  final String? thumbnail;
  final String type;
  final String status;
  final String? downloadPath;
  final String? savedFileName;
  final int? fileSize;
  final int? duration;
  final int downloadedAt;
  final int? completedAt;
  final String? error;
  final String? ytDlpCommand;
  final String? ytDlpLog;
  final String? description;
  final String? channel;
  final String? uploader;
  final int? viewCount;
  final String? tags;
  final String? origin;
  final String? subscriptionId;
  final String? selectedFormat;
  final String? playlistId;
  final String? playlistTitle;
  final int? playlistIndex;
  final int? playlistSize;
  const DownloadHistoryData({
    required this.id,
    required this.url,
    required this.title,
    this.thumbnail,
    required this.type,
    required this.status,
    this.downloadPath,
    this.savedFileName,
    this.fileSize,
    this.duration,
    required this.downloadedAt,
    this.completedAt,
    this.error,
    this.ytDlpCommand,
    this.ytDlpLog,
    this.description,
    this.channel,
    this.uploader,
    this.viewCount,
    this.tags,
    this.origin,
    this.subscriptionId,
    this.selectedFormat,
    this.playlistId,
    this.playlistTitle,
    this.playlistIndex,
    this.playlistSize,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || downloadPath != null) {
      map['download_path'] = Variable<String>(downloadPath);
    }
    if (!nullToAbsent || savedFileName != null) {
      map['saved_file_name'] = Variable<String>(savedFileName);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['downloaded_at'] = Variable<int>(downloadedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || ytDlpCommand != null) {
      map['yt_dlp_command'] = Variable<String>(ytDlpCommand);
    }
    if (!nullToAbsent || ytDlpLog != null) {
      map['yt_dlp_log'] = Variable<String>(ytDlpLog);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || channel != null) {
      map['channel'] = Variable<String>(channel);
    }
    if (!nullToAbsent || uploader != null) {
      map['uploader'] = Variable<String>(uploader);
    }
    if (!nullToAbsent || viewCount != null) {
      map['view_count'] = Variable<int>(viewCount);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || subscriptionId != null) {
      map['subscription_id'] = Variable<String>(subscriptionId);
    }
    if (!nullToAbsent || selectedFormat != null) {
      map['selected_format'] = Variable<String>(selectedFormat);
    }
    if (!nullToAbsent || playlistId != null) {
      map['playlist_id'] = Variable<String>(playlistId);
    }
    if (!nullToAbsent || playlistTitle != null) {
      map['playlist_title'] = Variable<String>(playlistTitle);
    }
    if (!nullToAbsent || playlistIndex != null) {
      map['playlist_index'] = Variable<int>(playlistIndex);
    }
    if (!nullToAbsent || playlistSize != null) {
      map['playlist_size'] = Variable<int>(playlistSize);
    }
    return map;
  }

  DownloadHistoryCompanion toCompanion(bool nullToAbsent) {
    return DownloadHistoryCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      type: Value(type),
      status: Value(status),
      downloadPath: downloadPath == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadPath),
      savedFileName: savedFileName == null && nullToAbsent
          ? const Value.absent()
          : Value(savedFileName),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      downloadedAt: Value(downloadedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      ytDlpCommand: ytDlpCommand == null && nullToAbsent
          ? const Value.absent()
          : Value(ytDlpCommand),
      ytDlpLog: ytDlpLog == null && nullToAbsent
          ? const Value.absent()
          : Value(ytDlpLog),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      channel: channel == null && nullToAbsent
          ? const Value.absent()
          : Value(channel),
      uploader: uploader == null && nullToAbsent
          ? const Value.absent()
          : Value(uploader),
      viewCount: viewCount == null && nullToAbsent
          ? const Value.absent()
          : Value(viewCount),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      subscriptionId: subscriptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionId),
      selectedFormat: selectedFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedFormat),
      playlistId: playlistId == null && nullToAbsent
          ? const Value.absent()
          : Value(playlistId),
      playlistTitle: playlistTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(playlistTitle),
      playlistIndex: playlistIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(playlistIndex),
      playlistSize: playlistSize == null && nullToAbsent
          ? const Value.absent()
          : Value(playlistSize),
    );
  }

  factory DownloadHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadHistoryData(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      downloadPath: serializer.fromJson<String?>(json['downloadPath']),
      savedFileName: serializer.fromJson<String?>(json['savedFileName']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      duration: serializer.fromJson<int?>(json['duration']),
      downloadedAt: serializer.fromJson<int>(json['downloadedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      error: serializer.fromJson<String?>(json['error']),
      ytDlpCommand: serializer.fromJson<String?>(json['ytDlpCommand']),
      ytDlpLog: serializer.fromJson<String?>(json['ytDlpLog']),
      description: serializer.fromJson<String?>(json['description']),
      channel: serializer.fromJson<String?>(json['channel']),
      uploader: serializer.fromJson<String?>(json['uploader']),
      viewCount: serializer.fromJson<int?>(json['viewCount']),
      tags: serializer.fromJson<String?>(json['tags']),
      origin: serializer.fromJson<String?>(json['origin']),
      subscriptionId: serializer.fromJson<String?>(json['subscriptionId']),
      selectedFormat: serializer.fromJson<String?>(json['selectedFormat']),
      playlistId: serializer.fromJson<String?>(json['playlistId']),
      playlistTitle: serializer.fromJson<String?>(json['playlistTitle']),
      playlistIndex: serializer.fromJson<int?>(json['playlistIndex']),
      playlistSize: serializer.fromJson<int?>(json['playlistSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'downloadPath': serializer.toJson<String?>(downloadPath),
      'savedFileName': serializer.toJson<String?>(savedFileName),
      'fileSize': serializer.toJson<int?>(fileSize),
      'duration': serializer.toJson<int?>(duration),
      'downloadedAt': serializer.toJson<int>(downloadedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'error': serializer.toJson<String?>(error),
      'ytDlpCommand': serializer.toJson<String?>(ytDlpCommand),
      'ytDlpLog': serializer.toJson<String?>(ytDlpLog),
      'description': serializer.toJson<String?>(description),
      'channel': serializer.toJson<String?>(channel),
      'uploader': serializer.toJson<String?>(uploader),
      'viewCount': serializer.toJson<int?>(viewCount),
      'tags': serializer.toJson<String?>(tags),
      'origin': serializer.toJson<String?>(origin),
      'subscriptionId': serializer.toJson<String?>(subscriptionId),
      'selectedFormat': serializer.toJson<String?>(selectedFormat),
      'playlistId': serializer.toJson<String?>(playlistId),
      'playlistTitle': serializer.toJson<String?>(playlistTitle),
      'playlistIndex': serializer.toJson<int?>(playlistIndex),
      'playlistSize': serializer.toJson<int?>(playlistSize),
    };
  }

  DownloadHistoryData copyWith({
    String? id,
    String? url,
    String? title,
    Value<String?> thumbnail = const Value.absent(),
    String? type,
    String? status,
    Value<String?> downloadPath = const Value.absent(),
    Value<String?> savedFileName = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    int? downloadedAt,
    Value<int?> completedAt = const Value.absent(),
    Value<String?> error = const Value.absent(),
    Value<String?> ytDlpCommand = const Value.absent(),
    Value<String?> ytDlpLog = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> channel = const Value.absent(),
    Value<String?> uploader = const Value.absent(),
    Value<int?> viewCount = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> origin = const Value.absent(),
    Value<String?> subscriptionId = const Value.absent(),
    Value<String?> selectedFormat = const Value.absent(),
    Value<String?> playlistId = const Value.absent(),
    Value<String?> playlistTitle = const Value.absent(),
    Value<int?> playlistIndex = const Value.absent(),
    Value<int?> playlistSize = const Value.absent(),
  }) => DownloadHistoryData(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    type: type ?? this.type,
    status: status ?? this.status,
    downloadPath: downloadPath.present ? downloadPath.value : this.downloadPath,
    savedFileName: savedFileName.present
        ? savedFileName.value
        : this.savedFileName,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    duration: duration.present ? duration.value : this.duration,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    error: error.present ? error.value : this.error,
    ytDlpCommand: ytDlpCommand.present ? ytDlpCommand.value : this.ytDlpCommand,
    ytDlpLog: ytDlpLog.present ? ytDlpLog.value : this.ytDlpLog,
    description: description.present ? description.value : this.description,
    channel: channel.present ? channel.value : this.channel,
    uploader: uploader.present ? uploader.value : this.uploader,
    viewCount: viewCount.present ? viewCount.value : this.viewCount,
    tags: tags.present ? tags.value : this.tags,
    origin: origin.present ? origin.value : this.origin,
    subscriptionId: subscriptionId.present
        ? subscriptionId.value
        : this.subscriptionId,
    selectedFormat: selectedFormat.present
        ? selectedFormat.value
        : this.selectedFormat,
    playlistId: playlistId.present ? playlistId.value : this.playlistId,
    playlistTitle: playlistTitle.present
        ? playlistTitle.value
        : this.playlistTitle,
    playlistIndex: playlistIndex.present
        ? playlistIndex.value
        : this.playlistIndex,
    playlistSize: playlistSize.present ? playlistSize.value : this.playlistSize,
  );
  DownloadHistoryData copyWithCompanion(DownloadHistoryCompanion data) {
    return DownloadHistoryData(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      downloadPath: data.downloadPath.present
          ? data.downloadPath.value
          : this.downloadPath,
      savedFileName: data.savedFileName.present
          ? data.savedFileName.value
          : this.savedFileName,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      duration: data.duration.present ? data.duration.value : this.duration,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      error: data.error.present ? data.error.value : this.error,
      ytDlpCommand: data.ytDlpCommand.present
          ? data.ytDlpCommand.value
          : this.ytDlpCommand,
      ytDlpLog: data.ytDlpLog.present ? data.ytDlpLog.value : this.ytDlpLog,
      description: data.description.present
          ? data.description.value
          : this.description,
      channel: data.channel.present ? data.channel.value : this.channel,
      uploader: data.uploader.present ? data.uploader.value : this.uploader,
      viewCount: data.viewCount.present ? data.viewCount.value : this.viewCount,
      tags: data.tags.present ? data.tags.value : this.tags,
      origin: data.origin.present ? data.origin.value : this.origin,
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      selectedFormat: data.selectedFormat.present
          ? data.selectedFormat.value
          : this.selectedFormat,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      playlistTitle: data.playlistTitle.present
          ? data.playlistTitle.value
          : this.playlistTitle,
      playlistIndex: data.playlistIndex.present
          ? data.playlistIndex.value
          : this.playlistIndex,
      playlistSize: data.playlistSize.present
          ? data.playlistSize.value
          : this.playlistSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryData(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('downloadPath: $downloadPath, ')
          ..write('savedFileName: $savedFileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('duration: $duration, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('error: $error, ')
          ..write('ytDlpCommand: $ytDlpCommand, ')
          ..write('ytDlpLog: $ytDlpLog, ')
          ..write('description: $description, ')
          ..write('channel: $channel, ')
          ..write('uploader: $uploader, ')
          ..write('viewCount: $viewCount, ')
          ..write('tags: $tags, ')
          ..write('origin: $origin, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('selectedFormat: $selectedFormat, ')
          ..write('playlistId: $playlistId, ')
          ..write('playlistTitle: $playlistTitle, ')
          ..write('playlistIndex: $playlistIndex, ')
          ..write('playlistSize: $playlistSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    url,
    title,
    thumbnail,
    type,
    status,
    downloadPath,
    savedFileName,
    fileSize,
    duration,
    downloadedAt,
    completedAt,
    error,
    ytDlpCommand,
    ytDlpLog,
    description,
    channel,
    uploader,
    viewCount,
    tags,
    origin,
    subscriptionId,
    selectedFormat,
    playlistId,
    playlistTitle,
    playlistIndex,
    playlistSize,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadHistoryData &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.thumbnail == this.thumbnail &&
          other.type == this.type &&
          other.status == this.status &&
          other.downloadPath == this.downloadPath &&
          other.savedFileName == this.savedFileName &&
          other.fileSize == this.fileSize &&
          other.duration == this.duration &&
          other.downloadedAt == this.downloadedAt &&
          other.completedAt == this.completedAt &&
          other.error == this.error &&
          other.ytDlpCommand == this.ytDlpCommand &&
          other.ytDlpLog == this.ytDlpLog &&
          other.description == this.description &&
          other.channel == this.channel &&
          other.uploader == this.uploader &&
          other.viewCount == this.viewCount &&
          other.tags == this.tags &&
          other.origin == this.origin &&
          other.subscriptionId == this.subscriptionId &&
          other.selectedFormat == this.selectedFormat &&
          other.playlistId == this.playlistId &&
          other.playlistTitle == this.playlistTitle &&
          other.playlistIndex == this.playlistIndex &&
          other.playlistSize == this.playlistSize);
}

class DownloadHistoryCompanion extends UpdateCompanion<DownloadHistoryData> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String?> thumbnail;
  final Value<String> type;
  final Value<String> status;
  final Value<String?> downloadPath;
  final Value<String?> savedFileName;
  final Value<int?> fileSize;
  final Value<int?> duration;
  final Value<int> downloadedAt;
  final Value<int?> completedAt;
  final Value<String?> error;
  final Value<String?> ytDlpCommand;
  final Value<String?> ytDlpLog;
  final Value<String?> description;
  final Value<String?> channel;
  final Value<String?> uploader;
  final Value<int?> viewCount;
  final Value<String?> tags;
  final Value<String?> origin;
  final Value<String?> subscriptionId;
  final Value<String?> selectedFormat;
  final Value<String?> playlistId;
  final Value<String?> playlistTitle;
  final Value<int?> playlistIndex;
  final Value<int?> playlistSize;
  final Value<int> rowid;
  const DownloadHistoryCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadPath = const Value.absent(),
    this.savedFileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.duration = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.error = const Value.absent(),
    this.ytDlpCommand = const Value.absent(),
    this.ytDlpLog = const Value.absent(),
    this.description = const Value.absent(),
    this.channel = const Value.absent(),
    this.uploader = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.tags = const Value.absent(),
    this.origin = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.selectedFormat = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.playlistTitle = const Value.absent(),
    this.playlistIndex = const Value.absent(),
    this.playlistSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadHistoryCompanion.insert({
    required String id,
    required String url,
    required String title,
    this.thumbnail = const Value.absent(),
    required String type,
    required String status,
    this.downloadPath = const Value.absent(),
    this.savedFileName = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.duration = const Value.absent(),
    required int downloadedAt,
    this.completedAt = const Value.absent(),
    this.error = const Value.absent(),
    this.ytDlpCommand = const Value.absent(),
    this.ytDlpLog = const Value.absent(),
    this.description = const Value.absent(),
    this.channel = const Value.absent(),
    this.uploader = const Value.absent(),
    this.viewCount = const Value.absent(),
    this.tags = const Value.absent(),
    this.origin = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.selectedFormat = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.playlistTitle = const Value.absent(),
    this.playlistIndex = const Value.absent(),
    this.playlistSize = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url),
       title = Value(title),
       type = Value(type),
       status = Value(status),
       downloadedAt = Value(downloadedAt);
  static Insertable<DownloadHistoryData> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? thumbnail,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? downloadPath,
    Expression<String>? savedFileName,
    Expression<int>? fileSize,
    Expression<int>? duration,
    Expression<int>? downloadedAt,
    Expression<int>? completedAt,
    Expression<String>? error,
    Expression<String>? ytDlpCommand,
    Expression<String>? ytDlpLog,
    Expression<String>? description,
    Expression<String>? channel,
    Expression<String>? uploader,
    Expression<int>? viewCount,
    Expression<String>? tags,
    Expression<String>? origin,
    Expression<String>? subscriptionId,
    Expression<String>? selectedFormat,
    Expression<String>? playlistId,
    Expression<String>? playlistTitle,
    Expression<int>? playlistIndex,
    Expression<int>? playlistSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (downloadPath != null) 'download_path': downloadPath,
      if (savedFileName != null) 'saved_file_name': savedFileName,
      if (fileSize != null) 'file_size': fileSize,
      if (duration != null) 'duration': duration,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (error != null) 'error': error,
      if (ytDlpCommand != null) 'yt_dlp_command': ytDlpCommand,
      if (ytDlpLog != null) 'yt_dlp_log': ytDlpLog,
      if (description != null) 'description': description,
      if (channel != null) 'channel': channel,
      if (uploader != null) 'uploader': uploader,
      if (viewCount != null) 'view_count': viewCount,
      if (tags != null) 'tags': tags,
      if (origin != null) 'origin': origin,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (selectedFormat != null) 'selected_format': selectedFormat,
      if (playlistId != null) 'playlist_id': playlistId,
      if (playlistTitle != null) 'playlist_title': playlistTitle,
      if (playlistIndex != null) 'playlist_index': playlistIndex,
      if (playlistSize != null) 'playlist_size': playlistSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? title,
    Value<String?>? thumbnail,
    Value<String>? type,
    Value<String>? status,
    Value<String?>? downloadPath,
    Value<String?>? savedFileName,
    Value<int?>? fileSize,
    Value<int?>? duration,
    Value<int>? downloadedAt,
    Value<int?>? completedAt,
    Value<String?>? error,
    Value<String?>? ytDlpCommand,
    Value<String?>? ytDlpLog,
    Value<String?>? description,
    Value<String?>? channel,
    Value<String?>? uploader,
    Value<int?>? viewCount,
    Value<String?>? tags,
    Value<String?>? origin,
    Value<String?>? subscriptionId,
    Value<String?>? selectedFormat,
    Value<String?>? playlistId,
    Value<String?>? playlistTitle,
    Value<int?>? playlistIndex,
    Value<int?>? playlistSize,
    Value<int>? rowid,
  }) {
    return DownloadHistoryCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      type: type ?? this.type,
      status: status ?? this.status,
      downloadPath: downloadPath ?? this.downloadPath,
      savedFileName: savedFileName ?? this.savedFileName,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
      ytDlpCommand: ytDlpCommand ?? this.ytDlpCommand,
      ytDlpLog: ytDlpLog ?? this.ytDlpLog,
      description: description ?? this.description,
      channel: channel ?? this.channel,
      uploader: uploader ?? this.uploader,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      origin: origin ?? this.origin,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      playlistId: playlistId ?? this.playlistId,
      playlistTitle: playlistTitle ?? this.playlistTitle,
      playlistIndex: playlistIndex ?? this.playlistIndex,
      playlistSize: playlistSize ?? this.playlistSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (downloadPath.present) {
      map['download_path'] = Variable<String>(downloadPath.value);
    }
    if (savedFileName.present) {
      map['saved_file_name'] = Variable<String>(savedFileName.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<int>(downloadedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (ytDlpCommand.present) {
      map['yt_dlp_command'] = Variable<String>(ytDlpCommand.value);
    }
    if (ytDlpLog.present) {
      map['yt_dlp_log'] = Variable<String>(ytDlpLog.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (uploader.present) {
      map['uploader'] = Variable<String>(uploader.value);
    }
    if (viewCount.present) {
      map['view_count'] = Variable<int>(viewCount.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<String>(subscriptionId.value);
    }
    if (selectedFormat.present) {
      map['selected_format'] = Variable<String>(selectedFormat.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (playlistTitle.present) {
      map['playlist_title'] = Variable<String>(playlistTitle.value);
    }
    if (playlistIndex.present) {
      map['playlist_index'] = Variable<int>(playlistIndex.value);
    }
    if (playlistSize.present) {
      map['playlist_size'] = Variable<int>(playlistSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadHistoryCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('downloadPath: $downloadPath, ')
          ..write('savedFileName: $savedFileName, ')
          ..write('fileSize: $fileSize, ')
          ..write('duration: $duration, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('error: $error, ')
          ..write('ytDlpCommand: $ytDlpCommand, ')
          ..write('ytDlpLog: $ytDlpLog, ')
          ..write('description: $description, ')
          ..write('channel: $channel, ')
          ..write('uploader: $uploader, ')
          ..write('viewCount: $viewCount, ')
          ..write('tags: $tags, ')
          ..write('origin: $origin, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('selectedFormat: $selectedFormat, ')
          ..write('playlistId: $playlistId, ')
          ..write('playlistTitle: $playlistTitle, ')
          ..write('playlistIndex: $playlistIndex, ')
          ..write('playlistSize: $playlistSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onlyDownloadLatestMeta =
      const VerificationMeta('onlyDownloadLatest');
  @override
  late final GeneratedColumn<int> onlyDownloadLatest = GeneratedColumn<int>(
    'only_download_latest',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<int> enabled = GeneratedColumn<int>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestVideoTitleMeta = const VerificationMeta(
    'latestVideoTitle',
  );
  @override
  late final GeneratedColumn<String> latestVideoTitle = GeneratedColumn<String>(
    'latest_video_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestVideoPublishedAtMeta =
      const VerificationMeta('latestVideoPublishedAt');
  @override
  late final GeneratedColumn<int> latestVideoPublishedAt = GeneratedColumn<int>(
    'latest_video_published_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<int> lastCheckedAt = GeneratedColumn<int>(
    'last_checked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<int> lastSuccessAt = GeneratedColumn<int>(
    'last_success_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadDirectoryMeta = const VerificationMeta(
    'downloadDirectory',
  );
  @override
  late final GeneratedColumn<String> downloadDirectory =
      GeneratedColumn<String>(
        'download_directory',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _namingTemplateMeta = const VerificationMeta(
    'namingTemplate',
  );
  @override
  late final GeneratedColumn<String> namingTemplate = GeneratedColumn<String>(
    'naming_template',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    sourceUrl,
    feedUrl,
    platform,
    keywords,
    tags,
    onlyDownloadLatest,
    enabled,
    coverUrl,
    latestVideoTitle,
    latestVideoPublishedAt,
    lastCheckedAt,
    lastSuccessAt,
    status,
    lastError,
    createdAt,
    updatedAt,
    downloadDirectory,
    namingTemplate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordsMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('only_download_latest')) {
      context.handle(
        _onlyDownloadLatestMeta,
        onlyDownloadLatest.isAcceptableOrUnknown(
          data['only_download_latest']!,
          _onlyDownloadLatestMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_onlyDownloadLatestMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('latest_video_title')) {
      context.handle(
        _latestVideoTitleMeta,
        latestVideoTitle.isAcceptableOrUnknown(
          data['latest_video_title']!,
          _latestVideoTitleMeta,
        ),
      );
    }
    if (data.containsKey('latest_video_published_at')) {
      context.handle(
        _latestVideoPublishedAtMeta,
        latestVideoPublishedAt.isAcceptableOrUnknown(
          data['latest_video_published_at']!,
          _latestVideoPublishedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('download_directory')) {
      context.handle(
        _downloadDirectoryMeta,
        downloadDirectory.isAcceptableOrUnknown(
          data['download_directory']!,
          _downloadDirectoryMeta,
        ),
      );
    }
    if (data.containsKey('naming_template')) {
      context.handle(
        _namingTemplateMeta,
        namingTemplate.isAcceptableOrUnknown(
          data['naming_template']!,
          _namingTemplateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      onlyDownloadLatest: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}only_download_latest'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enabled'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      latestVideoTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_video_title'],
      ),
      latestVideoPublishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latest_video_published_at'],
      ),
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_checked_at'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_success_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      downloadDirectory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_directory'],
      ),
      namingTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}naming_template'],
      ),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final String id;
  final String title;
  final String sourceUrl;
  final String feedUrl;
  final String platform;
  final String keywords;
  final String tags;
  final int onlyDownloadLatest;
  final int enabled;
  final String? coverUrl;
  final String? latestVideoTitle;
  final int? latestVideoPublishedAt;
  final int? lastCheckedAt;
  final int? lastSuccessAt;
  final String status;
  final String? lastError;
  final int createdAt;
  final int updatedAt;
  final String? downloadDirectory;
  final String? namingTemplate;
  const Subscription({
    required this.id,
    required this.title,
    required this.sourceUrl,
    required this.feedUrl,
    required this.platform,
    required this.keywords,
    required this.tags,
    required this.onlyDownloadLatest,
    required this.enabled,
    this.coverUrl,
    this.latestVideoTitle,
    this.latestVideoPublishedAt,
    this.lastCheckedAt,
    this.lastSuccessAt,
    required this.status,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
    this.downloadDirectory,
    this.namingTemplate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['source_url'] = Variable<String>(sourceUrl);
    map['feed_url'] = Variable<String>(feedUrl);
    map['platform'] = Variable<String>(platform);
    map['keywords'] = Variable<String>(keywords);
    map['tags'] = Variable<String>(tags);
    map['only_download_latest'] = Variable<int>(onlyDownloadLatest);
    map['enabled'] = Variable<int>(enabled);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || latestVideoTitle != null) {
      map['latest_video_title'] = Variable<String>(latestVideoTitle);
    }
    if (!nullToAbsent || latestVideoPublishedAt != null) {
      map['latest_video_published_at'] = Variable<int>(latestVideoPublishedAt);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<int>(lastCheckedAt);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<int>(lastSuccessAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || downloadDirectory != null) {
      map['download_directory'] = Variable<String>(downloadDirectory);
    }
    if (!nullToAbsent || namingTemplate != null) {
      map['naming_template'] = Variable<String>(namingTemplate);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      title: Value(title),
      sourceUrl: Value(sourceUrl),
      feedUrl: Value(feedUrl),
      platform: Value(platform),
      keywords: Value(keywords),
      tags: Value(tags),
      onlyDownloadLatest: Value(onlyDownloadLatest),
      enabled: Value(enabled),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      latestVideoTitle: latestVideoTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(latestVideoTitle),
      latestVideoPublishedAt: latestVideoPublishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(latestVideoPublishedAt),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      downloadDirectory: downloadDirectory == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadDirectory),
      namingTemplate: namingTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(namingTemplate),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      platform: serializer.fromJson<String>(json['platform']),
      keywords: serializer.fromJson<String>(json['keywords']),
      tags: serializer.fromJson<String>(json['tags']),
      onlyDownloadLatest: serializer.fromJson<int>(json['onlyDownloadLatest']),
      enabled: serializer.fromJson<int>(json['enabled']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      latestVideoTitle: serializer.fromJson<String?>(json['latestVideoTitle']),
      latestVideoPublishedAt: serializer.fromJson<int?>(
        json['latestVideoPublishedAt'],
      ),
      lastCheckedAt: serializer.fromJson<int?>(json['lastCheckedAt']),
      lastSuccessAt: serializer.fromJson<int?>(json['lastSuccessAt']),
      status: serializer.fromJson<String>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      downloadDirectory: serializer.fromJson<String?>(
        json['downloadDirectory'],
      ),
      namingTemplate: serializer.fromJson<String?>(json['namingTemplate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'platform': serializer.toJson<String>(platform),
      'keywords': serializer.toJson<String>(keywords),
      'tags': serializer.toJson<String>(tags),
      'onlyDownloadLatest': serializer.toJson<int>(onlyDownloadLatest),
      'enabled': serializer.toJson<int>(enabled),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'latestVideoTitle': serializer.toJson<String?>(latestVideoTitle),
      'latestVideoPublishedAt': serializer.toJson<int?>(latestVideoPublishedAt),
      'lastCheckedAt': serializer.toJson<int?>(lastCheckedAt),
      'lastSuccessAt': serializer.toJson<int?>(lastSuccessAt),
      'status': serializer.toJson<String>(status),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'downloadDirectory': serializer.toJson<String?>(downloadDirectory),
      'namingTemplate': serializer.toJson<String?>(namingTemplate),
    };
  }

  Subscription copyWith({
    String? id,
    String? title,
    String? sourceUrl,
    String? feedUrl,
    String? platform,
    String? keywords,
    String? tags,
    int? onlyDownloadLatest,
    int? enabled,
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> latestVideoTitle = const Value.absent(),
    Value<int?> latestVideoPublishedAt = const Value.absent(),
    Value<int?> lastCheckedAt = const Value.absent(),
    Value<int?> lastSuccessAt = const Value.absent(),
    String? status,
    Value<String?> lastError = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<String?> downloadDirectory = const Value.absent(),
    Value<String?> namingTemplate = const Value.absent(),
  }) => Subscription(
    id: id ?? this.id,
    title: title ?? this.title,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    feedUrl: feedUrl ?? this.feedUrl,
    platform: platform ?? this.platform,
    keywords: keywords ?? this.keywords,
    tags: tags ?? this.tags,
    onlyDownloadLatest: onlyDownloadLatest ?? this.onlyDownloadLatest,
    enabled: enabled ?? this.enabled,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    latestVideoTitle: latestVideoTitle.present
        ? latestVideoTitle.value
        : this.latestVideoTitle,
    latestVideoPublishedAt: latestVideoPublishedAt.present
        ? latestVideoPublishedAt.value
        : this.latestVideoPublishedAt,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    downloadDirectory: downloadDirectory.present
        ? downloadDirectory.value
        : this.downloadDirectory,
    namingTemplate: namingTemplate.present
        ? namingTemplate.value
        : this.namingTemplate,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      platform: data.platform.present ? data.platform.value : this.platform,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      tags: data.tags.present ? data.tags.value : this.tags,
      onlyDownloadLatest: data.onlyDownloadLatest.present
          ? data.onlyDownloadLatest.value
          : this.onlyDownloadLatest,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      latestVideoTitle: data.latestVideoTitle.present
          ? data.latestVideoTitle.value
          : this.latestVideoTitle,
      latestVideoPublishedAt: data.latestVideoPublishedAt.present
          ? data.latestVideoPublishedAt.value
          : this.latestVideoPublishedAt,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      downloadDirectory: data.downloadDirectory.present
          ? data.downloadDirectory.value
          : this.downloadDirectory,
      namingTemplate: data.namingTemplate.present
          ? data.namingTemplate.value
          : this.namingTemplate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('platform: $platform, ')
          ..write('keywords: $keywords, ')
          ..write('tags: $tags, ')
          ..write('onlyDownloadLatest: $onlyDownloadLatest, ')
          ..write('enabled: $enabled, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('latestVideoTitle: $latestVideoTitle, ')
          ..write('latestVideoPublishedAt: $latestVideoPublishedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('downloadDirectory: $downloadDirectory, ')
          ..write('namingTemplate: $namingTemplate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    sourceUrl,
    feedUrl,
    platform,
    keywords,
    tags,
    onlyDownloadLatest,
    enabled,
    coverUrl,
    latestVideoTitle,
    latestVideoPublishedAt,
    lastCheckedAt,
    lastSuccessAt,
    status,
    lastError,
    createdAt,
    updatedAt,
    downloadDirectory,
    namingTemplate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.title == this.title &&
          other.sourceUrl == this.sourceUrl &&
          other.feedUrl == this.feedUrl &&
          other.platform == this.platform &&
          other.keywords == this.keywords &&
          other.tags == this.tags &&
          other.onlyDownloadLatest == this.onlyDownloadLatest &&
          other.enabled == this.enabled &&
          other.coverUrl == this.coverUrl &&
          other.latestVideoTitle == this.latestVideoTitle &&
          other.latestVideoPublishedAt == this.latestVideoPublishedAt &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.downloadDirectory == this.downloadDirectory &&
          other.namingTemplate == this.namingTemplate);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> sourceUrl;
  final Value<String> feedUrl;
  final Value<String> platform;
  final Value<String> keywords;
  final Value<String> tags;
  final Value<int> onlyDownloadLatest;
  final Value<int> enabled;
  final Value<String?> coverUrl;
  final Value<String?> latestVideoTitle;
  final Value<int?> latestVideoPublishedAt;
  final Value<int?> lastCheckedAt;
  final Value<int?> lastSuccessAt;
  final Value<String> status;
  final Value<String?> lastError;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> downloadDirectory;
  final Value<String?> namingTemplate;
  final Value<int> rowid;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.platform = const Value.absent(),
    this.keywords = const Value.absent(),
    this.tags = const Value.absent(),
    this.onlyDownloadLatest = const Value.absent(),
    this.enabled = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.latestVideoTitle = const Value.absent(),
    this.latestVideoPublishedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.downloadDirectory = const Value.absent(),
    this.namingTemplate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    required String id,
    required String title,
    required String sourceUrl,
    required String feedUrl,
    required String platform,
    required String keywords,
    required String tags,
    required int onlyDownloadLatest,
    required int enabled,
    this.coverUrl = const Value.absent(),
    this.latestVideoTitle = const Value.absent(),
    this.latestVideoPublishedAt = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    required String status,
    this.lastError = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.downloadDirectory = const Value.absent(),
    this.namingTemplate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sourceUrl = Value(sourceUrl),
       feedUrl = Value(feedUrl),
       platform = Value(platform),
       keywords = Value(keywords),
       tags = Value(tags),
       onlyDownloadLatest = Value(onlyDownloadLatest),
       enabled = Value(enabled),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Subscription> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? sourceUrl,
    Expression<String>? feedUrl,
    Expression<String>? platform,
    Expression<String>? keywords,
    Expression<String>? tags,
    Expression<int>? onlyDownloadLatest,
    Expression<int>? enabled,
    Expression<String>? coverUrl,
    Expression<String>? latestVideoTitle,
    Expression<int>? latestVideoPublishedAt,
    Expression<int>? lastCheckedAt,
    Expression<int>? lastSuccessAt,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? downloadDirectory,
    Expression<String>? namingTemplate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (platform != null) 'platform': platform,
      if (keywords != null) 'keywords': keywords,
      if (tags != null) 'tags': tags,
      if (onlyDownloadLatest != null)
        'only_download_latest': onlyDownloadLatest,
      if (enabled != null) 'enabled': enabled,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (latestVideoTitle != null) 'latest_video_title': latestVideoTitle,
      if (latestVideoPublishedAt != null)
        'latest_video_published_at': latestVideoPublishedAt,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (downloadDirectory != null) 'download_directory': downloadDirectory,
      if (namingTemplate != null) 'naming_template': namingTemplate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? sourceUrl,
    Value<String>? feedUrl,
    Value<String>? platform,
    Value<String>? keywords,
    Value<String>? tags,
    Value<int>? onlyDownloadLatest,
    Value<int>? enabled,
    Value<String?>? coverUrl,
    Value<String?>? latestVideoTitle,
    Value<int?>? latestVideoPublishedAt,
    Value<int?>? lastCheckedAt,
    Value<int?>? lastSuccessAt,
    Value<String>? status,
    Value<String?>? lastError,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? downloadDirectory,
    Value<String?>? namingTemplate,
    Value<int>? rowid,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      feedUrl: feedUrl ?? this.feedUrl,
      platform: platform ?? this.platform,
      keywords: keywords ?? this.keywords,
      tags: tags ?? this.tags,
      onlyDownloadLatest: onlyDownloadLatest ?? this.onlyDownloadLatest,
      enabled: enabled ?? this.enabled,
      coverUrl: coverUrl ?? this.coverUrl,
      latestVideoTitle: latestVideoTitle ?? this.latestVideoTitle,
      latestVideoPublishedAt:
          latestVideoPublishedAt ?? this.latestVideoPublishedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadDirectory: downloadDirectory ?? this.downloadDirectory,
      namingTemplate: namingTemplate ?? this.namingTemplate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (onlyDownloadLatest.present) {
      map['only_download_latest'] = Variable<int>(onlyDownloadLatest.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<int>(enabled.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (latestVideoTitle.present) {
      map['latest_video_title'] = Variable<String>(latestVideoTitle.value);
    }
    if (latestVideoPublishedAt.present) {
      map['latest_video_published_at'] = Variable<int>(
        latestVideoPublishedAt.value,
      );
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<int>(lastCheckedAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<int>(lastSuccessAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (downloadDirectory.present) {
      map['download_directory'] = Variable<String>(downloadDirectory.value);
    }
    if (namingTemplate.present) {
      map['naming_template'] = Variable<String>(namingTemplate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('platform: $platform, ')
          ..write('keywords: $keywords, ')
          ..write('tags: $tags, ')
          ..write('onlyDownloadLatest: $onlyDownloadLatest, ')
          ..write('enabled: $enabled, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('latestVideoTitle: $latestVideoTitle, ')
          ..write('latestVideoPublishedAt: $latestVideoPublishedAt, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('downloadDirectory: $downloadDirectory, ')
          ..write('namingTemplate: $namingTemplate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionItemsTable extends SubscriptionItems
    with TableInfo<$SubscriptionItemsTable, SubscriptionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _subscriptionIdMeta = const VerificationMeta(
    'subscriptionId',
  );
  @override
  late final GeneratedColumn<String> subscriptionId = GeneratedColumn<String>(
    'subscription_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<int> publishedAt = GeneratedColumn<int>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedMeta = const VerificationMeta('added');
  @override
  late final GeneratedColumn<int> added = GeneratedColumn<int>(
    'added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadIdMeta = const VerificationMeta(
    'downloadId',
  );
  @override
  late final GeneratedColumn<String> downloadId = GeneratedColumn<String>(
    'download_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    subscriptionId,
    itemId,
    title,
    url,
    publishedAt,
    thumbnail,
    added,
    downloadId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('subscription_id')) {
      context.handle(
        _subscriptionIdMeta,
        subscriptionId.isAcceptableOrUnknown(
          data['subscription_id']!,
          _subscriptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriptionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('added')) {
      context.handle(
        _addedMeta,
        added.isAcceptableOrUnknown(data['added']!, _addedMeta),
      );
    } else if (isInserting) {
      context.missing(_addedMeta);
    }
    if (data.containsKey('download_id')) {
      context.handle(
        _downloadIdMeta,
        downloadId.isAcceptableOrUnknown(data['download_id']!, _downloadIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {subscriptionId, itemId};
  @override
  SubscriptionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionItem(
      subscriptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}published_at'],
      )!,
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      added: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added'],
      )!,
      downloadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SubscriptionItemsTable createAlias(String alias) {
    return $SubscriptionItemsTable(attachedDatabase, alias);
  }
}

class SubscriptionItem extends DataClass
    implements Insertable<SubscriptionItem> {
  final String subscriptionId;
  final String itemId;
  final String title;
  final String url;
  final int publishedAt;
  final String? thumbnail;
  final int added;
  final String? downloadId;
  final int createdAt;
  final int updatedAt;
  const SubscriptionItem({
    required this.subscriptionId,
    required this.itemId,
    required this.title,
    required this.url,
    required this.publishedAt,
    this.thumbnail,
    required this.added,
    this.downloadId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['subscription_id'] = Variable<String>(subscriptionId);
    map['item_id'] = Variable<String>(itemId);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['published_at'] = Variable<int>(publishedAt);
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    map['added'] = Variable<int>(added);
    if (!nullToAbsent || downloadId != null) {
      map['download_id'] = Variable<String>(downloadId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SubscriptionItemsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionItemsCompanion(
      subscriptionId: Value(subscriptionId),
      itemId: Value(itemId),
      title: Value(title),
      url: Value(url),
      publishedAt: Value(publishedAt),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      added: Value(added),
      downloadId: downloadId == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SubscriptionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionItem(
      subscriptionId: serializer.fromJson<String>(json['subscriptionId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      publishedAt: serializer.fromJson<int>(json['publishedAt']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      added: serializer.fromJson<int>(json['added']),
      downloadId: serializer.fromJson<String?>(json['downloadId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'subscriptionId': serializer.toJson<String>(subscriptionId),
      'itemId': serializer.toJson<String>(itemId),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'publishedAt': serializer.toJson<int>(publishedAt),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'added': serializer.toJson<int>(added),
      'downloadId': serializer.toJson<String?>(downloadId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SubscriptionItem copyWith({
    String? subscriptionId,
    String? itemId,
    String? title,
    String? url,
    int? publishedAt,
    Value<String?> thumbnail = const Value.absent(),
    int? added,
    Value<String?> downloadId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => SubscriptionItem(
    subscriptionId: subscriptionId ?? this.subscriptionId,
    itemId: itemId ?? this.itemId,
    title: title ?? this.title,
    url: url ?? this.url,
    publishedAt: publishedAt ?? this.publishedAt,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    added: added ?? this.added,
    downloadId: downloadId.present ? downloadId.value : this.downloadId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SubscriptionItem copyWithCompanion(SubscriptionItemsCompanion data) {
    return SubscriptionItem(
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      added: data.added.present ? data.added.value : this.added,
      downloadId: data.downloadId.present
          ? data.downloadId.value
          : this.downloadId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionItem(')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('added: $added, ')
          ..write('downloadId: $downloadId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    subscriptionId,
    itemId,
    title,
    url,
    publishedAt,
    thumbnail,
    added,
    downloadId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionItem &&
          other.subscriptionId == this.subscriptionId &&
          other.itemId == this.itemId &&
          other.title == this.title &&
          other.url == this.url &&
          other.publishedAt == this.publishedAt &&
          other.thumbnail == this.thumbnail &&
          other.added == this.added &&
          other.downloadId == this.downloadId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubscriptionItemsCompanion extends UpdateCompanion<SubscriptionItem> {
  final Value<String> subscriptionId;
  final Value<String> itemId;
  final Value<String> title;
  final Value<String> url;
  final Value<int> publishedAt;
  final Value<String?> thumbnail;
  final Value<int> added;
  final Value<String?> downloadId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SubscriptionItemsCompanion({
    this.subscriptionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.added = const Value.absent(),
    this.downloadId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionItemsCompanion.insert({
    required String subscriptionId,
    required String itemId,
    required String title,
    required String url,
    required int publishedAt,
    this.thumbnail = const Value.absent(),
    required int added,
    this.downloadId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : subscriptionId = Value(subscriptionId),
       itemId = Value(itemId),
       title = Value(title),
       url = Value(url),
       publishedAt = Value(publishedAt),
       added = Value(added),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SubscriptionItem> custom({
    Expression<String>? subscriptionId,
    Expression<String>? itemId,
    Expression<String>? title,
    Expression<String>? url,
    Expression<int>? publishedAt,
    Expression<String>? thumbnail,
    Expression<int>? added,
    Expression<String>? downloadId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (itemId != null) 'item_id': itemId,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (publishedAt != null) 'published_at': publishedAt,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (added != null) 'added': added,
      if (downloadId != null) 'download_id': downloadId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionItemsCompanion copyWith({
    Value<String>? subscriptionId,
    Value<String>? itemId,
    Value<String>? title,
    Value<String>? url,
    Value<int>? publishedAt,
    Value<String?>? thumbnail,
    Value<int>? added,
    Value<String?>? downloadId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SubscriptionItemsCompanion(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      added: added ?? this.added,
      downloadId: downloadId ?? this.downloadId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<String>(subscriptionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<int>(publishedAt.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (added.present) {
      map['added'] = Variable<int>(added.value);
    }
    if (downloadId.present) {
      map['download_id'] = Variable<String>(downloadId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionItemsCompanion(')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('itemId: $itemId, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('added: $added, ')
          ..write('downloadId: $downloadId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadHistoryTable downloadHistory = $DownloadHistoryTable(
    this,
  );
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $SubscriptionItemsTable subscriptionItems =
      $SubscriptionItemsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    downloadHistory,
    subscriptions,
    subscriptionItems,
    settings,
  ];
}

typedef $$DownloadHistoryTableCreateCompanionBuilder =
    DownloadHistoryCompanion Function({
      required String id,
      required String url,
      required String title,
      Value<String?> thumbnail,
      required String type,
      required String status,
      Value<String?> downloadPath,
      Value<String?> savedFileName,
      Value<int?> fileSize,
      Value<int?> duration,
      required int downloadedAt,
      Value<int?> completedAt,
      Value<String?> error,
      Value<String?> ytDlpCommand,
      Value<String?> ytDlpLog,
      Value<String?> description,
      Value<String?> channel,
      Value<String?> uploader,
      Value<int?> viewCount,
      Value<String?> tags,
      Value<String?> origin,
      Value<String?> subscriptionId,
      Value<String?> selectedFormat,
      Value<String?> playlistId,
      Value<String?> playlistTitle,
      Value<int?> playlistIndex,
      Value<int?> playlistSize,
      Value<int> rowid,
    });
typedef $$DownloadHistoryTableUpdateCompanionBuilder =
    DownloadHistoryCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String> title,
      Value<String?> thumbnail,
      Value<String> type,
      Value<String> status,
      Value<String?> downloadPath,
      Value<String?> savedFileName,
      Value<int?> fileSize,
      Value<int?> duration,
      Value<int> downloadedAt,
      Value<int?> completedAt,
      Value<String?> error,
      Value<String?> ytDlpCommand,
      Value<String?> ytDlpLog,
      Value<String?> description,
      Value<String?> channel,
      Value<String?> uploader,
      Value<int?> viewCount,
      Value<String?> tags,
      Value<String?> origin,
      Value<String?> subscriptionId,
      Value<String?> selectedFormat,
      Value<String?> playlistId,
      Value<String?> playlistTitle,
      Value<int?> playlistIndex,
      Value<int?> playlistSize,
      Value<int> rowid,
    });

class $$DownloadHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadPath => $composableBuilder(
    column: $table.downloadPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savedFileName => $composableBuilder(
    column: $table.savedFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ytDlpCommand => $composableBuilder(
    column: $table.ytDlpCommand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ytDlpLog => $composableBuilder(
    column: $table.ytDlpLog,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploader => $composableBuilder(
    column: $table.uploader,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionId => $composableBuilder(
    column: $table.subscriptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedFormat => $composableBuilder(
    column: $table.selectedFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playlistTitle => $composableBuilder(
    column: $table.playlistTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playlistIndex => $composableBuilder(
    column: $table.playlistIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playlistSize => $composableBuilder(
    column: $table.playlistSize,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadPath => $composableBuilder(
    column: $table.downloadPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savedFileName => $composableBuilder(
    column: $table.savedFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ytDlpCommand => $composableBuilder(
    column: $table.ytDlpCommand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ytDlpLog => $composableBuilder(
    column: $table.ytDlpLog,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploader => $composableBuilder(
    column: $table.uploader,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewCount => $composableBuilder(
    column: $table.viewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionId => $composableBuilder(
    column: $table.subscriptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedFormat => $composableBuilder(
    column: $table.selectedFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playlistTitle => $composableBuilder(
    column: $table.playlistTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playlistIndex => $composableBuilder(
    column: $table.playlistIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playlistSize => $composableBuilder(
    column: $table.playlistSize,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadHistoryTable> {
  $$DownloadHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get downloadPath => $composableBuilder(
    column: $table.downloadPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get savedFileName => $composableBuilder(
    column: $table.savedFileName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get ytDlpCommand => $composableBuilder(
    column: $table.ytDlpCommand,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ytDlpLog =>
      $composableBuilder(column: $table.ytDlpLog, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get uploader =>
      $composableBuilder(column: $table.uploader, builder: (column) => column);

  GeneratedColumn<int> get viewCount =>
      $composableBuilder(column: $table.viewCount, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get subscriptionId => $composableBuilder(
    column: $table.subscriptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedFormat => $composableBuilder(
    column: $table.selectedFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playlistId => $composableBuilder(
    column: $table.playlistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playlistTitle => $composableBuilder(
    column: $table.playlistTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playlistIndex => $composableBuilder(
    column: $table.playlistIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playlistSize => $composableBuilder(
    column: $table.playlistSize,
    builder: (column) => column,
  );
}

class $$DownloadHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadHistoryTable,
          DownloadHistoryData,
          $$DownloadHistoryTableFilterComposer,
          $$DownloadHistoryTableOrderingComposer,
          $$DownloadHistoryTableAnnotationComposer,
          $$DownloadHistoryTableCreateCompanionBuilder,
          $$DownloadHistoryTableUpdateCompanionBuilder,
          (
            DownloadHistoryData,
            BaseReferences<
              _$AppDatabase,
              $DownloadHistoryTable,
              DownloadHistoryData
            >,
          ),
          DownloadHistoryData,
          PrefetchHooks Function()
        > {
  $$DownloadHistoryTableTableManager(
    _$AppDatabase db,
    $DownloadHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> downloadPath = const Value.absent(),
                Value<String?> savedFileName = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int> downloadedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> ytDlpCommand = const Value.absent(),
                Value<String?> ytDlpLog = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<String?> uploader = const Value.absent(),
                Value<int?> viewCount = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> subscriptionId = const Value.absent(),
                Value<String?> selectedFormat = const Value.absent(),
                Value<String?> playlistId = const Value.absent(),
                Value<String?> playlistTitle = const Value.absent(),
                Value<int?> playlistIndex = const Value.absent(),
                Value<int?> playlistSize = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadHistoryCompanion(
                id: id,
                url: url,
                title: title,
                thumbnail: thumbnail,
                type: type,
                status: status,
                downloadPath: downloadPath,
                savedFileName: savedFileName,
                fileSize: fileSize,
                duration: duration,
                downloadedAt: downloadedAt,
                completedAt: completedAt,
                error: error,
                ytDlpCommand: ytDlpCommand,
                ytDlpLog: ytDlpLog,
                description: description,
                channel: channel,
                uploader: uploader,
                viewCount: viewCount,
                tags: tags,
                origin: origin,
                subscriptionId: subscriptionId,
                selectedFormat: selectedFormat,
                playlistId: playlistId,
                playlistTitle: playlistTitle,
                playlistIndex: playlistIndex,
                playlistSize: playlistSize,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                required String title,
                Value<String?> thumbnail = const Value.absent(),
                required String type,
                required String status,
                Value<String?> downloadPath = const Value.absent(),
                Value<String?> savedFileName = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                required int downloadedAt,
                Value<int?> completedAt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> ytDlpCommand = const Value.absent(),
                Value<String?> ytDlpLog = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<String?> uploader = const Value.absent(),
                Value<int?> viewCount = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> subscriptionId = const Value.absent(),
                Value<String?> selectedFormat = const Value.absent(),
                Value<String?> playlistId = const Value.absent(),
                Value<String?> playlistTitle = const Value.absent(),
                Value<int?> playlistIndex = const Value.absent(),
                Value<int?> playlistSize = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadHistoryCompanion.insert(
                id: id,
                url: url,
                title: title,
                thumbnail: thumbnail,
                type: type,
                status: status,
                downloadPath: downloadPath,
                savedFileName: savedFileName,
                fileSize: fileSize,
                duration: duration,
                downloadedAt: downloadedAt,
                completedAt: completedAt,
                error: error,
                ytDlpCommand: ytDlpCommand,
                ytDlpLog: ytDlpLog,
                description: description,
                channel: channel,
                uploader: uploader,
                viewCount: viewCount,
                tags: tags,
                origin: origin,
                subscriptionId: subscriptionId,
                selectedFormat: selectedFormat,
                playlistId: playlistId,
                playlistTitle: playlistTitle,
                playlistIndex: playlistIndex,
                playlistSize: playlistSize,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadHistoryTable,
      DownloadHistoryData,
      $$DownloadHistoryTableFilterComposer,
      $$DownloadHistoryTableOrderingComposer,
      $$DownloadHistoryTableAnnotationComposer,
      $$DownloadHistoryTableCreateCompanionBuilder,
      $$DownloadHistoryTableUpdateCompanionBuilder,
      (
        DownloadHistoryData,
        BaseReferences<
          _$AppDatabase,
          $DownloadHistoryTable,
          DownloadHistoryData
        >,
      ),
      DownloadHistoryData,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      required String id,
      required String title,
      required String sourceUrl,
      required String feedUrl,
      required String platform,
      required String keywords,
      required String tags,
      required int onlyDownloadLatest,
      required int enabled,
      Value<String?> coverUrl,
      Value<String?> latestVideoTitle,
      Value<int?> latestVideoPublishedAt,
      Value<int?> lastCheckedAt,
      Value<int?> lastSuccessAt,
      required String status,
      Value<String?> lastError,
      required int createdAt,
      required int updatedAt,
      Value<String?> downloadDirectory,
      Value<String?> namingTemplate,
      Value<int> rowid,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> sourceUrl,
      Value<String> feedUrl,
      Value<String> platform,
      Value<String> keywords,
      Value<String> tags,
      Value<int> onlyDownloadLatest,
      Value<int> enabled,
      Value<String?> coverUrl,
      Value<String?> latestVideoTitle,
      Value<int?> latestVideoPublishedAt,
      Value<int?> lastCheckedAt,
      Value<int?> lastSuccessAt,
      Value<String> status,
      Value<String?> lastError,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> downloadDirectory,
      Value<String?> namingTemplate,
      Value<int> rowid,
    });

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onlyDownloadLatest => $composableBuilder(
    column: $table.onlyDownloadLatest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestVideoTitle => $composableBuilder(
    column: $table.latestVideoTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latestVideoPublishedAt => $composableBuilder(
    column: $table.latestVideoPublishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadDirectory => $composableBuilder(
    column: $table.downloadDirectory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get namingTemplate => $composableBuilder(
    column: $table.namingTemplate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onlyDownloadLatest => $composableBuilder(
    column: $table.onlyDownloadLatest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestVideoTitle => $composableBuilder(
    column: $table.latestVideoTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latestVideoPublishedAt => $composableBuilder(
    column: $table.latestVideoPublishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadDirectory => $composableBuilder(
    column: $table.downloadDirectory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get namingTemplate => $composableBuilder(
    column: $table.namingTemplate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get onlyDownloadLatest => $composableBuilder(
    column: $table.onlyDownloadLatest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get latestVideoTitle => $composableBuilder(
    column: $table.latestVideoTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latestVideoPublishedAt => $composableBuilder(
    column: $table.latestVideoPublishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get downloadDirectory => $composableBuilder(
    column: $table.downloadDirectory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get namingTemplate => $composableBuilder(
    column: $table.namingTemplate,
    builder: (column) => column,
  );
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (
            Subscription,
            BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>,
          ),
          Subscription,
          PrefetchHooks Function()
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> onlyDownloadLatest = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> latestVideoTitle = const Value.absent(),
                Value<int?> latestVideoPublishedAt = const Value.absent(),
                Value<int?> lastCheckedAt = const Value.absent(),
                Value<int?> lastSuccessAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> downloadDirectory = const Value.absent(),
                Value<String?> namingTemplate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                title: title,
                sourceUrl: sourceUrl,
                feedUrl: feedUrl,
                platform: platform,
                keywords: keywords,
                tags: tags,
                onlyDownloadLatest: onlyDownloadLatest,
                enabled: enabled,
                coverUrl: coverUrl,
                latestVideoTitle: latestVideoTitle,
                latestVideoPublishedAt: latestVideoPublishedAt,
                lastCheckedAt: lastCheckedAt,
                lastSuccessAt: lastSuccessAt,
                status: status,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                downloadDirectory: downloadDirectory,
                namingTemplate: namingTemplate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String sourceUrl,
                required String feedUrl,
                required String platform,
                required String keywords,
                required String tags,
                required int onlyDownloadLatest,
                required int enabled,
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> latestVideoTitle = const Value.absent(),
                Value<int?> latestVideoPublishedAt = const Value.absent(),
                Value<int?> lastCheckedAt = const Value.absent(),
                Value<int?> lastSuccessAt = const Value.absent(),
                required String status,
                Value<String?> lastError = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<String?> downloadDirectory = const Value.absent(),
                Value<String?> namingTemplate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                title: title,
                sourceUrl: sourceUrl,
                feedUrl: feedUrl,
                platform: platform,
                keywords: keywords,
                tags: tags,
                onlyDownloadLatest: onlyDownloadLatest,
                enabled: enabled,
                coverUrl: coverUrl,
                latestVideoTitle: latestVideoTitle,
                latestVideoPublishedAt: latestVideoPublishedAt,
                lastCheckedAt: lastCheckedAt,
                lastSuccessAt: lastSuccessAt,
                status: status,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                downloadDirectory: downloadDirectory,
                namingTemplate: namingTemplate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (
        Subscription,
        BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>,
      ),
      Subscription,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionItemsTableCreateCompanionBuilder =
    SubscriptionItemsCompanion Function({
      required String subscriptionId,
      required String itemId,
      required String title,
      required String url,
      required int publishedAt,
      Value<String?> thumbnail,
      required int added,
      Value<String?> downloadId,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SubscriptionItemsTableUpdateCompanionBuilder =
    SubscriptionItemsCompanion Function({
      Value<String> subscriptionId,
      Value<String> itemId,
      Value<String> title,
      Value<String> url,
      Value<int> publishedAt,
      Value<String?> thumbnail,
      Value<int> added,
      Value<String?> downloadId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$SubscriptionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionItemsTable> {
  $$SubscriptionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get subscriptionId => $composableBuilder(
    column: $table.subscriptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadId => $composableBuilder(
    column: $table.downloadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionItemsTable> {
  $$SubscriptionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get subscriptionId => $composableBuilder(
    column: $table.subscriptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadId => $composableBuilder(
    column: $table.downloadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionItemsTable> {
  $$SubscriptionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get subscriptionId => $composableBuilder(
    column: $table.subscriptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<int> get added =>
      $composableBuilder(column: $table.added, builder: (column) => column);

  GeneratedColumn<String> get downloadId => $composableBuilder(
    column: $table.downloadId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SubscriptionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionItemsTable,
          SubscriptionItem,
          $$SubscriptionItemsTableFilterComposer,
          $$SubscriptionItemsTableOrderingComposer,
          $$SubscriptionItemsTableAnnotationComposer,
          $$SubscriptionItemsTableCreateCompanionBuilder,
          $$SubscriptionItemsTableUpdateCompanionBuilder,
          (
            SubscriptionItem,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionItemsTable,
              SubscriptionItem
            >,
          ),
          SubscriptionItem,
          PrefetchHooks Function()
        > {
  $$SubscriptionItemsTableTableManager(
    _$AppDatabase db,
    $SubscriptionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> subscriptionId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> publishedAt = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<int> added = const Value.absent(),
                Value<String?> downloadId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionItemsCompanion(
                subscriptionId: subscriptionId,
                itemId: itemId,
                title: title,
                url: url,
                publishedAt: publishedAt,
                thumbnail: thumbnail,
                added: added,
                downloadId: downloadId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String subscriptionId,
                required String itemId,
                required String title,
                required String url,
                required int publishedAt,
                Value<String?> thumbnail = const Value.absent(),
                required int added,
                Value<String?> downloadId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionItemsCompanion.insert(
                subscriptionId: subscriptionId,
                itemId: itemId,
                title: title,
                url: url,
                publishedAt: publishedAt,
                thumbnail: thumbnail,
                added: added,
                downloadId: downloadId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionItemsTable,
      SubscriptionItem,
      $$SubscriptionItemsTableFilterComposer,
      $$SubscriptionItemsTableOrderingComposer,
      $$SubscriptionItemsTableAnnotationComposer,
      $$SubscriptionItemsTableCreateCompanionBuilder,
      $$SubscriptionItemsTableUpdateCompanionBuilder,
      (
        SubscriptionItem,
        BaseReferences<
          _$AppDatabase,
          $SubscriptionItemsTable,
          SubscriptionItem
        >,
      ),
      SubscriptionItem,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadHistoryTableTableManager get downloadHistory =>
      $$DownloadHistoryTableTableManager(_db, _db.downloadHistory);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$SubscriptionItemsTableTableManager get subscriptionItems =>
      $$SubscriptionItemsTableTableManager(_db, _db.subscriptionItems);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
