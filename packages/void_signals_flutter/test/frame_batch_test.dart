import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_signals_flutter/void_signals_flutter.dart';

void main() {
  setUp(() {
    // Clear any pending updates between tests
    FrameBatchScope.flush();
  });

  group('batchLater - Cross-component batching', () {
    test('multiple batchLater calls share single flush', () async {
      final counter = signal(0);
      var effectRunCount = 0;

      final eff = effect(() {
        counter.value;
        effectRunCount++;
      });

      effectRunCount = 0; // Reset after initial

      // Multiple batchLater calls in same sync block
      batchLater(() => counter.value++);
      batchLater(() => counter.value++);
      batchLater(() => counter.value++);

      // Values are updated immediately (inside the batch)
      expect(counter.value, 3);

      // But effects haven't run yet
      expect(effectRunCount, 0);

      // Wait for microtask to flush
      await Future.microtask(() {});

      // Now effects should have run - just once!
      expect(effectRunCount, 1);

      eff.stop();
    });

    test('compare with regular batch - multiple effect runs', () {
      final counter = signal(0);
      var effectRunCount = 0;

      final eff = effect(() {
        counter.value;
        effectRunCount++;
      });

      effectRunCount = 0;

      // Regular batch: each batch flushes independently
      batch(() => counter.value++);
      batch(() => counter.value++);

      expect(counter.value, 2);
      expect(effectRunCount, 2, reason: 'Regular batch flushes independently');

      eff.stop();
    });

    testWidgets('Watch rebuilds once with batchLater', (tester) async {
      final counterA = signal(0);
      final counterB = signal(0);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('update'),
                onPressed: () {
                  batchLater(() => counterA.value++);
                  batchLater(() => counterB.value++);
                },
                child: const Text('Update'),
              ),
              Watch(builder: (_, __) {
                buildCount++;
                return Text('A=${counterA.value}, B=${counterB.value}');
              }),
            ],
          ),
        ),
      );

      expect(buildCount, 1); // Initial

      await tester.tap(find.byKey(const Key('update')));
      await tester.pump(); // Process microtask

      expect(buildCount, 2, reason: 'Single rebuild for both updates');
      expect(find.text('A=1, B=1'), findsOneWidget);
    });

    test('nested batchLater calls', () async {
      final counter = signal(0);
      var effectRunCount = 0;

      final eff = effect(() {
        counter.value;
        effectRunCount++;
      });

      effectRunCount = 0;

      batchLater(() {
        counter.value++;
        batchLater(() {
          counter.value++;
          batchLater(() {
            counter.value++;
          });
        });
      });

      expect(counter.value, 3);
      expect(effectRunCount, 0);

      await Future.microtask(() {});

      expect(effectRunCount, 1,
          reason: 'Nested batchLater shares single flush');

      eff.stop();
    });
  });

  group('queueUpdate', () {
    test('queues updates for batched execution', () async {
      final a = signal(0);
      final b = signal(0);
      var effectRunCount = 0;

      final eff = effect(() {
        a.value;
        b.value;
        effectRunCount++;
      });

      effectRunCount = 0;

      queueUpdate(() => a.value = 10);
      queueUpdate(() => b.value = 20);

      // Not yet executed
      expect(a.value, 0);
      expect(b.value, 0);

      await Future.microtask(() {});

      expect(a.value, 10);
      expect(b.value, 20);
      expect(effectRunCount, 1);

      eff.stop();
    });
  });

  group('FrameBatchScope', () {
    test('static update method batches updates', () async {
      final counter = signal(0);
      var effectRunCount = 0;

      final eff = effect(() {
        counter.value;
        effectRunCount++;
      });

      effectRunCount = 0;

      FrameBatchScope.update(() => counter.value++);
      FrameBatchScope.update(() => counter.value++);
      FrameBatchScope.update(() => counter.value++);

      expect(counter.value, 0); // Not yet

      await Future.microtask(() {});

      expect(counter.value, 3);
      expect(effectRunCount, 1);

      eff.stop();
    });

    test('flush() executes immediately', () {
      final counter = signal(0);
      var effectRunCount = 0;

      final eff = effect(() {
        counter.value;
        effectRunCount++;
      });

      effectRunCount = 0;

      FrameBatchScope.update(() => counter.value++);
      FrameBatchScope.update(() => counter.value++);

      expect(counter.value, 0);

      // Force immediate flush
      FrameBatchScope.flush();

      expect(counter.value, 2);
      expect(effectRunCount, 1);

      eff.stop();
    });
  });

  group('Real-world scenarios', () {
    testWidgets('dashboard with multiple data updates', (tester) async {
      final users = signal<List<String>>([]);
      final orders = signal<List<String>>([]);
      final stats = signal<Map<String, int>>({});
      var renderCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('refresh'),
                onPressed: () {
                  // Simulate API responses coming in
                  batchLater(() => users.value = ['Alice', 'Bob']);
                  batchLater(() => orders.value = ['Order1', 'Order2']);
                  batchLater(() => stats.value = {'total': 100});
                },
                child: const Text('Refresh'),
              ),
              Watch(builder: (_, __) {
                renderCount++;
                return Text(
                  'Users: ${users.value.length}, '
                  'Orders: ${orders.value.length}, '
                  'Stats: ${stats.value.length}',
                );
              }),
            ],
          ),
        ),
      );

      expect(renderCount, 1);

      await tester.tap(find.byKey(const Key('refresh')));
      await tester.pump();

      expect(renderCount, 2, reason: 'Single render for all data updates');
      expect(find.text('Users: 2, Orders: 2, Stats: 1'), findsOneWidget);
    });

    test('API response handling with batchLater', () async {
      final isLoading = signal(true);
      final data = signal<List<String>>([]);
      final error = signal<String?>(null);
      var effectRunCount = 0;

      final eff = effect(() {
        isLoading.value;
        data.value;
        error.value;
        effectRunCount++;
      });

      effectRunCount = 0;

      // Simulate API response handling
      Future<void> handleApiResponse() async {
        // Multiple state updates from API response
        batchLater(() {
          isLoading.value = false;
          data.value = ['item1', 'item2', 'item3'];
          error.value = null;
        });
      }

      await handleApiResponse();
      await Future.microtask(() {});

      expect(isLoading.value, false);
      expect(data.value.length, 3);
      expect(error.value, null);
      expect(effectRunCount, 1, reason: 'Single effect run for API response');

      eff.stop();
    });
  });

  group('Comparison: batch vs batchLater vs queueUpdate', () {
    test('batch - immediate sync flush', () {
      final counter = signal(0);
      var runs = 0;
      final eff = effect(() {
        counter.value;
        runs++;
      });
      runs = 0;

      batch(() => counter.value++);
      expect(runs, 1, reason: 'batch flushes immediately');

      batch(() => counter.value++);
      expect(runs, 2, reason: 'each batch flushes');

      eff.stop();
    });

    test('batchLater - deferred flush, values updated immediately', () async {
      final counter = signal(0);
      var runs = 0;
      final eff = effect(() {
        counter.value;
        runs++;
      });
      runs = 0;

      batchLater(() => counter.value++);
      expect(counter.value, 1, reason: 'value updated immediately');
      expect(runs, 0, reason: 'effect not run yet');

      batchLater(() => counter.value++);
      expect(counter.value, 2);
      expect(runs, 0);

      await Future.microtask(() {});
      expect(runs, 1, reason: 'single flush for all batchLater calls');

      eff.stop();
    });

    test('queueUpdate - deferred execution and flush', () async {
      final counter = signal(0);
      var runs = 0;
      final eff = effect(() {
        counter.value;
        runs++;
      });
      runs = 0;

      queueUpdate(() => counter.value++);
      expect(counter.value, 0, reason: 'update not executed yet');
      expect(runs, 0);

      queueUpdate(() => counter.value++);
      expect(counter.value, 0);

      await Future.microtask(() {});
      expect(counter.value, 2, reason: 'both updates executed');
      expect(runs, 1, reason: 'single flush');

      eff.stop();
    });
  });

  group('Edge Cases - Exception Handling', () {
    test('batchLater exception does not break subsequent batches', () async {
      final counter = signal(0);
      var effectCount = 0;

      final eff = effect(() {
        counter.value;
        effectCount++;
      });
      effectCount = 0;

      batchLater(() => counter.value = 10);

      // Exception in batchLater
      expect(
        () => batchLater(() => throw StateError('Test error')),
        throwsStateError,
      );

      // Continue after exception
      batchLater(() => counter.value = 20);

      await Future.microtask(() {});

      expect(counter.value, 20);
      expect(effectCount, 1); // Still single flush

      eff.stop();
    });

    test('queueUpdate exception does not stop other updates', () async {
      final a = signal(0);
      final c = signal(0);

      queueUpdate(() => a.value = 1);
      queueUpdate(() => throw Exception('Error in middle'));
      queueUpdate(() => c.value = 3);

      await Future.microtask(() {});

      expect(a.value, 1, reason: 'First update succeeds');
      // b is not updated
      expect(c.value, 3,
          reason: 'Last update succeeds despite error in middle');
    });

    test('FrameBatchScope.update handles multiple exceptions', () async {
      final a = signal(0);
      final b = signal(0);
      final c = signal(0);

      FrameBatchScope.update(() => a.value = 1);
      FrameBatchScope.update(() => throw Exception('Error 1'));
      FrameBatchScope.update(() => b.value = 2);
      FrameBatchScope.update(() => throw Exception('Error 2'));
      FrameBatchScope.update(() => c.value = 3);

      await Future.microtask(() {});

      // All non-throwing updates should succeed
      expect(a.value, 1);
      expect(b.value, 2);
      expect(c.value, 3);
    });
  });

  group('Edge Cases - Concurrent Microtasks', () {
    test('multiple async operations with batchLater', () async {
      final counter = signal(0);
      var effectCount = 0;

      final eff = effect(() {
        counter.value;
        effectCount++;
      });
      effectCount = 0;

      // Simulate multiple async operations
      Future.microtask(() {
        batchLater(() => counter.value++);
        batchLater(() => counter.value++);
      });

      Future.microtask(() {
        batchLater(() => counter.value++);
      });

      await Future.delayed(Duration.zero);
      await Future.microtask(() {});

      expect(counter.value, 3);
      // Multiple microtasks may result in multiple flushes
      expect(effectCount, greaterThanOrEqualTo(1));

      eff.stop();
    });

    test('interleaved batch and batchLater', () async {
      final counter = signal(0);
      var effectCount = 0;

      final eff = effect(() {
        counter.value;
        effectCount++;
      });
      effectCount = 0;

      // Regular batch - flushes immediately
      batch(() => counter.value++);
      expect(effectCount, 1);

      // batchLater - deferred flush
      batchLater(() => counter.value++);
      batchLater(() => counter.value++);
      expect(effectCount, 1); // Still 1

      await Future.microtask(() {});
      expect(effectCount, 2); // Now flushed
      expect(counter.value, 3);

      eff.stop();
    });

    test('queueUpdate after immediate flush', () async {
      final counter = signal(0);

      queueUpdate(() => counter.value++);
      expect(counter.value, 0);

      // Force immediate flush
      FrameBatchScope.flush();
      expect(counter.value, 1);

      // Queue more updates
      queueUpdate(() => counter.value++);
      expect(counter.value, 1); // Not executed yet

      await Future.microtask(() {});
      expect(counter.value, 2);
    });
  });

  group('Edge Cases - Empty and Null', () {
    test('batchLater with empty function', () async {
      var runs = 0;

      batchLater(() {
        runs++;
      });

      expect(runs, 1);
      await Future.microtask(() {});
    });

    test('queueUpdate with empty function', () async {
      var runs = 0;

      queueUpdate(() {
        runs++;
      });

      expect(runs, 0);
      await Future.microtask(() {});
      expect(runs, 1);
    });

    test('FrameBatchScope.flush with empty queue', () {
      // Should not throw
      FrameBatchScope.flush();
      FrameBatchScope.flush();
      FrameBatchScope.flush();
    });

    test('multiple flush calls have no side effects', () async {
      final counter = signal(0);

      queueUpdate(() => counter.value++);
      FrameBatchScope.flush();
      expect(counter.value, 1);

      // Additional flushes should be no-op
      FrameBatchScope.flush();
      FrameBatchScope.flush();
      expect(counter.value, 1);
    });
  });

  group('Edge Cases - Return Values', () {
    test('batchLater preserves return values', () async {
      final result1 = batchLater(() => 42);
      final result2 = batchLater(() => 'hello');
      final result3 = batchLater(() => [1, 2, 3]);
      final result4 = batchLater<int?>(() => null);

      expect(result1, 42);
      expect(result2, 'hello');
      expect(result3, [1, 2, 3]);
      expect(result4, isNull);

      await Future.microtask(() {});
    });

    test('batchLater with complex return type', () async {
      final result = batchLater(() {
        return {
          'id': 1,
          'nested': {
            'value': [1, 2, 3],
          },
        };
      });

      expect(result['id'], 1);
      expect(result['nested'], isA<Map>());

      await Future.microtask(() {});
    });
  });

  group('Edge Cases - Widget Lifecycle', () {
    testWidgets('batchLater during widget dispose', (tester) async {
      final counter = signal(0);
      final showWidget = signal(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Watch(builder: (_, __) {
            if (!showWidget.value) return const SizedBox();
            return Column(
              children: [
                ElevatedButton(
                  key: const Key('update'),
                  onPressed: () {
                    batchLater(() => counter.value++);
                  },
                  child: const Text('Update'),
                ),
                Watch(builder: (_, __) => Text('${counter.value}')),
              ],
            );
          }),
        ),
      );

      await tester.tap(find.byKey(const Key('update')));

      // Dispose widget while batchLater pending
      showWidget.value = false;
      await tester.pump();

      // Should not crash
      await Future.microtask(() {});
    });

    testWidgets('queueUpdate survives widget rebuild', (tester) async {
      final counter = signal(0);
      final trigger = signal(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Watch(builder: (_, __) {
            trigger.value; // Force rebuild on trigger change
            return Column(
              children: [
                ElevatedButton(
                  key: const Key('queue'),
                  onPressed: () {
                    queueUpdate(() => counter.value++);
                    trigger.value++; // Trigger rebuild
                  },
                  child: const Text('Queue'),
                ),
                Watch(builder: (_, __) => Text('${counter.value}')),
              ],
            );
          }),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('queue')));
      await tester.pump(); // Process the tap and rebuild
      await tester.pump(); // Process the microtask

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Edge Cases - Deep Nesting', () {
    test('deeply nested batchLater calls', () async {
      final counter = signal(0);
      var effectCount = 0;

      final eff = effect(() {
        counter.value;
        effectCount++;
      });
      effectCount = 0;

      batchLater(() {
        counter.value++;
        batchLater(() {
          counter.value++;
          batchLater(() {
            counter.value++;
            batchLater(() {
              counter.value++;
              batchLater(() {
                counter.value++;
              });
            });
          });
        });
      });

      expect(counter.value, 5);
      expect(effectCount, 0);

      await Future.microtask(() {});

      expect(effectCount, 1, reason: 'All nested calls share single flush');

      eff.stop();
    });

    test('deep nesting with queueUpdate', () async {
      final results = <int>[];

      queueUpdate(() {
        results.add(1);
        queueUpdate(() {
          results.add(2);
          queueUpdate(() {
            results.add(3);
          });
        });
      });

      await Future.microtask(() {});
      // First level executes
      expect(results.contains(1), true);

      await Future.microtask(() {});
      // Second level
      expect(results.contains(2), true);

      await Future.microtask(() {});
      // Third level
      expect(results.contains(3), true);
    });
  });

  group('Edge Cases - Computed and Effect Interaction', () {
    test('batchLater with computed dependencies', () async {
      final a = signal(1);
      final b = signal(2);
      final sum = computed((_) => a.value + b.value);
      var effectCount = 0;
      final values = <int>[];

      final eff = effect(() {
        values.add(sum.value);
        effectCount++;
      });
      effectCount = 0;
      values.clear();

      batchLater(() {
        a.value = 10;
        b.value = 20;
      });

      await Future.microtask(() {});

      expect(sum.value, 30);
      expect(effectCount, 1);
      expect(values, [30]); // Only final value

      eff.stop();
    });

    test('queueUpdate with diamond dependency', () async {
      final source = signal(1);
      final left = computed((_) => source.value * 2);
      final right = computed((_) => source.value * 3);
      final bottom = computed((_) => left.value + right.value);
      var effectCount = 0;

      final eff = effect(() {
        bottom.value;
        effectCount++;
      });
      effectCount = 0;

      queueUpdate(() => source.value = 10);

      await Future.microtask(() {});

      expect(bottom.value, 50); // 20 + 30
      expect(effectCount, 1);

      eff.stop();
    });
  });
}
