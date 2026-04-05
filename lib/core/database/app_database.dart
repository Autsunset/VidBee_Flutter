import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart';

class DownloadHistory extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get thumbnail => text().nullable()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  TextColumn get downloadPath => text().nullable()();
  TextColumn get savedFileName => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get duration => integer().nullable()();
  IntColumn get downloadedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get error => text().nullable()();
  TextColumn get ytDlpCommand => text().nullable()();
  TextColumn get ytDlpLog => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get channel => text().nullable()();
  TextColumn get uploader => text().nullable()();
  IntColumn get viewCount => integer().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get origin => text().nullable()();
  TextColumn get subscriptionId => text().nullable()();
  TextColumn get selectedFormat => text().nullable()();
  TextColumn get playlistId => text().nullable()();
  TextColumn get playlistTitle => text().nullable()();
  IntColumn get playlistIndex => integer().nullable()();
  IntColumn get playlistSize => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Subscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get sourceUrl => text()();
  TextColumn get feedUrl => text()();
  TextColumn get platform => text()();
  TextColumn get keywords => text()();
  TextColumn get tags => text()();
  IntColumn get onlyDownloadLatest => integer()();
  IntColumn get enabled => integer()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get latestVideoTitle => text().nullable()();
  IntColumn get latestVideoPublishedAt => integer().nullable()();
  IntColumn get lastCheckedAt => integer().nullable()();
  IntColumn get lastSuccessAt => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get lastError => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get downloadDirectory => text().nullable()();
  TextColumn get namingTemplate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SubscriptionItems extends Table {
  TextColumn get subscriptionId => text()();
  TextColumn get itemId => text()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  IntColumn get publishedAt => integer()();
  TextColumn get thumbnail => text().nullable()();
  IntColumn get added => integer()();
  TextColumn get downloadId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {subscriptionId, itemId};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [DownloadHistory, Subscriptions, SubscriptionItems, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'vidbee.db'));
      return NativeDatabase(file);
    });
  }
}
