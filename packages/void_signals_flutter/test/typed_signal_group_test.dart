import 'package:flutter_test/flutter_test.dart';
import 'package:void_signals_flutter/void_signals_flutter.dart';

void main() {
  group('SignalGroup', () {
    test('create and access values', () {
      final group = SignalGroup({'count': 0, 'name': 'Alice'});

      expect(group.get<int>('count'), equals(0));
      expect(group.get<String>('name'), equals('Alice'));
    });

    test('set values', () {
      final group = SignalGroup({'count': 0});

      group.set('count', 10);
      expect(group.get<int>('count'), equals(10));
    });

    test('operator [] and []=', () {
      final group = SignalGroup({'x': 1, 'y': 2});

      expect(group['x'], equals(1));
      group['x'] = 100;
      expect(group['x'], equals(100));
    });

    test('values returns all current values', () {
      final group = SignalGroup({'a': 1, 'b': 'two'});

      expect(group.values, equals({'a': 1, 'b': 'two'}));
    });

    test('batch update', () {
      final group = SignalGroup({'x': 0, 'y': 0});

      int notifyCount = 0;
      group.watch((_) => notifyCount++);

      expect(notifyCount, equals(1));

      group.update({'x': 10, 'y': 20});

      expect(notifyCount, equals(2)); // Only one notification for batch
      expect(group['x'], equals(10));
      expect(group['y'], equals(20));
    });

    test('watch reacts to changes', () {
      final group = SignalGroup({'count': 0});

      final values = <int>[];
      group.watch((v) => values.add(v['count'] as int));

      expect(values, equals([0]));

      group['count'] = 1;
      expect(values, equals([0, 1]));

      group['count'] = 2;
      expect(values, equals([0, 1, 2]));
    });

    test('combine creates computed', () {
      final group = SignalGroup({'x': 10, 'y': 20});

      final sum = group.combine<int>((v) => (v['x'] as int) + (v['y'] as int));

      expect(sum.value, equals(30));

      group['x'] = 100;
      expect(sum.value, equals(120));
    });

    test('raw returns signal for watching', () {
      final group = SignalGroup({'count': 0});

      final rawSignal = group.raw('count');
      expect(rawSignal, isNotNull);

      // Can watch raw signal
      final doubled = computed((self) => (rawSignal!.value as int) * 2);
      expect(doubled.value, equals(0));

      group['count'] = 5;
      expect(doubled.value, equals(10));
    });

    test('keys, length, containsKey', () {
      final group = SignalGroup({'a': 1, 'b': 2, 'c': 3});

      expect(group.keys.toSet(), equals({'a', 'b', 'c'}));
      expect(group.length, equals(3));
      expect(group.containsKey('a'), isTrue);
      expect(group.containsKey('z'), isFalse);
    });

    test('signalGroup factory', () {
      final group = signalGroup({'x': 1, 'y': 2});

      expect(group.get<int>('x'), equals(1));
      expect(group.get<int>('y'), equals(2));
    });

    test('works with various types', () {
      final group = SignalGroup({
        'int': 42,
        'string': 'hello',
        'bool': true,
        'list': [1, 2, 3],
        'map': {'a': 1},
      });

      expect(group.get<int>('int'), equals(42));
      expect(group.get<String>('string'), equals('hello'));
      expect(group.get<bool>('bool'), isTrue);
      expect(group.get<List<int>>('list'), equals([1, 2, 3]));
      expect(group.get<Map<String, int>>('map'), equals({'a': 1}));
    });
  });
}
