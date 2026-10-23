import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/providers/appearance_provider.dart';
import 'package:vidbee_flutter/features/download/add_url_dialog.dart';
import 'package:vidbee_flutter/shared/i18n/app_localizations.dart';
import 'package:vidbee_flutter/shared/theme/app_theme.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${locale.languageCode} $brightness glass URL dialog fits above keyboard',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          tester.view.viewInsets = const FakeViewPadding(bottom: 220);
          tester.platformDispatcher.textScaleFactorTestValue = 1.6;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewInsets);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final loc = AppLocalizations(locale);

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: AppTheme.build(
                  brightness: brightness,
                  style: AppThemeStyle.liquidGlass,
                ),
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: Builder(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => const AddUrlDialog(),
                        ),
                        child: const Text('show'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('show'));
          await tester.pumpAndSettle();

          expect(find.byType(AddUrlDialog), findsOneWidget);
          expect(tester.takeException(), isNull);
          final cancel = find.widgetWithText(TextButton, loc.cancel);
          expect(cancel.hitTestable(), findsOneWidget);
          expect(tester.getBottomRight(cancel).dy, lessThanOrEqualTo(420));
          await tester.tap(cancel);
          await tester.pumpAndSettle();
          expect(find.byType(AddUrlDialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
