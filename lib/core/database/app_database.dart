import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart';

@TableIndex(
  name: 'idx_download_history_downloaded_at',
  columns: {#downloadedAt},
)
@TableIndex(name: 'idx_download_history_playlist_id', columns: {#playlistId})
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
  TextColumn get selectedFormat => text().nullable()();
  TextColumn get playlistId => text().nullable()();
  TextColumn get playlistTitle => text().nullable()();
  IntColumn get playlistIndex => integer().nullable()();
  IntColumn get playlistSize => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DownloadHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试专用构造：注入自定义执行器（如内存数据库）。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // 仅做可加性迁移：为既有库补建查询索引，不改动任何列结构。
      // 新库由 createAll() 依据 @TableIndex 注解自动建索引。
      if (from < 2) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_download_history_downloaded_at '
          'ON download_history (downloaded_at)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_download_history_playlist_id '
          'ON download_history (playlist_id)',
        );
      }
      // v3：从 Drift schema 移除未接线的 subscription_id。
      // 不在这里 DROP COLUMN——Android minSdk 24 自带的 SQLite 过旧，
      // 不支持 DROP COLUMN；旧库保留该孤儿列无害（Drift 读写均不引用它），
      // 新库由 createAll() 直接按新 schema 建表（不含该列）。
      if (from < 3) {
        // no-op migration marker for schemaVersion bump
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'vidbee.db'));
      return NativeDatabase(file);
    });
  }
}
