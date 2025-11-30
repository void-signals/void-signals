# Reactivity Benchmark Report

Generated: 2025-11-30T22:10:06.467319

## Results

| Test | void_signals ([1.0.0](https://pub.dev/packages/void_signals/versions/1.0.0)) | alien_signals ([2.0.1](https://pub.dev/packages/alien_signals/versions/2.0.1)) | state_beacon ([1.0.1](https://pub.dev/packages/state_beacon_core/versions/1.0.1)) | preact_signals ([1.9.3](https://pub.dev/packages/preact_signals/versions/1.9.3)) | mobx ([2.5.0](https://pub.dev/packages/mobx/versions/2.5.0)) | signals_core ([6.2.0](https://pub.dev/packages/signals_core/versions/6.2.0)) | solidart ([2.8.3](https://pub.dev/packages/solidart/versions/2.8.3)) |
|------|--------|--------|--------|--------|--------|--------|--------|
| 1000x12 - 4 sources - dynamic (large, sum: pass, count: pass) | 259.67ms | **256.00ms** 🏆 | 338.29ms | 3.65s | 1.78s | 3.50s | 1.68s |
| 1000x5 - 25 sources (wide dense, sum: pass, count: pass) | **389.25ms** 🏆 | 415.23ms | 498.92ms | 3.36s | 3.42s | 3.50s | 21.26s |
| 100x15 - 6 sources - dynamic (very dynamic, sum: pass, count: pass) | **219.65ms** 🏆 | 229.67ms | 257.48ms | 465.49ms | 1.66s | 478.37ms | 1.76s |
| 10x10 - 6 sources - dynamic (dynamic, sum: pass, count: pass) | **139.57ms** 🏆 | 155.51ms | 201.91ms | 291.38ms | 1.48s | 292.32ms | 1.43s |
| 10x5 - 2 sources (simple, sum: pass, count: pass) | **163.93ms** 🏆 | 184.58ms | 250.85ms | 507.30ms | 1.90s | 534.25ms | 753.07ms |
| 5x500 - 3 sources (deep, sum: pass, count: pass) | **143.42ms** 🏆 | 151.87ms | 202.63ms | 234.55ms | 1.09s | 216.78ms | 492.27ms |
| avoidablePropagation (success) | **119.99ms** 🏆 | 132.76ms | 176.85ms | 207.66ms | 2.47s | 247.76ms | 496.51ms |
| broadPropagation (success) | **216.27ms** 🏆 | 242.92ms | 397.17ms | 463.18ms | 4.21s | 457.11ms | 4.77s |
| cellx1000 (first: pass, last: pass) | 5.78ms | **5.40ms** 🏆 | 17.82ms | 9.70ms | 66.21ms | 11.79ms | 20.96ms |
| cellx2500 (first: pass, last: pass) | **18.25ms** 🏆 | 20.50ms | 45.68ms | 27.23ms | 255.76ms | 26.27ms | 52.49ms |
| cellx5000 (first: pass, last: pass) | 57.03ms | **54.93ms** 🏆 | 110.71ms | 68.89ms | 551.09ms | 77.23ms | 252.26ms |
| comp_0to1 | 66μs | **30μs** 🏆 | 50.79ms | 16.43ms | 16.19ms | 29.11ms | 20.89ms |
| comp_1000to1 | **0μs** 🏆 | **0μs** 🏆 | 38μs | 13μs | 21μs | 6μs | 13μs |
| comp_1to1 | **882μs** 🏆 | 946μs | 47.78ms | 28.26ms | 41.68ms | 17.52ms | 23.35ms |
| comp_1to1000 | **42μs** 🏆 | 65μs | 36.71ms | 2.80ms | 14.45ms | 4.34ms | 13.80ms |
| comp_1to2 | 649μs | **439μs** 🏆 | 43.00ms | 21.40ms | 20.46ms | 30.26ms | 35.20ms |
| comp_1to4 | 287μs | **218μs** 🏆 | 42.75ms | 23.33ms | 28.81ms | 26.77ms | 20.77ms |
| comp_1to8 | 112μs | **108μs** 🏆 | 41.61ms | 4.07ms | 23.58ms | 5.76ms | 24.29ms |
| comp_2to1 | **1.76ms** 🏆 | 2.27ms | 26.01ms | 8.64ms | 31.74ms | 12.29ms | 19.37ms |
| comp_4to1 | 2.37ms | **824μs** 🏆 | 18.02ms | 14.23ms | 11.56ms | 1.60ms | 10.15ms |
| create_signals | 23.76ms | 30.35ms | 58.38ms | **5.18ms** 🏆 | 61.86ms | 25.00ms | 52.91ms |
| deepPropagation (success) | **75.14ms** 🏆 | 78.14ms | 159.99ms | 177.94ms | 1.49s | 173.33ms | 267.05ms |
| diamond (success) | **129.28ms** 🏆 | 154.72ms | 220.67ms | 288.43ms | 2.30s | 307.81ms | 995.15ms |
| molBench | **474.35ms** 🏆 | 486.32ms | 1.14s | 493.37ms | 574.63ms | 487.55ms | 521.25ms |
| mux (success) | 293.24ms | **291.69ms** 🏆 | 371.00ms | 388.46ms | 1.75s | 379.85ms | 5.95s |
| repeatedObservers (success) | **21.34ms** 🏆 | 32.95ms | 59.14ms | 39.76ms | 223.40ms | 51.33ms | 198.49ms |
| triangle (success) | **58.96ms** 🏆 | 63.40ms | 88.44ms | 105.29ms | 728.27ms | 108.55ms | 250.35ms |
| unstable (success) | **38.77ms** 🏆 | 49.75ms | 343.86ms | 70.12ms | 325.92ms | 80.64ms | 332.37ms |
| update_1000to1 | **8μs** 🏆 | 27μs | 16μs | 20μs | 57μs | 65μs | 94μs |
| update_1to1 | 18.72ms | 11.00ms | **6.65ms** 🏆 | 8.15ms | 21.19ms | 26.68ms | 38.04ms |
| update_1to1000 | **8μs** 🏆 | 10μs | 377μs | 30μs | 149μs | 52μs | 152μs |
| update_1to2 | 4.48ms | 4.04ms | **3.31ms** 🏆 | 4.22ms | 10.44ms | 13.45ms | 19.59ms |
| update_1to4 | **901μs** 🏆 | 2.77ms | 1.64ms | 2.07ms | 5.41ms | 6.61ms | 9.53ms |
| update_2to1 | **1.96ms** 🏆 | 5.58ms | 3.31ms | 4.16ms | 10.64ms | 13.31ms | 18.98ms |
| update_4to1 | 2.45ms | 2.75ms | **1.66ms** 🏆 | 2.11ms | 5.15ms | 6.75ms | 9.58ms |

## Summary

| Rank | Framework | Wins | Pass Rate |
|------|-----------|------|-----------|
| 🥇 | void_signals | 22 | 100% |
| 🥈 | alien_signals | 10 | 100% |
| 🥉 | state_beacon | 3 | 100% |
| 4 | preact_signals | 1 | 100% |
| 5 | mobx | 0 | 100% |
| 6 | signals_core | 0 | 100% |
| 7 | solidart | 0 | 100% |
