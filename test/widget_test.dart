// This is a basic Flutter widget test for VidBee

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vidbee_flutter/main.dart';

void main() {
  testWidgets('App startup smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: VidBeeApp(),
      ),
    );

    // Verify that our app starts correctly
    expect(find.text('VidBee'), findsOneWidget);
    expect(find.text('下载'), findsOneWidget);
    expect(find.text('历史'), findsOneWidget);
    expect(find.text('订阅'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
