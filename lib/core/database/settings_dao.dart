import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/models.dart';
import 'app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  static const String _settingsKey = 'app_settings';

  Future<void> saveSettings(AppSettings appSettings) async {
    final json = jsonEncode(appSettings.toJson());
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: const Value(_settingsKey),
        value: Value(json),
      ),
    );
  }

  Future<AppSettings> getSettings() async {
    final query = select(settings)..where((t) => t.key.equals(_settingsKey));
    final row = await query.getSingleOrNull();
    if (row == null) {
      return AppSettings.defaults();
    }
    try {
      final json = jsonDecode(row.value) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (e) {
      return AppSettings.defaults();
    }
  }

  Future<void> updateSingleSetting<T>(String key, T value) async {
    final currentSettings = await getSettings();
    final Map<String, dynamic> json = currentSettings.toJson();
    json[key] = value;
    final updatedSettings = AppSettings.fromJson(json);
    await saveSettings(updatedSettings);
  }

  Future<void> resetToDefaults() async {
    await saveSettings(AppSettings.defaults());
  }
}
