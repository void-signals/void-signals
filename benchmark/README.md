# Reactivity Benchmark

A comprehensive benchmark suite for comparing Dart reactive/signals frameworks.

## Frameworks Tested

| Framework | Description |
|-----------|-------------|
| **void_signals** | High-performance reactive signals library |
| **alien_signals** | Dart port of alien-signals |
| **preact_signals** | Dart port of Preact Signals |
| **signals_core** | Core signals library |
| **solidart** | Dart port of SolidJS reactivity |
| **state_beacon** | State management with beacons |
| **mobx** | MobX for Dart |

## Benchmark Categories

### Kairo Benchmarks
Performance tests from the Kairo benchmark suite:
- **avoidablePropagation** - Tests lazy evaluation optimization
- **broadPropagation** - Wide dependency graph propagation
- **deepPropagation** - Deep dependency chain propagation
- **diamond** - Diamond-shaped dependency resolution
- **mux** - Multiplexer pattern performance
- **repeatedObservers** - Multiple observer handling
- **triangle** - Triangle dependency pattern
- **unstable** - Unstable dependency graph handling

### S-Bench (Signal Operations)
Signal creation and update micro-benchmarks:
- **create_signals** - Signal creation overhead
- **comp_XtoY** - Computed creation with X inputs to Y outputs
- **update_XtoY** - Update propagation patterns

### CellX Benchmarks
Stress tests with varying graph sizes:
- **cellx1000** - 1000 reactive cells
- **cellx2500** - 2500 reactive cells
- **cellx5000** - 5000 reactive cells

### Mol Benchmark
Complex molecular simulation benchmark:
- **molBench** - Molecule state propagation

### Dynamic Graph Benchmarks
Tests with dynamic dependency graphs:
- **simple** - 10x5, 2 sources
- **dynamic** - 10x10, 6 sources, dynamic dependencies
- **large** - 1000x12, 4 sources, mostly static
- **wide dense** - 1000x5, 25 sources
- **deep** - 5x500, 3 sources
- **very dynamic** - 100x15, 6 sources, highly dynamic

## Running Benchmarks

```bash
# Run all benchmarks
./bench.sh

# Or run individual framework benchmark
cd frameworks/void_signals
dart run main.dart
```

## Output

Benchmark results are saved to:
- `bench/BENCHMARK_REPORT.md` - Combined markdown report
- `bench/benchmark_results.json` - JSON format for programmatic access
- `bench/<framework>.md` - Individual framework results

---

<!-- BENCHMARK_RESULTS_START -->
## Latest Benchmark Results

| Test | void_signals ([1.0.0](https://pub.dev/packages/void_signals/versions/1.0.0)) | alien_signals ([2.0.1](https://pub.dev/packages/alien_signals/versions/2.0.1)) | state_beacon ([1.0.1](https://pub.dev/packages/state_beacon_core/versions/1.0.1)) | preact_signals ([1.9.3](https://pub.dev/packages/preact_signals/versions/1.9.3)) | mobx ([2.5.0](https://pub.dev/packages/mobx/versions/2.5.0)) | signals_core ([6.2.0](https://pub.dev/packages/signals_core/versions/6.2.0)) | solidart ([2.8.3](https://pub.dev/packages/solidart/versions/2.8.3)) |
|------|--------|--------|--------|--------|--------|--------|--------|
| 1000x12 - 4 sources - dynamic (large, sum: pass, count: pass) | **256.80ms** 🏆 | 261.82ms | 342.46ms | 3.64s | 1.78s | 3.57s | 1.69s |
| 1000x5 - 25 sources (wide dense, sum: pass, count: pass) | **385.35ms** 🏆 | 407.34ms | 503.11ms | 3.33s | 3.34s | 3.32s | 21.28s |
| 100x15 - 6 sources - dynamic (very dynamic, sum: pass, count: pass) | **219.71ms** 🏆 | 235.47ms | 259.58ms | 472.33ms | 1.68s | 482.80ms | 1.75s |
| 10x10 - 6 sources - dynamic (dynamic, sum: pass, count: pass) | **140.66ms** 🏆 | 155.18ms | 200.83ms | 291.87ms | 1.45s | 291.89ms | 1.44s |
| 10x5 - 2 sources (simple, sum: pass, count: pass) | **165.44ms** 🏆 | 184.60ms | 245.93ms | 510.68ms | 1.94s | 534.82ms | 756.30ms |
| 5x500 - 3 sources (deep, sum: pass, count: pass) | **140.85ms** 🏆 | 150.40ms | 204.81ms | 228.77ms | 1.11s | 218.77ms | 487.89ms |
| avoidablePropagation (success) | **120.06ms** 🏆 | 131.58ms | 179.44ms | 206.34ms | 2.34s | 246.76ms | 488.62ms |
| broadPropagation (success) | **215.29ms** 🏆 | 243.72ms | 399.20ms | 462.47ms | 4.25s | 447.53ms | 4.73s |
| cellx1000 (first: pass, last: pass) | **5.83ms** 🏆 | 6.31ms | 15.91ms | 12.06ms | 74.57ms | 12.47ms | 17.66ms |
| cellx2500 (first: pass, last: pass) | **16.38ms** 🏆 | 19.33ms | 46.93ms | 27.59ms | 255.90ms | 26.84ms | 51.19ms |
| cellx5000 (first: pass, last: pass) | **53.36ms** 🏆 | 53.60ms | 105.88ms | 77.91ms | 551.52ms | 75.02ms | 255.39ms |
| comp_0to1 | 33μs | **30μs** 🏆 | 52.02ms | 19.48ms | 16.84ms | 26.48ms | 39.31ms |
| comp_1000to1 | **0μs** 🏆 | 1μs | 37μs | 13μs | 15μs | 3μs | 13μs |
| comp_1to1 | **894μs** 🏆 | 3.85ms | 47.22ms | 18.14ms | 31.94ms | 19.99ms | 35.92ms |
| comp_1to1000 | **42μs** 🏆 | 62μs | 40.01ms | 2.86ms | 13.65ms | 3.83ms | 13.37ms |
| comp_1to2 | 939μs | **616μs** 🏆 | 43.42ms | 35.75ms | 30.59ms | 21.71ms | 40.29ms |
| comp_1to4 | 378μs | **280μs** 🏆 | 43.48ms | 20.62ms | 20.57ms | 26.23ms | 30.41ms |
| comp_1to8 | **120μs** 🏆 | 133μs | 48.35ms | 5.78ms | 21.85ms | 2.67ms | 24.55ms |
| comp_2to1 | 7.35ms | **1.72ms** 🏆 | 26.11ms | 2.32ms | 35.64ms | 24.83ms | 19.25ms |
| comp_4to1 | 3.58ms | **929μs** 🏆 | 19.32ms | 19.32ms | 11.32ms | 1.70ms | 7.71ms |
| create_signals | 30.54ms | 27.29ms | 58.65ms | **12.46ms** 🏆 | 79.40ms | 23.54ms | 62.70ms |
| deepPropagation (success) | **75.15ms** 🏆 | 78.94ms | 161.27ms | 179.08ms | 1.51s | 175.83ms | 261.79ms |
| diamond (success) | **128.94ms** 🏆 | 153.19ms | 203.57ms | 284.89ms | 2.33s | 302.27ms | 989.16ms |
| molBench | **474.20ms** 🏆 | 488.85ms | 1.13s | 489.27ms | 576.51ms | 485.69ms | 526.25ms |
| mux (success) | **282.82ms** 🏆 | 301.36ms | 367.99ms | 384.98ms | 1.76s | 381.33ms | 6.26s |
| repeatedObservers (success) | **21.06ms** 🏆 | 32.98ms | 59.79ms | 39.97ms | 228.06ms | 50.92ms | 197.28ms |
| triangle (success) | **58.78ms** 🏆 | 65.48ms | 85.58ms | 103.24ms | 731.47ms | 109.18ms | 254.13ms |
| unstable (success) | **38.32ms** 🏆 | 49.21ms | 341.58ms | 70.87ms | 337.07ms | 78.18ms | 326.54ms |
| update_1000to1 | **8μs** 🏆 | 26μs | 17μs | 39μs | 61μs | 64μs | 94μs |
| update_1to1 | 15.48ms | 11.03ms | **6.64ms** 🏆 | 8.23ms | 22.54ms | 26.46ms | 37.89ms |
| update_1to1000 | **8μs** 🏆 | 10μs | 375μs | 29μs | 146μs | 53μs | 150μs |
| update_1to2 | 3.26ms | **1.94ms** 🏆 | 3.28ms | 4.55ms | 11.25ms | 13.10ms | 19.32ms |
| update_1to4 | **1.51ms** 🏆 | 2.73ms | 1.65ms | 2.07ms | 5.45ms | 6.51ms | 9.67ms |
| update_2to1 | **2.39ms** 🏆 | 5.50ms | 3.33ms | 4.16ms | 11.49ms | 13.12ms | 19.30ms |
| update_4to1 | 2.39ms | 2.69ms | **1.64ms** 🏆 | 2.25ms | 5.27ms | 6.67ms | 9.64ms |

| Rank | Framework | Wins | Pass Rate |
|------|-----------|------|-----------|
| 🥇 | void_signals | 26 | 100% |
| 🥈 | alien_signals | 6 | 100% |
| 🥉 | state_beacon | 2 | 100% |
| 4 | preact_signals | 1 | 100% |
| 5 | mobx | 0 | 100% |
| 6 | signals_core | 0 | 100% |
| 7 | solidart | 0 | 100% |
<!-- BENCHMARK_RESULTS_END -->

---

## Environment

Benchmarks are run with:
- Dart SDK: 3.10+
- Compilation: Native AOT (`dart compile exe`)
- Platform: macOS/Linux

## Contributing

To add a new framework:

1. Create a directory under `frameworks/<name>/`
2. Add `pubspec.yaml` with the framework dependency
3. Implement `main.dart` using the `ReactiveFramework` interface
4. Run `./bench.sh` to include in benchmarks

## License

MIT License - See [LICENSE](../LICENSE) for details.
