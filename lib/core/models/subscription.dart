enum SubscriptionPlatform {
  youtube,
  bilibili,
  custom,
}

enum SubscriptionStatus {
  idle,
  checking,
  upToDate,
  failed,
}

class SubscriptionFeedItem {
  final String id;
  final String url;
  final String title;
  final int publishedAt;
  final String? thumbnail;
  final bool addedToQueue;
  final String? downloadId;

  SubscriptionFeedItem({
    required this.id,
    required this.url,
    required this.title,
    required this.publishedAt,
    this.thumbnail,
    required this.addedToQueue,
    this.downloadId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'publishedAt': publishedAt,
      'thumbnail': thumbnail,
      'addedToQueue': addedToQueue,
      'downloadId': downloadId,
    };
  }

  factory SubscriptionFeedItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeedItem(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      publishedAt: json['publishedAt'] as int,
      thumbnail: json['thumbnail'] as String?,
      addedToQueue: json['addedToQueue'] as bool,
      downloadId: json['downloadId'] as String?,
    );
  }

  SubscriptionFeedItem copyWith({
    String? id,
    String? url,
    String? title,
    int? publishedAt,
    String? thumbnail,
    bool? addedToQueue,
    String? downloadId,
  }) {
    return SubscriptionFeedItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      publishedAt: publishedAt ?? this.publishedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      addedToQueue: addedToQueue ?? this.addedToQueue,
      downloadId: downloadId ?? this.downloadId,
    );
  }
}

class SubscriptionRule {
  final String id;
  final String title;
  final String sourceUrl;
  final String feedUrl;
  final SubscriptionPlatform platform;
  final List<String> keywords;
  final List<String> tags;
  final bool onlyDownloadLatest;
  final bool enabled;
  final String? coverUrl;
  final String? latestVideoTitle;
  final int? latestVideoPublishedAt;
  final int? lastCheckedAt;
  final int? lastSuccessAt;
  final SubscriptionStatus status;
  final String? lastError;
  final int createdAt;
  final int updatedAt;
  final String? downloadDirectory;
  final String? namingTemplate;
  final List<SubscriptionFeedItem> items;

  SubscriptionRule({
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
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sourceUrl': sourceUrl,
      'feedUrl': feedUrl,
      'platform': platform.name,
      'keywords': keywords,
      'tags': tags,
      'onlyDownloadLatest': onlyDownloadLatest,
      'enabled': enabled,
      'coverUrl': coverUrl,
      'latestVideoTitle': latestVideoTitle,
      'latestVideoPublishedAt': latestVideoPublishedAt,
      'lastCheckedAt': lastCheckedAt,
      'lastSuccessAt': lastSuccessAt,
      'status': status.name,
      'lastError': lastError,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'downloadDirectory': downloadDirectory,
      'namingTemplate': namingTemplate,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory SubscriptionRule.fromJson(Map<String, dynamic> json) {
    return SubscriptionRule(
      id: json['id'] as String,
      title: json['title'] as String,
      sourceUrl: json['sourceUrl'] as String,
      feedUrl: json['feedUrl'] as String,
      platform: SubscriptionPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => SubscriptionPlatform.custom,
      ),
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      onlyDownloadLatest: json['onlyDownloadLatest'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
      coverUrl: json['coverUrl'] as String?,
      latestVideoTitle: json['latestVideoTitle'] as String?,
      latestVideoPublishedAt: json['latestVideoPublishedAt'] as int?,
      lastCheckedAt: json['lastCheckedAt'] as int?,
      lastSuccessAt: json['lastSuccessAt'] as int?,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.idle,
      ),
      lastError: json['lastError'] as String?,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      downloadDirectory: json['downloadDirectory'] as String?,
      namingTemplate: json['namingTemplate'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => SubscriptionFeedItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  SubscriptionRule copyWith({
    String? id,
    String? title,
    String? sourceUrl,
    String? feedUrl,
    SubscriptionPlatform? platform,
    List<String>? keywords,
    List<String>? tags,
    bool? onlyDownloadLatest,
    bool? enabled,
    String? coverUrl,
    String? latestVideoTitle,
    int? latestVideoPublishedAt,
    int? lastCheckedAt,
    int? lastSuccessAt,
    SubscriptionStatus? status,
    String? lastError,
    int? createdAt,
    int? updatedAt,
    String? downloadDirectory,
    String? namingTemplate,
    List<SubscriptionFeedItem>? items,
  }) {
    return SubscriptionRule(
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
      latestVideoPublishedAt: latestVideoPublishedAt ?? this.latestVideoPublishedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadDirectory: downloadDirectory ?? this.downloadDirectory,
      namingTemplate: namingTemplate ?? this.namingTemplate,
      items: items ?? this.items,
    );
  }
}

class SubscriptionResolvedFeed {
  final String sourceUrl;
  final String feedUrl;
  final SubscriptionPlatform platform;

  SubscriptionResolvedFeed({
    required this.sourceUrl,
    required this.feedUrl,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceUrl': sourceUrl,
      'feedUrl': feedUrl,
      'platform': platform.name,
    };
  }

  factory SubscriptionResolvedFeed.fromJson(Map<String, dynamic> json) {
    return SubscriptionResolvedFeed(
      sourceUrl: json['sourceUrl'] as String,
      feedUrl: json['feedUrl'] as String,
      platform: SubscriptionPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => SubscriptionPlatform.custom,
      ),
    );
  }
}

class SubscriptionCreatePayload {
  final String sourceUrl;
  final String feedUrl;
  final SubscriptionPlatform platform;
  final List<String>? keywords;
  final List<String>? tags;
  final bool? onlyDownloadLatest;
  final String? downloadDirectory;
  final String? namingTemplate;
  final bool? enabled;

  SubscriptionCreatePayload({
    required this.sourceUrl,
    required this.feedUrl,
    required this.platform,
    this.keywords,
    this.tags,
    this.onlyDownloadLatest,
    this.downloadDirectory,
    this.namingTemplate,
    this.enabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceUrl': sourceUrl,
      'feedUrl': feedUrl,
      'platform': platform.name,
      'keywords': keywords,
      'tags': tags,
      'onlyDownloadLatest': onlyDownloadLatest,
      'downloadDirectory': downloadDirectory,
      'namingTemplate': namingTemplate,
      'enabled': enabled,
    };
  }
}

class SubscriptionUpdatePayload {
  final String? title;
  final String? sourceUrl;
  final String? feedUrl;
  final SubscriptionPlatform? platform;
  final List<String>? keywords;
  final List<String>? tags;
  final bool? onlyDownloadLatest;
  final bool? enabled;
  final String? downloadDirectory;
  final String? namingTemplate;
  final List<SubscriptionFeedItem>? items;

  SubscriptionUpdatePayload({
    this.title,
    this.sourceUrl,
    this.feedUrl,
    this.platform,
    this.keywords,
    this.tags,
    this.onlyDownloadLatest,
    this.enabled,
    this.downloadDirectory,
    this.namingTemplate,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sourceUrl': sourceUrl,
      'feedUrl': feedUrl,
      'platform': platform?.name,
      'keywords': keywords,
      'tags': tags,
      'onlyDownloadLatest': onlyDownloadLatest,
      'enabled': enabled,
      'downloadDirectory': downloadDirectory,
      'namingTemplate': namingTemplate,
      'items': items?.map((i) => i.toJson()).toList(),
    };
  }
}
