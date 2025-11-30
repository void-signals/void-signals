<p align="center">
  <img src="https://raw.githubusercontent.com/void-signals/void-signals/main/art/void.png" alt="void_signals logo" width="180" />
</p>

<h1 align="center">void_signals</h1>

<p align="center">
  A high-performance signal reactivity library for Dart, based on <a href="https://github.com/stackblitz/alien-signals">alien-signals</a>.
</p>

<p align="center">
  <a href="https://pub.dev/packages/void_signals"><img src="https://img.shields.io/pub/v/void_signals" alt="Pub Version" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
</p>

<p align="center">
  English | <a href="README_CN.md">简体中文</a>
</p>

---

## Features

### Core Reactivity
- ⚡ **High Performance**: Based on alien-signals, one of the fastest signal implementations
- 🎯 **Zero Overhead Abstractions**: Uses Dart extension types for zero-cost abstractions
- 🔄 **Fine-Grained Reactivity**: Only updates what actually changed
- 🧩 **Minimal API**: Just `signal()`, `computed()`, `effect()` - that's it!
- 📦 **Tree Shakable**: Only bundle what you use

### Advanced Async Support
- 🔮 **AsyncValue**: Riverpod-style sealed class for loading/data/error states
- ⏳ **AsyncComputed**: Async computed values with automatic dependency tracking
- 🌊 **StreamComputed**: Subscribe to streams with automatic lifecycle management
- 🔗 **combineAsync**: Combine multiple async values into one

### Lifecycle Management (Riverpod-inspired)
- 🎯 **SignalLifecycle**: `onDispose`, `onCancel`, `onResume` callbacks
- 🔒 **KeepAliveLink**: Prevent automatic disposal of signals
- 📡 **SignalSubscription**: Pause/resume subscriptions with missed update handling
- 🎛️ **SubscriptionController**: Manage multiple subscriptions together

### Error Handling & Retry
- ✅ **Result Type**: Type-safe `Result<T>` for operations that can fail
- 🔄 **Retry Logic**: Exponential backoff with jitter for async operations
- 🛡️ **runGuarded/runGuardedAsync**: Safe execution with error capture
- ⚠️ **SignalErrorHandler**: Global error handler for signal operations

### Utility Functions
- 📦 **batch**: Batch multiple updates into a single flush
- 🚫 **untrack**: Read signals without creating dependencies
- 🎯 **trigger**: Manually trigger subscribers of accessed signals
- 🔍 **Type Checks**: `isSignal()`, `isComputed()`, `isEffect()`, `isEffectScope()`

## Installation

```yaml
dependencies:
  void_signals: ^1.0.0
```

## Quick Start

```dart
import 'package:void_signals/void_signals.dart';

void main() {
  // Create a signal
  final count = signal(0);
  
  // Create a computed value
  final doubled = computed((prev) => count() * 2);
  
  // Create an effect
  effect(() {
    print('Count: ${count()}, Doubled: ${doubled()}');
  });
  
  count.value = 1;  // Prints: Count: 1, Doubled: 2
}
```

## Core API

### Signal

A signal holds a reactive value that notifies subscribers when changed.

```dart
// Create a signal with initial value
final name = signal('John');

// Read the value (multiple ways)
print(name.value);  // 'John'
print(name());      // 'John' (callable syntax)

// Update the value
name.value = 'Jane';

// Read without tracking (useful in effects)
print(name.peek());

// Check if signal has subscribers
print(name.hasSubscribers);  // true/false
```

### Computed

A computed value is derived from other signals and automatically updates.

```dart
final firstName = signal('John');
final lastName = signal('Doe');

// Computed with access to previous value
final fullName = computed((prev) => '${firstName()} ${lastName()}');

print(fullName());  // 'John Doe'

// Update dependencies
firstName.value = 'Jane';
print(fullName());  // 'Jane Doe'

// Previous value is available
final runningSum = computed<int>((prev) => (prev ?? 0) + count());
```

### Effect

An effect runs automatically when its dependencies change.

```dart
final count = signal(0);

// Create an effect - runs immediately
final eff = effect(() {
  print('Count is: ${count()}');
});
// Prints: Count is: 0

count.value = 1;  // Prints: Count is: 1

// Stop the effect
eff.stop();
count.value = 2;  // Nothing printed
```

### Effect Scope

Group multiple effects for easy cleanup.

```dart
final scope = effectScope(() {
  effect(() { /* effect 1 */ });
  effect(() { /* effect 2 */ });
  effect(() { /* effect 3 */ });
});

// Later, stop all effects at once
scope.stop();
```

### Batch

Batch multiple updates to run effects only once.

```dart
final a = signal(1);
final b = signal(2);

effect(() {
  print('Sum: ${a() + b()}');
});

// Without batch: would print twice
// With batch: prints once
batch(() {
  a.value = 10;
  b.value = 20;
});
// Prints: Sum: 30
```

### Untrack

Read signals without creating dependencies.

```dart
effect(() {
  // This creates a dependency
  print('Count: ${count()}');
  
  // This does NOT create a dependency
  final other = untrack(() => otherSignal());
});
```

### Trigger

Manually trigger subscribers of accessed signals.

```dart
final list = signal<List<int>>([]);

// Mutate in place
list.value.add(1);

// Trigger subscribers manually
trigger(() => list());
```

## Async Support

### AsyncValue

A sealed class representing async states: loading, data, or error.

```dart
// All AsyncValue variants:
const AsyncLoading<int>();           // Initial loading state
const AsyncData<int>(42);            // Success with value
AsyncError<int>(error, stackTrace);  // Error state

// With previous value (for refreshing):
AsyncLoadingWithPrevious<int>(42);   // Loading but has previous value
AsyncErrorWithPrevious<int>(error, stackTrace, 42);

// Pattern matching
asyncValue.when(
  loading: () => print('Loading...'),
  data: (value) => print('Got: $value'),
  error: (error, stack) => print('Error: $error'),
);

// Convenient getters
asyncValue.isLoading;     // true if loading
asyncValue.hasData;       // true if has data
asyncValue.hasError;      // true if has error
asyncValue.valueOrNull;   // value or null
asyncValue.errorOrNull;   // error or null
```

### AsyncComputed

Computed values for async operations with automatic dependency tracking.

```dart
final userId = signal(1);

// Create an async computed that fetches user data
final user = asyncComputed(() async {
  final id = userId();  // Tracked synchronously before await
  final response = await fetchUser(id);
  return response;
});

// Use the async state
print(user().isLoading);  // true initially

// When userId changes, user automatically refetches
userId.value = 2;  // Triggers new computation

// Access the future for async dependencies
final derived = asyncComputed(() async {
  final u = await user.future;  // Creates dependency
  return 'Hello, ${u.name}!';
});

// Manual refresh
user.refresh();

// Cleanup
user.dispose();
```

### StreamComputed

Subscribe to streams with automatic lifecycle management.

```dart
final filter = signal('active');

// Create a stream computed
final items = streamComputed(() {
  return database.watchItems(filter: filter());  // Tracked dependency
});

// Access stream state
items().when(
  loading: () => 'Loading...',
  data: (value) => 'Items: $value',
  error: (e, _) => 'Error: $e',
);

// When filter changes, automatically resubscribes to new stream
filter.value = 'archived';

// Cleanup
items.dispose();
```

### combineAsync

Combine multiple async values into one.

```dart
final user = asyncComputed(() => fetchUser(userId()));
final posts = asyncComputed(() => fetchPosts(userId()));
final comments = asyncComputed(() => fetchComments(userId()));

// Combine all async values
final combined = combineAsync(
  [user, posts, comments],
  (values) => UserProfile(
    user: values[0] as User,
    posts: values[1] as List<Post>,
    comments: values[2] as List<Comment>,
  ),
);

// combined is loading until all sources complete
combined.when(
  loading: () => showSpinner(),
  data: (profile) => showProfile(profile),
  error: (e, _) => showError(e),
);
```

## Type Checking

```dart
final s = signal(1);
final c = computed((p) => s() * 2);
final e = effect(() => print(s()));
final scope = effectScope(() {});

isSignal(s);        // true
isComputed(c);      // true
isEffect(e);        // true
isEffectScope(scope);  // true
```

## Lifecycle Management

Inspired by Riverpod's robust patterns, void_signals provides production-grade lifecycle hooks.

### SignalSubscription - Pause/Resume Updates

```dart
final count = signal(0);

// Subscribe with change listener
final sub = count.subscribe(
  (previous, current) => print('Changed: $previous -> $current'),
  fireImmediately: true,
);

count.value = 1;  // Prints: Changed: 0 -> 1

// Pause subscription - updates are queued
sub.pause();
count.value = 2;  // Nothing printed
count.value = 3;  // Nothing printed

// Resume - last update is delivered
sub.resume();  // Prints: Changed: 1 -> 3

// Read current value without creating dependency
print(sub.read());  // 3

// Close when done
sub.close();
```

### SignalLifecycle Mixin - Lifecycle Callbacks

```dart
// Create a signal with lifecycle management
class ManagedSignal<T> extends Signal<T> with SignalLifecycle {
  ManagedSignal(super.value);
}

final sig = ManagedSignal(0);

// Register disposal callback
sig.onDispose(() {
  print('Signal disposed - cleanup resources');
});

// Called when listeners are added/removed
sig.onAddListener(() => print('Listener added'));
sig.onRemoveListener(() => print('Listener removed'));

// Called when all listeners are paused/removed
sig.onCancel(() => print('All listeners cancelled'));
sig.onResume(() => print('Listeners resumed'));

// Later, dispose and run all callbacks
sig.dispose();
```

### KeepAliveLink - Prevent Disposal

```dart
final sig = ManagedSignal(0);

// Create a keep-alive link to prevent disposal
final keepAlive = sig.keepAlive();

print(sig.hasKeepAliveLinks);  // true

// Later, allow disposal
keepAlive.close();
print(keepAlive.closed);  // true
```

### SubscriptionController - Manage Multiple Subscriptions

```dart
final controller = SubscriptionController();

// Add subscriptions to be managed together
controller.add(signal1.subscribe((_, v) => print('Signal 1: $v')));
controller.add(signal2.subscribe((_, v) => print('Signal 2: $v')));
controller.add(signal3.subscribe((_, v) => print('Signal 3: $v')));

// Pause all subscriptions at once
controller.pauseAll();

// Resume all subscriptions
controller.resumeAll();

// Dispose controller and close all subscriptions
controller.dispose();
```

### Global Error Handler

```dart
// Set up global error handling
SignalErrorHandler.setHandler((error, stackTrace) {
  print('Signal error: $error');
  // Log to crash reporting service (e.g., Sentry, Firebase Crashlytics)
  crashlytics.recordError(error, stackTrace);
});

// Later, clear the handler
SignalErrorHandler.clearHandler();
```

## Error Handling & Retry

### Result Type - Safe Operations

```dart
// Wrap operations that might fail
final result = runGuarded(() => someRiskyOperation());

// Pattern matching
switch (result) {
  case ResultData(:final value):
    print('Success: $value');
  case ResultError(:final error, :final stackTrace):
    print('Error: $error');
}

// Convenient methods
result.ifValue((value) => print('Got: $value'));
result.ifError((error, stack) => print('Failed: $error'));

// Get value with fallback
final value = result.getOrElse(defaultValue);
final computed = result.getOrElseCompute(() => computeDefault());

// Transform values
final mapped = result.map((value) => value.toString());

// Convert to AsyncValue
final asyncValue = result.toAsyncValue();
```

### Async Error Handling

```dart
// Async version
final result = await runGuardedAsync(() => fetchData());

result.ifValue((data) => updateUI(data));
result.ifError((error, stack) => showErrorDialog(error));
```

### Retry with Exponential Backoff

```dart
// Configure retry behavior
final config = RetryConfig(
  maxAttempts: 3,
  baseDelay: Duration(milliseconds: 100),
  maxDelay: Duration(seconds: 10),
  exponentialBackoff: true,
  jitter: 0.1,  // Add randomness to prevent thundering herd
  shouldRetry: (error, attempt) => error is NetworkError,
);

// Retry async operation
final result = await retry(
  () => fetchDataFromServer(),
  config: config,
  onRetry: (error, attempt) => print('Retry attempt $attempt: $error'),
);

// Sync retry (without delay)
final syncResult = retrySync(
  () => parseData(input),
  config: RetryConfig(maxAttempts: 3),
);
```

### AsyncSignal - Full-Featured Async State

```dart
// Auto-refresh on creation
final users = AsyncSignal.autoRefresh(
  fetch: () => api.fetchUsers(),
  retryConfig: RetryConfig(maxAttempts: 3),
);

// Lazy fetch - doesn't start until refresh() is called
final lazyData = AsyncSignal.lazy(
  fetch: () => api.fetchData(),
);

// From Future
final fromFuture = AsyncSignal.fromFuture(
  someAsyncOperation(),
  initialValue: cachedData,
);

// From Stream
final fromStream = AsyncSignal.fromStream(
  webSocket.messages,
);

// Check state
print(users.state);       // AsyncState.loading | .data | .error
print(users.isLoading);   // true/false
print(users.hasData);     // true/false
print(users.hasError);    // true/false

// Access data
print(users.data);        // T? - current data
print(users.error);       // Object? - current error
print(users.stackTrace);  // StackTrace? - error stack trace

// Manual control
await users.refresh();    // Force refresh
users.setValue(newData);  // Set value directly
users.setError(error);    // Set error directly
users.reset();            // Reset to initial state

// Watch signals for reactive updates
effect(() {
  final state = users.stateSignal();
  print('Users state: $state');
});

// Cleanup
users.dispose();
```

### Safe Signal Extensions

```dart
final sig = signal(0);

// Try operations that might fail
final readResult = sig.tryRead();      // Result<T>
final updateResult = sig.tryUpdate(5); // Result<void>

// Update with error handling
sig.updateSafe(newValue, onError: (e) => print('Update failed: $e'));
```

## Advanced Usage

### Nested Computed Values

```dart
final a = signal(1);
final b = computed((p) => a() * 2);
final c = computed((p) => b() + 1);

print(c());  // 3
a.value = 5;
print(c());  // 11
```

### Diamond Dependencies

Handles diamond-shaped dependency graphs efficiently:

```dart
final source = signal(1);
final left = computed((p) => source() * 2);
final right = computed((p) => source() * 3);
final combined = computed((p) => left() + right());

// Updates only once when source changes
source.value = 2;  // combined recalculates only once
```

### Conditional Dependencies

```dart
final showDetails = signal(false);
final details = signal('Secret');

effect(() {
  if (showDetails()) {
    print('Details: ${details()}');
  } else {
    print('Hidden');
  }
});

// Effect doesn't re-run when details changes (not a dependency yet)
details.value = 'New Secret';

// Now details becomes a dependency
showDetails.value = true;
```

## Low-Level API

For advanced use cases, the library exposes low-level functions:

```dart
import 'package:void_signals/void_signals.dart';

// Get/set the active subscriber
final prevSub = setActiveSub(null);
// ... do untracked work
setActiveSub(prevSub);

// Manually control batching
startBatch();
try {
  // Multiple updates
} finally {
  endBatch();
}

// Access reactive flags
final flags = someNode.flags;
if (flags & ReactiveFlags.dirty != 0) { /* ... */ }

// Direct node access
final node = SignalNode(42);
final compNode = ComputedNode((prev) => node.currentValue * 2);
```

## Performance Tips

1. **Use `peek()` for untracked reads** instead of wrapping in `untrack()`
2. **Batch related updates** to minimize effect re-runs
3. **Use effect scopes** to manage effect lifecycle
4. **Prefer computed over effects** for derived state
5. **Place signals at file top-level** for better tree shaking
6. **Use `syncPeek()` when you need pending updates applied** without tracking

## Related Packages

- [void_signals_flutter](https://pub.dev/packages/void_signals_flutter) - Flutter bindings
- [void_signals_hooks](https://pub.dev/packages/void_signals_hooks) - Flutter hooks integration

## License

MIT License - see [LICENSE](LICENSE) for details.
