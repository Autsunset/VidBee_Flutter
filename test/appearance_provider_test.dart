import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/providers/appearance_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer createContainer({
    Future<SharedPreferences> Function()? loadPreferences,
  }) {
    final container = ProviderContainer(
      overrides: [
        if (loadPreferences != null)
          appThemeStyleProvider.overrideWith(
            (ref) => AppThemeStyleNotifier(loadPreferences: loadPreferences),
          ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('new installations use Liquid Glass', () async {
    final container = createContainer();
    expect(container.read(appThemeStyleProvider), AppThemeStyle.liquidGlass);
    await container.read(appThemeStyleProvider.notifier).ready;
    expect(container.read(appThemeStyleProvider), AppThemeStyle.liquidGlass);
  });

  for (final style in AppThemeStyle.values) {
    test('restores ${style.name} without changing color mode', () async {
      SharedPreferences.setMockInitialValues({
        AppThemeStyleNotifier.preferenceKey: style.name,
        'theme_mode': 'dark',
      });
      final container = createContainer();
      await container.read(appThemeStyleProvider.notifier).ready;

      expect(container.read(appThemeStyleProvider), style);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('theme_mode'), 'dark');
    });
  }

  for (final invalid in ['unknown', 'dark', '', 42, true]) {
    test('falls back safely for malformed stored value $invalid', () async {
      SharedPreferences.setMockInitialValues({
        AppThemeStyleNotifier.preferenceKey: invalid,
      });
      final container = createContainer();
      await container.read(appThemeStyleProvider.notifier).ready;

      expect(container.read(appThemeStyleProvider), AppThemeStyle.liquidGlass);
    });
  }

  test('style changes immediately and survives a new provider', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
    final container = createContainer();
    final notifier = container.read(appThemeStyleProvider.notifier);
    await notifier.ready;

    final save = notifier.setStyle(AppThemeStyle.classic);
    expect(container.read(appThemeStyleProvider), AppThemeStyle.classic);
    await save;
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme_mode'), 'system');

    final restored = createContainer();
    await restored.read(appThemeStyleProvider.notifier).ready;
    expect(restored.read(appThemeStyleProvider), AppThemeStyle.classic);
  });

  test('late initial load never replaces an explicit selection', () async {
    final preferences = _ControlledPreferences({
      AppThemeStyleNotifier.preferenceKey: AppThemeStyle.classic.name,
    });
    final load = Completer<SharedPreferences>();
    final container = createContainer(loadPreferences: () => load.future);
    final notifier = container.read(appThemeStyleProvider.notifier);

    final save = notifier.setStyle(AppThemeStyle.liquidGlass);
    load.complete(preferences);
    await notifier.ready;
    await save;

    expect(container.read(appThemeStyleProvider), AppThemeStyle.liquidGlass);
    expect(
      preferences.get(AppThemeStyleNotifier.preferenceKey),
      AppThemeStyle.liquidGlass.name,
    );
  });

  test('rapid selections serialize writes and persist the last one', () async {
    final firstWrite = Completer<bool>();
    final preferences = _ControlledPreferences({}, firstWrite: firstWrite);
    final container = createContainer(loadPreferences: () async => preferences);
    final notifier = container.read(appThemeStyleProvider.notifier);
    await notifier.ready;

    final first = notifier.setStyle(AppThemeStyle.classic);
    final second = notifier.setStyle(AppThemeStyle.liquidGlass);
    final third = notifier.setStyle(AppThemeStyle.classic);
    await Future<void>.delayed(Duration.zero);
    expect(preferences.startedWrites, ['classic']);
    expect(container.read(appThemeStyleProvider), AppThemeStyle.classic);

    firstWrite.complete(true);
    await Future.wait([first, second, third]);
    expect(preferences.startedWrites, ['classic', 'liquidGlass', 'classic']);
    expect(preferences.get(AppThemeStyleNotifier.preferenceKey), 'classic');
  });

  test('a failed write does not block the next selection', () async {
    final firstWrite = Completer<bool>();
    final preferences = _ControlledPreferences({}, firstWrite: firstWrite);
    final container = createContainer(loadPreferences: () async => preferences);
    final notifier = container.read(appThemeStyleProvider.notifier);
    await notifier.ready;

    final first = notifier.setStyle(AppThemeStyle.classic);
    final firstExpectation = expectLater(first, throwsStateError);
    final second = notifier.setStyle(AppThemeStyle.liquidGlass);
    firstWrite.complete(false);
    await firstExpectation;
    await second;

    expect(
      preferences.get(AppThemeStyleNotifier.preferenceKey),
      AppThemeStyle.liquidGlass.name,
    );
  });

  test('load errors keep the default and later saves may recover', () async {
    final preferences = _ControlledPreferences({});
    var loads = 0;
    final container = createContainer(
      loadPreferences: () async {
        if (loads++ == 0) throw StateError('Preferences unavailable');
        return preferences;
      },
    );
    final notifier = container.read(appThemeStyleProvider.notifier);
    await notifier.ready;
    expect(container.read(appThemeStyleProvider), AppThemeStyle.liquidGlass);

    await notifier.setStyle(AppThemeStyle.classic);
    expect(preferences.get(AppThemeStyleNotifier.preferenceKey), 'classic');
  });

  test(
    'disposing before preferences load does not update disposed state',
    () async {
      final load = Completer<SharedPreferences>();
      final notifier = AppThemeStyleNotifier(
        loadPreferences: () => load.future,
      );
      notifier.dispose();
      load.complete(_ControlledPreferences({}));
      await expectLater(notifier.ready, completes);
    },
  );
}

class _ControlledPreferences implements SharedPreferences {
  _ControlledPreferences(this.values, {this.firstWrite});

  final Map<String, Object> values;
  final Completer<bool>? firstWrite;
  final List<String> startedWrites = [];

  @override
  Object? get(String key) => values[key];

  @override
  Future<bool> setString(String key, String value) async {
    startedWrites.add(value);
    if (startedWrites.length == 1 && firstWrite != null) {
      if (!await firstWrite!.future) return false;
    }
    values[key] = value;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
