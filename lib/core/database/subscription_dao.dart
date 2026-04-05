import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/models.dart';
import 'app_database.dart';

part 'subscription_dao.g.dart';

@DriftAccessor(tables: [Subscriptions, SubscriptionItems])
class SubscriptionDao extends DatabaseAccessor<AppDatabase> with _$SubscriptionDaoMixin {
  SubscriptionDao(AppDatabase db) : super(db);

  Future<int> insertSubscription(SubscriptionRule subscription) async {
    await into(subscriptions).insert(
      SubscriptionsCompanion(
        id: Value(subscription.id),
        title: Value(subscription.title),
        sourceUrl: Value(subscription.sourceUrl),
        feedUrl: Value(subscription.feedUrl),
        platform: Value(subscription.platform.name),
        keywords: Value(jsonEncode(subscription.keywords)),
        tags: Value(jsonEncode(subscription.tags)),
        onlyDownloadLatest: Value(subscription.onlyDownloadLatest ? 1 : 0),
        enabled: Value(subscription.enabled ? 1 : 0),
        coverUrl: Value(subscription.coverUrl),
        latestVideoTitle: Value(subscription.latestVideoTitle),
        latestVideoPublishedAt: Value(subscription.latestVideoPublishedAt),
        lastCheckedAt: Value(subscription.lastCheckedAt),
        lastSuccessAt: Value(subscription.lastSuccessAt),
        status: Value(subscription.status.name),
        lastError: Value(subscription.lastError),
        createdAt: Value(subscription.createdAt),
        updatedAt: Value(subscription.updatedAt),
        downloadDirectory: Value(subscription.downloadDirectory),
        namingTemplate: Value(subscription.namingTemplate),
      ),
    );

    for (final item in subscription.items) {
      await into(subscriptionItems).insert(
        SubscriptionItemsCompanion(
          subscriptionId: Value(subscription.id),
          itemId: Value(item.id),
          title: Value(item.title),
          url: Value(item.url),
          publishedAt: Value(item.publishedAt),
          thumbnail: Value(item.thumbnail),
          added: Value(item.addedToQueue ? 1 : 0),
          downloadId: Value(item.downloadId),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    }

    return 1;
  }

  Future<List<SubscriptionRule>> getAllSubscriptions() async {
    final subscriptionQuery = select(subscriptions)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final subscriptionRows = await subscriptionQuery.get();

    final List<SubscriptionRule> results = [];

    for (final subRow in subscriptionRows) {
      final itemQuery = select(subscriptionItems)
        ..where((t) => t.subscriptionId.equals(subRow.id))
        ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
      final itemRows = await itemQuery.get();

      results.add(_rowToSubscription(subRow, itemRows));
    }

    return results;
  }

  Future<SubscriptionRule?> getSubscriptionById(String id) async {
    final subQuery = select(subscriptions)..where((t) => t.id.equals(id));
    final subRow = await subQuery.getSingleOrNull();
    if (subRow == null) return null;

    final itemQuery = select(subscriptionItems)
      ..where((t) => t.subscriptionId.equals(id))
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)]);
    final itemRows = await itemQuery.get();

    return _rowToSubscription(subRow, itemRows);
  }

  Future<int> updateSubscription(SubscriptionRule subscription) async {
    await (update(subscriptions)..where((t) => t.id.equals(subscription.id))).write(
      SubscriptionsCompanion(
        title: Value(subscription.title),
        sourceUrl: Value(subscription.sourceUrl),
        feedUrl: Value(subscription.feedUrl),
        platform: Value(subscription.platform.name),
        keywords: Value(jsonEncode(subscription.keywords)),
        tags: Value(jsonEncode(subscription.tags)),
        onlyDownloadLatest: Value(subscription.onlyDownloadLatest ? 1 : 0),
        enabled: Value(subscription.enabled ? 1 : 0),
        coverUrl: Value(subscription.coverUrl),
        latestVideoTitle: Value(subscription.latestVideoTitle),
        latestVideoPublishedAt: Value(subscription.latestVideoPublishedAt),
        lastCheckedAt: Value(subscription.lastCheckedAt),
        lastSuccessAt: Value(subscription.lastSuccessAt),
        status: Value(subscription.status.name),
        lastError: Value(subscription.lastError),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        downloadDirectory: Value(subscription.downloadDirectory),
        namingTemplate: Value(subscription.namingTemplate),
      ),
    );

    await (delete(subscriptionItems)..where((t) => t.subscriptionId.equals(subscription.id))).go();

    for (final item in subscription.items) {
      await into(subscriptionItems).insert(
        SubscriptionItemsCompanion(
          subscriptionId: Value(subscription.id),
          itemId: Value(item.id),
          title: Value(item.title),
          url: Value(item.url),
          publishedAt: Value(item.publishedAt),
          thumbnail: Value(item.thumbnail),
          added: Value(item.addedToQueue ? 1 : 0),
          downloadId: Value(item.downloadId),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    }

    return 1;
  }

  Future<int> deleteSubscription(String id) async {
    await (delete(subscriptionItems)..where((t) => t.subscriptionId.equals(id))).go();
    return (delete(subscriptions)..where((t) => t.id.equals(id))).go();
  }

  SubscriptionRule _rowToSubscription(Subscription subRow, List<SubscriptionItem> itemRows) {
    return SubscriptionRule(
      id: subRow.id,
      title: subRow.title,
      sourceUrl: subRow.sourceUrl,
      feedUrl: subRow.feedUrl,
      platform: SubscriptionPlatform.values.firstWhere((e) => e.name == subRow.platform),
      keywords: List<String>.from(jsonDecode(subRow.keywords)),
      tags: List<String>.from(jsonDecode(subRow.tags)),
      onlyDownloadLatest: subRow.onlyDownloadLatest == 1,
      enabled: subRow.enabled == 1,
      coverUrl: subRow.coverUrl,
      latestVideoTitle: subRow.latestVideoTitle,
      latestVideoPublishedAt: subRow.latestVideoPublishedAt,
      lastCheckedAt: subRow.lastCheckedAt,
      lastSuccessAt: subRow.lastSuccessAt,
      status: SubscriptionStatus.values.firstWhere((e) => e.name == subRow.status),
      lastError: subRow.lastError,
      createdAt: subRow.createdAt,
      updatedAt: subRow.updatedAt,
      downloadDirectory: subRow.downloadDirectory,
      namingTemplate: subRow.namingTemplate,
      items: itemRows.map(_rowToFeedItem).toList(),
    );
  }

  SubscriptionFeedItem _rowToFeedItem(SubscriptionItem itemRow) {
    return SubscriptionFeedItem(
      id: itemRow.itemId,
      url: itemRow.url,
      title: itemRow.title,
      publishedAt: itemRow.publishedAt,
      thumbnail: itemRow.thumbnail,
      addedToQueue: itemRow.added == 1,
      downloadId: itemRow.downloadId,
    );
  }
}
