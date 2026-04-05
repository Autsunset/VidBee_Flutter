// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dao.dart';

// ignore_for_file: type=lint
mixin _$SubscriptionDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubscriptionsTable get subscriptions => attachedDatabase.subscriptions;
  $SubscriptionItemsTable get subscriptionItems =>
      attachedDatabase.subscriptionItems;
  SubscriptionDaoManager get managers => SubscriptionDaoManager(this);
}

class SubscriptionDaoManager {
  final _$SubscriptionDaoMixin _db;
  SubscriptionDaoManager(this._db);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db.attachedDatabase, _db.subscriptions);
  $$SubscriptionItemsTableTableManager get subscriptionItems =>
      $$SubscriptionItemsTableTableManager(
        _db.attachedDatabase,
        _db.subscriptionItems,
      );
}
