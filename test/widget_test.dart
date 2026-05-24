// This is a basic Flutter widget test for VidBee

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vidbee_flutter/main.dart';

void main() {
  testWidgets('App startup smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VidBeeApp()));

    expect(find.text('下载'), findsWidgets);
    expect(find.text('历史'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
