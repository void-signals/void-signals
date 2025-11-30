import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_signals_hooks/void_signals_hooks.dart';

void main() {
  group('AsyncState', () {
    test('idle state properties', () {
      const state = UseAsyncState<int>.idle();
      expect(state.isIdle, true);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.isError, false);
      expect(state.isComplete, false);
      expect(state.data, isNull);
      expect(state.error, isNull);
    });

    test('loading state properties', () {
      const state = UseAsyncState<int>.loading();
      expect(state.isIdle, false);
      expect(state.isLoading, true);
      expect(state.isSuccess, false);
      expect(state.isError, false);
      expect(state.isComplete, false);
    });

    test('success state properties', () {
      const state = UseAsyncState<int>.success(42);
      expect(state.isIdle, false);
      expect(state.isLoading, false);
      expect(state.isSuccess, true);
      expect(state.isError, false);
      expect(state.isComplete, true);
      expect(state.data, 42);
    });

    test('error state properties', () {
      final state = UseAsyncState<int>.error('error', StackTrace.current);
      expect(state.isIdle, false);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.isError, true);
      expect(state.isComplete, true);
      expect(state.error, 'error');
      expect(state.stackTrace, isNotNull);
    });

    test('dataOr returns data when available', () {
      const state = UseAsyncState<int>.success(42);
      expect(state.dataOr(0), 42);
    });

    test('dataOr returns default when no data', () {
      const state = UseAsyncState<int>.loading();
      expect(state.dataOr(0), 0);
    });

    test('map transforms data', () {
      const state = UseAsyncState<int>.success(42);
      final mapped = state.map((v) => v.toString());
      expect(mapped.data, '42');
    });

    test('map preserves error state', () {
      final state = UseAsyncState<int>.error('error');
      final mapped = state.map((v) => v.toString());
      expect(mapped.isError, true);
      expect(mapped.error, 'error');
    });

    test('equality works correctly', () {
      const state1 = UseAsyncState<int>.success(42);
      const state2 = UseAsyncState<int>.success(42);
      const state3 = UseAsyncState<int>.success(100);

      expect(state1 == state2, true);
      expect(state1 == state3, false);
    });

    test('hashCode is consistent', () {
      const state1 = UseAsyncState<int>.success(42);
      const state2 = UseAsyncState<int>.success(42);
      expect(state1.hashCode, state2.hashCode);
    });

    test('toString returns readable string', () {
      expect(
          const UseAsyncState<int>.idle().toString(), 'UseAsyncState.idle()');
      expect(const UseAsyncState<int>.loading().toString(),
          'UseAsyncState.loading()');
      expect(const UseAsyncState<int>.success(42).toString(),
          'UseAsyncState.success(42)');
      expect(UseAsyncState<int>.error('err').toString(),
          'UseAsyncState.error(err)');
    });
  });

  group('UseAsyncState.when', () {
    testWidgets('returns correct widget for idle', (tester) async {
      const state = UseAsyncState<int>.idle();

      await tester.pumpWidget(
        MaterialApp(
          home: state.when(
            idle: () => const Text('idle'),
            loading: () => const Text('loading'),
            success: (data) => Text('success: $data'),
            error: (e, _) => Text('error: $e'),
          ),
        ),
      );

      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('returns correct widget for loading', (tester) async {
      const state = UseAsyncState<int>.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: state.when(
            idle: () => const Text('idle'),
            loading: () => const Text('loading'),
            success: (data) => Text('success: $data'),
            error: (e, _) => Text('error: $e'),
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('returns correct widget for success', (tester) async {
      const state = UseAsyncState<int>.success(42);

      await tester.pumpWidget(
        MaterialApp(
          home: state.when(
            idle: () => const Text('idle'),
            loading: () => const Text('loading'),
            success: (data) => Text('success: $data'),
            error: (e, _) => Text('error: $e'),
          ),
        ),
      );

      expect(find.text('success: 42'), findsOneWidget);
    });

    testWidgets('returns correct widget for error', (tester) async {
      final state = UseAsyncState<int>.error('failed');

      await tester.pumpWidget(
        MaterialApp(
          home: state.when(
            idle: () => const Text('idle'),
            loading: () => const Text('loading'),
            success: (data) => Text('success: $data'),
            error: (e, _) => Text('error: $e'),
          ),
        ),
      );

      expect(find.text('error: failed'), findsOneWidget);
    });
  });

  group('UseAsyncState.maybeWhen', () {
    testWidgets('uses orElse when handler not provided', (tester) async {
      const state = UseAsyncState<int>.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: state.maybeWhen(
            success: (data) => Text('success: $data'),
            orElse: () => const Text('fallback'),
          ),
        ),
      );

      expect(find.text('fallback'), findsOneWidget);
    });

    testWidgets('uses specific handler when provided', (tester) async {
      const state = UseAsyncState<int>.success(42);

      await tester.pumpWidget(
        MaterialApp(
          home: state.maybeWhen(
            success: (data) => Text('success: $data'),
            orElse: () => const Text('fallback'),
          ),
        ),
      );

      expect(find.text('success: 42'), findsOneWidget);
    });
  });

  group('useAsync', () {
    testWidgets('starts with idle state', (tester) async {
      late UseAsyncController<int> controller;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useAsync<int>();
              return Text(controller.state.status.name);
            },
          ),
        ),
      );

      expect(controller.state.isIdle, true);
      expect(find.text('idle'), findsOneWidget);
    });

    testWidgets('execute transitions to loading then success', (tester) async {
      late UseAsyncController<int> controller;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useAsync<int>();
              return Text(controller.state.status.name);
            },
          ),
        ),
      );

      expect(controller.state.isIdle, true);

      // Execute async operation
      controller.execute(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      // Should be loading
      await tester.pump();
      expect(controller.state.isLoading, true);

      // Wait for completion
      await tester.pumpAndSettle();
      expect(controller.state.isSuccess, true);
      expect(controller.state.data, 42);
    });

    testWidgets('execute handles errors', (tester) async {
      late UseAsyncController<int> controller;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useAsync<int>();
              return Text(controller.state.status.name);
            },
          ),
        ),
      );

      controller.execute(() async {
        throw Exception('test error');
      });

      await tester.pumpAndSettle();
      expect(controller.state.isError, true);
      expect(controller.state.error, isA<Exception>());
    });

    testWidgets('reset returns to idle state', (tester) async {
      late UseAsyncController<int> controller;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useAsync<int>();
              return Text(controller.state.status.name);
            },
          ),
        ),
      );

      // Execute and complete
      controller.execute(() async => 42);
      await tester.pumpAndSettle();
      expect(controller.state.isSuccess, true);

      // Reset
      controller.reset();
      await tester.pump();
      expect(controller.state.isIdle, true);
    });

    testWidgets('cancels stale operations', (tester) async {
      late UseAsyncController<int> controller;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              controller = useAsync<int>();
              return Text(controller.state.status.name);
            },
          ),
        ),
      );

      // Start first operation
      controller.execute(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 1;
      });

      // Start second operation before first completes
      await tester.pump(const Duration(milliseconds: 10));
      controller.execute(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 2;
      });

      await tester.pumpAndSettle();

      // Should have result from second operation
      expect(controller.state.data, 2);
    });
  });

  group('useAsyncData', () {
    testWidgets('starts loading and completes with data', (tester) async {
      UseAsyncState<int>? state;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              state = useAsyncData(() async {
                await Future.delayed(const Duration(milliseconds: 10));
                return 42;
              });
              return Text(state!.status.name);
            },
          ),
        ),
      );

      // Initial state should be loading
      expect(find.text('loading'), findsOneWidget);

      await tester.pumpAndSettle();
      // After completion, should show success
      expect(find.text('success'), findsOneWidget);
    });

    testWidgets('re-executes when keys change', (tester) async {
      int executionCount = 0;
      final keySignal = signal(1);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final key = useWatch(keySignal);
              useAsyncData(() async {
                executionCount++;
                return key;
              }, keys: [key]);
              return Text('key: $key');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(executionCount, 1);

      keySignal.value = 2;
      await tester.pumpAndSettle();
      expect(executionCount, 2);
    });
  });

  group('useLatest', () {
    testWidgets('provides access to latest value without subscription',
        (tester) async {
      late Signal<int> sig;
      late ValueRef<int> ref;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              buildCount++;
              sig = useSignal(0);
              ref = useLatest(sig);
              return Text('builds: $buildCount');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(ref.current, 0);

      sig.value = 10;
      await tester.pump();

      // Should not rebuild (no useWatch)
      expect(buildCount, 1);
      // But ref should have latest value
      expect(ref.current, 10);
    });
  });

  group('useListener', () {
    testWidgets('calls listener on signal change', (tester) async {
      late Signal<int> sig;
      final log = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              sig = useSignal(0);
              useListener(sig, (value) => log.add(value));
              return const SizedBox();
            },
          ),
        ),
      );

      // Should not fire immediately by default
      expect(log, isEmpty);

      sig.value = 1;
      expect(log, [1]);

      sig.value = 2;
      expect(log, [1, 2]);
    });

    testWidgets('fires immediately when requested', (tester) async {
      late Signal<int> sig;
      final log = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              sig = useSignal(42);
              useListener(sig, (value) => log.add(value),
                  fireImmediately: true);
              return const SizedBox();
            },
          ),
        ),
      );

      // Should fire immediately
      expect(log, [42]);

      sig.value = 100;
      expect(log, [42, 100]);
    });

    testWidgets('cleans up on dispose', (tester) async {
      late Signal<int> sig;
      final log = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              sig = useSignal(0);
              useListener(sig, (value) => log.add(value));
              return const SizedBox();
            },
          ),
        ),
      );

      sig.value = 1;
      expect(log, [1]);

      // Dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      sig.value = 100;
      // Should not fire after dispose
      expect(log, [1]);
    });
  });

  group('useToggle', () {
    testWidgets('provides toggle functions', (tester) async {
      late bool value;
      late void Function() toggle;
      late void Function() setTrue;
      late void Function() setFalse;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              (value, toggle, setTrue, setFalse) = useToggle(false);
              return Column(
                children: [
                  Text('value: $value'),
                  TextButton(onPressed: toggle, child: const Text('toggle')),
                  TextButton(onPressed: setTrue, child: const Text('setTrue')),
                  TextButton(
                      onPressed: setFalse, child: const Text('setFalse')),
                ],
              );
            },
          ),
        ),
      );

      expect(value, false);
      expect(find.text('value: false'), findsOneWidget);

      // Toggle
      await tester.tap(find.text('toggle'));
      await tester.pump();
      expect(find.text('value: true'), findsOneWidget);

      // Toggle again
      await tester.tap(find.text('toggle'));
      await tester.pump();
      expect(find.text('value: false'), findsOneWidget);

      // Set true
      await tester.tap(find.text('setTrue'));
      await tester.pump();
      expect(find.text('value: true'), findsOneWidget);

      // Set false
      await tester.tap(find.text('setFalse'));
      await tester.pump();
      expect(find.text('value: false'), findsOneWidget);
    });

    testWidgets('starts with provided initial value', (tester) async {
      late bool value;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              (value, _, _, _) = useToggle(true);
              return Text('value: $value');
            },
          ),
        ),
      );

      expect(value, true);
    });
  });

  group('useCounter', () {
    testWidgets('provides counter functions', (tester) async {
      late int count;
      late void Function([int step]) inc;
      late void Function([int step]) dec;
      late void Function() reset;
      late void Function(int) set;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              (count, inc, dec, reset, set) = useCounter(10);
              return Column(
                children: [
                  Text('count: $count'),
                  TextButton(onPressed: () => inc(), child: const Text('inc')),
                  TextButton(onPressed: () => dec(), child: const Text('dec')),
                  TextButton(onPressed: reset, child: const Text('reset')),
                  TextButton(
                      onPressed: () => set(100), child: const Text('set100')),
                ],
              );
            },
          ),
        ),
      );

      expect(count, 10);
      expect(find.text('count: 10'), findsOneWidget);

      // Increment
      await tester.tap(find.text('inc'));
      await tester.pump();
      expect(find.text('count: 11'), findsOneWidget);

      // Decrement
      await tester.tap(find.text('dec'));
      await tester.pump();
      expect(find.text('count: 10'), findsOneWidget);

      // Reset
      await tester.tap(find.text('inc'));
      await tester.tap(find.text('inc'));
      await tester.pump();
      expect(find.text('count: 12'), findsOneWidget);

      await tester.tap(find.text('reset'));
      await tester.pump();
      expect(find.text('count: 10'), findsOneWidget);

      // Set
      await tester.tap(find.text('set100'));
      await tester.pump();
      expect(find.text('count: 100'), findsOneWidget);
    });

    testWidgets('supports custom step', (tester) async {
      late int count;
      late void Function([int step]) inc;
      late void Function([int step]) dec;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              (count, inc, dec, _, _) = useCounter(0);
              return Column(
                children: [
                  Text('count: $count'),
                  TextButton(
                      onPressed: () => inc(5), child: const Text('inc5')),
                  TextButton(
                      onPressed: () => dec(3), child: const Text('dec3')),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('inc5'));
      await tester.pump();
      expect(find.text('count: 5'), findsOneWidget);

      await tester.tap(find.text('dec3'));
      await tester.pump();
      expect(find.text('count: 2'), findsOneWidget);
    });
  });

  group('useInterval', () {
    testWidgets('calls callback periodically', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              useInterval(() => callCount++, const Duration(milliseconds: 100));
              return const SizedBox();
            },
          ),
        ),
      );

      expect(callCount, 0);

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 1);

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 2);

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 3);
    });

    testWidgets('pauses when callback is null', (tester) async {
      int callCount = 0;
      final running = signal(true);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final isRunning = useWatch(running);
              useInterval(
                isRunning ? () => callCount++ : null,
                const Duration(milliseconds: 100),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 1);

      // Pause
      running.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(callCount, 1); // No more increments

      // Resume
      running.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 2);
    });

    testWidgets('cleans up on dispose', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              useInterval(() => callCount++, const Duration(milliseconds: 100));
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 1);

      // Dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      await tester.pump(const Duration(milliseconds: 200));
      expect(callCount, 1); // No more increments
    });
  });

  group('useTimeout', () {
    testWidgets('calls callback after delay', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              useTimeout(() => callCount++, const Duration(milliseconds: 100));
              return const SizedBox();
            },
          ),
        ),
      );

      expect(callCount, 0);

      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 1);

      // Should not call again
      await tester.pump(const Duration(milliseconds: 200));
      expect(callCount, 1);
    });

    testWidgets('can be cancelled', (tester) async {
      int callCount = 0;
      late void Function() cancel;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              cancel = useTimeout(
                  () => callCount++, const Duration(milliseconds: 100));
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      cancel();

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 0); // Should not have fired
    });

    testWidgets('does not fire when callback is null', (tester) async {
      int callCount = 0;
      final shouldFire = signal(false);

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final fire = useWatch(shouldFire);
              useTimeout(
                fire ? () => callCount++ : null,
                const Duration(milliseconds: 100),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(callCount, 0);

      shouldFire.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 1);
    });

    testWidgets('cleans up on dispose', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              useTimeout(() => callCount++, const Duration(milliseconds: 100));
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      // Dispose before timeout
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      await tester.pump(const Duration(milliseconds: 100));
      expect(callCount, 0); // Should not have fired
    });
  });
}
