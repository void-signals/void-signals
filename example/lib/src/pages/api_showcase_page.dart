import 'dart:async';

import 'package:flutter/material.dart';
import 'package:void_signals_flutter/void_signals_flutter.dart';

/// API Showcase page demonstrating all major APIs
class ApiShowcasePage extends StatefulWidget {
  const ApiShowcasePage({super.key});

  @override
  State<ApiShowcasePage> createState() => _ApiShowcasePageState();
}

class _ApiShowcasePageState extends State<ApiShowcasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionTitle('Core: signal() + Watch()'),
          _SignalAndWatchDemo(),
          SizedBox(height: 24),
          _SectionTitle('WatchValue - Derived Value'),
          _WatchValueDemo(),
          SizedBox(height: 24),
          _SectionTitle('computed() - Derived State'),
          _ComputedDemo(),
          SizedBox(height: 24),
          _SectionTitle('signal.watch() - Extension'),
          _SignalWatchExtensionDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalBuilder - Explicit'),
          _SignalBuilderDemo(),
          SizedBox(height: 24),
          _SectionTitle('ComputedBuilder'),
          _ComputedBuilderDemo(),
          SizedBox(height: 24),
          _SectionTitle('MultiSignalBuilder'),
          _MultiSignalBuilderDemo(),
          SizedBox(height: 24),
          _SectionTitle('effect() - Side Effects'),
          _EffectDemo(),
          SizedBox(height: 24),
          _SectionTitle('batch() - Batched Updates'),
          _BatchDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalList - Reactive List'),
          _SignalListDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalMap - Reactive Map'),
          _SignalMapDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalSet - Reactive Set'),
          _SignalSetDemo(),
          SizedBox(height: 24),
          _SectionTitle('debounced() - Debounce'),
          _DebouncedDemo(),
          SizedBox(height: 24),
          _SectionTitle('throttled() - Throttle'),
          _ThrottledDemo(),
          SizedBox(height: 24),
          _SectionTitle('Combinators'),
          _CombinatorsDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalField - Form Validation'),
          _SignalFieldDemo(),
          SizedBox(height: 24),
          _SectionTitle('FormSignal - Form Management'),
          _FormSignalDemo(),
          SizedBox(height: 24),
          _SectionTitle('AsyncValue - Async State'),
          _AsyncValueDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalScope - Route Override'),
          _SignalScopeDemo(),
          SizedBox(height: 24),
          _SectionTitle('Integer/Bool Extensions'),
          _SignalExtensionsDemo(),
          SizedBox(height: 24),
          _SectionTitle('signal.modify() - Functional Update'),
          _ModifyDemo(),
          SizedBox(height: 24),
          _SectionTitle('peek() & untrack() - No Tracking'),
          _PeekUntrackDemo(),
          SizedBox(height: 24),
          _SectionTitle('effectScope() - Group Effects'),
          _EffectScopeDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalSelector - Partial Subscription'),
          _SignalSelectorDemo(),
          SizedBox(height: 24),
          _SectionTitle('AsyncSignalBuilder - Async Widget'),
          _AsyncSignalBuilderDemo(),
          SizedBox(height: 24),
          _SectionTitle('More Extensions'),
          _MoreExtensionsDemo(),
          SizedBox(height: 24),
          _SectionTitle('Consumer - Riverpod Style'),
          _ConsumerDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalGroup - Group Related Signals'),
          _SignalGroupDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalTuple - Tuple of Signals'),
          _SignalTupleDemo(),
          SizedBox(height: 24),
          _SectionTitle('delayed() - Fixed Delay'),
          _DelayedDemo(),
          SizedBox(height: 24),
          _SectionTitle('distinctUntilChanged() - Skip Duplicates'),
          _DistinctUntilChangedDemo(),
          SizedBox(height: 24),
          _SectionTitle('filtered() - Conditional Updates'),
          _FilteredDemo(),
          SizedBox(height: 24),
          _SectionTitle('batchLater() - Frame Batching'),
          _BatchLaterDemo(),
          SizedBox(height: 24),
          _SectionTitle('FrameBatchScope - Scoped Batching'),
          _FrameBatchScopeDemo(),
          SizedBox(height: 24),
          _SectionTitle('SignalObserver - Debug Logging'),
          _SignalObserverDemo(),
          SizedBox(height: 24),
          _SectionTitle('ReactiveStateMixin - Mixin Pattern'),
          _ReactiveStateMixinDemo(),
          SizedBox(height: 24),
          _SectionTitle('ComputedSelector - Select from Computed'),
          _ComputedSelectorDemo(),
          SizedBox(height: 24),
          _SectionTitle('asyncSignalFromStream - Stream to Signal'),
          _AsyncSignalFromStreamDemo(),
          SizedBox(height: 24),
          _SectionTitle('AsyncComputed - Async Computed Values'),
          _AsyncComputedDemo(),
          SizedBox(height: 24),
          _SectionTitle('StreamComputed - Stream with Dependencies'),
          _StreamComputedDemo(),
          SizedBox(height: 24),
          _SectionTitle('combineAsync - Combine Async Values'),
          _CombineAsyncDemo(),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final Widget child;

  const _DemoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

// ============================================================
// 1. signal() + Watch() - Core API
// ============================================================
class _SignalAndWatchDemo extends StatefulWidget {
  const _SignalAndWatchDemo();

  @override
  State<_SignalAndWatchDemo> createState() => _SignalAndWatchDemoState();
}

class _SignalAndWatchDemoState extends State<_SignalAndWatchDemo> {
  final counter = signal(0);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'signal() creates reactive state, Watch() rebuilds on change',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Count: ${counter.value}')),
              const Spacer(),
              IconButton(
                onPressed: () => counter.value--,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () => counter.value++,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 2. WatchValue - Derived Value
// ============================================================
class _WatchValueDemo extends StatefulWidget {
  const _WatchValueDemo();

  @override
  State<_WatchValueDemo> createState() => _WatchValueDemoState();
}

class _WatchValueDemoState extends State<_WatchValueDemo> {
  final count = signal(0);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WatchValue watches a getter function'),
          const SizedBox(height: 12),
          Row(
            children: [
              // Derived value: count * 10
              WatchValue<int>(
                getter: () => count.value * 10,
                builder: (ctx, value) => Text('count × 10 = $value'),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => count.value++,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3. computed() - Derived State
// ============================================================
class _ComputedDemo extends StatefulWidget {
  const _ComputedDemo();

  @override
  State<_ComputedDemo> createState() => _ComputedDemoState();
}

class _ComputedDemoState extends State<_ComputedDemo> {
  final firstName = signal('John');
  final lastName = signal('Doe');
  late final fullName = computed(
    (prev) => '${firstName.value} ${lastName.value}',
  );

  // TextEditingControllers should be created once in State, not in build
  late final _firstNameController = TextEditingController(
    text: firstName.value,
  );
  late final _lastNameController = TextEditingController(text: lastName.value);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('computed() creates derived state that caches its value'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    isDense: true,
                  ),
                  onChanged: (v) => firstName.value = v,
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    isDense: true,
                  ),
                  onChanged: (v) => lastName.value = v,
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Watch(builder: (ctx, _) => Text('Full name: ${fullName.value}')),
        ],
      ),
    );
  }
}

// ============================================================
// 4. signal.watch() - Extension method
// ============================================================
class _SignalWatchExtensionDemo extends StatefulWidget {
  const _SignalWatchExtensionDemo();

  @override
  State<_SignalWatchExtensionDemo> createState() =>
      _SignalWatchExtensionDemoState();
}

class _SignalWatchExtensionDemoState extends State<_SignalWatchExtensionDemo> {
  final counter = signal(0);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('signal.watch() is a shorthand extension'),
          const SizedBox(height: 12),
          Row(
            children: [
              // Using .watch() extension
              counter.watch((value) => Text('Value: $value')),
              const Spacer(),
              IconButton(
                onPressed: () => counter.value++,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 5. SignalBuilder - Explicit subscription
// ============================================================
class _SignalBuilderDemo extends StatefulWidget {
  const _SignalBuilderDemo();

  @override
  State<_SignalBuilderDemo> createState() => _SignalBuilderDemoState();
}

class _SignalBuilderDemoState extends State<_SignalBuilderDemo> {
  final counter = signal(0);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalBuilder explicitly subscribes to a signal'),
          const SizedBox(height: 12),
          Row(
            children: [
              SignalBuilder<int>(
                signal: counter,
                child: const Icon(Icons.favorite, color: Colors.red),
                builder:
                    (ctx, value, child) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [child!, Text(' $value likes')],
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => counter.value++,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 6. ComputedBuilder
// ============================================================
class _ComputedBuilderDemo extends StatefulWidget {
  const _ComputedBuilderDemo();

  @override
  State<_ComputedBuilderDemo> createState() => _ComputedBuilderDemoState();
}

class _ComputedBuilderDemoState extends State<_ComputedBuilderDemo> {
  final items = signal<List<int>>([1, 2, 3]);
  late final sum = computed((_) => items.value.fold(0, (a, b) => a + b));

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ComputedBuilder subscribes to a computed value'),
          const SizedBox(height: 12),
          Row(
            children: [
              ComputedBuilder<int>(
                computed: sum,
                builder: (ctx, value, _) => Text('Sum: $value'),
              ),
              const Spacer(),
              IconButton(
                onPressed:
                    () =>
                        items.value = [...items.value, items.value.length + 1],
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Watch(builder: (ctx, _) => Text('Items: ${items.value.join(", ")}')),
        ],
      ),
    );
  }
}

// ============================================================
// 7. MultiSignalBuilder
// ============================================================
class _MultiSignalBuilderDemo extends StatefulWidget {
  const _MultiSignalBuilderDemo();

  @override
  State<_MultiSignalBuilderDemo> createState() =>
      _MultiSignalBuilderDemoState();
}

class _MultiSignalBuilderDemoState extends State<_MultiSignalBuilderDemo> {
  final a = signal(1);
  final b = signal(2);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MultiSignalBuilder watches multiple signals'),
          const SizedBox(height: 12),
          Row(
            children: [
              MultiSignalBuilder(
                signals: [a, b],
                builder: (ctx, _) => Text('${a()} + ${b()} = ${a() + b()}'),
              ),
              const Spacer(),
              IconButton(onPressed: () => a.value++, icon: const Text('A+')),
              IconButton(onPressed: () => b.value++, icon: const Text('B+')),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 8. effect() - Side Effects
// ============================================================
class _EffectDemo extends StatefulWidget {
  const _EffectDemo();

  @override
  State<_EffectDemo> createState() => _EffectDemoState();
}

class _EffectDemoState extends State<_EffectDemo> {
  final counter = signal(0);
  final logs = signal<List<String>>([]);
  Effect? _effect;

  @override
  void initState() {
    super.initState();
    _effect = effect(() {
      logs.value = [...logs.value, 'Effect ran: counter = ${counter.value}'];
    });
  }

  @override
  void dispose() {
    _effect?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('effect() runs side effects when dependencies change'),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Counter: ${counter.value}')),
              const Spacer(),
              IconButton(
                onPressed: () => counter.value++,
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () => logs.value = [],
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          Watch(
            builder:
                (ctx, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      logs.value
                          .map(
                            (log) =>
                                Text(log, style: const TextStyle(fontSize: 12)),
                          )
                          .toList(),
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 9. batch() - Batched Updates
// ============================================================
class _BatchDemo extends StatefulWidget {
  const _BatchDemo();

  @override
  State<_BatchDemo> createState() => _BatchDemoState();
}

class _BatchDemoState extends State<_BatchDemo> {
  final a = signal(0);
  final b = signal(0);
  final effectCount = signal(0);
  Effect? _effect;

  @override
  void initState() {
    super.initState();
    _effect = effect(() {
      // Access both signals
      a.value;
      b.value;
      effectCount.value++;
    });
  }

  @override
  void dispose() {
    _effect?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('batch() groups multiple updates into one effect run'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Text(
                  'a=${a.value}, b=${b.value}, effect ran ${effectCount.value} times',
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Without batch - effect runs twice
                  a.value++;
                  b.value++;
                },
                child: const Text('Without batch'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // With batch - effect runs once
                  batch(() {
                    a.value++;
                    b.value++;
                  });
                },
                child: const Text('With batch'),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  effectCount.value = 0;
                  a.value = 0;
                  b.value = 0;
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 10. SignalList - Reactive List
// ============================================================
class _SignalListDemo extends StatefulWidget {
  const _SignalListDemo();

  @override
  State<_SignalListDemo> createState() => _SignalListDemoState();
}

class _SignalListDemoState extends State<_SignalListDemo> {
  final items = SignalList<String>(['Apple', 'Banana']);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalList provides reactive list operations'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Wrap(
                  spacing: 8,
                  children:
                      items.map((item) => Chip(label: Text(item))).toList(),
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => items.add('Item ${items.length + 1}'),
                child: const Text('Add'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => items.isNotEmpty ? items.removeLast() : null,
                child: const Text('Remove Last'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => items.clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 11. SignalMap - Reactive Map
// ============================================================
class _SignalMapDemo extends StatefulWidget {
  const _SignalMapDemo();

  @override
  State<_SignalMapDemo> createState() => _SignalMapDemoState();
}

class _SignalMapDemoState extends State<_SignalMapDemo> {
  final settings = SignalMap<String, dynamic>({
    'theme': 'dark',
    'fontSize': 14,
  });

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalMap provides reactive map operations'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      settings.keys
                          .map((k) => Text('$k: ${settings[k]}'))
                          .toList(),
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed:
                    () =>
                        settings['theme'] =
                            settings['theme'] == 'dark' ? 'light' : 'dark',
                child: const Text('Toggle Theme'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed:
                    () =>
                        settings['fontSize'] =
                            (settings['fontSize'] as int) + 1,
                child: const Text('Increase Font'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 12. SignalSet - Reactive Set
// ============================================================
class _SignalSetDemo extends StatefulWidget {
  const _SignalSetDemo();

  @override
  State<_SignalSetDemo> createState() => _SignalSetDemoState();
}

class _SignalSetDemoState extends State<_SignalSetDemo> {
  final selected = SignalSet<int>({1, 2});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalSet provides reactive set operations'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Wrap(
                  spacing: 8,
                  children:
                      [1, 2, 3, 4, 5].map((n) {
                        final isSelected = selected.contains(n);
                        return FilterChip(
                          label: Text('$n'),
                          selected: isSelected,
                          onSelected: (_) => selected.toggle(n),
                        );
                      }).toList(),
                ),
          ),
          Watch(
            builder:
                (ctx, _) =>
                    Text('Selected: ${selected.value.toList().join(", ")}'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 13. debounced() - Debounce
// ============================================================
class _DebouncedDemo extends StatefulWidget {
  const _DebouncedDemo();

  @override
  State<_DebouncedDemo> createState() => _DebouncedDemoState();
}

class _DebouncedDemoState extends State<_DebouncedDemo> {
  final input = signal('');
  late final debouncedInput = debounced(
    input,
    const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    debouncedInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('debounced() delays updates until input stops (500ms)'),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Type something...',
              isDense: true,
            ),
            onChanged: (v) => input.value = v,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Immediate: '),
              Watch(builder: (ctx, _) => Text(input.value)),
            ],
          ),
          Row(
            children: [
              const Text('Debounced: '),
              Watch(builder: (ctx, _) => Text(debouncedInput.value)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 14. throttled() - Throttle
// ============================================================
class _ThrottledDemo extends StatefulWidget {
  const _ThrottledDemo();

  @override
  State<_ThrottledDemo> createState() => _ThrottledDemoState();
}

class _ThrottledDemoState extends State<_ThrottledDemo> {
  final clickCount = signal(0);
  late final throttledCount = throttled(clickCount, const Duration(seconds: 1));

  @override
  void dispose() {
    throttledCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('throttled() limits updates to once per duration (1s)'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => clickCount.value++,
                child: const Text('Click rapidly!'),
              ),
              const Spacer(),
              Watch(
                builder: (ctx, _) => Text('Immediate: ${clickCount.value}'),
              ),
              const SizedBox(width: 16),
              Watch(
                builder: (ctx, _) => Text('Throttled: ${throttledCount.value}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 15. Combinators
// ============================================================
class _CombinatorsDemo extends StatefulWidget {
  const _CombinatorsDemo();

  @override
  State<_CombinatorsDemo> createState() => _CombinatorsDemoState();
}

class _CombinatorsDemoState extends State<_CombinatorsDemo> {
  final a = signal(5);
  final b = signal(3);
  late final mappedA = mapped(a, (v) => v * 2);
  late final combined = combine2(a, b, (x, y) => x + y);
  late final Computed<int> current;
  late final Computed<int?> previous;

  @override
  void initState() {
    super.initState();
    final result = withPrevious(a);
    current = result.$1;
    previous = result.$2;
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Combinators: mapped, combine2, withPrevious'),
          const SizedBox(height: 12),
          Watch(builder: (ctx, _) => Text('a = ${a.value}, b = ${b.value}')),
          Watch(builder: (ctx, _) => Text('mapped(a, x2) = ${mappedA.value}')),
          Watch(
            builder: (ctx, _) => Text('combine2(a, b, +) = ${combined.value}'),
          ),
          Watch(
            builder:
                (ctx, _) => Text(
                  'withPrevious: current=${current.value}, prev=${previous.value ?? "null"}',
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => a.value++,
                child: const Text('a++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => b.value++,
                child: const Text('b++'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 16. SignalField - Form Validation
// ============================================================
class _SignalFieldDemo extends StatefulWidget {
  const _SignalFieldDemo();

  @override
  State<_SignalFieldDemo> createState() => _SignalFieldDemoState();
}

class _SignalFieldDemoState extends State<_SignalFieldDemo> {
  late final emailField = SignalField<String>(
    initialValue: '',
    validators: [
      requiredValidator('Email is required'),
      emailValidator('Invalid email format'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalField provides reactive form validation'),
          const SizedBox(height: 12),
          SignalFieldBuilder<String>(
            field: emailField,
            builder:
                (ctx, value, error, field) => TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: error,
                    isDense: true,
                  ),
                  onChanged: (v) => field.value = v,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Watch(
                builder:
                    (ctx, _) =>
                        Text('Valid: ${emailField.isValid ? "✅" : "❌"}'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => emailField.reset(),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 17. FormSignal - Form Management
// ============================================================
class _FormSignalDemo extends StatefulWidget {
  const _FormSignalDemo();

  @override
  State<_FormSignalDemo> createState() => _FormSignalDemoState();
}

class _FormSignalDemoState extends State<_FormSignalDemo> {
  late final form = FormSignal({
    'username': SignalField<String>(
      initialValue: '',
      validators: [
        requiredValidator('Username is required'),
        minLengthValidator(3, 'At least 3 characters'),
      ],
    ),
    'password': SignalField<String>(
      initialValue: '',
      validators: [
        requiredValidator('Password is required'),
        minLengthValidator(6, 'At least 6 characters'),
      ],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FormSignal manages multiple form fields'),
          const SizedBox(height: 12),
          SignalFieldBuilder<String>(
            field: form.field<String>('username')!,
            builder:
                (ctx, value, error, field) => TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: error,
                    isDense: true,
                  ),
                  onChanged: (v) => field.value = v,
                ),
          ),
          const SizedBox(height: 8),
          SignalFieldBuilder<String>(
            field: form.field<String>('password')!,
            builder:
                (ctx, value, error, field) => TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: error,
                    isDense: true,
                  ),
                  obscureText: true,
                  onChanged: (v) => field.value = v,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Watch(
                builder:
                    (ctx, _) => Text('Form valid: ${form.isValid ? "✅" : "❌"}'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (form.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form submitted: ${form.values}')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => form.reset(),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 18. AsyncValue - Async State
// ============================================================
class _AsyncValueDemo extends StatefulWidget {
  const _AsyncValueDemo();

  @override
  State<_AsyncValueDemo> createState() => _AsyncValueDemoState();
}

class _AsyncValueDemoState extends State<_AsyncValueDemo> {
  final data = signal<AsyncValue<String>>(const AsyncLoading());

  Future<void> _load() async {
    data.value = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    // Randomly succeed or fail
    if (DateTime.now().millisecond % 2 == 0) {
      data.value = const AsyncData('Hello from async!');
    } else {
      data.value = AsyncError('Random error', StackTrace.current);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AsyncValue represents loading/data/error states'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => data.value.when(
                  loading:
                      () => const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      ),
                  data: (value) => Text('✅ $value'),
                  error: (error, _) => Text('❌ Error: $error'),
                ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _load,
            child: const Text('Reload (random success/fail)'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 19. SignalScope - Route Override
// ============================================================
final _globalCounter = signal(0);

class _SignalScopeDemo extends StatelessWidget {
  const _SignalScopeDemo();

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalScope overrides signals for a subtree'),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(
                builder: (ctx, _) => Text('Global: ${_globalCounter.value}'),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _globalCounter.value++,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Scoped override
          SignalScope(
            overrides: [_globalCounter.override(100)],
            child: Builder(
              builder: (context) {
                final scoped = _globalCounter.scoped(context);
                return Row(
                  children: [
                    Watch(builder: (ctx, _) => Text('Scoped: ${scoped.value}')),
                    const Spacer(),
                    IconButton(
                      onPressed: () => scoped.value++,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                );
              },
            ),
          ),
          const Text(
            'The scoped counter is independent!',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 20. Integer/Bool Extensions
// ============================================================
class _SignalExtensionsDemo extends StatefulWidget {
  const _SignalExtensionsDemo();

  @override
  State<_SignalExtensionsDemo> createState() => _SignalExtensionsDemoState();
}

class _SignalExtensionsDemoState extends State<_SignalExtensionsDemo> {
  final counter = signal(0);
  final isActive = signal(false);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Extension methods for common operations'),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Counter: ${counter.value}')),
              const Spacer(),
              ElevatedButton(
                onPressed: () => counter.increment(),
                child: const Text('increment()'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => counter.decrement(),
                child: const Text('decrement()'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Active: ${isActive.value}')),
              const Spacer(),
              ElevatedButton(
                onPressed: () => isActive.toggle(),
                child: const Text('toggle()'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 21. modify() - Functional Update
// ============================================================
class _ModifyDemo extends StatefulWidget {
  const _ModifyDemo();

  @override
  State<_ModifyDemo> createState() => _ModifyDemoState();
}

class _ModifyDemoState extends State<_ModifyDemo> {
  final user = signal({'name': 'John', 'age': 25});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('modify() updates value with a function'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Text(
                  'User: ${user.value['name']}, Age: ${user.value['age']}',
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Use modify to update immutably
                  user.modify((u) => {...u, 'age': (u['age'] as int) + 1});
                },
                child: const Text('Increment Age'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  user.modify((u) => {...u, 'name': 'Jane'});
                },
                child: const Text('Change Name'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 22. peek() & untrack() - No Tracking
// ============================================================
class _PeekUntrackDemo extends StatefulWidget {
  const _PeekUntrackDemo();

  @override
  State<_PeekUntrackDemo> createState() => _PeekUntrackDemoState();
}

class _PeekUntrackDemoState extends State<_PeekUntrackDemo> {
  final counter = signal(0);
  final other = signal(100);
  final logs = signal<List<String>>([]);
  Effect? _effect;

  @override
  void initState() {
    super.initState();
    _effect = effect(() {
      // Access counter normally (tracked)
      final count = counter.value;
      // Access other with peek/untrack (NOT tracked)
      final otherPeeked = other.peek();
      final otherUntracked = untrack(() => other.value);
      logs.value = [
        ...logs.value,
        'Effect: count=$count, other(peek)=$otherPeeked, other(untrack)=$otherUntracked',
      ];
    });
  }

  @override
  void dispose() {
    _effect?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('peek() reads without tracking, untrack() runs untracked'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => counter.value++,
                child: const Text('counter++ (triggers)'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => other.value++,
                child: const Text('other++ (no trigger)'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => logs.value = [],
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: Watch(
              builder:
                  (ctx, _) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          logs.value
                              .map(
                                (l) => Text(
                                  l,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                              .toList(),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 23. effectScope() - Group Effects
// ============================================================
class _EffectScopeDemo extends StatefulWidget {
  const _EffectScopeDemo();

  @override
  State<_EffectScopeDemo> createState() => _EffectScopeDemoState();
}

class _EffectScopeDemoState extends State<_EffectScopeDemo> {
  final counter = signal(0);
  final logs = signal<List<String>>([]);
  EffectScope? _scope;

  void _createScope() {
    _scope?.stop();
    logs.value = [...logs.value, 'Scope created with 2 effects'];
    _scope = effectScope(() {
      effect(() {
        logs.value = [...logs.value, 'Effect 1: counter = ${counter.value}'];
      });
      effect(() {
        logs.value = [
          ...logs.value,
          'Effect 2: doubled = ${counter.value * 2}',
        ];
      });
    });
  }

  void _stopScope() {
    _scope?.stop();
    _scope = null;
    logs.value = [...logs.value, 'Scope stopped - all effects cleaned up'];
  }

  @override
  void dispose() {
    _scope?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('effectScope() groups effects for batch cleanup'),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _createScope,
                child: const Text('Create Scope'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => counter.value++,
                child: const Text('counter++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _stopScope,
                child: const Text('Stop Scope'),
              ),
              IconButton(
                onPressed: () => logs.value = [],
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: Watch(
              builder:
                  (ctx, _) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          logs.value
                              .map(
                                (l) => Text(
                                  l,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                              .toList(),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 24. SignalSelector - Partial Subscription
// ============================================================

class _User {
  final String name;
  final int age;
  final String email;

  const _User({required this.name, required this.age, required this.email});

  _User copyWith({String? name, int? age, String? email}) {
    return _User(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }
}

class _SignalSelectorDemo extends StatefulWidget {
  const _SignalSelectorDemo();

  @override
  State<_SignalSelectorDemo> createState() => _SignalSelectorDemoState();
}

class _SignalSelectorDemoState extends State<_SignalSelectorDemo> {
  final user = signal(
    const _User(name: 'John', age: 25, email: 'john@example.com'),
  );

  int nameRebuilds = 0;
  int ageRebuilds = 0;

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SignalSelector only rebuilds when selected value changes',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SignalSelector<_User, String>(
                  signal: user,
                  selector: (u) => u.name,
                  builder: (ctx, name, _) {
                    nameRebuilds++;
                    return Text('Name: $name (rebuilds: $nameRebuilds)');
                  },
                ),
              ),
              Expanded(
                child: SignalSelector<_User, int>(
                  signal: user,
                  selector: (u) => u.age,
                  builder: (ctx, age, _) {
                    ageRebuilds++;
                    return Text('Age: $age (rebuilds: $ageRebuilds)');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  user.value = user.value.copyWith(name: 'Jane');
                },
                child: const Text('Change Name'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  user.value = user.value.copyWith(age: user.value.age + 1);
                },
                child: const Text('Increment Age'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  user.value = user.value.copyWith(email: 'new@email.com');
                },
                child: const Text('Change Email (no rebuild)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 25. AsyncSignalBuilder - Async Widget
// ============================================================
class _AsyncSignalBuilderDemo extends StatefulWidget {
  const _AsyncSignalBuilderDemo();

  @override
  State<_AsyncSignalBuilderDemo> createState() =>
      _AsyncSignalBuilderDemoState();
}

class _AsyncSignalBuilderDemoState extends State<_AsyncSignalBuilderDemo> {
  late Signal<AsyncValue<String>> dataSignal;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    dataSignal = asyncSignal(
      Future.delayed(
        const Duration(seconds: 1),
        () => 'Data loaded at ${DateTime.now().toIso8601String()}',
      ),
    );
    setState(() {}); // Recreate widget with new signal
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AsyncSignalBuilder handles loading/data/error states'),
          const SizedBox(height: 12),
          AsyncSignalBuilder<String>(
            signal: dataSignal,
            loading:
                (ctx) => const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Loading...'),
                  ],
                ),
            data: (ctx, value) => Text('✅ $value'),
            error: (ctx, error, stackTrace) => Text('❌ Error: $error'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadData, child: const Text('Reload')),
        ],
      ),
    );
  }
}

// ============================================================
// 26. More Extensions
// ============================================================
class _MoreExtensionsDemo extends StatefulWidget {
  const _MoreExtensionsDemo();

  @override
  State<_MoreExtensionsDemo> createState() => _MoreExtensionsDemoState();
}

class _MoreExtensionsDemoState extends State<_MoreExtensionsDemo> {
  final list = signal<List<int>>([1, 2, 3]);
  final map = signal<Map<String, int>>({'a': 1, 'b': 2});
  final nullable = signal<String?>(null);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('List, Map, Nullable extensions'),
          const SizedBox(height: 12),
          // List extensions
          Watch(builder: (ctx, _) => Text('List: ${list.value.join(", ")}')),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => list.add(list.value.length + 1),
                child: const Text('add()'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed:
                    () =>
                        list.value.isNotEmpty
                            ? list.remove(list.value.last)
                            : null,
                child: const Text('remove()'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => list.clear(),
                child: const Text('clear()'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Map extensions
          Watch(builder: (ctx, _) => Text('Map: ${map.value}')),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => map.set('c', 3),
                child: const Text('set("c", 3)'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => map.remove('c'),
                child: const Text('remove("c")'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Nullable extensions
          Watch(
            builder:
                (ctx, _) => Text('Nullable: ${nullable.value ?? "(null)"}'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => nullable.value = 'Hello!',
                child: const Text('Set value'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => nullable.clear(),
                child: const Text('clear()'),
              ),
              const SizedBox(width: 4),
              Text('orDefault: ${nullable.orDefault("default")}'),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 27. Consumer - Riverpod Style API
// ============================================================
final _consumerCounter = signal(0);

class _ConsumerDemo extends StatelessWidget {
  const _ConsumerDemo();

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Consumer provides ref.watch/read (Riverpod-style)'),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(_consumerCounter);
              return Row(
                children: [Text('Count: $count'), const Spacer(), child!],
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _consumerCounter.value--,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () => _consumerCounter.value++,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ref.watch() tracks, ref.read() doesn\'t track',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 28. SignalGroup - Group Related Signals
// ============================================================
class _SignalGroupDemo extends StatefulWidget {
  const _SignalGroupDemo();

  @override
  State<_SignalGroupDemo> createState() => _SignalGroupDemoState();
}

class _SignalGroupDemoState extends State<_SignalGroupDemo> {
  // SignalGroup manages multiple named signals together
  late final group = SignalGroup({'count': 0, 'name': 'Alice', 'active': true});

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalGroup groups multiple named signals'),
          const SizedBox(height: 12),
          // Use raw() to get the signal for watching
          Watch(
            builder: (ctx, _) {
              // Access raw signals to trigger reactivity
              group.raw('count')?.value;
              group.raw('name')?.value;
              group.raw('active')?.value;
              // Use get<T> for typed access
              final count = group.get<int>('count');
              final name = group.get<String>('name');
              final active = group.get<bool>('active');
              return Text('count: $count, name: $name, active: $active');
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => group['count'] = (group['count'] as int) + 1,
                child: const Text('count++'),
              ),
              ElevatedButton(
                onPressed: () {
                  group['name'] = group['name'] == 'Alice' ? 'Bob' : 'Alice';
                },
                child: const Text('Toggle name'),
              ),
              ElevatedButton(
                onPressed: () {
                  group['active'] = !(group['active'] as bool);
                },
                child: const Text('Toggle active'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'update() updates multiple values atomically',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          ElevatedButton(
            onPressed: () {
              group.update({'count': 0, 'name': 'Alice', 'active': true});
            },
            child: const Text('Reset All (update)'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 29. SignalTuple - Tuple of Signals
// ============================================================
class _SignalTupleDemo extends StatefulWidget {
  const _SignalTupleDemo();

  @override
  State<_SignalTupleDemo> createState() => _SignalTupleDemoState();
}

class _SignalTupleDemoState extends State<_SignalTupleDemo> {
  late final tuple = signalTuple3(10, 20, 30);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SignalTuple bundles signals with type-safe access'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Text(
                  'x: ${tuple.$1.value}, y: ${tuple.$2.value}, z: ${tuple.$3.value}',
                ),
          ),
          Watch(
            builder:
                (ctx, _) => Text(
                  'Sum: ${tuple.$1.value + tuple.$2.value + tuple.$3.value}',
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => tuple.$1.value++,
                child: const Text('x++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => tuple.$2.value++,
                child: const Text('y++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => tuple.$3.value++,
                child: const Text('z++'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 30. delayed() - Fixed Delay
// ============================================================
class _DelayedDemo extends StatefulWidget {
  const _DelayedDemo();

  @override
  State<_DelayedDemo> createState() => _DelayedDemoState();
}

class _DelayedDemoState extends State<_DelayedDemo> {
  final input = signal('');
  late final delayedInput = delayed(input, const Duration(milliseconds: 500));

  @override
  void dispose() {
    delayedInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('delayed() adds a fixed delay to every update'),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Type something...',
              isDense: true,
            ),
            onChanged: (v) => input.value = v,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Immediate: '),
              Expanded(child: Watch(builder: (ctx, _) => Text(input.value))),
            ],
          ),
          Row(
            children: [
              const Text('Delayed (500ms): '),
              Expanded(
                child: Watch(builder: (ctx, _) => Text(delayedInput.value)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Unlike debounce, delayed waits for EVERY change',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 31. distinctUntilChanged() - Skip Duplicates
// ============================================================
class _DistinctUntilChangedDemo extends StatefulWidget {
  const _DistinctUntilChangedDemo();

  @override
  State<_DistinctUntilChangedDemo> createState() =>
      _DistinctUntilChangedDemoState();
}

class _DistinctUntilChangedDemoState extends State<_DistinctUntilChangedDemo> {
  final source = signal(0);
  late final distinct = distinctUntilChanged(source);
  final logs = signal<List<String>>([]);
  Effect? _effect;

  @override
  void initState() {
    super.initState();
    _effect = effect(() {
      logs.value = [...logs.value, 'Distinct updated: ${distinct.value}'];
    });
  }

  @override
  void dispose() {
    _effect?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('distinctUntilChanged() skips duplicate values'),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Source: ${source.value}')),
              const SizedBox(width: 16),
              Watch(builder: (ctx, _) => Text('Distinct: ${distinct.value}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => source.value++,
                child: const Text('Increment (new value)'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => source.value = source.value,
                child: const Text('Set same (skipped)'),
              ),
              IconButton(
                onPressed: () => logs.value = [],
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: Watch(
              builder:
                  (ctx, _) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          logs.value
                              .map(
                                (l) => Text(
                                  l,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                              .toList(),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 32. filtered() - Conditional Updates
// ============================================================
class _FilteredDemo extends StatefulWidget {
  const _FilteredDemo();

  @override
  State<_FilteredDemo> createState() => _FilteredDemoState();
}

class _FilteredDemoState extends State<_FilteredDemo> {
  final source = signal(0);
  // Only pass through even numbers
  late final evenOnly = filtered(source, (value) => value % 2 == 0);

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('filtered() only passes values matching a condition'),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Source: ${source.value}')),
              const SizedBox(width: 16),
              Watch(builder: (ctx, _) => Text('Even only: ${evenOnly.value}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => source.value++,
                child: const Text('source++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => source.value = 0,
                child: const Text('Reset to 0'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Only even values pass through (0, 2, 4, ...)',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 33. batchLater() - Frame Batching
// ============================================================
class _BatchLaterDemo extends StatefulWidget {
  const _BatchLaterDemo();

  @override
  State<_BatchLaterDemo> createState() => _BatchLaterDemoState();
}

class _BatchLaterDemoState extends State<_BatchLaterDemo> {
  final a = signal(0);
  final b = signal(0);
  final effectCount = signal(0);
  Effect? _effect;

  @override
  void initState() {
    super.initState();
    _effect = effect(() {
      a.value;
      b.value;
      effectCount.value++;
    });
  }

  @override
  void dispose() {
    _effect?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('batchLater() defers updates to next frame (async batch)'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Text(
                  'a=${a.value}, b=${b.value}, effects=${effectCount.value}',
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Immediate batch - synchronous
                  batch(() {
                    a.value++;
                    b.value++;
                  });
                },
                child: const Text('batch()'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Deferred batch - async, combines across frames
                  batchLater(() {
                    a.value++;
                    b.value++;
                  });
                },
                child: const Text('batchLater()'),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  effectCount.value = 0;
                  a.value = 0;
                  b.value = 0;
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const Text(
            'batchLater is useful for cross-widget updates',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 34. FrameBatchScope - Scoped Batching
// ============================================================
class _FrameBatchScopeDemo extends StatefulWidget {
  const _FrameBatchScopeDemo();

  @override
  State<_FrameBatchScopeDemo> createState() => _FrameBatchScopeDemoState();
}

class _FrameBatchScopeDemoState extends State<_FrameBatchScopeDemo> {
  final counter1 = signal(0);
  final counter2 = signal(0);
  final batchCount = signal(0);
  Effect? _effect;

  @override
  void initState() {
    super.initState();
    _effect = effect(() {
      counter1.value;
      counter2.value;
      batchCount.value++;
    });
  }

  @override
  void dispose() {
    _effect?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FrameBatchScope.update() queues updates for batching'),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => Text(
                  'c1=${counter1.value}, c2=${counter2.value}, batches=${batchCount.value}',
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // These queue updates that get batched together
                  queueUpdate(() => counter1.value++);
                },
                child: const Text('c1++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  queueUpdate(() => counter2.value++);
                },
                child: const Text('c2++'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Both queued in same frame = single batch
                  queueUpdate(() => counter1.value++);
                  queueUpdate(() => counter2.value++);
                },
                child: const Text('Both (1 batch)'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'queueUpdate() defers updates to run in a single batch',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// Helper widget removed - no longer needed

// ============================================================
// 35. SignalObserver - Debug Logging
// ============================================================
class _SignalObserverDemo extends StatefulWidget {
  const _SignalObserverDemo();

  @override
  State<_SignalObserverDemo> createState() => _SignalObserverDemoState();
}

class _SignalObserverDemoState extends State<_SignalObserverDemo> {
  final logs = signal<List<String>>([]);
  Signal<int>? _observedSignal;

  void _createObservedSignal() {
    // Create a signal and register it for debug tracking
    _observedSignal = signal(0);
    VoidSignalsDebugService.tracker.trackSignal(
      _observedSignal!,
      label: 'ObservedCounter',
    );
    logs.value = [...logs.value, 'Created signal with label "ObservedCounter"'];
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VoidSignalsDebugService tracks signals for DevTools'),
          const SizedBox(height: 12),
          if (_observedSignal != null)
            Watch(
              builder: (ctx, _) => Text('Value: ${_observedSignal!.value}'),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_observedSignal == null)
                ElevatedButton(
                  onPressed: _createObservedSignal,
                  child: const Text('Create Tracked Signal'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    _observedSignal!.value++;
                    logs.value = [
                      ...logs.value,
                      'Updated to ${_observedSignal!.value}',
                    ];
                  },
                  child: const Text('Increment'),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => logs.value = [],
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: Watch(
              builder:
                  (ctx, _) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          logs.value
                              .map(
                                (l) => Text(
                                  l,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                              .toList(),
                    ),
                  ),
            ),
          ),
          const Text(
            'Check DevTools extension for signal inspection',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 36. ReactiveStateMixin - Mixin Pattern
// ============================================================
class _ReactiveStateMixinDemo extends StatefulWidget {
  const _ReactiveStateMixinDemo();

  @override
  State<_ReactiveStateMixinDemo> createState() =>
      _ReactiveStateMixinDemoState();
}

class _ReactiveStateMixinDemoState extends State<_ReactiveStateMixinDemo>
    with ReactiveStateMixin<_ReactiveStateMixinDemo> {
  final counter = signal(0);
  late final doubled = computed((_) => counter.value * 2);
  final logs = signal<List<String>>([]);

  @override
  void initState() {
    super.initState();
    // Initialize reactive effects that auto-dispose with the widget
    initReactive(() {
      effect(() {
        logs.value = [...logs.value, 'Counter changed to ${counter.value}'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ReactiveStateMixin auto-disposes effects on unmount'),
          const SizedBox(height: 12),
          Row(
            children: [
              Watch(builder: (ctx, _) => Text('Counter: ${counter.value}')),
              const SizedBox(width: 16),
              Watch(builder: (ctx, _) => Text('Doubled: ${doubled.value}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => counter.value++,
                child: const Text('Increment'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  counter.value = 0;
                  logs.value = [];
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: Watch(
              builder:
                  (ctx, _) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          logs.value
                              .take(3)
                              .map(
                                (l) => Text(
                                  l,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              )
                              .toList(),
                    ),
                  ),
            ),
          ),
          const Text(
            'Effects in initReactive() are auto-disposed',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 37. ComputedSelector - Select from Computed
// ============================================================
class _ComputedSelectorDemo extends StatefulWidget {
  const _ComputedSelectorDemo();

  @override
  State<_ComputedSelectorDemo> createState() => _ComputedSelectorDemoState();
}

class _ComputedSelectorDemoState extends State<_ComputedSelectorDemo> {
  final items = signal<List<int>>([1, 2, 3, 4, 5]);
  late final stats = computed(
    (_) => {
      'sum': items.value.fold(0, (a, b) => a + b),
      'count': items.value.length,
      'avg':
          items.value.isEmpty
              ? 0.0
              : items.value.fold(0, (a, b) => a + b) / items.value.length,
    },
  );

  int sumRebuilds = 0;
  int countRebuilds = 0;

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ComputedSelector selects from computed values'),
          const SizedBox(height: 12),
          Watch(builder: (ctx, _) => Text('Items: ${items.value.join(", ")}')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ComputedSelector<Map<String, dynamic>, int>(
                  computed: stats,
                  selector: (s) => s['sum'] as int,
                  builder: (ctx, sum, _) {
                    sumRebuilds++;
                    return Text('Sum: $sum (rebuilds: $sumRebuilds)');
                  },
                ),
              ),
              Expanded(
                child: ComputedSelector<Map<String, dynamic>, int>(
                  computed: stats,
                  selector: (s) => s['count'] as int,
                  builder: (ctx, count, _) {
                    countRebuilds++;
                    return Text('Count: $count (rebuilds: $countRebuilds)');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  items.value = [...items.value, items.value.length + 1];
                },
                child: const Text('Add item'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (items.value.isNotEmpty) {
                    items.value = items.value.sublist(
                      0,
                      items.value.length - 1,
                    );
                  }
                },
                child: const Text('Remove item'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 38. asyncSignalFromStream - Stream to Signal
// ============================================================
class _AsyncSignalFromStreamDemo extends StatefulWidget {
  const _AsyncSignalFromStreamDemo();

  @override
  State<_AsyncSignalFromStreamDemo> createState() =>
      _AsyncSignalFromStreamDemoState();
}

class _AsyncSignalFromStreamDemoState
    extends State<_AsyncSignalFromStreamDemo> {
  late final StreamController<int> _controller;
  late final Signal<AsyncValue<int>> _streamSignal;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<int>.broadcast();
    _streamSignal = asyncSignalFromStream(_controller.stream);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'asyncSignalFromStream converts Stream to AsyncValue signal',
          ),
          const SizedBox(height: 12),
          Watch(
            builder:
                (ctx, _) => _streamSignal.value.when(
                  loading: () => const Text('Waiting for stream data...'),
                  data: (value) => Text('Stream value: $value'),
                  error: (e, _) => Text('Error: $e'),
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _controller.add(DateTime.now().second),
                child: const Text('Emit value'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _controller.addError('Simulated error'),
                child: const Text('Emit error'),
              ),
            ],
          ),
          const Text(
            'Great for listening to Streams reactively',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AsyncComputed - Async Computed Values
// ============================================================
class _AsyncComputedDemo extends StatefulWidget {
  const _AsyncComputedDemo();

  @override
  State<_AsyncComputedDemo> createState() => _AsyncComputedDemoState();
}

class _AsyncComputedDemoState extends State<_AsyncComputedDemo> {
  final userId = signal(1);
  late final AsyncComputed<String> userData;

  @override
  void initState() {
    super.initState();
    // AsyncComputed automatically tracks signal dependencies (before await)
    userData = asyncComputed(() async {
      final id = userId(); // This is tracked as a dependency
      await Future.delayed(const Duration(milliseconds: 800));
      // Simulate random success/failure
      if (id % 3 == 0) {
        throw Exception('Failed to fetch user $id');
      }
      return 'User #$id: ${_randomName(id)}';
    });
  }

  String _randomName(int id) {
    const names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'];
    return names[id % names.length];
  }

  @override
  void dispose() {
    userData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AsyncComputed automatically tracks signal dependencies and '
            'refetches when they change.',
          ),
          const SizedBox(height: 12),
          Watch(
            builder: (ctx, _) {
              return userData.value.when(
                loading:
                    () => const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Fetching user...'),
                      ],
                    ),
                data: (value) => Text('✅ $value'),
                error: (error, _) => Text('❌ $error'),
              );
            },
          ),
          const SizedBox(height: 8),
          Watch(builder: (ctx, _) => Text('Current userId: ${userId()}')),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => userId.value++,
                child: const Text('Next User'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => userData.refresh(),
                child: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tip: User IDs divisible by 3 will fail',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// StreamComputed - Stream with Dependencies
// ============================================================
class _StreamComputedDemo extends StatefulWidget {
  const _StreamComputedDemo();

  @override
  State<_StreamComputedDemo> createState() => _StreamComputedDemoState();
}

class _StreamComputedDemoState extends State<_StreamComputedDemo> {
  final interval = signal(1);
  late final StreamComputed<int> counter;

  @override
  void initState() {
    super.initState();
    // StreamComputed subscribes to a stream that depends on signals
    counter = streamComputed(() {
      final seconds = interval(); // Tracked dependency
      // When interval changes, automatically resubscribes to new stream
      return Stream.periodic(Duration(seconds: seconds), (i) => i + 1);
    });
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'StreamComputed subscribes to a stream and automatically '
            'resubscribes when dependencies change.',
          ),
          const SizedBox(height: 12),
          Watch(
            builder: (ctx, _) {
              return counter.value.when(
                loading: () => const Text('Waiting for first value...'),
                data: (value) => Text('Counter: $value'),
                error: (error, _) => Text('Error: $error'),
              );
            },
          ),
          const SizedBox(height: 8),
          Watch(builder: (ctx, _) => Text('Interval: ${interval()}s')),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => interval.value = 1,
                child: const Text('1s'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => interval.value = 2,
                child: const Text('2s'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => interval.value = 3,
                child: const Text('3s'),
              ),
            ],
          ),
          const Text(
            'Changing interval resets the counter',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// combineAsync - Combine Async Values
// ============================================================
class _CombineAsyncDemo extends StatefulWidget {
  const _CombineAsyncDemo();

  @override
  State<_CombineAsyncDemo> createState() => _CombineAsyncDemoState();
}

class _CombineAsyncDemoState extends State<_CombineAsyncDemo> {
  late final AsyncComputed<String> userName;
  late final AsyncComputed<int> userAge;
  late final AsyncComputed<String> userCity;
  late final Computed<AsyncValue<String>> combined;

  @override
  void initState() {
    super.initState();

    // Simulate multiple async data sources with different delays
    userName = asyncComputed(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return 'Alice';
    });

    userAge = asyncComputed(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      return 30;
    });

    userCity = asyncComputed(() async {
      await Future.delayed(const Duration(milliseconds: 600));
      return 'New York';
    });

    // Combine all async values into one using computed + combineAsync
    // combineAsync takes List<AsyncValue> and returns an AsyncValue
    combined = computed(
      (_) => combineAsync<String>([
        userName.value,
        userAge.value,
        userCity.value,
      ], (values) => '${values[0]}, ${values[1]} years old, from ${values[2]}'),
    );
  }

  @override
  void dispose() {
    userName.dispose();
    userAge.dispose();
    userCity.dispose();
    super.dispose();
  }

  void _refresh() {
    userName.refresh();
    userAge.refresh();
    userCity.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'combineAsync waits for all async values to complete '
            'before combining them.',
          ),
          const SizedBox(height: 12),
          // Show individual states
          const Text(
            'Individual states:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Watch(
            builder:
                (ctx, _) => Row(
                  children: [
                    _AsyncStateIndicator('Name', userName.value),
                    const SizedBox(width: 8),
                    _AsyncStateIndicator('Age', userAge.value),
                    const SizedBox(width: 8),
                    _AsyncStateIndicator('City', userCity.value),
                  ],
                ),
          ),
          const SizedBox(height: 12),
          // Show combined result
          const Text(
            'Combined result:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Watch(
            builder: (ctx, _) {
              return combined.value.when(
                loading:
                    () => const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Waiting for all data...'),
                      ],
                    ),
                data: (value) => Text('✅ $value'),
                error: (error, _) => Text('❌ $error'),
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _refresh, child: const Text('Refresh All')),
          const Text(
            'All sources must complete before combined value is ready',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _AsyncStateIndicator extends StatelessWidget {
  final String label;
  final AsyncValue<dynamic> value;

  const _AsyncStateIndicator(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final icon = value.when(
      loading: () => '⏳',
      data: (_) => '✅',
      error: (_, __) => '❌',
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: Text('$label: $icon'),
    );
  }
}
