import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/providers/appearance_provider.dart';
import 'package:vidbee_flutter/features/settings/cookie_settings_section.dart';
import 'package:vidbee_flutter/shared/i18n/app_localizations.dart';
import 'package:vidbee_flutter/shared/theme/app_theme.dart';
import 'package:vidbee_flutter/shared/widgets/glass_widgets.dart';

const _cookies = {
  'bilibili.com': 'test-bilibili-cookie',
  'youtube.com': 'test-youtube-cookie',
  'example.com': 'test-other-cookie',
};

const _longFileName =
    'browser-cookies-export-with-an-extraordinarily-long-filename-for-testing.txt';
const _windowsCookiePath =
    r'C:\Users\Example\Documents\Browser Profiles\Exports\'
    '$_longFileName';
const _linuxCookiePath =
    '/home/example/Documents/browser-profiles/exported-cookies/$_longFileName';

enum _CookieAction {
  importFile,
  clearFile,
  loginBilibili,
  editBilibili,
  removeBilibili,
  loginYouTube,
  editYouTube,
  removeYouTube,
  addOther,
  clearAll,
}

class _CookieActions {
  final calls = <_CookieAction>[];
  late final callbacks = <_CookieAction, VoidCallback>{
    for (final action in _CookieAction.values) action: () => calls.add(action),
  };

  VoidCallback operator [](_CookieAction action) => callbacks[action]!;
}

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    for (final style in AppThemeStyle.values) {
      for (final brightness in Brightness.values) {
        testWidgets('${locale.languageCode} ${style.name} ${brightness.name} '
            'keeps all cookie actions reachable with large text', (
          tester,
        ) async {
          _useNarrowDisplay(tester);
          final actions = _CookieActions();
          final loc = AppLocalizations(locale);
          final cookieFilePath = brightness == Brightness.light
              ? _windowsCookiePath
              : _linuxCookiePath;

          await tester.pumpWidget(
            _app(
              locale: locale,
              style: style,
              brightness: brightness,
              cookies: _cookies,
              cookieFilePath: cookieFilePath,
              actions: actions,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(
            find.text('${loc.currentCookieFile}: $_longFileName'),
            findsOneWidget,
          );
          expect(find.text(loc.success), findsNWidgets(2));
          expect(find.text('3 Cookies'), findsOneWidget);

          for (final action in _CookieAction.values) {
            await _tapAction(tester, actions[action]);
            expect(actions.calls.last, action);
          }
          expect(actions.calls, _CookieAction.values);
        });
      }
    }
  }

  for (final style in AppThemeStyle.values) {
    testWidgets('${style.name} empty cookie state hides destructive actions '
        'and keeps setup controls usable', (tester) async {
      _useNarrowDisplay(tester);
      final actions = _CookieActions();
      final loc = AppLocalizations(const Locale('en'));
      await tester.pumpWidget(
        _app(
          locale: const Locale('en'),
          style: style,
          brightness: Brightness.light,
          cookies: const {},
          cookieFilePath: null,
          actions: actions,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(loc.noCookieFile), findsOneWidget);
      expect(find.text(loc.loginRequired), findsNWidgets(2));
      for (final action in [
        _CookieAction.clearFile,
        _CookieAction.removeBilibili,
        _CookieAction.removeYouTube,
        _CookieAction.clearAll,
      ]) {
        expect(_actionControl(actions[action]), findsNothing);
      }

      const setupActions = [
        _CookieAction.importFile,
        _CookieAction.loginBilibili,
        _CookieAction.editBilibili,
        _CookieAction.loginYouTube,
        _CookieAction.editYouTube,
        _CookieAction.addOther,
      ];
      for (final action in setupActions) {
        await _tapAction(tester, actions[action]);
      }
      expect(actions.calls, setupActions);
    });
  }
}

void _useNarrowDisplay(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _actionControl(VoidCallback callback) => find.byWidgetPredicate(
  (widget) =>
      (widget is ButtonStyleButton && widget.onPressed == callback) ||
      (widget is ListTile && widget.onTap == callback),
);

Future<void> _tapAction(WidgetTester tester, VoidCallback callback) async {
  final control = _actionControl(callback);
  expect(control, findsOneWidget);
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  expect(control.hitTestable(), findsOneWidget);
  await tester.tap(control);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Widget _app({
  required Locale locale,
  required AppThemeStyle style,
  required Brightness brightness,
  required Map<String, String> cookies,
  required String? cookieFilePath,
  required _CookieActions actions,
}) {
  return MaterialApp(
    theme: AppTheme.build(brightness: brightness, style: style),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) {
        final section = CookieSettingsSection(
          loc: AppLocalizations.of(context)!,
          cookies: cookies,
          cookieFilePath: cookieFilePath,
          onImportCookieFile: actions[_CookieAction.importFile],
          onClearCookieFile: actions[_CookieAction.clearFile],
          onLoginBilibili: actions[_CookieAction.loginBilibili],
          onLoginYouTube: actions[_CookieAction.loginYouTube],
          onEditBilibiliCookie: actions[_CookieAction.editBilibili],
          onEditYouTubeCookie: actions[_CookieAction.editYouTube],
          onRemoveBilibiliCookie: actions[_CookieAction.removeBilibili],
          onRemoveYouTubeCookie: actions[_CookieAction.removeYouTube],
          onAddOtherCookies: actions[_CookieAction.addOther],
          onClearAllCookies: actions[_CookieAction.clearAll],
        );
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: style == AppThemeStyle.liquidGlass
                  ? GlassCard(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: section,
                    )
                  : section,
            ),
          ),
        );
      },
    ),
  );
}
