import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidbee_flutter/core/models/models.dart';
import 'package:vidbee_flutter/core/providers/service_providers.dart';
import 'package:vidbee_flutter/core/services/services.dart';
import 'package:vidbee_flutter/features/download/add_url_dialog.dart';
import 'package:vidbee_flutter/main.dart';

const _shareChannel = MethodChannel('com.vidbee.share');
const _downloadPath = '/tmp/vidbee-share-test';
const _format = VideoFormat(
  formatId: 'test',
  ext: 'mp4',
  width: 640,
  height: 360,
);
const _videoInfo = VideoInfo(
  id: 'video',
  title: 'Shared video',
  formats: [_format],
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late List<String> pendingShares;
  late _FakeDownloads downloads;
  late _FakeExtractor extractor;

  setUp(() {
    pendingShares = [];
    downloads = _FakeDownloads();
    extractor = _FakeExtractor();
    SharedPreferences.setMockInitialValues({
      'download_path': _downloadPath,
      'language': 'en',
    });
    binding.defaultBinaryMessenger.setMockMethodCallHandler(_shareChannel, (
      call,
    ) async {
      expect(call.method, 'takeSharedTexts');
      final texts = List.of(pendingShares);
      pendingShares.clear();
      return texts;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _shareChannel,
      null,
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          downloadServiceProvider.overrideWithValue(downloads),
          ytDlpServiceProvider.overrideWithValue(extractor),
        ],
        child: const VidBeeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> notifyShare(Iterable<String> texts) async {
    pendingShares.addAll(texts);
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      _shareChannel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('shareReceived'),
      ),
      (_) {},
    );
  }

  testWidgets(
    'cold share prefills the dialog and uses the normal download flow',
    (tester) async {
      const url = 'https://youtu.be/123';
      pendingShares.add('Shared video: $url');
      await pumpApp(tester);

      expect(find.byType(AddUrlDialog), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).autofocus,
        isFalse,
      );
      expect(find.text(url), findsOneWidget);
      expect(extractor.requests, isEmpty);
      expect(downloads.tasks, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Parse'));
      await tester.pumpAndSettle();
      expect(extractor.requests, [url]);
      expect(find.text(_videoInfo.title), findsOneWidget);
      expect(downloads.tasks, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Download'));
      await tester.pumpAndSettle();
      expect(find.byType(AddUrlDialog), findsNothing);
      final task = downloads.tasks.single;
      expect(task.url, url);
      expect(task.downloadPath, _downloadPath);
      expect(task.selectedFormat, _format);
    },
  );

  testWidgets('warm shares wait for an open dialog and import in order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpApp(tester);
    await tester.tap(find.text('Add download'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'manual draft');

    const first = 'https://b23.tv/first';
    const second = 'https://example.com/second';
    await notifyShare(['标题 $first。', second]);
    await tester.pumpAndSettle();
    expect(find.byType(AddUrlDialog), findsOneWidget);
    expect(find.text('manual draft'), findsOneWidget);

    for (final url in [first, second]) {
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AddUrlDialog), findsOneWidget);
      expect(find.text(url), findsOneWidget);
    }

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    await notifyShare([]);
    await tester.pumpAndSettle();
    expect(find.byType(AddUrlDialog), findsNothing);
  });

  testWidgets('non-link text shows a message without opening a dialog', (
    tester,
  ) async {
    await pumpApp(tester);
    await notifyShare(['Only a title']);
    await tester.pumpAndSettle();

    expect(find.byType(AddUrlDialog), findsNothing);
    expect(
      find.text('The shared text does not contain a video link.'),
      findsOneWidget,
    );
    expect(extractor.requests, isEmpty);
  });
}

class _FakeExtractor implements YtDlpService {
  final requests = <String>[];

  @override
  Future<VideoInfo?> getVideoInfo(String url, {String? customUA}) async {
    requests.add(url);
    return _videoInfo;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloads implements DownloadService {
  final tasks = <DownloadTask>[];

  @override
  Future<void> initialize() async {}

  @override
  List<DownloadTask> getAllTasks() => List.of(tasks);

  @override
  Future<DownloadTask> addTask({
    required String url,
    DownloadType type = DownloadType.video,
    VideoFormat? selectedFormat,
    String? title,
    String? thumbnail,
    String? channel,
    String? duration,
    int? fileSize,
    String? downloadPath,
  }) async {
    final task = DownloadTask(
      id: 'shared-video',
      url: url,
      type: type,
      title: title,
      status: DownloadStatus.pending,
      createdAt: 0,
      selectedFormat: selectedFormat,
      downloadPath: downloadPath,
    );
    tasks.add(task);
    return task;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
