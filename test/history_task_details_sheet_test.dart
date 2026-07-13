import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/models/download_task.dart';
import 'package:vidbee_flutter/features/history/history_page.dart';
import 'package:vidbee_flutter/shared/i18n/app_localizations.dart';

void main() {
  testWidgets(
    'TaskDetailsBottomSheet keeps open/share/close visible for long title',
    (tester) async {
      // Compact phone-like viewport where long content used to clip actions.
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final longTitle = List.filled(40, '很长的视频标题用来测试底部按钮是否被顶出').join(' ');
      final task = DownloadTask(
        id: 't1',
        url: 'https://example.com/watch?v=abcdefg&extra=${'x' * 120}',
        title: longTitle,
        type: DownloadType.video,
        status: DownloadStatus.completed,
        createdAt: DateTime(2026, 7, 13, 12, 30, 0).millisecondsSinceEpoch,
        completedAt: DateTime(2026, 7, 13, 12, 35, 0).millisecondsSinceEpoch,
        duration: 125,
        fileSize: 1024 * 1024 * 12,
        downloadPath: '/storage/emulated/0/Download/${'path/' * 20}video.mp4',
        savedFileName: 'video.mp4',
      );

      final loc = AppLocalizations(const Locale('zh'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => TaskDetailsBottomSheet(
                          task: task,
                          loc: loc,
                          onRetry: () {},
                          onOpen: () {},
                          onShare: () {},
                        ),
                      );
                    },
                    child: const Text('open-sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-sheet'));
      await tester.pumpAndSettle();

      final openFinder = find.text(loc.open);
      final shareFinder = find.text(loc.share);
      final closeFinder = find.text(loc.close);

      expect(openFinder, findsOneWidget);
      expect(shareFinder, findsOneWidget);
      expect(closeFinder, findsOneWidget);

      // All three action labels must be fully on-screen (not clipped off-bottom).
      final screen = tester.getRect(find.byType(MaterialApp));
      for (final finder in [openFinder, shareFinder, closeFinder]) {
        final rect = tester.getRect(finder);
        expect(rect.bottom, lessThanOrEqualTo(screen.bottom + 0.5));
        expect(rect.top, greaterThanOrEqualTo(screen.top - 0.5));
      }

      // Buttons remain tappable.
      await tester.tap(openFinder);
      await tester.tap(shareFinder);
      await tester.tap(closeFinder);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('TaskDetailsBottomSheet shows time/duration/size correctly', (
    tester,
  ) async {
    final task = DownloadTask(
      id: 't2',
      url: 'https://b23.tv/abc',
      title: '测试视频',
      type: DownloadType.video,
      status: DownloadStatus.completed,
      createdAt: DateTime(2026, 7, 13, 12, 0, 0).millisecondsSinceEpoch,
      completedAt: DateTime(2026, 7, 13, 12, 22, 25).millisecondsSinceEpoch,
      duration: 65,
      fileSize: 2048,
      downloadPath: '/storage/emulated/0/Download/VidBee_测试视频.mp4',
      savedFileName: 'VidBee_测试视频.mp4',
    );
    final loc = AppLocalizations(const Locale('zh'));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TaskDetailsBottomSheet(
            task: task,
            loc: loc,
            onRetry: () {},
            onOpen: () {},
            onShare: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026/07/13 12:22:25'), findsOneWidget);
    expect(find.text('01:05'), findsOneWidget);
    expect(find.text('2.0 KB'), findsOneWidget);
    expect(find.text('VidBee_测试视频.mp4'), findsOneWidget);
    expect(
      find.text('/storage/emulated/0/Download/VidBee_测试视频.mp4'),
      findsOneWidget,
    );
    // 不应出现 epoch 0 的 1970 显示
    expect(find.textContaining('1970'), findsNothing);
  });

  testWidgets('TaskDetailsBottomSheet hides invalid zero metadata', (
    tester,
  ) async {
    final task = DownloadTask(
      id: 't3',
      url: 'https://example.com/v',
      title: '无元数据',
      type: DownloadType.video,
      status: DownloadStatus.completed,
      createdAt: 0,
      completedAt: 0,
      duration: 0,
      fileSize: 0,
      downloadPath: '/storage/emulated/0/Download',
      savedFileName: 'VidBee_x.mp4',
    );
    final loc = AppLocalizations(const Locale('zh'));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TaskDetailsBottomSheet(
            task: task,
            loc: loc,
            onRetry: () {},
            onOpen: () {},
            onShare: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1970'), findsNothing);
    expect(find.text('00:00'), findsNothing);
    expect(find.text('0 B'), findsNothing);
    expect(find.text('0B'), findsNothing);
    expect(find.text(loc.downloadedTime), findsNothing);
  });
}
