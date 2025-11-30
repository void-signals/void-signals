import 'dart:async';

import 'package:test/test.dart';
import 'package:void_signals/void_signals.dart';

void main() {
  group('AsyncValue', () {
    test('loading state', () {
      const loading = AsyncLoading<int>();
      expect(loading.isLoading, isTrue);
      expect(loading.hasValue, isFalse);
      expect(loading.hasError, isFalse);
      expect(loading.valueOrNull, isNull);
    });

    test('data state', () {
      const data = AsyncData(42);
      expect(data.isLoading, isFalse);
      expect(data.hasValue, isTrue);
      expect(data.hasError, isFalse);
      expect(data.value, equals(42));
      expect(data.valueOrNull, equals(42));
      expect(data.requireValue, equals(42));
    });

    test('error state', () {
      final error = AsyncError<int>(Exception('test'), StackTrace.current);
      expect(error.isLoading, isFalse);
      expect(error.hasValue, isFalse);
      expect(error.hasError, isTrue);
      expect(error.error, isA<Exception>());
      expect(error.valueOrNull, isNull);
    });

    test('when pattern matching', () {
      const loading = AsyncLoading<int>();
      const data = AsyncData(42);
      final error = AsyncError<int>(Exception('test'), StackTrace.current);

      expect(
        loading.when(
          loading: () => 'loading',
          data: (v) => 'data: $v',
          error: (e, s) => 'error',
        ),
        equals('loading'),
      );

      expect(
        data.when(
          loading: () => 'loading',
          data: (v) => 'data: $v',
          error: (e, s) => 'error',
        ),
        equals('data: 42'),
      );

      expect(
        error.when(
          loading: () => 'loading',
          data: (v) => 'data: $v',
          error: (e, s) => 'error',
        ),
        equals('error'),
      );
    });

    test('map transforms data', () {
      const data = AsyncData(21);
      final mapped = data.map((v) => v * 2);
      expect(mapped, isA<AsyncData<int>>());
      expect((mapped as AsyncData).value, equals(42));
    });

    test('map preserves loading', () {
      const loading = AsyncLoading<int>();
      final mapped = loading.map((v) => v.toString());
      expect(mapped, isA<AsyncLoading<String>>());
    });

    test('map preserves error', () {
      final error = AsyncError<int>(Exception('test'), StackTrace.current);
      final mapped = error.map((v) => v.toString());
      expect(mapped, isA<AsyncError<String>>());
    });

    test('copyWithPrevious preserves value during loading', () {
      const previous = AsyncData(42);
      final loading = const AsyncLoading<int>().copyWithPrevious(previous);
      expect(loading, isA<AsyncLoadingWithPrevious<int>>());
      expect(loading.isLoading, isTrue);
      expect(loading.hasValue, isTrue);
      expect(loading.valueOrNull, equals(42));
    });

    test('guard catches errors', () {
      final result = AsyncValue.guard(() => throw Exception('test'));
      expect(result, isA<AsyncError>());
    });
  });

  group('AsyncComputed', () {
    test('basic async computation', () async {
      final userId = signal(1);
      final user = asyncComputed(() async {
        final id = userId(); // Read signal BEFORE await
        await Future.delayed(const Duration(milliseconds: 10));
        return 'User $id';
      });

      // Initially loading
      expect(user().isLoading, isTrue);

      // Wait for completion
      final result = await user.future;
      expect(result, equals('User 1'));
      expect(user().hasValue, isTrue);
      expect((user() as AsyncData).value, equals('User 1'));

      user.dispose();
    });

    test('re-computes when dependency changes', () async {
      final counter = signal(1);
      var computeCount = 0;

      final doubled = asyncComputed(() async {
        final value = counter(); // Read signal BEFORE await
        computeCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return value * 2;
      });

      // Initial computation - wait for it to complete
      final result1 = await doubled.future;
      expect(result1, equals(2));
      expect(computeCount, equals(1));
      expect(doubled.valueOrNull, equals(2));

      // Change dependency
      counter.value = 5;
      // Allow the effect to be scheduled
      await Future.microtask(() {});

      // Wait for re-computation to complete (effect triggers, then async work)
      await Future.delayed(const Duration(milliseconds: 50));

      final result2 = await doubled.future;
      expect(result2, equals(10));
      expect(computeCount, equals(2));
      expect(doubled.valueOrNull, equals(10));

      doubled.dispose();
    });

    test('cancels previous computation when dependency changes', () async {
      final input = signal(1);
      var completedWithValue = <int>[];

      final computed = asyncComputed(() async {
        final value = input(); // Read signal BEFORE await
        await Future.delayed(const Duration(milliseconds: 50));
        completedWithValue.add(value);
        return value;
      });

      // Start first computation
      await Future.delayed(const Duration(milliseconds: 10));

      // Change input before first computation completes
      input.value = 2;
      await Future.delayed(const Duration(milliseconds: 10));

      // Change again
      input.value = 3;

      // Wait for final result (need enough time for the computation)
      await Future.delayed(const Duration(milliseconds: 100));
      final result = await computed.future;
      expect(result, equals(3));

      // Only the last computation should have updated the state
      expect(computed.valueOrNull, equals(3));

      computed.dispose();
    });

    test('handles errors', () async {
      final shouldFail = signal(true);
      final computed = asyncComputed(() async {
        final fail = shouldFail(); // Read signal BEFORE await
        await Future.delayed(const Duration(milliseconds: 10));
        if (fail) {
          throw Exception('Intentional failure');
        }
        return 'success';
      });

      // Wait for error - use try/catch since future will throw
      try {
        await computed.future;
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      expect(computed().hasError, isTrue);
      expect(computed().errorOrNull, isA<Exception>());

      // Fix the error
      shouldFail.value = false;

      // Wait for recomputation
      await Future.delayed(const Duration(milliseconds: 50));
      final result = await computed.future;
      expect(result, equals('success'));

      computed.dispose();
    });

    test('chained async dependencies', () async {
      final userId = signal(1);

      // First async computed
      final user = asyncComputed(() async {
        final id = userId(); // Read signal BEFORE await
        await Future.delayed(const Duration(milliseconds: 10));
        return {'id': id, 'name': 'User $id'};
      });

      // Second async computed that depends on the first
      final userPosts = asyncComputed(() async {
        final userData = await user.future;
        await Future.delayed(const Duration(milliseconds: 10));
        return ['Post by ${userData['name']}'];
      });

      // Wait for both to complete
      final posts = await userPosts.future;
      expect(posts, equals(['Post by User 1']));

      // Change userId - this triggers user to re-compute
      userId.value = 2;

      // Wait for user to start recomputing
      await Future.delayed(const Duration(milliseconds: 5));

      // Trigger userPosts to re-fetch (it depends on user.future)
      userPosts.refresh();

      final newPosts = await userPosts.future;
      expect(newPosts, equals(['Post by User 2']));

      user.dispose();
      userPosts.dispose();
    });

    test('refresh forces re-computation', () async {
      var counter = 0;
      final computed = asyncComputed(() async {
        counter++;
        await Future.delayed(const Duration(milliseconds: 10));
        return counter;
      });

      await computed.future;
      expect(computed.valueOrNull, equals(1));

      computed.refresh();
      await Future.delayed(const Duration(milliseconds: 50));
      final result = await computed.future;
      expect(result, equals(2));
      expect(computed.valueOrNull, equals(2));

      computed.dispose();
    });

    test('preserves previous value during loading', () async {
      final input = signal(1);
      final computed = asyncComputed(() async {
        final value = input(); // Read signal BEFORE await
        await Future.delayed(const Duration(milliseconds: 50));
        return value * 10;
      });

      // Wait for initial value
      await computed.future;
      expect(computed.valueOrNull, equals(10));

      // Trigger re-computation
      input.value = 2;

      // Give a little time for effect to trigger but not complete
      await Future.delayed(const Duration(milliseconds: 10));

      // Should be loading but still have previous value
      final state = computed();
      expect(state.isLoading, isTrue);
      expect(state.hasValue, isTrue);
      expect(state.valueOrNull, equals(10));

      // Wait for new value
      await Future.delayed(const Duration(milliseconds: 100));
      await computed.future;
      expect(computed.valueOrNull, equals(20));

      computed.dispose();
    });
  });

  group('StreamComputed', () {
    test('basic stream subscription', () async {
      final controller = StreamController<int>.broadcast();
      final stream = streamComputed(() => controller.stream);

      // Initially loading
      expect(stream().isLoading, isTrue);

      // Emit value
      controller.add(42);
      await Future.delayed(const Duration(milliseconds: 20));

      expect(stream().hasValue, isTrue);
      expect(stream.valueOrNull, equals(42));

      // Emit another value
      controller.add(100);
      await Future.delayed(const Duration(milliseconds: 20));
      expect(stream.valueOrNull, equals(100));

      stream.dispose();
      await controller.close();
    });

    test('re-subscribes when dependency changes', () async {
      final roomId = signal('room1');

      Stream<String> createStream(String id) async* {
        await Future.delayed(const Duration(milliseconds: 10));
        yield 'Message from $id';
      }

      final messages = streamComputed(() {
        final id = roomId(); // Read signal in sync part
        return createStream(id);
      });

      await Future.delayed(const Duration(milliseconds: 50));
      expect(messages.valueOrNull, equals('Message from room1'));

      // Change room
      roomId.value = 'room2';
      await Future.delayed(const Duration(milliseconds: 50));
      expect(messages.valueOrNull, equals('Message from room2'));

      messages.dispose();
    });

    test('handles stream errors', () async {
      final shouldFail = signal(true);

      Stream<int> createStream(bool fail) async* {
        await Future.delayed(const Duration(milliseconds: 10));
        if (fail) {
          throw Exception('Stream error');
        }
        yield 42;
      }

      final stream = streamComputed(() {
        final fail = shouldFail(); // Read signal in sync part
        return createStream(fail);
      });
      await Future.delayed(const Duration(milliseconds: 50));

      expect(stream().hasError, isTrue);

      stream.dispose();
    });
  });

  group('combineAsync', () {
    test('combines multiple data states', () {
      final a = const AsyncData(1);
      final b = const AsyncData('hello');
      final c = const AsyncData(true);

      final combined = combineAsync<List<Object?>>(
        [a, b, c],
        (values) => values,
      );

      expect(combined.hasValue, isTrue);
      expect((combined as AsyncData).value, equals([1, 'hello', true]));
    });

    test('returns loading if any is loading', () {
      final a = const AsyncData(1);
      final b = const AsyncLoading<String>();
      final c = const AsyncData(true);

      final combined = combineAsync<List<Object?>>(
        [a, b, c],
        (values) => values,
      );

      expect(combined.isLoading, isTrue);
    });

    test('returns error if any has error', () {
      final a = const AsyncData(1);
      final b = AsyncError<String>(Exception('test'), StackTrace.current);
      final c = const AsyncData(true);

      final combined = combineAsync<List<Object?>>(
        [a, b, c],
        (values) => values,
      );

      expect(combined.hasError, isTrue);
    });
  });

  group('AsyncValue edge cases', () {
    test('AsyncLoadingWithPrevious properties', () {
      const previous = AsyncLoadingWithPrevious<int>(42);
      expect(previous.isLoading, isTrue);
      expect(previous.hasValue, isTrue);
      expect(previous.hasError, isFalse);
      expect(previous.valueOrNull, equals(42));
      expect(previous.requireValue, equals(42));
      expect(previous.toString(), contains('42'));
    });

    test('AsyncErrorWithPrevious properties', () {
      final error = AsyncErrorWithPrevious<int>(
        Exception('test'),
        StackTrace.current,
        42,
      );
      expect(error.isLoading, isFalse);
      expect(error.hasValue, isTrue);
      expect(error.hasError, isTrue);
      expect(error.valueOrNull, equals(42));
      expect(error.errorOrNull, isA<Exception>());
      expect(error.stackTraceOrNull, isNotNull);
      expect(error.toString(), contains('42'));
    });

    test('maybeWhen with all handlers', () {
      const data = AsyncData(42);
      final result = data.maybeWhen(
        data: (v) => 'data: $v',
        orElse: () => 'fallback',
      );
      expect(result, equals('data: 42'));
    });

    test('maybeWhen with orElse fallback', () {
      const loading = AsyncLoading<int>();
      final result = loading.maybeWhen(
        data: (v) => 'data: $v',
        orElse: () => 'fallback',
      );
      expect(result, equals('fallback'));
    });

    test('flatMap transforms data', () {
      const data = AsyncData(21);
      final mapped = data.flatMap((v) => AsyncData(v * 2));
      expect(mapped, isA<AsyncData<int>>());
      expect((mapped as AsyncData).value, equals(42));
    });

    test('flatMap with loading state', () {
      const loading = AsyncLoading<int>();
      final mapped = loading.flatMap((v) => AsyncData(v * 2));
      expect(mapped, isA<AsyncLoading<int>>());
    });

    test('flatMap with LoadingWithPrevious', () {
      const loadingWithPrevious = AsyncLoadingWithPrevious<int>(10);
      final mapped = loadingWithPrevious.flatMap((v) => AsyncData(v * 2));
      expect(mapped, isA<AsyncData<int>>());
      expect((mapped as AsyncData).value, equals(20));
    });

    test('getOrElse returns value or fallback', () {
      const data = AsyncData(42);
      const loading = AsyncLoading<int>();
      expect(data.getOrElse(0), equals(42));
      expect(loading.getOrElse(0), equals(0));
    });

    test('getOrElseCompute computes fallback lazily', () {
      const loading = AsyncLoading<int>();
      var computed = false;
      final result = loading.getOrElseCompute(() {
        computed = true;
        return 99;
      });
      expect(result, equals(99));
      expect(computed, isTrue);
    });

    test('requireValue throws on loading', () {
      const loading = AsyncLoading<int>();
      expect(() => loading.requireValue, throwsStateError);
    });

    test('requireValue rethrows on error', () {
      final error = AsyncError<int>(Exception('test'), StackTrace.current);
      expect(() => error.requireValue, throwsException);
    });

    test('map with LoadingWithPrevious transforms previous value', () {
      const loadingWithPrevious = AsyncLoadingWithPrevious<int>(10);
      final mapped = loadingWithPrevious.map((v) => v * 2);
      expect(mapped, isA<AsyncLoadingWithPrevious<int>>());
      expect(
        (mapped as AsyncLoadingWithPrevious).previousValue,
        equals(20),
      );
    });

    test('map with ErrorWithPrevious transforms previous value', () {
      final errorWithPrevious = AsyncErrorWithPrevious<int>(
        Exception('test'),
        StackTrace.current,
        10,
      );
      final mapped = errorWithPrevious.map((v) => v * 2);
      expect(mapped, isA<AsyncErrorWithPrevious<int>>());
      expect(
        (mapped as AsyncErrorWithPrevious).previousValue,
        equals(20),
      );
    });

    test('copyWithPrevious with null previous', () {
      const loading = AsyncLoading<int>();
      final result = loading.copyWithPrevious(null);
      expect(result, isA<AsyncLoading<int>>());
    });

    test('copyWithPrevious with error and previous value', () {
      const previous = AsyncData(42);
      final error = AsyncError<int>(Exception('test'), StackTrace.current)
          .copyWithPrevious(previous);
      expect(error, isA<AsyncErrorWithPrevious<int>>());
      expect((error as AsyncErrorWithPrevious).previousValue, equals(42));
    });

    test('equality for AsyncData', () {
      const data1 = AsyncData(42);
      const data2 = AsyncData(42);
      const data3 = AsyncData(43);
      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
      expect(data1.hashCode, equals(data2.hashCode));
    });

    test('equality for AsyncLoading', () {
      const loading1 = AsyncLoading<int>();
      const loading2 = AsyncLoading<int>();
      expect(loading1, equals(loading2));
      expect(loading1.hashCode, equals(loading2.hashCode));
    });

    test('guardAsync catches async errors', () async {
      final result = await AsyncValue.guardAsync(
        () async => throw Exception('async error'),
      );
      expect(result, isA<AsyncError>());
    });

    test('guardAsync returns data on success', () async {
      final result = await AsyncValue.guardAsync(() async => 42);
      expect(result, isA<AsyncData<int>>());
      expect((result as AsyncData).value, equals(42));
    });
  });

  group('AsyncComputed edge cases', () {
    test('dispose prevents future updates', () async {
      final counter = signal(0);
      var computeCount = 0;

      final computed = asyncComputed(() async {
        counter();
        computeCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return computeCount;
      });

      await computed.future;
      expect(computeCount, equals(1));

      computed.dispose();

      // Try to trigger update
      counter.value = 1;
      await Future.delayed(const Duration(milliseconds: 50));

      // Should not have recomputed
      expect(computeCount, equals(1));
    });

    test('handles synchronous errors in compute function', () async {
      final shouldThrowSync = signal(true);

      // Synchronous errors are now caught and turned into AsyncError state
      // without propagating out of the AsyncComputed constructor
      final computed = asyncComputed(() {
        if (shouldThrowSync()) {
          throw Exception('Sync error');
        }
        return Future.value(42);
      });

      // The error should be captured in state, not thrown
      await Future.delayed(const Duration(milliseconds: 20));
      expect(computed().hasError, isTrue);
      expect(computed().errorOrNull.toString(), contains('Sync error'));

      computed.dispose();
    });

    test('stateSignal allows external watching', () async {
      final computed = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      var watchCount = 0;
      final eff = effect(() {
        computed.stateSignal();
        watchCount++;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      expect(watchCount, greaterThan(1)); // Initial + update

      eff.stop();
      computed.dispose();
    });

    test('multiple rapid refreshes only complete last one', () async {
      var computeCount = 0;
      final computed = asyncComputed(() async {
        final count = ++computeCount;
        await Future.delayed(const Duration(milliseconds: 50));
        return count;
      });

      // Rapid refreshes
      computed.refresh();
      await Future.delayed(const Duration(milliseconds: 5));
      computed.refresh();
      await Future.delayed(const Duration(milliseconds: 5));
      computed.refresh();

      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 100));
      final result = await computed.future;

      // Last computation should be the result
      expect(result, greaterThan(1));
      expect(computed.valueOrNull, equals(result));

      computed.dispose();
    });

    test('isLoading, hasValue, hasError getters', () async {
      final computed = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(computed.isLoading, isTrue);
      expect(computed.hasValue, isFalse);
      expect(computed.hasError, isFalse);

      await computed.future;

      expect(computed.isLoading, isFalse);
      expect(computed.hasValue, isTrue);
      expect(computed.hasError, isFalse);

      computed.dispose();
    });

    test('future returns current value if already completed', () async {
      final computed = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      await computed.future;

      // Calling future again should immediately return the value
      final start = DateTime.now();
      final result = await computed.future;
      final duration = DateTime.now().difference(start);

      expect(result, equals(42));
      expect(duration.inMilliseconds, lessThan(5));

      computed.dispose();
    });

    test('future returns error if computation failed', () async {
      final computed = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        throw Exception('test error');
      });

      Object? firstError;
      try {
        await computed.future;
      } catch (e) {
        firstError = e;
      }
      expect(firstError.toString(), contains('test error'));

      // Calling future again should return the same error
      Object? secondError;
      try {
        await computed.future;
      } catch (e) {
        secondError = e;
      }
      expect(secondError.toString(), contains('test error'));

      computed.dispose();
    });

    test('handles null values correctly', () async {
      final computed = asyncComputed<String?>(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return null;
      });

      await computed.future;
      expect(computed.valueOrNull, isNull);
      expect(computed.hasValue, isTrue);

      computed.dispose();
    });
  });

  group('StreamComputed edge cases', () {
    test('dispose cancels stream subscription', () async {
      final controller = StreamController<int>.broadcast();
      var emitCount = 0;

      final stream = streamComputed(() {
        return controller.stream.map((v) {
          emitCount++;
          return v;
        });
      });

      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 20));
      expect(emitCount, equals(1));

      stream.dispose();

      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 20));
      expect(emitCount, equals(1)); // Should not have increased

      await controller.close();
    });

    test('refresh resubscribes to stream', () async {
      var subscriptionCount = 0;

      final stream = streamComputed(() {
        subscriptionCount++;
        return Stream.value(subscriptionCount);
      });

      await Future.delayed(const Duration(milliseconds: 20));
      expect(subscriptionCount, equals(1));

      stream.refresh();
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subscriptionCount, equals(2));

      stream.dispose();
    });

    test('stateSignal allows external watching', () async {
      final controller = StreamController<int>.broadcast();
      final stream = streamComputed(() => controller.stream);

      var watchCount = 0;
      final eff = effect(() {
        stream.stateSignal();
        watchCount++;
      });

      controller.add(42);
      await Future.delayed(const Duration(milliseconds: 20));
      expect(watchCount, greaterThan(1));

      eff.stop();
      stream.dispose();
      await controller.close();
    });

    test('handles stream that completes', () async {
      final stream = streamComputed(() async* {
        yield 1;
        yield 2;
        yield 3;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      expect(stream.valueOrNull, equals(3)); // Last emitted value

      stream.dispose();
    });

    test('preserves previous value on resubscription', () async {
      final trigger = signal(0);
      var counter = 0;

      final stream = streamComputed(() {
        trigger();
        return Stream.value(++counter);
      });

      await Future.delayed(const Duration(milliseconds: 20));
      expect(stream.valueOrNull, equals(1));

      trigger.value++;
      // During resubscription, should show loading with previous
      await Future.delayed(const Duration(milliseconds: 5));

      await Future.delayed(const Duration(milliseconds: 30));
      expect(stream.valueOrNull, equals(2));

      stream.dispose();
    });

    test('handles synchronous stream errors in factory', () async {
      final stream = streamComputed<int>(() {
        throw Exception('Factory error');
      });

      await Future.delayed(const Duration(milliseconds: 20));
      expect(stream().hasError, isTrue);
      expect(stream().errorOrNull.toString(), contains('Factory error'));

      stream.dispose();
    });
  });

  group('combineAsync edge cases', () {
    test('handles empty list', () {
      final combined = combineAsync<List<Object?>>([], (values) => values);
      expect(combined.hasValue, isTrue);
      expect((combined as AsyncData).value, isEmpty);
    });

    test('handles combiner error', () {
      final a = const AsyncData(1);
      final b = const AsyncData(2);

      final combined = combineAsync<int>([a, b], (values) {
        throw Exception('Combiner error');
      });

      expect(combined.hasError, isTrue);
      expect(combined.errorOrNull.toString(), contains('Combiner error'));
    });

    test('first loading wins over later errors', () {
      final a = const AsyncLoading<int>();
      final b = AsyncError<String>(Exception('test'), StackTrace.current);
      final c = const AsyncData(true);

      final combined = combineAsync<List<Object?>>(
        [a, b, c],
        (values) => values,
      );

      // Loading takes precedence
      expect(combined.isLoading, isTrue);
    });

    test('LoadingWithPrevious is also considered loading', () {
      final a = const AsyncData(1);
      final b = const AsyncLoadingWithPrevious<String>('prev');
      final c = const AsyncData(true);

      final combined = combineAsync<List<Object?>>(
        [a, b, c],
        (values) => values,
      );

      expect(combined.isLoading, isTrue);
    });

    test('ErrorWithPrevious is treated as error', () {
      final a = const AsyncData(1);
      final b = AsyncErrorWithPrevious<String>(
        Exception('test'),
        StackTrace.current,
        'prev',
      );
      final c = const AsyncData(true);

      final combined = combineAsync<List<Object?>>(
        [a, b, c],
        (values) => values,
      );

      expect(combined.hasError, isTrue);
    });
  });

  group('AsyncComputedListExtension', () {
    test('allFutures waits for all computeds', () async {
      final c1 = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 1;
      });
      final c2 = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return 2;
      });

      final results = await [c1, c2].allFutures;
      expect(results, equals([1, 2]));

      c1.dispose();
      c2.dispose();
    });

    test('combined returns combined async state', () async {
      final c1 = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 1;
      });
      final c2 = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 2;
      });

      // Initially loading
      expect([c1, c2].combined.isLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 50));

      final combined = [c1, c2].combined;
      expect(combined.hasValue, isTrue);
      expect((combined as AsyncData).value, equals([1, 2]));

      c1.dispose();
      c2.dispose();
    });
  });

  group('FutureAsyncValueExtension', () {
    test('toAsyncValue returns data on success', () async {
      final result = await Future.value(42).toAsyncValue();
      expect(result, isA<AsyncData<int>>());
      expect((result as AsyncData).value, equals(42));
    });

    test('toAsyncValue returns error on failure', () async {
      final result = await Future<int>.error(Exception('test')).toAsyncValue();
      expect(result, isA<AsyncError<int>>());
    });
  });

  group('Complex async dependency scenarios', () {
    test('multiple levels of async dependencies', () async {
      // Level 1: Config
      final config = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return {'apiUrl': 'https://api.example.com'};
      });

      // Level 2: Auth (depends on config)
      final auth = asyncComputed(() async {
        final cfg = await config.future;
        await Future.delayed(const Duration(milliseconds: 10));
        return {'token': 'token-for-${cfg['apiUrl']}'};
      });

      // Level 3: User data (depends on auth)
      final userData = asyncComputed(() async {
        final authData = await auth.future;
        await Future.delayed(const Duration(milliseconds: 10));
        return {'user': 'authenticated with ${authData['token']}'};
      });

      // All should start loading
      expect(config().isLoading, isTrue);

      // Wait for the full chain
      final result = await userData.future;
      expect(result['user'], contains('authenticated'));
      expect(result['user'], contains('https://api.example.com'));

      config.dispose();
      auth.dispose();
      userData.dispose();
    });

    test('parallel async dependencies with Future.wait', () async {
      final user = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return {'name': 'John'};
      });

      final posts = asyncComputed(() async {
        await Future.delayed(const Duration(milliseconds: 30));
        return ['Post 1', 'Post 2'];
      });

      // Combine them in parallel
      final dashboard = asyncComputed(() async {
        final results = await Future.wait([user.future, posts.future]);
        return {
          'user': results[0],
          'posts': results[1],
        };
      });

      final result = await dashboard.future;
      expect(result['user'], isA<Map>());
      expect(result['posts'], isA<List>());
      expect((result['user'] as Map)['name'], equals('John'));
      expect((result['posts'] as List).length, equals(2));

      user.dispose();
      posts.dispose();
      dashboard.dispose();
    });

    test('async computed with sync signal dependency', () async {
      final userId = signal(1);
      final refreshTrigger = signal(0);

      var fetchCount = 0;
      final user = asyncComputed(() async {
        // Read signals BEFORE await to ensure dependency tracking
        final id = userId();
        refreshTrigger(); // Just to create dependency

        fetchCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return 'User $id (fetch #$fetchCount)';
      });

      await user.future;
      expect(fetchCount, equals(1));

      // Change userId - should trigger refetch
      userId.value = 2;
      await Future.delayed(const Duration(milliseconds: 50));
      await user.future;
      expect(fetchCount, equals(2));
      expect(user.valueOrNull, contains('User 2'));

      // Trigger refresh via refreshTrigger - should also trigger refetch
      refreshTrigger.value++;
      await Future.delayed(const Duration(milliseconds: 50));
      await user.future;
      expect(fetchCount, equals(3));

      user.dispose();
    });

    test('diamond dependency pattern', () async {
      // A diamond pattern: A -> B, A -> C, B -> D, C -> D
      final a = signal(1);

      final b = asyncComputed(() async {
        final val = a();
        await Future.delayed(const Duration(milliseconds: 10));
        return val * 2;
      });

      final c = asyncComputed(() async {
        final val = a();
        await Future.delayed(const Duration(milliseconds: 15));
        return val * 3;
      });

      final d = asyncComputed(() async {
        final bVal = await b.future;
        final cVal = await c.future;
        await Future.delayed(const Duration(milliseconds: 5));
        return bVal + cVal;
      });

      final result = await d.future;
      expect(result, equals(5)); // 1*2 + 1*3 = 5

      // Change A - should propagate through B, C to D
      a.value = 2;
      await Future.delayed(const Duration(milliseconds: 10));
      d.refresh();
      await Future.delayed(const Duration(milliseconds: 50));
      final newResult = await d.future;
      expect(newResult, equals(10)); // 2*2 + 2*3 = 10

      b.dispose();
      c.dispose();
      d.dispose();
    });

    test('error recovery with retry pattern', () async {
      var attemptCount = 0;
      final shouldFail = signal(true);

      final computed = asyncComputed(() async {
        attemptCount++;
        final fail = shouldFail();
        await Future.delayed(const Duration(milliseconds: 10));
        if (fail) {
          throw Exception('Attempt $attemptCount failed');
        }
        return 'Success on attempt $attemptCount';
      });

      // First attempt fails
      try {
        await computed.future;
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Attempt 1 failed'));
      }

      // Fix the error condition - this triggers recomputation
      shouldFail.value = false;
      await Future.delayed(const Duration(milliseconds: 50));
      final result = await computed.future;
      expect(result, contains('Success'));

      computed.dispose();
    });

    test('concurrent async computeds with shared dependency', () async {
      final userId = signal(1);

      final user = asyncComputed(() async {
        final id = userId();
        await Future.delayed(const Duration(milliseconds: 20));
        return 'User $id';
      });

      final profile = asyncComputed(() async {
        final id = userId();
        await Future.delayed(const Duration(milliseconds: 15));
        return 'Profile for User $id';
      });

      final activity = asyncComputed(() async {
        final id = userId();
        await Future.delayed(const Duration(milliseconds: 25));
        return 'Activity for User $id';
      });

      // Wait for all to complete
      final results = await Future.wait([
        user.future,
        profile.future,
        activity.future,
      ]);

      expect(results[0], equals('User 1'));
      expect(results[1], equals('Profile for User 1'));
      expect(results[2], equals('Activity for User 1'));

      // Change userId - all should recompute
      userId.value = 2;
      await Future.delayed(const Duration(milliseconds: 100));

      final newResults = await Future.wait([
        user.future,
        profile.future,
        activity.future,
      ]);

      expect(newResults[0], equals('User 2'));
      expect(newResults[1], equals('Profile for User 2'));
      expect(newResults[2], equals('Activity for User 2'));

      user.dispose();
      profile.dispose();
      activity.dispose();
    });

    test('async computed with timeout pattern', () async {
      final computed = asyncComputed(() async {
        // Simulate a slow operation that we want to timeout
        await Future.delayed(const Duration(milliseconds: 100));
        return 'result';
      });

      // Use timeout with the future
      try {
        await computed.future.timeout(const Duration(milliseconds: 20));
        fail('Should have timed out');
      } catch (e) {
        expect(e, isA<TimeoutException>());
      }

      // Wait for actual completion
      await Future.delayed(const Duration(milliseconds: 150));
      final result = await computed.future;
      expect(result, equals('result'));

      computed.dispose();
    });

    test('batch updates to multiple dependencies', () async {
      final a = signal(1);
      final b = signal(2);
      var computeCount = 0;

      final computed = asyncComputed(() async {
        final aVal = a();
        final bVal = b();
        computeCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return aVal + bVal;
      });

      await computed.future;
      expect(computeCount, equals(1));

      // Batch update - should only trigger one recomputation
      batch(() {
        a.value = 10;
        b.value = 20;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      await computed.future;
      expect(computed.valueOrNull, equals(30));
      expect(computeCount, equals(2)); // Only one more recomputation

      computed.dispose();
    });

    test('async computed with conditional dependencies', () async {
      final useFeatureA = signal(true);
      final featureAData = signal('Feature A Data');
      final featureBData = signal('Feature B Data');
      var computeCount = 0;

      // Note: Dependencies are tracked before the first await
      // So both featureAData and featureBData are NOT tracked
      // because they are read AFTER the await
      final computed = asyncComputed(() async {
        final useA = useFeatureA(); // This is tracked
        computeCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        // These reads are NOT tracked (after await)
        if (useA) {
          return featureAData.peek(); // Use peek to read without tracking
        } else {
          return featureBData.peek();
        }
      });

      await computed.future;
      expect(computed.valueOrNull, equals('Feature A Data'));
      expect(computeCount, equals(1));

      // Changing useFeatureA should trigger recomputation
      useFeatureA.value = false;
      await Future.delayed(const Duration(milliseconds: 50));
      await computed.future;
      expect(computed.valueOrNull, equals('Feature B Data'));
      expect(computeCount, equals(2));

      computed.dispose();
    });

    test('stream computed with multiple rapid emissions', () async {
      final controller = StreamController<int>.broadcast();

      final stream = streamComputed(() {
        return controller.stream;
      });

      // Rapid emissions
      for (var i = 1; i <= 10; i++) {
        controller.add(i);
      }

      await Future.delayed(const Duration(milliseconds: 50));
      expect(stream.valueOrNull, equals(10)); // Should have last value

      stream.dispose();
      await controller.close();
    });
  });

  group('Performance and stress tests', () {
    test('handles many concurrent async computeds', () async {
      final base = signal(1);
      final computeds = <AsyncComputed<int>>[];

      // Create many computeds
      for (var i = 0; i < 20; i++) {
        computeds.add(asyncComputed(() async {
          final val = base();
          await Future.delayed(const Duration(milliseconds: 5));
          return val + i;
        }));
      }

      // Wait for all to complete
      final results = await Future.wait(computeds.map((c) => c.future));
      expect(results.length, equals(20));
      for (var i = 0; i < 20; i++) {
        expect(results[i], equals(1 + i));
      }

      // Change base - all should update
      base.value = 10;
      await Future.delayed(const Duration(milliseconds: 100));

      final newResults = await Future.wait(computeds.map((c) => c.future));
      for (var i = 0; i < 20; i++) {
        expect(newResults[i], equals(10 + i));
      }

      // Cleanup
      for (final c in computeds) {
        c.dispose();
      }
    });

    test('deep chain of async dependencies', () async {
      final base = signal(1);
      AsyncComputed<int>? previous;
      final chain = <AsyncComputed<int>>[];

      // Create a chain of 5 async computeds
      for (var i = 0; i < 5; i++) {
        final prev = previous;
        final computed = asyncComputed(() async {
          int val;
          if (prev != null) {
            val = await prev.future;
          } else {
            val = base();
          }
          await Future.delayed(const Duration(milliseconds: 5));
          return val + 1;
        });
        chain.add(computed);
        previous = computed;
      }

      // Wait for the entire chain
      final result = await chain.last.future;
      expect(result, equals(6)); // 1 + 5 additions

      // Cleanup
      for (final c in chain.reversed) {
        c.dispose();
      }
    });
  });
}
