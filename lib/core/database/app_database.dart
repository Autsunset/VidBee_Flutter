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

@DriftDatabase(
  tables: [DownloadHistory],
)
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
