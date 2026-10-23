import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/providers/appearance_provider.dart';
import 'package:vidbee_flutter/features/settings/appearance_settings_section.dart';
import 'package:vidbee_flutter/shared/i18n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp(
    ProviderContainer container, {
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: const Scaffold(
              body: SingleChildScrollView(child: AppearanceSettingsSection()),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('selects either style immediately and persists it', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    expect(find.text('Interface style'), findsOneWidget);
    expect(find.text('Liquid Glass'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('style-classic')));
    await tester.pumpAndSettle();
    expect(container.read(appThemeStyleProvider), AppThemeStyle.classic);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(AppThemeStyleNotifier.preferenceKey),
      'classic',
    );

    await tester.tap(find.byKey(const ValueKey('style-liquid-glass')));
    await tester.pumpAndSettle();
    expect(container.read(appThemeStyleProvider), AppThemeStyle.liquidGlass);
    expect(
      preferences.getString(AppThemeStyleNotifier.preferenceKey),
      'liquidGlass',
    );
  });

  testWidgets('announces button and selected state to assistive technology', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(buildApp(container));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byKey(const ValueKey('style-liquid-glass'))),
        matchesSemantics(
          label: 'Liquid Glass. Luminous layers, softer surfaces',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      await tester.tap(find.byKey(const ValueKey('style-classic')));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byKey(const ValueKey('style-classic'))),
        matchesSemantics(
          label: 'Classic. The familiar original interface',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('reports a delayed save failure after the section unmounts', (
    tester,
  ) async {
    final writeResult = Completer<bool>();
    final preferences = _DelayedPreferences(writeResult);
    final container = ProviderContainer(
      overrides: [
        appThemeStyleProvider.overrideWith(
          (ref) =>
              AppThemeStyleNotifier(loadPreferences: () async => preferences),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(appThemeStyleProvider.notifier).ready;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, child) {
                if (ref.watch(appThemeStyleProvider) == AppThemeStyle.classic) {
                  return const Center(child: Text('Classic layout'));
                }
                return const SingleChildScrollView(
                  child: AppearanceSettingsSection(),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final originalSection = tester.element(
      find.byType(AppearanceSettingsSection),
    );
    final messenger = ScaffoldMessenger.of(originalSection);

    await tester.tap(find.byKey(const ValueKey('style-classic')));
    await tester.pumpAndSettle();

    expect(container.read(appThemeStyleProvider), AppThemeStyle.classic);
    expect(preferences.writtenValue, AppThemeStyle.classic.name);
    expect(originalSection.mounted, isFalse);
    expect(
      ScaffoldMessenger.of(tester.element(find.text('Classic layout'))),
      same(messenger),
    );
    expect(writeResult.isCompleted, isFalse);

    writeResult.complete(false);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.descendant(of: find.byType(SnackBar), matching: find.text('Error')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      '${locale.languageCode} fits a narrow display with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          buildApp(container, locale: locale, textScale: 2),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final glass = find.byKey(const ValueKey('style-liquid-glass'));
        final classic = find.byKey(const ValueKey('style-classic'));
        expect(
          tester.getTopLeft(classic).dy,
          greaterThan(tester.getBottomLeft(glass).dy),
        );
        await tester.ensureVisible(classic);
        await tester.tap(classic);
        await tester.pumpAndSettle();
        expect(container.read(appThemeStyleProvider), AppThemeStyle.classic);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _DelayedPreferences implements SharedPreferences {
  _DelayedPreferences(this.writeResult);

  final Completer<bool> writeResult;
  String? writtenValue;

  @override
  Object? get(String key) => null;

  @override
  Future<bool> setString(String key, String value) {
    writtenValue = value;
    return writeResult.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
