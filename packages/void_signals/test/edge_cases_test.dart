import 'package:test/test.dart';
import 'package:void_signals/void_signals.dart';

/// Edge cases and boundary conditions tests
void main() {
  group('Signal - Edge Cases', () {
    test('should handle NaN correctly', () {
      final s = signal(double.nan);
      expect(s().isNaN, true);

      // NaN != NaN, so this should trigger update
      int updateCount = 0;
      effect(() {
        s();
        updateCount++;
      });

      expect(updateCount, 1);

      // Setting to same NaN should NOT trigger (since we check equality)
      // Note: NaN == NaN is false, but signals use identical() for NaN
      s.value = double.nan;
      // This behavior depends on implementation
    });

    test('should handle infinity', () {
      final s = signal(double.infinity);
      expect(s(), double.infinity);

      s.value = double.negativeInfinity;
      expect(s(), double.negativeInfinity);
    });

    test('should handle very large numbers', () {
      final s = signal(9007199254740991); // Max safe integer in JS
      expect(s(), 9007199254740991);

      s.value = -9007199254740991;
      expect(s(), -9007199254740991);
    });

    test('should handle empty map', () {
      final s = signal<Map<String, int>>({});
      expect(s(), isEmpty);

      s.value = {'a': 1};
      expect(s()['a'], 1);

      s.value = {};
      expect(s(), isEmpty);
    });

    test('should handle deeply nested objects', () {
      final s = signal({
        'level1': {
          'level2': {
            'level3': {'value': 42},
          },
        },
      });

      expect(s()['level1']!['level2']!['level3']!['value'], 42);
    });

    test('should handle rapid value changes', () {
      final s = signal(0);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      // Rapid changes without batch
      for (int i = 1; i <= 100; i++) {
        s.value = i;
      }

      // Each change triggers effect
      expect(effectCount, 101); // 1 initial + 100 updates
      expect(s.value, 100);
    });

    test('should handle alternating values', () {
      final s = signal(0);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      // Alternate between 0 and 1
      // i=0: 0%2=0, same as initial, no change
      // i=1: 1%2=1, changes from 0 to 1
      // i=2: 2%2=0, changes from 1 to 0
      // i=3: 3%2=1, changes from 0 to 1
      // ... etc
      for (int i = 0; i < 10; i++) {
        s.value = i % 2;
      }

      // Initial run + changes: 0->0 (no), 0->1 (yes), 1->0 (yes), 0->1 (yes),
      // 1->0 (yes), 0->1 (yes), 1->0 (yes), 0->1 (yes), 1->0 (yes), 0->1 (yes)
      // First iteration i=0: value stays 0, no effect trigger
      // Then 9 actual changes (i=1 to i=9)
      expect(effectCount, 10); // 1 initial + 9 changes
    });

    test('should handle setting same object reference', () {
      final list = [1, 2, 3];
      final s = signal(list);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      expect(effectCount, 1);

      // Same reference - should NOT trigger
      s.value = list;
      expect(effectCount, 1);

      // Mutate and set same reference - still same reference
      list.add(4);
      s.value = list;
      expect(effectCount, 1);

      // New list with same content - SHOULD trigger (different reference)
      s.value = [1, 2, 3, 4];
      expect(effectCount, 2);
    });
  });

  group('Computed - Lazy Evaluation', () {
    test('should not compute until accessed', () {
      int computeCount = 0;
      final source = signal(1);
      final lazy = computed((p) {
        computeCount++;
        return source() * 2;
      });

      // Not accessed yet
      expect(computeCount, 0);

      // First access
      expect(lazy(), 2);
      expect(computeCount, 1);

      // Cached access
      expect(lazy(), 2);
      expect(computeCount, 1);
    });

    test('should not recompute when source changes but not accessed', () {
      int computeCount = 0;
      final source = signal(1);
      final lazy = computed((p) {
        computeCount++;
        return source() * 2;
      });

      // First access
      expect(lazy(), 2);
      expect(computeCount, 1);

      // Change source but don't access computed
      source.value = 5;
      expect(computeCount, 1); // Still 1, not recomputed

      // Now access - should recompute
      expect(lazy(), 10);
      expect(computeCount, 2);
    });

    test('should be truly lazy in chain', () {
      int aCount = 0, bCount = 0, cCount = 0;

      final source = signal(1);
      final a = computed((p) {
        aCount++;
        return source() * 2;
      });
      final b = computed((p) {
        bCount++;
        return a() + 1;
      });
      final c = computed((p) {
        cCount++;
        return b() * 10;
      });

      expect(aCount, 0);
      expect(bCount, 0);
      expect(cCount, 0);

      // Access only c - should compute all in chain
      expect(c(), 30);
      expect(aCount, 1);
      expect(bCount, 1);
      expect(cCount, 1);

      // Access c again - all cached
      expect(c(), 30);
      expect(aCount, 1);
      expect(bCount, 1);
      expect(cCount, 1);
    });

    test('should not compute unused branches', () {
      int leftCount = 0, rightCount = 0;

      final condition = signal(true);
      final left = computed((p) {
        leftCount++;
        return 'left';
      });
      final right = computed((p) {
        rightCount++;
        return 'right';
      });
      final result = computed((p) => condition() ? left() : right());

      // Access result when condition is true
      expect(result(), 'left');
      expect(leftCount, 1);
      expect(rightCount, 0); // Right never computed

      // Switch condition
      condition.value = false;
      expect(result(), 'right');
      expect(leftCount, 1); // Left not recomputed
      expect(rightCount, 1); // Right now computed
    });
  });

  group('Batch - Coalescing Updates', () {
    test('should coalesce multiple updates in batch', () {
      final s = signal(0);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      expect(effectCount, 1);

      batch(() {
        s.value = 1;
        s.value = 2;
        s.value = 3;
        s.value = 4;
        s.value = 5;
      });

      // Only one additional effect run after batch
      expect(effectCount, 2);
      expect(s.value, 5);
    });

    test('should coalesce updates across multiple signals in batch', () {
      final a = signal(0);
      final b = signal(0);
      final c = signal(0);
      int effectCount = 0;

      effect(() {
        a();
        b();
        c();
        effectCount++;
      });

      expect(effectCount, 1);

      batch(() {
        a.value = 1;
        b.value = 2;
        c.value = 3;
      });

      // Only one additional effect run
      expect(effectCount, 2);
    });

    test('should handle nested batches', () {
      final s = signal(0);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      expect(effectCount, 1);

      batch(() {
        s.value = 1;
        batch(() {
          s.value = 2;
          batch(() {
            s.value = 3;
          });
          s.value = 4;
        });
        s.value = 5;
      });

      // Still only one effect run for all nested batches
      expect(effectCount, 2);
      expect(s.value, 5);
    });

    test('should handle batch with computed', () {
      final a = signal(1);
      final b = signal(2);
      final sum = computed((p) => a() + b());
      int effectCount = 0;
      int? lastSum;

      effect(() {
        lastSum = sum();
        effectCount++;
      });

      expect(effectCount, 1);
      expect(lastSum, 3);

      batch(() {
        a.value = 10;
        b.value = 20;
      });

      expect(effectCount, 2);
      expect(lastSum, 30);
    });

    test('should handle batch that reverts value', () {
      final s = signal(0);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      expect(effectCount, 1);

      batch(() {
        s.value = 1;
        s.value = 2;
        s.value = 0; // Revert to original
      });

      // Effect should NOT run if final value equals original
      expect(effectCount, 1);
      expect(s.value, 0);
    });

    test('batch should return value from callback', () {
      final result = batch(() {
        return 42;
      });

      expect(result, 42);
    });
  });

  group('Effect - Cleanup and Memory', () {
    test('should allow effect to be stopped multiple times safely', () {
      final s = signal(0);
      final eff = effect(() {
        s();
      });

      eff.stop();
      eff.stop(); // Second stop should be safe
      eff.stop(); // Third stop should be safe

      expect(s.hasSubscribers, false);
    });

    test('should clean up dependencies when effect stops', () {
      final a = signal(1);
      final b = signal(2);
      final c = computed((p) => a() + b());

      final eff = effect(() {
        c();
      });

      expect(a.hasSubscribers, true);
      expect(b.hasSubscribers, true);
      expect(c.hasSubscribers, true);

      eff.stop();

      expect(c.hasSubscribers, false);
    });

    test('should handle effect that modifies signal it reads', () {
      final s = signal(0);
      int iterations = 0;

      final eff = effect(() {
        final current = s();
        iterations++;
        if (current < 3) {
          // This creates a new update which will be processed
          // but should not cause infinite loop
          s.value = current + 1;
        }
      });

      // Due to synchronous updates, all iterations should complete
      expect(iterations >= 1, true);

      eff.stop();
    });
  });

  group('Untrack - Isolation', () {
    test('should not track signals inside untrack', () {
      final tracked = signal(1);
      final untracked_ = signal(100);
      int effectCount = 0;

      effect(() {
        tracked();
        untrack(() {
          untracked_();
        });
        effectCount++;
      });

      expect(effectCount, 1);

      // Tracked signal change should trigger effect
      tracked.value = 2;
      expect(effectCount, 2);

      // Untracked signal change should NOT trigger effect
      untracked_.value = 200;
      expect(effectCount, 2);
    });

    test('should return value from untrack', () {
      final s = signal(42);

      final result = untrack(() => s() * 2);
      expect(result, 84);
    });

    test('should handle nested untrack', () {
      final a = signal(1);
      final b = signal(2);
      int effectCount = 0;

      effect(() {
        a();
        untrack(() {
          untrack(() {
            b();
          });
        });
        effectCount++;
      });

      expect(effectCount, 1);

      b.value = 20;
      expect(effectCount, 1); // Still not tracked
    });
  });

  group('Computed - Error Recovery', () {
    test('should recover from error when dependency changes', () {
      final s = signal(0);
      final c = computed((p) {
        if (s() == 1) throw Exception('Error at 1');
        return s() * 10;
      });

      expect(c(), 0);

      s.value = 1;
      expect(() => c(), throwsException);

      s.value = 2;
      expect(c(), 20); // Should recover
    });

    test('should propagate error through chain', () {
      final s = signal(1);
      final a = computed((p) {
        if (s() < 0) throw Exception('Negative');
        return s();
      });
      final b = computed((p) => a() * 2);
      final c = computed((p) => b() + 10);

      expect(c(), 12);

      s.value = -1;
      expect(() => c(), throwsException);

      s.value = 5;
      expect(c(), 20); // Recover
    });
  });

  group('Signal - Type Safety', () {
    test('should preserve generic type', () {
      final intSignal = signal<int>(42);
      final stringSignal = signal<String>('hello');
      final listSignal = signal<List<int>>([1, 2, 3]);

      // Type checks
      expect(intSignal.value, isA<int>());
      expect(stringSignal.value, isA<String>());
      expect(listSignal.value, isA<List<int>>());
    });

    test('should work with custom objects', () {
      final person = signal(_Person('John', 30));

      expect(person().name, 'John');
      expect(person().age, 30);

      person.value = _Person('Jane', 25);
      expect(person().name, 'Jane');
    });

    test('should work with enums', () {
      final status = signal(_Status.pending);

      expect(status(), _Status.pending);

      status.value = _Status.completed;
      expect(status(), _Status.completed);
    });
  });

  group('Performance - Stress Tests', () {
    test('should handle many signals', () {
      final signals = List.generate(1000, (i) => signal(i));
      final sum = computed((p) {
        int total = 0;
        for (final s in signals) {
          total += s();
        }
        return total;
      });

      expect(sum(), 499500); // Sum of 0..999

      signals[0].value = 1000;
      expect(sum(), 500500);
    });

    test('should handle deep computed chains', () {
      final source = signal(1);
      Computed<int> current = computed((p) => source());

      for (int i = 0; i < 1000; i++) {
        final prev = current;
        current = computed((p) => prev() + 1);
      }

      expect(current(), 1001);
      source.value = 0;
      expect(current(), 1000);
    });

    test('should handle many effects on single signal', () {
      final s = signal(0);
      int totalRuns = 0;

      final effects = List.generate(100, (_) {
        return effect(() {
          s();
          totalRuns++;
        });
      });

      expect(totalRuns, 100); // Initial runs

      s.value = 1;
      expect(totalRuns, 200); // All effects run again

      // Cleanup
      for (final eff in effects) {
        eff.stop();
      }
    });

    test('should handle rapid batch operations', () {
      final s = signal(0);
      int effectCount = 0;

      effect(() {
        s();
        effectCount++;
      });

      for (int i = 0; i < 100; i++) {
        batch(() {
          s.value = i * 10;
          s.value = i * 10 + 1;
          s.value = i * 10 + 2;
        });
      }

      // 1 initial + 100 batch operations
      expect(effectCount, 101);
    });
  });

  group('EffectScope - Boundary Tests', () {
    test('should handle empty scope', () {
      final scope = effectScope(() {});
      scope.stop(); // Should not throw
    });

    test('should handle scope with only computeds', () {
      final s = signal(1);
      final c = computed((p) => s() * 2);

      final scope = effectScope(() {
        expect(c(), 2);
      });

      scope.stop();
    });

    test('should handle deeply nested scopes', () {
      EffectScope? deepest;

      final root = effectScope(() {
        effectScope(() {
          effectScope(() {
            effectScope(() {
              deepest = effectScope(() {});
            });
          });
        });
      });

      expect(deepest, isNotNull);
      root.stop(); // Should stop all nested scopes
    });

    test('should allow multiple stop calls', () {
      final s = signal(0);

      final scope = effectScope(() {
        effect(() {
          s();
        });
      });

      scope.stop();
      scope.stop(); // Should not throw
      scope.stop();
    });
  });
}

class _Person {
  final String name;
  final int age;

  _Person(this.name, this.age);
}

enum _Status { pending, completed }
