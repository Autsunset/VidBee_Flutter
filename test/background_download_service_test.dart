import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidbee_flutter/core/services/background_download_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.vidbee.background_download');
  late List<String> calls;

  setUp(() {
    calls = [];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return null;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    channel.setMethodCallHandler(null);
  });

  test(
    'shares one foreground service until the last task releases it',
    () async {
      final service = BackgroundDownloadService(isAndroid: true);

      await Future.wait([service.acquire('a'), service.acquire('b')]);
      await service.acquire('a');
      expect(calls, ['start']);

      await service.release('a');
      await service.release('a');
      expect(calls, ['start']);

      await service.release('b');
      expect(calls, ['start', 'stop']);
    },
  );

  test('waits for native startup and serializes a concurrent stop', () async {
    final started = Completer<void>();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      if (call.method == 'start') await started.future;
      return null;
    });
    final service = BackgroundDownloadService(isAndroid: true);
    var acquired = false;
    final acquire = service.acquire('a').then((_) => acquired = true);
    final release = service.release('a');

    await Future<void>.delayed(Duration.zero);
    expect(acquired, isFalse);
    expect(calls, ['start']);

    started.complete();
    await Future.wait([acquire, release]);
    expect(acquired, isTrue);
    expect(calls, ['start', 'stop']);
  });

  test('startup failure is propagated and a later task can retry', () async {
    var failStart = true;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      if (call.method == 'start' && failStart) {
        throw PlatformException(code: 'BACKGROUND_START_FAILED');
      }
      return null;
    });
    final service = BackgroundDownloadService(isAndroid: true);
    await expectLater(service.acquire('a'), throwsA(isA<PlatformException>()));
    await service.release('a');
    expect(calls, ['start']);

    failStart = false;
    await service.acquire('b');
    await service.release('b');
    expect(calls, ['start', 'start', 'stop']);
  });

  test('queued restart runs after the previous stop', () async {
    final service = BackgroundDownloadService(isAndroid: true);
    await service.acquire('a');
    await Future.wait([service.release('a'), service.acquire('b')]);
    await service.release('b');
    expect(calls, ['start', 'stop', 'start', 'stop']);
  });

  test('non-Android platforms never invoke the foreground channel', () async {
    final service = BackgroundDownloadService(isAndroid: false);
    await service.acquire('a');
    await service.release('a');
    expect(calls, isEmpty);
  });

  test(
    'native timeout is reported and blocks new work until cleanup',
    () async {
      final service = BackgroundDownloadService(isAndroid: true);
      await service.acquire('a');
      final timeout = service.timeouts.first;
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onTimeout'),
        ),
        (_) {},
      );
      await timeout;
      await expectLater(
        service.acquire('b'),
        throwsA(isA<PlatformException>()),
      );
      await service.release('a');
      await service.acquire('b');
      await service.release('b');
      expect(calls, ['start', 'stop', 'start', 'stop']);
    },
  );
}
