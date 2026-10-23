import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeStyle { liquidGlass, classic }

final appThemeStyleProvider =
    StateNotifierProvider<AppThemeStyleNotifier, AppThemeStyle>((ref) {
      return AppThemeStyleNotifier();
    });

class AppThemeStyleNotifier extends StateNotifier<AppThemeStyle> {
  AppThemeStyleNotifier({Future<SharedPreferences> Function()? loadPreferences})
    : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance,
      super(AppThemeStyle.liquidGlass) {
    ready = _restoreStyle();
  }

  static const preferenceKey = 'app_theme_style';

  final Future<SharedPreferences> Function() _loadPreferences;
  late final Future<void> ready;
  Future<void> _writeQueue = Future<void>.value();
  bool _hasUserSelection = false;

  Future<void> _restoreStyle() async {
    try {
      final preferences = await _loadPreferences();
      if (!mounted || _hasUserSelection) return;

      state = preferences.get(preferenceKey) == AppThemeStyle.classic.name
          ? AppThemeStyle.classic
          : AppThemeStyle.liquidGlass;
    } catch (error) {
      debugPrint('Unable to restore interface style: $error');
    }
  }

  Future<void> setStyle(AppThemeStyle style) {
    if (!mounted) return Future<void>.value();
    _hasUserSelection = true;
    state = style;

    // Serialize storage writes so quick changes also persist in selection order.
    final save = _writeQueue.then((_) async {
      final preferences = await _loadPreferences();
      final saved = await preferences.setString(preferenceKey, style.name);
      if (!saved) throw StateError('Unable to save interface style');
    });
    _writeQueue = save.catchError((Object error, StackTrace stackTrace) {
      // A failed write must not prevent the next selection from being saved.
    });
    return save;
  }
}
