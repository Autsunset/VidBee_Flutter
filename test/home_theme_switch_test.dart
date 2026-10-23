import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';
import 'package:vidbee_flutter/core/providers/appearance_provider.dart';
import 'package:vidbee_flutter/core/providers/service_providers.dart';
import 'package:vidbee_flutter/core/services/download_service.dart';
import 'package:vidbee_flutter/core/services/history_service.dart';
import 'package:vidbee_flutter/core/services/ytdlp_service.dart';
import 'package:vidbee_flutter/features/download/add_url_dialog.dart';
import 'package:vidbee_flutter/features/download/downloads_page.dart';
import 'package:vidbee_flutter/features/history/history_page.dart';
import 'package:vidbee_flutter/features/settings/settings_page.dart';
import 'package:vidbee_flutter/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'download_path': '/tmp/vidbee-theme-test',
      'language': 'en',
    });
    PackageInfo.setMockInitialValues(
      appName: 'VidBee',
      packageName: 'com.example.vidbee',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets(
    'switching styles keeps visited pages, active tab, and scroll positions',
    (tester) async {
      final harness = await _pumpApp(tester, populated: true);
      final homeState = tester.state(find.byType(HomePage));
      final downloadsState = tester.state(find.byType(DownloadsPage));

      expect(find.byKey(const ValueKey('glass-nav-0')), findsOneWidget);
      expect(find.byType(HistoryPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);

      await tester.drag(
        find.descendant(
          of: find.byType(DownloadsPage),
          matching: find.byType(Scrollable),
        ),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      final downloadOffset = _scrollPosition(tester, DownloadsPage).pixels;
      expect(downloadOffset, greaterThan(0));

      await tester.tap(find.byKey(const ValueKey('glass-nav-1')));
      await tester.pumpAndSettle();
      final historyState = tester.state(find.byType(HistoryPage));
      await tester.drag(
        find.descendant(
          of: find.byType(HistoryPage),
          matching: find.byType(Scrollable),
        ),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      final historyOffset = _scrollPosition(tester, HistoryPage).pixels;
      expect(historyOffset, greaterThan(0));

      await tester.tap(find.byKey(const ValueKey('glass-nav-2')));
      await tester.pumpAndSettle();
      final settingsState = tester.state(find.byType(SettingsPage));
      await tester.drag(
        find.descendant(
          of: find.byType(SettingsPage),
          matching: find.byType(ListView),
        ),
        const Offset(0, -220),
      );
      await tester.pumpAndSettle();
      final settingsOffset = _scrollPosition(tester, SettingsPage).pixels;
      expect(settingsOffset, greaterThan(0));

      await harness.container
          .read(appThemeStyleProvider.notifier)
          .setStyle(AppThemeStyle.classic);
      await tester.pumpAndSettle();

      expect(tester.state(find.byType(HomePage)), same(homeState));
      expect(tester.state(find.byType(SettingsPage)), same(settingsState));
      expect(
        tester.state(find.byType(DownloadsPage, skipOffstage: false)),
        same(downloadsState),
      );
      expect(
        tester.state(find.byType(HistoryPage, skipOffstage: false)),
        same(historyState),
      );
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      expect(_scrollPosition(tester, SettingsPage).pixels, settingsOffset);
      expect(_scrollPosition(tester, DownloadsPage).pixels, downloadOffset);
      expect(_scrollPosition(tester, HistoryPage).pixels, historyOffset);

      await harness.container
          .read(appThemeStyleProvider.notifier)
          .setStyle(AppThemeStyle.liquidGlass);
      await tester.pumpAndSettle();

      expect(tester.state(find.byType(HomePage)), same(homeState));
      expect(tester.state(find.byType(SettingsPage)), same(settingsState));
      expect(_scrollPosition(tester, SettingsPage).pixels, settingsOffset);
      await tester.tap(find.byKey(const ValueKey('glass-nav-0')));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(DownloadsPage)), same(downloadsState));
      expect(_scrollPosition(tester, DownloadsPage).pixels, downloadOffset);
      expect(harness.downloads.initializations, 1);
      expect(harness.history.initializations, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'appearance controls persist classic and restore glass without leaving settings',
    (tester) async {
      final harness = await _pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('glass-nav-2')));
      await tester.pumpAndSettle();
      final settingsState = tester.state(find.byType(SettingsPage));

      final classicCard = find.byKey(const ValueKey('style-classic'));
      await tester.ensureVisible(classicCard);
      await tester.tap(classicCard);
      await tester.pumpAndSettle();

      expect(
        harness.container.read(appThemeStyleProvider),
        AppThemeStyle.classic,
      );
      expect(tester.state(find.byType(SettingsPage)), same(settingsState));
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(AppThemeStyleNotifier.preferenceKey),
        AppThemeStyle.classic.name,
      );

      final glassCard = find.byKey(const ValueKey('style-liquid-glass'));
      await tester.scrollUntilVisible(
        glassCard,
        250,
        scrollable: find.descendant(
          of: find.byType(SettingsPage),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(glassCard);
      await tester.pumpAndSettle();

      expect(
        harness.container.read(appThemeStyleProvider),
        AppThemeStyle.liquidGlass,
      );
      expect(
        preferences.getString(AppThemeStyleNotifier.preferenceKey),
        AppThemeStyle.liquidGlass.name,
      );
      expect(tester.state(find.byType(SettingsPage)), same(settingsState));
      expect(find.byKey(const ValueKey('glass-nav-2')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('both styles preserve navigation on a wide display', (
    tester,
  ) async {
    final harness = await _pumpApp(tester, size: const Size(1280, 900));

    for (final style in AppThemeStyle.values) {
      await harness.container
          .read(appThemeStyleProvider.notifier)
          .setStyle(style);
      await tester.pumpAndSettle();

      for (var index = 0; index < 3; index++) {
        final destination = style == AppThemeStyle.liquidGlass
            ? find.byKey(ValueKey('glass-nav-$index'))
            : find.byType(NavigationDestination).at(index);
        expect(destination.hitTestable(), findsOneWidget);
        await tester.tap(destination);
        await tester.pumpAndSettle();
        expect(
          find.byType([DownloadsPage, HistoryPage, SettingsPage][index]),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    }
    expect(harness.downloads.initializations, 1);
    expect(harness.history.initializations, 1);
  });

  testWidgets(
    'stored classic preference restores the original navigation on startup',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'download_path': '/tmp/vidbee-theme-test',
        'language': 'en',
        AppThemeStyleNotifier.preferenceKey: AppThemeStyle.classic.name,
      });
      final harness = await _pumpApp(tester);

      expect(
        harness.container.read(appThemeStyleProvider),
        AppThemeStyle.classic,
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byKey(const ValueKey('glass-nav-0')), findsNothing);
      expect(find.byType(DownloadsPage), findsOneWidget);
      expect(find.byType(HistoryPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    },
  );

  testWidgets(
    'both styles open the download dialog independently of light and dark mode',
    (tester) async {
      final harness = await _pumpApp(tester);

      for (final style in AppThemeStyle.values) {
        await harness.container
            .read(appThemeStyleProvider.notifier)
            .setStyle(style);
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          harness.container.read(themeModeProvider.notifier).state = mode;
          await tester.pumpAndSettle();

          expect(
            Theme.of(tester.element(find.byType(DownloadsPage))).brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          );
          expect(harness.container.read(appThemeStyleProvider), style);
          final overlay = tester
              .widget<AppBar>(find.byType(AppBar))
              .systemOverlayStyle;
          if (style == AppThemeStyle.liquidGlass) {
            expect(
              overlay?.statusBarIconBrightness,
              mode == ThemeMode.dark ? Brightness.light : Brightness.dark,
            );
            expect(overlay?.statusBarColor, Colors.transparent);
          } else {
            expect(overlay, isNull);
          }

          await tester.tap(find.byTooltip('Add URL'));
          await tester.pumpAndSettle();
          expect(find.byType(AddUrlDialog), findsOneWidget);
          expect(find.byType(TextField), findsOneWidget);
          await tester.enterText(
            find.byType(TextField),
            'https://example.com/video',
          );
          await tester.tap(
            find.descendant(
              of: find.byType(AddUrlDialog),
              matching: find.widgetWithText(TextButton, 'Cancel'),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AddUrlDialog), findsNothing);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'color mode label stays current and cancelling does not apply it',
    (tester) async {
      final harness = await _pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('glass-nav-2')));
      await tester.pumpAndSettle();
      final themeTile = find.widgetWithText(ListTile, 'Theme Mode');
      await tester.ensureVisible(themeTile);
      expect(
        find.descendant(of: themeTile, matching: find.text('Light Mode')),
        findsOneWidget,
      );

      harness.container.read(themeModeProvider.notifier).state = ThemeMode.dark;
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: themeTile, matching: find.text('Dark Mode')),
        findsOneWidget,
      );
      await tester.tap(themeTile);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(RadioListTile<ThemeMode>, 'Light Mode'),
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);
      await harness.container
          .read(appThemeStyleProvider.notifier)
          .setStyle(AppThemeStyle.classic);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: themeTile, matching: find.text('Dark Mode')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('glass navigation exposes selected and labeled tabs', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpApp(tester);

      final downloads = tester.getSemantics(
        find.byKey(const ValueKey('glass-nav-0')),
      );
      expect(downloads.label, contains('Download'));
      expect(downloads.flagsCollection.isButton, isTrue);
      expect(downloads.flagsCollection.isSelected, Tristate.isTrue);

      await tester.tap(find.byKey(const ValueKey('glass-nav-1')));
      await tester.pumpAndSettle();
      final history = tester.getSemantics(
        find.byKey(const ValueKey('glass-nav-1')),
      );
      expect(history.label, contains('History'));
      expect(history.flagsCollection.isSelected, Tristate.isTrue);
      expect(
        tester
            .getSemantics(find.byKey(const ValueKey('glass-nav-0')))
            .flagsCollection
            .isSelected,
        Tristate.isFalse,
      );
    } finally {
      semantics.dispose();
    }
  });

  for (final scale in [1.6, 2.0]) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final populated in [false, true]) {
        testWidgets('320x640 $scale text ${mode.name} '
            '${populated ? "populated" : "empty"} pages remain usable', (
          tester,
        ) async {
          final harness = await _pumpApp(
            tester,
            populated: populated,
            size: const Size(320, 640),
            textScale: scale,
            mode: mode,
          );
          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const ValueKey('glass-nav-0')).hitTestable(),
            findsOneWidget,
          );
          if (populated) {
            await tester.drag(
              find.descendant(
                of: find.byType(DownloadsPage),
                matching: find.byType(Scrollable),
              ),
              const Offset(0, -500),
            );
            await tester.pumpAndSettle();
            expect(find.byType(DownloadTaskCard), findsWidgets);
            expect(tester.takeException(), isNull);
          }

          await tester.tap(find.byKey(const ValueKey('glass-nav-1')));
          await tester.pumpAndSettle();
          expect(find.byType(HistoryPage), findsOneWidget);
          if (populated) {
            await tester.drag(
              find.descendant(
                of: find.byType(HistoryPage),
                matching: find.byType(Scrollable),
              ),
              const Offset(0, -350),
            );
            await tester.pumpAndSettle();
            expect(find.byType(HistoryTaskCard), findsWidgets);
          }
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(const ValueKey('glass-nav-2')));
          await tester.pumpAndSettle();
          expect(find.byType(SettingsPage), findsOneWidget);
          expect(tester.takeException(), isNull);

          final classicCard = find.byKey(const ValueKey('style-classic'));
          await tester.ensureVisible(classicCard);
          await tester.pumpAndSettle();
          await tester.tap(classicCard);
          await tester.pumpAndSettle();
          expect(
            harness.container.read(appThemeStyleProvider),
            AppThemeStyle.classic,
          );
          expect(tester.takeException(), isNull);

          await harness.container
              .read(appThemeStyleProvider.notifier)
              .setStyle(AppThemeStyle.liquidGlass);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('glass-nav-0')));
          await tester.pumpAndSettle();
          expect(find.byType(DownloadsPage), findsOneWidget);
          expect(
            Theme.of(tester.element(find.byType(DownloadsPage))).brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

Future<_AppHarness> _pumpApp(
  WidgetTester tester, {
  bool populated = false,
  Size size = const Size(420, 900),
  double textScale = 1,
  ThemeMode mode = ThemeMode.light,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final downloads = _FakeDownloadService(
    populated ? _tasks(DownloadStatus.pending) : [],
  );
  final history = _FakeHistoryService(
    populated ? _tasks(DownloadStatus.completed) : [],
  );
  final container = ProviderContainer(
    overrides: [
      languageProvider.overrideWith((ref) => 'en'),
      themeModeProvider.overrideWith((ref) => mode),
      downloadServiceProvider.overrideWithValue(downloads),
      historyServiceProvider.overrideWithValue(history),
      ytDlpServiceProvider.overrideWithValue(_FakeYtDlpService()),
    ],
  );
  addTearDown(container.dispose);
  await container.read(appThemeStyleProvider.notifier).ready;
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const VidBeeApp()),
  );
  await tester.pumpAndSettle();
  return _AppHarness(container, downloads, history);
}

ScrollPosition _scrollPosition(WidgetTester tester, Type pageType) {
  final scrollable = find.descendant(
    of: find.byType(pageType, skipOffstage: false),
    matching: find.byType(Scrollable, skipOffstage: false),
    skipOffstage: false,
  );
  return tester.state<ScrollableState>(scrollable.first).position;
}

List<DownloadTask> _tasks(DownloadStatus status) => List.generate(
  24,
  (index) => DownloadTask(
    id: '${status.name}-$index',
    url: 'https://example.com/video/$index',
    title: 'Saved video $index',
    type: DownloadType.video,
    status: status,
    createdAt: index,
    completedAt: status == DownloadStatus.completed ? index + 1 : null,
  ),
);

class _AppHarness {
  const _AppHarness(this.container, this.downloads, this.history);

  final ProviderContainer container;
  final _FakeDownloadService downloads;
  final _FakeHistoryService history;
}

class _FakeDownloadService implements DownloadService {
  _FakeDownloadService(this.tasks);

  final List<DownloadTask> tasks;
  int initializations = 0;

  @override
  Future<void> initialize() async {
    initializations++;
  }

  @override
  List<DownloadTask> getAllTasks() => List.of(tasks);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHistoryService implements HistoryService {
  _FakeHistoryService(this.tasks);

  final List<DownloadTask> tasks;
  int initializations = 0;

  @override
  Future<void> initialize() async {
    initializations++;
  }

  @override
  List<DownloadTask> getHistory() => List.of(tasks);

  @override
  Stream<List<DownloadTask>> get historyStream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeYtDlpService implements YtDlpService {
  @override
  Future<Map<String, String>> getVersionInfo() async => {
    'yt-dlp': 'test-version',
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
