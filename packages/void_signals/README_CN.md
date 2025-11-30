<p align="center">
  <img src="https://raw.githubusercontent.com/void-signals/void-signals/main/art/void.png" alt="void_signals logo" width="180" />
</p>

<h1 align="center">void_signals</h1>

<p align="center">
  基于 <a href="https://github.com/stackblitz/alien-signals">alien-signals</a> 的高性能 Dart 信号响应式库。
</p>

<p align="center">
  <a href="https://pub.dev/packages/void_signals"><img src="https://img.shields.io/pub/v/void_signals" alt="Pub Version" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
</p>

<p align="center">
  <a href="README.md">English</a> | 简体中文
</p>

---

## 特性

### 核心响应式
- ⚡ **高性能**: 基于 alien-signals，最快的信号实现之一
- 🎯 **零开销抽象**: 使用 Dart 扩展类型实现零成本抽象
- 🔄 **细粒度响应**: 只更新真正变化的部分
- 🧩 **极简 API**: 只需 `signal()`、`computed()`、`effect()`
- 📦 **Tree Shakable**: 只打包你使用的功能

### 高级异步支持
- 🔮 **AsyncValue**: Riverpod 风格的密封类，处理 loading/data/error 状态
- ⏳ **AsyncComputed**: 带自动依赖追踪的异步计算值
- 🌊 **StreamComputed**: 订阅流并自动管理生命周期
- 🔗 **combineAsync**: 合并多个异步值为一个

### 生命周期管理（Riverpod 风格）
- 🎯 **SignalLifecycle**: `onDispose`、`onCancel`、`onResume` 回调
- 🔒 **KeepAliveLink**: 阻止信号自动释放
- 📡 **SignalSubscription**: 暂停/恢复订阅，处理错过的更新
- 🎛️ **SubscriptionController**: 统一管理多个订阅

### 错误处理与重试
- ✅ **Result 类型**: 类型安全的 `Result<T>`，用于可能失败的操作
- 🔄 **重试逻辑**: 指数退避与抖动的异步操作重试
- 🛡️ **runGuarded/runGuardedAsync**: 安全执行并捕获错误
- ⚠️ **SignalErrorHandler**: 信号操作的全局错误处理器

### 工具函数
- 📦 **batch**: 批量更新合并为单次刷新
- 🚫 **untrack**: 读取信号但不创建依赖
- 🎯 **trigger**: 手动触发访问信号的订阅者
- 🔍 **类型检查**: `isSignal()`、`isComputed()`、`isEffect()`、`isEffectScope()`

## 安装

```yaml
dependencies:
  void_signals: ^1.0.0
```

## 快速开始

```dart
import 'package:void_signals/void_signals.dart';

void main() {
  // 创建信号
  final count = signal(0);
  
  // 创建计算值
  final doubled = computed((prev) => count() * 2);
  
  // 创建副作用
  effect(() {
    print('Count: ${count()}, Doubled: ${doubled()}');
  });
  
  count.value = 1;  // 打印: Count: 1, Doubled: 2
}
```

## 核心 API

### Signal (信号)

信号持有一个响应式值，变化时通知订阅者。

```dart
// 创建带初始值的信号
final name = signal('张三');

// 读取值（多种方式）
print(name.value);  // '张三'
print(name());      // '张三' (可调用语法)

// 更新值
name.value = '李四';

// 无追踪读取（在副作用中有用）
print(name.peek());

// 检查是否有订阅者
print(name.hasSubscribers);  // true/false
```

### Computed (计算值)

计算值从其他信号派生，自动更新。

```dart
final firstName = signal('张');
final lastName = signal('三');

// 可访问前一个值的计算
final fullName = computed((prev) => '${firstName()} ${lastName()}');

print(fullName());  // '张 三'

// 更新依赖
firstName.value = '李';
print(fullName());  // '李 三'

// 前一个值可用
final runningSum = computed<int>((prev) => (prev ?? 0) + count());
```

### Effect (副作用)

副作用在依赖变化时自动运行。

```dart
final count = signal(0);

// 创建副作用 - 立即运行
final eff = effect(() {
  print('计数是: ${count()}');
});
// 打印: 计数是: 0

count.value = 1;  // 打印: 计数是: 1

// 停止副作用
eff.stop();
count.value = 2;  // 不打印
```

### Effect Scope (副作用作用域)

将多个副作用组合便于清理。

```dart
final scope = effectScope(() {
  effect(() { /* 副作用 1 */ });
  effect(() { /* 副作用 2 */ });
  effect(() { /* 副作用 3 */ });
});

// 稍后一次性停止所有副作用
scope.stop();
```

### Batch (批量)

批量更新多个信号，副作用只运行一次。

```dart
final a = signal(1);
final b = signal(2);

effect(() {
  print('总和: ${a() + b()}');
});

// 不使用 batch: 会打印两次
// 使用 batch: 只打印一次
batch(() {
  a.value = 10;
  b.value = 20;
});
// 打印: 总和: 30
```

### Untrack (取消追踪)

读取信号但不创建依赖。

```dart
effect(() {
  // 这会创建依赖
  print('Count: ${count()}');
  
  // 这不会创建依赖
  final other = untrack(() => otherSignal());
});
```

### Trigger (触发)

手动触发访问信号的订阅者。

```dart
final list = signal<List<int>>([]);

// 原地修改
list.value.add(1);

// 手动触发订阅者
trigger(() => list());
```

## 异步支持

### AsyncValue

表示异步状态的密封类：loading、data 或 error。

```dart
// 所有 AsyncValue 变体：
const AsyncLoading<int>();           // 初始加载状态
const AsyncData<int>(42);            // 成功带值
AsyncError<int>(error, stackTrace);  // 错误状态

// 带前值（用于刷新）：
AsyncLoadingWithPrevious<int>(42);   // 加载中但有前值
AsyncErrorWithPrevious<int>(error, stackTrace, 42);

// 模式匹配
asyncValue.when(
  loading: () => print('加载中...'),
  data: (value) => print('获取到: $value'),
  error: (error, stack) => print('错误: $error'),
);

// 便捷 getter
asyncValue.isLoading;     // 是否加载中
asyncValue.hasData;       // 是否有数据
asyncValue.hasError;      // 是否有错误
asyncValue.valueOrNull;   // 值或 null
asyncValue.errorOrNull;   // 错误或 null
```

### AsyncComputed

带自动依赖追踪的异步计算值。

```dart
final userId = signal(1);

// 创建获取用户数据的异步计算
final user = asyncComputed(() async {
  final id = userId();  // await 前同步追踪
  final response = await fetchUser(id);
  return response;
});

// 使用异步状态
print(user().isLoading);  // 初始为 true

// userId 变化时，user 自动重新获取
userId.value = 2;  // 触发新计算

// 手动刷新
user.refresh();

// 清理
user.dispose();
```

### StreamComputed

订阅流并自动管理生命周期。

```dart
final filter = signal('active');

// 创建流计算
final items = streamComputed(() {
  return database.watchItems(filter: filter());  // 追踪的依赖
});

// 访问流状态
items().when(
  loading: () => '加载中...',
  data: (value) => '项目: $value',
  error: (e, _) => '错误: $e',
);

// filter 变化时自动重新订阅新流
filter.value = 'archived';

// 清理
items.dispose();
```

## 类型检查

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

## 生命周期管理

受 Riverpod 健壮模式启发，void_signals 提供生产级的生命周期钩子。

### SignalSubscription - 暂停/恢复更新

```dart
final count = signal(0);

// 使用变更监听器订阅
final sub = count.subscribe(
  (previous, current) => print('变化: $previous -> $current'),
  fireImmediately: true,
);

count.value = 1;  // 打印: 变化: 0 -> 1

// 暂停订阅 - 更新会排队
sub.pause();
count.value = 2;  // 不打印
count.value = 3;  // 不打印

// 恢复 - 传递最后一次更新
sub.resume();  // 打印: 变化: 1 -> 3

// 读取当前值而不创建依赖
print(sub.read());  // 3

// 完成时关闭
sub.close();
```

### SignalLifecycle Mixin - 生命周期回调

```dart
// 创建带生命周期管理的信号
class ManagedSignal<T> extends Signal<T> with SignalLifecycle {
  ManagedSignal(super.value);
}

final sig = ManagedSignal(0);

// 注册销毁回调
sig.onDispose(() {
  print('信号已销毁 - 清理资源');
});

// 当监听器添加/移除时调用
sig.onAddListener(() => print('监听器已添加'));
sig.onRemoveListener(() => print('监听器已移除'));

// 当所有监听器暂停/移除时调用
sig.onCancel(() => print('所有监听器已取消'));
sig.onResume(() => print('监听器已恢复'));

// 稍后，销毁并运行所有回调
sig.dispose();
```

### KeepAliveLink - 阻止销毁

```dart
final sig = ManagedSignal(0);

// 创建保活链接以阻止销毁
final keepAlive = sig.keepAlive();

print(sig.hasKeepAliveLinks);  // true

// 稍后，允许销毁
keepAlive.close();
print(keepAlive.closed);  // true
```

### SubscriptionController - 管理多个订阅

```dart
final controller = SubscriptionController();

// 添加要一起管理的订阅
controller.add(signal1.subscribe((_, v) => print('信号 1: $v')));
controller.add(signal2.subscribe((_, v) => print('信号 2: $v')));
controller.add(signal3.subscribe((_, v) => print('信号 3: $v')));

// 一次暂停所有订阅
controller.pauseAll();

// 恢复所有订阅
controller.resumeAll();

// 销毁控制器并关闭所有订阅
controller.dispose();
```

### 全局错误处理器

```dart
// 设置全局错误处理
SignalErrorHandler.setHandler((error, stackTrace) {
  print('信号错误: $error');
  // 记录到崩溃报告服务（如 Sentry、Firebase Crashlytics）
  crashlytics.recordError(error, stackTrace);
});

// 稍后，清除处理器
SignalErrorHandler.clearHandler();
```

## 错误处理与重试

### Result 类型 - 安全操作

```dart
// 包装可能失败的操作
final result = runGuarded(() => someRiskyOperation());

// 模式匹配
switch (result) {
  case ResultData(:final value):
    print('成功: $value');
  case ResultError(:final error, :final stackTrace):
    print('错误: $error');
}

// 便捷方法
result.ifValue((value) => print('获取到: $value'));
result.ifError((error, stack) => print('失败: $error'));

// 获取值或回退
final value = result.getOrElse(defaultValue);
final computed = result.getOrElseCompute(() => computeDefault());

// 转换值
final mapped = result.map((value) => value.toString());

// 转换为 AsyncValue
final asyncValue = result.toAsyncValue();
```

### 异步错误处理

```dart
// 异步版本
final result = await runGuardedAsync(() => fetchData());

result.ifValue((data) => updateUI(data));
result.ifError((error, stack) => showErrorDialog(error));
```

### 指数退避重试

```dart
// 配置重试行为
final config = RetryConfig(
  maxAttempts: 3,
  baseDelay: Duration(milliseconds: 100),
  maxDelay: Duration(seconds: 10),
  exponentialBackoff: true,
  jitter: 0.1,  // 添加随机性防止惊群效应
  shouldRetry: (error, attempt) => error is NetworkError,
);

// 重试异步操作
final result = await retry(
  () => fetchDataFromServer(),
  config: config,
  onRetry: (error, attempt) => print('重试第 $attempt 次: $error'),
);

// 同步重试（无延迟）
final syncResult = retrySync(
  () => parseData(input),
  config: RetryConfig(maxAttempts: 3),
);
```

### AsyncSignal - 全功能异步状态

```dart
// 创建时自动刷新
final users = AsyncSignal.autoRefresh(
  fetch: () => api.fetchUsers(),
  retryConfig: RetryConfig(maxAttempts: 3),
);

// 懒加载 - 直到调用 refresh() 才开始
final lazyData = AsyncSignal.lazy(
  fetch: () => api.fetchData(),
);

// 从 Future 创建
final fromFuture = AsyncSignal.fromFuture(
  someAsyncOperation(),
  initialValue: cachedData,
);

// 从 Stream 创建
final fromStream = AsyncSignal.fromStream(
  webSocket.messages,
);

// 检查状态
print(users.state);       // AsyncState.loading | .data | .error
print(users.isLoading);   // true/false
print(users.hasData);     // true/false
print(users.hasError);    // true/false

// 访问数据
print(users.data);        // T? - 当前数据
print(users.error);       // Object? - 当前错误
print(users.stackTrace);  // StackTrace? - 错误堆栈

// 手动控制
await users.refresh();    // 强制刷新
users.setValue(newData);  // 直接设置值
users.setError(error);    // 直接设置错误
users.reset();            // 重置为初始状态

// 监听信号进行响应式更新
effect(() {
  final state = users.stateSignal();
  print('用户状态: $state');
});

// 清理
users.dispose();
```

### 安全信号扩展

```dart
final sig = signal(0);

// 尝试可能失败的操作
final readResult = sig.tryRead();      // Result<T>
final updateResult = sig.tryUpdate(5); // Result<void>

// 带错误处理的更新
sig.updateSafe(newValue, onError: (e) => print('更新失败: $e'));
```

## 性能提示

1. **使用 `peek()` 进行无追踪读取**，而不是包装在 `untrack()` 中
2. **批量相关更新** 以最小化副作用重新运行
3. **使用副作用作用域** 管理副作用生命周期
4. **优先使用 computed 而非 effects** 处理派生状态
5. **将信号放在文件顶层** 以获得更好的 tree shaking
6. **需要应用挂起更新时使用 `syncPeek()`** 而无需追踪

## 相关包

- [void_signals_flutter](https://pub.dev/packages/void_signals_flutter) - Flutter 绑定
- [void_signals_hooks](https://pub.dev/packages/void_signals_hooks) - Flutter hooks 集成

## 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。
