import 'dart:async';

import 'package:test/test.dart';
import 'package:void_signals/void_signals.dart';

void main() {
  group('Result', () {
    group('ResultData', () {
      test('should create a successful result', () {
        const result = ResultData(42);

        expect(result.hasValue, true);
        expect(result.hasError, false);
        expect(result.value, 42);
        expect(result.error, null);
        expect(result.stackTrace, null);
      });

      test('should map the value', () {
        const result = ResultData(10);
        final mapped = result.map((v) => v * 2);

        expect(mapped, isA<ResultData<int>>());
        expect((mapped as ResultData<int>).value, 20);
      });

      test('should not map error on success', () {
        const result = ResultData<int>(42);
        final mapped = result.mapError((e) => 'mapped');

        expect(mapped, same(result));
      });

      test('should return value with getOrElse', () {
        const result = ResultData(42);
        expect(result.getOrElse(0), 42);
      });

      test('should return value with getOrElseCompute', () {
        const result = ResultData(42);
        expect(result.getOrElseCompute(() => 0), 42);
      });

      test('should execute ifValue callback', () {
        const result = ResultData(42);
        int? captured;

        result.ifValue((v) => captured = v);
        expect(captured, 42);
      });

      test('should not execute ifError callback', () {
        const result = ResultData(42);
        var called = false;

        result.ifError((e, s) => called = true);
        expect(called, false);
      });

      test('should convert to AsyncDataLike', () {
        const result = ResultData(42);
        final asyncValue = result.toAsyncValue();

        expect(asyncValue, isA<AsyncDataLike<int>>());
        expect((asyncValue as AsyncDataLike<int>).value, 42);
      });
    });

    group('ResultError', () {
      test('should create an error result', () {
        final error = Exception('test error');
        final stack = StackTrace.current;
        final result = ResultError<int>(error, stack);

        expect(result.hasValue, false);
        expect(result.hasError, true);
        expect(result.error, error);
        expect(result.stackTrace, stack);
      });

      test('should throw when accessing value', () {
        final result = ResultError<int>(Exception('test'), StackTrace.current);

        expect(() => result.value, throwsStateError);
      });

      test('should map error to new error type', () {
        final result = ResultError<int>(Exception('test'), StackTrace.current);
        final mapped = result.map((v) => v * 2);

        expect(mapped, isA<ResultError<int>>());
        expect((mapped as ResultError).error, result.error);
      });

      test('should map error with mapError', () {
        final result =
            ResultError<int>(Exception('original'), StackTrace.current);
        final mapped = result.mapError((e) => Exception('mapped'));

        expect(mapped, isA<ResultError<int>>());
        expect((mapped as ResultError).error.toString(), contains('mapped'));
      });

      test('should return fallback with getOrElse', () {
        final result = ResultError<int>(Exception('test'), StackTrace.current);
        expect(result.getOrElse(42), 42);
      });

      test('should compute fallback with getOrElseCompute', () {
        final result = ResultError<int>(Exception('test'), StackTrace.current);
        expect(result.getOrElseCompute(() => 42), 42);
      });

      test('should not execute ifValue callback', () {
        final result = ResultError<int>(Exception('test'), StackTrace.current);
        var called = false;

        result.ifValue((v) => called = true);
        expect(called, false);
      });

      test('should execute ifError callback', () {
        final error = Exception('test error');
        final stack = StackTrace.current;
        final result = ResultError<int>(error, stack);

        Object? capturedError;
        StackTrace? capturedStack;

        result.ifError((e, s) {
          capturedError = e;
          capturedStack = s;
        });

        expect(capturedError, error);
        expect(capturedStack, stack);
      });

      test('should convert to AsyncErrorLike', () {
        final error = Exception('test');
        final stack = StackTrace.current;
        final result = ResultError<int>(error, stack);
        final asyncValue = result.toAsyncValue();

        expect(asyncValue, isA<AsyncErrorLike<int>>());
        final asyncError = asyncValue as AsyncErrorLike<int>;
        expect(asyncError.error, error);
        expect(asyncError.stackTrace, stack);
      });
    });
  });

  group('runGuarded', () {
    test('should return ResultData on success', () {
      final result = runGuarded(() => 42);

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData).value, 42);
    });

    test('should return ResultError on exception', () {
      final result = runGuarded<int>(() => throw Exception('test'));

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError).error, isA<Exception>());
    });

    test('should capture stack trace on exception', () {
      final result = runGuarded<int>(() => throw Exception('test'));

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError).stackTrace, isNotNull);
    });

    test('should handle null return value', () {
      final result = runGuarded<int?>(() => null);

      expect(result, isA<ResultData<int?>>());
      expect((result as ResultData).value, null);
    });
  });

  group('runGuardedAsync', () {
    test('should return ResultData on async success', () async {
      final result = await runGuardedAsync(() async {
        await Future.delayed(Duration.zero);
        return 42;
      });

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData).value, 42);
    });

    test('should return ResultError on async exception', () async {
      final result = await runGuardedAsync<int>(() async {
        await Future.delayed(Duration.zero);
        throw Exception('async error');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError).error, isA<Exception>());
    });

    test('should capture stack trace on async exception', () async {
      final result = await runGuardedAsync<int>(() async {
        throw Exception('test');
      });

      expect(result, isA<ResultError<int>>());
      expect((result as ResultError).stackTrace, isNotNull);
    });
  });

  group('RetryConfig', () {
    test('should have default values', () {
      const config = RetryConfig();

      expect(config.maxAttempts, 3);
      expect(config.baseDelay, const Duration(milliseconds: 100));
      expect(config.maxDelay, const Duration(seconds: 10));
      expect(config.exponentialBackoff, true);
      expect(config.jitter, 0.1);
      expect(config.shouldRetry, null);
    });

    test('should compute delay without backoff', () {
      const config = RetryConfig(
        baseDelay: Duration(milliseconds: 100),
        exponentialBackoff: false,
        jitter: 0,
      );

      expect(config.computeDelay(1), const Duration(milliseconds: 100));
      expect(config.computeDelay(2), const Duration(milliseconds: 100));
      expect(config.computeDelay(3), const Duration(milliseconds: 100));
    });

    test('should compute delay with exponential backoff', () {
      const config = RetryConfig(
        baseDelay: Duration(milliseconds: 100),
        exponentialBackoff: true,
        jitter: 0,
      );

      expect(config.computeDelay(1), const Duration(milliseconds: 100));
      expect(config.computeDelay(2), const Duration(milliseconds: 200));
      expect(config.computeDelay(3), const Duration(milliseconds: 400));
    });

    test('should cap delay at maxDelay', () {
      const config = RetryConfig(
        baseDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 2),
        exponentialBackoff: true,
        jitter: 0,
      );

      expect(config.computeDelay(1), const Duration(seconds: 1));
      expect(config.computeDelay(2), const Duration(seconds: 2));
      expect(config.computeDelay(3), const Duration(seconds: 2)); // Capped
      expect(config.computeDelay(10), const Duration(seconds: 2)); // Capped
    });

    test('should apply jitter', () {
      const config = RetryConfig(
        baseDelay: Duration(milliseconds: 1000),
        exponentialBackoff: false,
        jitter: 0.5, // 50% jitter
      );

      // Run multiple times to verify randomness
      final delays = <Duration>[];
      for (var i = 0; i < 10; i++) {
        delays.add(config.computeDelay(1));
      }

      // All delays should be >= base delay (jitter adds, doesn't subtract)
      for (final delay in delays) {
        expect(delay.inMilliseconds, greaterThanOrEqualTo(1000));
        expect(delay.inMilliseconds, lessThanOrEqualTo(1500));
      }
    });

    test('noRetry should have 0 attempts', () {
      expect(RetryConfig.noRetry.maxAttempts, 0);
    });
  });

  group('retry', () {
    test('should succeed on first attempt', () async {
      var attempts = 0;
      final result = await retry(
        () async {
          attempts++;
          return 42;
        },
        config: const RetryConfig(maxAttempts: 3),
      );

      expect(result, 42);
      expect(attempts, 1);
    });

    test('should retry on failure and succeed', () async {
      var attempts = 0;
      final result = await retry(
        () async {
          attempts++;
          if (attempts < 3) throw Exception('fail');
          return 42;
        },
        config: const RetryConfig(
          maxAttempts: 5,
          baseDelay: Duration(milliseconds: 1),
        ),
      );

      expect(result, 42);
      expect(attempts, 3);
    });

    test('should throw after max attempts', () async {
      expect(
        () async => await retry(
          () async {
            throw Exception('always fail');
          },
          config: const RetryConfig(
            maxAttempts: 3,
            baseDelay: Duration(milliseconds: 1),
          ),
        ),
        throwsException,
      );
    });

    test('should call onRetry callback', () async {
      final errors = <Object>[];
      final attemptNumbers = <int>[];

      try {
        await retry(
          () async => throw Exception('fail'),
          config: const RetryConfig(
            maxAttempts: 3,
            baseDelay: Duration(milliseconds: 1),
          ),
          onRetry: (error, attempt) {
            errors.add(error);
            attemptNumbers.add(attempt);
          },
        );
      } catch (_) {}

      expect(errors.length, 2); // Called on 1st and 2nd failure, not 3rd
      expect(attemptNumbers, [1, 2]);
    });

    test('should respect shouldRetry predicate', () async {
      var attempts = 0;

      try {
        await retry(
          () async {
            attempts++;
            throw Exception('fail');
          },
          config: RetryConfig(
            maxAttempts: 5,
            baseDelay: const Duration(milliseconds: 1),
            shouldRetry: (error, attempt) => attempt < 2,
          ),
        );
      } catch (_) {}

      expect(attempts, 2);
    });
  });

  group('retrySync', () {
    test('should succeed on first attempt', () {
      var attempts = 0;
      final result = retrySync(
        () {
          attempts++;
          return 42;
        },
        config: const RetryConfig(maxAttempts: 3),
      );

      expect(result, 42);
      expect(attempts, 1);
    });

    test('should retry on failure and succeed', () {
      var attempts = 0;
      final result = retrySync(
        () {
          attempts++;
          if (attempts < 3) throw Exception('fail');
          return 42;
        },
        config: const RetryConfig(maxAttempts: 5),
      );

      expect(result, 42);
      expect(attempts, 3);
    });

    test('should throw after max attempts', () {
      expect(
        () => retrySync(
          () {
            throw Exception('always fail');
          },
          config: const RetryConfig(maxAttempts: 3),
        ),
        throwsException,
      );
    });
  });

  group('AsyncState', () {
    test('should have all expected values', () {
      expect(AsyncState.values, [
        AsyncState.idle,
        AsyncState.loading,
        AsyncState.data,
        AsyncState.error,
        AsyncState.refreshing,
      ]);
    });
  });

  group('AsyncSignal', () {
    test('should start in idle state', () {
      final sig = AsyncSignal.lazy(fetch: () async => 42);

      expect(sig.state, AsyncState.idle);
      expect(sig.isLoading, false);
      expect(sig.hasData, false);
      expect(sig.hasError, false);
      expect(sig.data, null);
      expect(sig.error, null);
    });

    test('should auto-refresh when created with autoRefresh', () async {
      final sig = AsyncSignal.autoRefresh(fetch: () async => 42);

      // Wait for initial fetch
      await Future.delayed(const Duration(milliseconds: 50));

      expect(sig.state, AsyncState.data);
      expect(sig.data, 42);
    });

    test('should handle fetch errors', () async {
      var caughtError = false;
      final sig = AsyncSignal.lazy(
        fetch: () async => throw Exception('fetch error'),
        retryConfig: const RetryConfig(maxAttempts: 1), // Allow 1 attempt
      );

      try {
        await sig.refresh();
      } on Exception {
        caughtError = true;
      }

      expect(caughtError, isTrue);
      expect(sig.state, AsyncState.error);
      expect(sig.error, isA<Exception>());
    });

    test('should refresh data', () async {
      var counter = 0;
      final sig = AsyncSignal.lazy(fetch: () async => ++counter);

      await sig.refresh();
      expect(sig.data, 1);

      await sig.refresh();
      expect(sig.data, 2);
    });

    test('should show refreshing state when has existing data', () async {
      final completer = Completer<int>();
      final sig = AsyncSignal.lazy(fetch: () => completer.future);

      sig.setValue(42);
      expect(sig.state, AsyncState.data);

      final refreshFuture = sig.refresh();

      await Future.delayed(Duration.zero);
      expect(sig.state, AsyncState.refreshing);
      expect(sig.isLoading, true);

      completer.complete(100);
      await refreshFuture;

      expect(sig.state, AsyncState.data);
      expect(sig.data, 100);
    });

    test('should return pending operation if already loading', () async {
      var callCount = 0;
      final completer = Completer<int>();
      final sig = AsyncSignal.lazy(
        fetch: () {
          callCount++;
          return completer.future;
        },
      );

      // Start two refreshes
      final future1 = sig.refresh();
      final future2 = sig.refresh();

      expect(callCount, 1); // Only one call

      completer.complete(42);
      await Future.wait([future1, future2]);

      expect(sig.data, 42);
    });

    test('should set value directly', () {
      final sig = AsyncSignal.lazy(fetch: () async => 0);

      sig.setValue(100);

      expect(sig.state, AsyncState.data);
      expect(sig.data, 100);
      expect(sig.error, null);
    });

    test('should set error directly', () {
      final sig = AsyncSignal.lazy(fetch: () async => 0);

      sig.setError(Exception('manual error'));

      expect(sig.state, AsyncState.error);
      expect(sig.error, isA<Exception>());
      expect(sig.stackTrace, isNotNull);
    });

    test('should reset to idle state', () async {
      final sig = AsyncSignal.autoRefresh(fetch: () async => 42);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(sig.state, AsyncState.data);

      sig.reset();

      expect(sig.state, AsyncState.idle);
      expect(sig.data, null);
      expect(sig.error, null);
    });

    test('should throw when refreshing without fetch function', () {
      final sig = AsyncSignal.fromFuture(Future.value(42));

      expect(() => sig.refresh(), throwsStateError);
    });

    test('should create from future', () async {
      final sig = AsyncSignal.fromFuture(Future.value(42));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(sig.state, AsyncState.data);
      expect(sig.data, 42);
    });

    test('should create from stream', () async {
      final controller = StreamController<int>();
      final sig = AsyncSignal.fromStream(controller.stream);

      expect(sig.state, AsyncState.loading);

      controller.add(1);
      await Future.delayed(Duration.zero);
      expect(sig.data, 1);

      controller.add(2);
      await Future.delayed(Duration.zero);
      expect(sig.data, 2);

      controller.addError(Exception('stream error'));
      await Future.delayed(Duration.zero);
      expect(sig.state, AsyncState.error);

      await controller.close();
    });

    test('should provide reactive signals', () {
      final sig = AsyncSignal.lazy(fetch: () async => 42);

      expect(sig.stateSignal, isA<Signal<AsyncState>>());
      expect(sig.valueSignal, isA<Signal<int?>>());
      expect(sig.errorSignal, isA<Signal<Object?>>());

      expect(sig.stateSignal.value, AsyncState.idle);
    });

    test('should handle dispose', () {
      final sig = AsyncSignal.lazy(fetch: () async => 42);
      sig.dispose();
      // Should not throw after dispose
    });
  });

  group('SafeSignalExtension', () {
    test('tryRead should return ResultData on success', () {
      final s = signal(42);
      final result = s.tryRead();

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData).value, 42);
    });

    test('tryUpdate should return ResultData on success', () {
      final s = signal(0);
      final result = s.tryUpdate(42);

      expect(result, isA<ResultData<void>>());
      expect(s.value, 42);
    });

    test('updateSafe should call onError on failure', () {
      Object? capturedError;
      final s = signal(0);

      // Create an effect that will throw when signal changes
      var shouldThrow = false;
      effect(() {
        s.value;
        if (shouldThrow) throw Exception('effect error');
      });

      shouldThrow = true;
      s.updateSafe(42, onError: (e) => capturedError = e);

      expect(capturedError, isNotNull);
    });
  });

  group('SafeComputedExtension', () {
    test('tryRead should return ResultData on success', () {
      final a = signal(10);
      final c = computed((p) => a.value * 2);
      final result = c.tryRead();

      expect(result, isA<ResultData<int>>());
      expect((result as ResultData).value, 20);
    });

    test('tryRead should return ResultError on computation failure', () {
      final a = signal(true);
      final c = computed<int>((p) {
        if (a.value) throw Exception('computation error');
        return 42;
      });

      final result = c.tryRead();

      expect(result, isA<ResultError<int>>());
    });
  });
}
