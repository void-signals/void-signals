import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_signals_flutter/void_signals_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleSignal', () {
    test('should create with initial resumed state', () {
      final lifecycle = appLifecycleSignal();
      // Default state when no lifecycle events have occurred
      expect(lifecycle.state, isNotNull);
      expect(lifecycle.value, isA<AppLifecycleState>());
      lifecycle.dispose();
    });

    test('should provide convenience getters', () {
      final lifecycle = appLifecycleSignal();
      // These should not throw
      expect(lifecycle.isResumed, isA<bool>());
      expect(lifecycle.isPaused, isA<bool>());
      expect(lifecycle.isInactive, isA<bool>());
      lifecycle.dispose();
    });

    test('should dispose properly', () {
      final lifecycle = appLifecycleSignal();
      lifecycle.dispose();
      // Double dispose should not throw
      lifecycle.dispose();
    });
  });

  group('IntervalSignal', () {
    test('should create and start immediately by default', () async {
      final interval = intervalSignal(const Duration(milliseconds: 50));
      expect(interval.value, equals(0));

      await Future.delayed(const Duration(milliseconds: 120));
      expect(interval.value, greaterThanOrEqualTo(2));
      interval.dispose();
    });

    test('should not start immediately when specified', () async {
      final interval = intervalSignal(
        const Duration(milliseconds: 50),
        startImmediately: false,
      );
      expect(interval.isRunning, isFalse);
      expect(interval.value, equals(0));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(interval.value, equals(0));

      interval.start();
      await Future.delayed(const Duration(milliseconds: 120));
      expect(interval.value, greaterThanOrEqualTo(2));
      interval.dispose();
    });

    test('should pause and resume', () async {
      final interval = intervalSignal(const Duration(milliseconds: 50));

      await Future.delayed(const Duration(milliseconds: 120));
      final countBeforePause = interval.value;
      expect(countBeforePause, greaterThanOrEqualTo(2));

      interval.pause();
      expect(interval.isPaused, isTrue);
      expect(interval.isRunning, isFalse);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(interval.value, equals(countBeforePause));

      interval.resume();
      expect(interval.isPaused, isFalse);
      expect(interval.isRunning, isTrue);

      await Future.delayed(const Duration(milliseconds: 120));
      expect(interval.value, greaterThan(countBeforePause));
      interval.dispose();
    });

    test('should reset count', () async {
      final interval = intervalSignal(const Duration(milliseconds: 50));

      await Future.delayed(const Duration(milliseconds: 120));
      expect(interval.value, greaterThan(0));

      interval.reset();
      expect(interval.value, equals(0));
      interval.dispose();
    });

    test('should restart', () async {
      final interval = intervalSignal(const Duration(milliseconds: 50));

      await Future.delayed(const Duration(milliseconds: 120));
      expect(interval.value, greaterThan(0));

      interval.restart();
      expect(interval.value, equals(0));

      await Future.delayed(const Duration(milliseconds: 120));
      expect(interval.value, greaterThan(0));
      interval.dispose();
    });

    test('should expose count signal', () {
      final interval = intervalSignal(const Duration(milliseconds: 100));
      expect(interval.count, isA<Signal<int>>());
      interval.dispose();
    });

    test('should dispose properly', () async {
      final interval = intervalSignal(const Duration(milliseconds: 50));
      await Future.delayed(const Duration(milliseconds: 100));

      interval.dispose();
      final countAtDispose = interval.value;

      await Future.delayed(const Duration(milliseconds: 100));
      expect(interval.value, equals(countAtDispose));

      // Double dispose should not throw
      interval.dispose();
    });

    test('should trigger effect on tick', () async {
      final interval = intervalSignal(const Duration(milliseconds: 50));
      var effectCount = 0;

      final eff = effect(() {
        interval.count.value;
        effectCount++;
      });

      await Future.delayed(const Duration(milliseconds: 120));
      expect(effectCount, greaterThanOrEqualTo(2));

      eff.stop();
      interval.dispose();
    });
  });

  group('CountdownSignal', () {
    test('should create with initial duration', () {
      final countdown = countdownSignal(const Duration(seconds: 10));
      expect(countdown.remaining.value, equals(const Duration(seconds: 10)));
      expect(countdown.isFinished.value, isFalse);
      expect(countdown.isRunning.value, isFalse);
      countdown.dispose();
    });

    test('should start automatically when specified', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 150),
        interval: const Duration(milliseconds: 50),
        startImmediately: true,
      );

      expect(countdown.isRunning.value, isTrue);

      await Future.delayed(const Duration(milliseconds: 200));
      expect(countdown.isFinished.value, isTrue);
      expect(countdown.remaining.value, equals(Duration.zero));
      countdown.dispose();
    });

    test('should countdown when started', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 200),
        interval: const Duration(milliseconds: 50),
      );

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 120));

      expect(countdown.remaining.value.inMilliseconds, lessThan(200));
      countdown.dispose();
    });

    test('should pause and resume', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 500),
        interval: const Duration(milliseconds: 50),
      );

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 100));

      countdown.pause();
      expect(countdown.isRunning.value, isFalse);
      final remainingAtPause = countdown.remaining.value;

      await Future.delayed(const Duration(milliseconds: 100));
      expect(countdown.remaining.value, equals(remainingAtPause));

      countdown.resume();
      expect(countdown.isRunning.value, isTrue);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(countdown.remaining.value.inMilliseconds,
          lessThan(remainingAtPause.inMilliseconds));
      countdown.dispose();
    });

    test('should reset to initial duration', () async {
      final countdown = countdownSignal(
        const Duration(seconds: 10),
        interval: const Duration(milliseconds: 50),
      );

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(countdown.remaining.value.inSeconds, lessThan(10));

      countdown.reset();
      expect(countdown.remaining.value, equals(const Duration(seconds: 10)));
      expect(countdown.isFinished.value, isFalse);
      expect(countdown.isRunning.value, isFalse);
      countdown.dispose();
    });

    test('should restart', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 200),
        interval: const Duration(milliseconds: 50),
      );

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 100));

      countdown.restart();
      expect(
          countdown.remaining.value, equals(const Duration(milliseconds: 200)));
      expect(countdown.isRunning.value, isTrue);
      countdown.dispose();
    });

    test('should add time', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 100),
        interval: const Duration(milliseconds: 50),
      );

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 200));
      expect(countdown.isFinished.value, isTrue);

      countdown.addTime(const Duration(milliseconds: 200));
      expect(countdown.remaining.value.inMilliseconds, greaterThan(0));
      expect(countdown.isFinished.value, isFalse);
      countdown.dispose();
    });

    test('should calculate progress', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 200),
        interval: const Duration(milliseconds: 50),
      );

      expect(countdown.progress, closeTo(0.0, 0.01));

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(countdown.progress, greaterThan(0.0));
      expect(countdown.progress, lessThan(1.0));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(countdown.progress, closeTo(1.0, 0.01));
      countdown.dispose();
    });

    test('should provide remainingSeconds', () {
      final countdown = countdownSignal(const Duration(seconds: 30));
      expect(countdown.remainingSeconds, equals(30));
      countdown.dispose();
    });

    test('should call onFinished callback', () async {
      var finishedCalled = false;
      final countdown = countdownSignal(
        const Duration(milliseconds: 100),
        interval: const Duration(milliseconds: 50),
        onFinished: () {
          finishedCalled = true;
        },
      );

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(finishedCalled, isTrue);
      countdown.dispose();
    });

    test('should not start when already running', () async {
      final countdown = countdownSignal(
        const Duration(seconds: 10),
        interval: const Duration(milliseconds: 50),
      );

      countdown.start();
      countdown.start(); // Should not restart

      expect(countdown.isRunning.value, isTrue);
      countdown.dispose();
    });

    test('should dispose properly', () {
      final countdown = countdownSignal(const Duration(seconds: 10));
      countdown.start();
      countdown.dispose();
      // Double dispose should not throw
      countdown.dispose();
    });
  });

  group('StopwatchSignal', () {
    test('should create with zero elapsed time', () {
      final stopwatch = stopwatchSignal();
      expect(stopwatch.elapsed.value, equals(Duration.zero));
      expect(stopwatch.isRunning.value, isFalse);
      stopwatch.dispose();
    });

    test('should start and track time', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      stopwatch.start();
      expect(stopwatch.isRunning.value, isTrue);

      await Future.delayed(const Duration(milliseconds: 200));
      expect(stopwatch.elapsed.value.inMilliseconds, greaterThan(100));
      stopwatch.dispose();
    });

    test('should stop', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      stopwatch.start();
      await Future.delayed(const Duration(milliseconds: 100));

      stopwatch.stop();
      expect(stopwatch.isRunning.value, isFalse);

      final elapsedAtStop = stopwatch.elapsed.value;
      await Future.delayed(const Duration(milliseconds: 100));

      // Elapsed time should be very close (within update interval)
      expect(
        (stopwatch.elapsed.value - elapsedAtStop).inMilliseconds.abs(),
        lessThanOrEqualTo(100),
      );
      stopwatch.dispose();
    });

    test('should reset', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      stopwatch.start();
      await Future.delayed(const Duration(milliseconds: 100));

      stopwatch.reset();
      expect(stopwatch.elapsed.value, equals(Duration.zero));
      stopwatch.dispose();
    });

    test('should restart', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      stopwatch.start();
      await Future.delayed(const Duration(milliseconds: 100));

      stopwatch.restart();
      expect(stopwatch.elapsed.value.inMilliseconds, lessThan(50));
      expect(stopwatch.isRunning.value, isTrue);
      stopwatch.dispose();
    });

    test('should record lap times', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      stopwatch.start();
      await Future.delayed(const Duration(milliseconds: 100));

      final lap1 = stopwatch.lap();
      expect(lap1.inMilliseconds, greaterThan(50));

      await Future.delayed(const Duration(milliseconds: 100));
      final lap2 = stopwatch.lap();
      expect(lap2.inMilliseconds, greaterThan(lap1.inMilliseconds));
      stopwatch.dispose();
    });

    test('should not start when already running', () async {
      final stopwatch = stopwatchSignal();

      stopwatch.start();
      stopwatch.start(); // Should not restart

      expect(stopwatch.isRunning.value, isTrue);
      stopwatch.dispose();
    });

    test('should dispose properly', () {
      final stopwatch = stopwatchSignal();
      stopwatch.start();
      stopwatch.dispose();
      // Double dispose should not throw
      stopwatch.dispose();
    });
  });

  group('FrameSignal', () {
    testWidgets('should update on each frame', (tester) async {
      final frame = frameSignal();

      await tester.pump(const Duration(milliseconds: 100));

      expect(frame.elapsed.value.inMilliseconds, greaterThanOrEqualTo(0));
      expect(frame.frameCount.value, greaterThanOrEqualTo(0));
      frame.dispose();
    });

    testWidgets('should track frame count', (tester) async {
      final frame = frameSignal();

      final initialCount = frame.frameCount.value;
      await tester.pump(const Duration(milliseconds: 16)); // ~1 frame
      await tester.pump(const Duration(milliseconds: 16)); // ~1 frame

      expect(frame.frameCount.value, greaterThan(initialCount));
      frame.dispose();
    });

    testWidgets('should dispose properly', (tester) async {
      final frame = frameSignal();
      await tester.pump(const Duration(milliseconds: 50));

      frame.dispose();
      // Double dispose should not throw
      frame.dispose();
    });
  });

  group('ClockSignal', () {
    test('should create with current time', () {
      final clock = clockSignal();
      final now = DateTime.now();

      expect(clock.now.value.difference(now).inSeconds.abs(), lessThan(2));
      clock.dispose();
    });

    test('should update at specified interval', () async {
      final clock = clockSignal(
        updateInterval: const Duration(milliseconds: 100),
      );

      final initialTime = clock.now.value;
      await Future.delayed(const Duration(milliseconds: 250));

      expect(clock.now.value.isAfter(initialTime), isTrue);
      clock.dispose();
    });

    test('should trigger effect on update', () async {
      final clock = clockSignal(
        updateInterval: const Duration(milliseconds: 100),
      );

      var effectCount = 0;
      final eff = effect(() {
        clock.now.value;
        effectCount++;
      });

      await Future.delayed(const Duration(milliseconds: 350));
      expect(effectCount, greaterThanOrEqualTo(3));

      eff.stop();
      clock.dispose();
    });

    test('should dispose properly', () {
      final clock = clockSignal();
      clock.dispose();
      // Double dispose should not throw
      clock.dispose();
    });
  });

  group('Edge cases', () {
    test('IntervalSignal should handle very short intervals', () async {
      final interval = intervalSignal(const Duration(milliseconds: 10));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(interval.value, greaterThan(5));
      interval.dispose();
    });

    test('CountdownSignal should handle zero duration', () async {
      final countdown = countdownSignal(
        Duration.zero,
        interval: const Duration(milliseconds: 50),
        startImmediately: true,
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(countdown.isFinished.value, isTrue);
      countdown.dispose();
    });

    test('CountdownSignal should handle very long duration', () {
      final countdown = countdownSignal(const Duration(days: 365));
      expect(countdown.remaining.value.inDays, equals(365));
      expect(countdown.progress, closeTo(0.0, 0.01));
      countdown.dispose();
    });

    test('StopwatchSignal should handle rapid start/stop', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      for (int i = 0; i < 10; i++) {
        stopwatch.start();
        await Future.delayed(const Duration(milliseconds: 10));
        stopwatch.stop();
      }

      expect(stopwatch.elapsed.value.inMilliseconds, greaterThan(0));
      stopwatch.dispose();
    });

    test('Multiple timers should work independently', () async {
      final interval1 = intervalSignal(const Duration(milliseconds: 50));
      final interval2 = intervalSignal(const Duration(milliseconds: 100));

      await Future.delayed(const Duration(milliseconds: 250));

      // interval1 should tick more frequently
      expect(interval1.value, greaterThan(interval2.value));

      interval1.dispose();
      interval2.dispose();
    });
  });

  group('Reactivity', () {
    test('CountdownSignal remaining should trigger effects', () async {
      final countdown = countdownSignal(
        const Duration(milliseconds: 200),
        interval: const Duration(milliseconds: 50),
      );

      var effectCount = 0;
      final eff = effect(() {
        countdown.remaining.value;
        effectCount++;
      });

      countdown.start();
      await Future.delayed(const Duration(milliseconds: 250));

      expect(effectCount, greaterThan(2));

      eff.stop();
      countdown.dispose();
    });

    test('StopwatchSignal elapsed should trigger effects', () async {
      final stopwatch = stopwatchSignal(
        updateInterval: const Duration(milliseconds: 50),
      );

      var effectCount = 0;
      final eff = effect(() {
        stopwatch.elapsed.value;
        effectCount++;
      });

      stopwatch.start();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(effectCount, greaterThan(2));

      eff.stop();
      stopwatch.dispose();
    });
  });
}
