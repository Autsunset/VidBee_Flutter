import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/providers/appearance_provider.dart';
import 'package:vidbee_flutter/shared/theme/app_theme.dart';
import 'package:vidbee_flutter/shared/widgets/glass_widgets.dart';

void main() {
  for (final brightness in Brightness.values) {
    test('Classic $brightness retains the original Material theme', () {
      final classic = AppTheme.build(
        brightness: brightness,
        style: AppThemeStyle.classic,
      );
      final original = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF9B61B),
          brightness: brightness,
        ),
      );

      expect(classic, original);
      expect(classic.extension<GlassTheme>(), isNull);
    });

    test('Glass $brightness provides a high-contrast body palette', () {
      final theme = AppTheme.build(
        brightness: brightness,
        style: AppThemeStyle.liquidGlass,
      );
      final background = theme.colorScheme.surface.computeLuminance();
      final foreground = theme.colorScheme.onSurface.computeLuminance();
      final lighter = background > foreground ? background : foreground;
      final darker = background > foreground ? foreground : background;

      expect(theme.extension<GlassTheme>(), isNotNull);
      expect((lighter + 0.05) / (darker + 0.05), greaterThan(7));
    });
  }

  testWidgets('Floating glass blur is clipped to the surface', (tester) async {
    await tester.pumpWidget(
      _app(
        child: const GlassSurface(
          padding: EdgeInsets.all(20),
          child: Text('Floating controls'),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(BackdropFilter),
        matching: find.byType(ClipRRect),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('List cards do not add a backdrop filter per row', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassCard(child: Text('Download one')),
            GlassCard(child: Text('Download two')),
          ],
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Download two'), findsOneWidget);
  });

  testWidgets('High contrast uses an opaque material without blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        highContrast: true,
        child: const GlassSurface(child: Text('Readable controls')),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
    final surface = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(ClipRRect),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = surface.decoration as BoxDecoration;
    expect(decoration.color?.a, 1);
    expect(decoration.gradient, isNull);
  });

  testWidgets('Glass surfaces respect reduced motion without ongoing tickers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        disableAnimations: true,
        child: const GlassSurface(child: Text('Still material')),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Switching the backdrop preserves state and pointer input', (
    tester,
  ) async {
    late StateSetter update;
    var enabled = true;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Theme(
              data: AppTheme.build(
                brightness: Brightness.light,
                style: enabled
                    ? AppThemeStyle.liquidGlass
                    : AppThemeStyle.classic,
              ),
              child: GlassBackdrop(
                enabled: enabled,
                child: const _StatefulContent(),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Count 0'));
    await tester.pump();
    expect(find.text('Count 1'), findsOneWidget);

    update(() => enabled = false);
    await tester.pump();
    expect(find.text('Count 1'), findsOneWidget);

    update(() => enabled = true);
    await tester.pump();
    await tester.tap(find.text('Count 1'));
    await tester.pump();
    expect(find.text('Count 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({
  required Widget child,
  bool highContrast = false,
  bool disableAnimations = false,
}) => MaterialApp(
  theme: AppTheme.build(
    brightness: Brightness.light,
    style: AppThemeStyle.liquidGlass,
  ),
  home: MediaQuery(
    data: MediaQueryData(
      highContrast: highContrast,
      disableAnimations: disableAnimations,
    ),
    child: Scaffold(body: Center(child: child)),
  ),
);

class _StatefulContent extends StatefulWidget {
  const _StatefulContent();

  @override
  State<_StatefulContent> createState() => _StatefulContentState();
}

class _StatefulContentState extends State<_StatefulContent> {
  var count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Center(
      child: TextButton(
        onPressed: () => setState(() => count++),
        child: Text('Count $count'),
      ),
    ),
  );
}
