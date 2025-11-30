import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:void_signals_flutter/void_signals_flutter.dart';

void main() {
  group('PaginationConfig', () {
    test('should have correct default values', () {
      const config = PaginationConfig();
      expect(config.pageSize, equals(20));
      expect(config.loadMoreThreshold, equals(5));
      expect(config.autoLoadMore, isTrue);
    });

    test('should accept custom values', () {
      const config = PaginationConfig(
        pageSize: 50,
        loadMoreThreshold: 10,
        autoLoadMore: false,
      );
      expect(config.pageSize, equals(50));
      expect(config.loadMoreThreshold, equals(10));
      expect(config.autoLoadMore, isFalse);
    });
  });

  group('PaginationResult', () {
    test('should create with required parameters', () {
      final result = PaginationResult<int>(
        items: [1, 2, 3],
        hasMore: true,
      );
      expect(result.items, equals([1, 2, 3]));
      expect(result.hasMore, isTrue);
      expect(result.total, isNull);
    });

    test('should create with total', () {
      final result = PaginationResult<int>(
        items: [1, 2, 3],
        hasMore: true,
        total: 100,
      );
      expect(result.total, equals(100));
    });

    test('should create empty result', () {
      const result = PaginationResult<int>.empty();
      expect(result.items, isEmpty);
      expect(result.hasMore, isFalse);
      expect(result.total, equals(0));
    });
  });

  group('PaginatedSignal', () {
    test('should start in initial state', () {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async => PaginationResult(
          items: [],
          hasMore: false,
        ),
      );

      expect(paginated.state.value, equals(PaginationState.initial));
      expect(paginated.items.value, isEmpty);
      expect(paginated.hasMore.value, isTrue);
      expect(paginated.currentPage.value, equals(0));
      paginated.dispose();
    });

    test('should load first page', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: true,
          );
        },
      );

      await paginated.loadFirst();

      expect(paginated.state.value, equals(PaginationState.loaded));
      expect(paginated.items.value, equals([1, 2, 3]));
      expect(paginated.hasMore.value, isTrue);
      expect(paginated.currentPage.value, equals(0));
      paginated.dispose();
    });

    test('should load more pages', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          if (page == 0) {
            return PaginationResult(
              items: [1, 2, 3],
              hasMore: true,
            );
          } else {
            return PaginationResult(
              items: [4, 5, 6],
              hasMore: false,
            );
          }
        },
      );

      await paginated.loadFirst();
      expect(paginated.items.value, equals([1, 2, 3]));

      await paginated.loadMore();
      expect(paginated.items.value, equals([1, 2, 3, 4, 5, 6]));
      expect(paginated.currentPage.value, equals(1));
      expect(paginated.hasMore.value, isFalse);
      expect(paginated.state.value, equals(PaginationState.loadedAll));
      paginated.dispose();
    });

    test('should not load more when already loading', () async {
      var loadCount = 0;
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          loadCount++;
          await Future.delayed(const Duration(milliseconds: 100));
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: true,
          );
        },
      );

      await paginated.loadFirst();
      expect(loadCount, equals(1));

      // Start loading more without awaiting
      final future1 = paginated.loadMore();
      final future2 = paginated.loadMore(); // Should be ignored

      await Future.wait([future1, future2]);
      expect(loadCount, equals(2)); // Only one additional load
      paginated.dispose();
    });

    test('should not load more when no more items', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();
      await paginated.loadMore();

      expect(paginated.currentPage.value, equals(0));
      expect(paginated.state.value, equals(PaginationState.loadedAll));
      paginated.dispose();
    });

    test('should handle errors', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          throw Exception('Network error');
        },
      );

      await paginated.loadFirst();

      expect(paginated.state.value, equals(PaginationState.error));
      expect(paginated.error.value, isNotNull);
      expect(paginated.stackTrace.value, isNotNull);
      paginated.dispose();
    });

    test('should refresh data', () async {
      var callCount = 0;
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          callCount++;
          return PaginationResult(
            items: [callCount * 10],
            hasMore: true,
          );
        },
      );

      await paginated.loadFirst();
      expect(paginated.items.value, equals([10]));

      await paginated.refresh();
      expect(paginated.items.value, equals([20]));
      expect(paginated.currentPage.value, equals(0));
      paginated.dispose();
    });

    test('should retry after error', () async {
      var shouldFail = true;
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          if (shouldFail) {
            throw Exception('Error');
          }
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();
      expect(paginated.state.value, equals(PaginationState.error));

      shouldFail = false;
      await paginated.retry();
      expect(paginated.state.value, equals(PaginationState.loadedAll));
      expect(paginated.items.value, equals([1, 2, 3]));
      paginated.dispose();
    });

    test('should reset to initial state', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: true,
          );
        },
      );

      await paginated.loadFirst();
      expect(paginated.items.value, isNotEmpty);

      paginated.reset();
      expect(paginated.state.value, equals(PaginationState.initial));
      expect(paginated.items.value, isEmpty);
      expect(paginated.currentPage.value, equals(0));
      expect(paginated.hasMore.value, isTrue);
      paginated.dispose();
    });

    test('should update item at index', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();
      paginated.updateAt(1, 99);
      expect(paginated.items.value, equals([1, 99, 3]));
      paginated.dispose();
    });

    test('should remove item at index', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();
      paginated.removeAt(1);
      expect(paginated.items.value, equals([1, 3]));
      paginated.dispose();
    });

    test('should prepend item', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();
      paginated.prepend(0);
      expect(paginated.items.value, equals([0, 1, 2, 3]));
      paginated.dispose();
    });

    test('should append item', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();
      paginated.append(4);
      expect(paginated.items.value, equals([1, 2, 3, 4]));
      paginated.dispose();
    });

    test('should compute isLoading correctly', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: true,
          );
        },
      );

      expect(paginated.isLoading.value, isFalse);

      final loadFuture = paginated.loadFirst();
      // Give time for state to change
      await Future.delayed(const Duration(milliseconds: 10));
      expect(paginated.isLoading.value, isTrue);

      await loadFuture;
      expect(paginated.isLoading.value, isFalse);
      paginated.dispose();
    });

    test('should compute isEmpty and isNotEmpty', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      expect(paginated.isEmpty.value, isTrue);
      expect(paginated.isNotEmpty.value, isFalse);

      await paginated.loadFirst();
      expect(paginated.isEmpty.value, isFalse);
      expect(paginated.isNotEmpty.value, isTrue);
      paginated.dispose();
    });

    test('should compute itemCount', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      expect(paginated.itemCount.value, equals(0));

      await paginated.loadFirst();
      expect(paginated.itemCount.value, equals(3));
      paginated.dispose();
    });

    test('should create with initial items', () {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [],
            hasMore: false,
          );
        },
        initialItems: [10, 20, 30],
      );

      expect(paginated.items.value, equals([10, 20, 30]));
      expect(paginated.state.value, equals(PaginationState.loaded));
      paginated.dispose();
    });

    test('should handle boundary conditions for updateAt', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();

      // Invalid indices should not throw
      paginated.updateAt(-1, 99);
      paginated.updateAt(100, 99);
      expect(paginated.items.value, equals([1, 2, 3]));
      paginated.dispose();
    });

    test('should handle boundary conditions for removeAt', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: [1, 2, 3],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();

      // Invalid indices should not throw
      paginated.removeAt(-1);
      paginated.removeAt(100);
      expect(paginated.items.value, equals([1, 2, 3]));
      paginated.dispose();
    });
  });

  group('PaginationState enum', () {
    test('should have all expected values', () {
      expect(PaginationState.values.length, equals(7));
      expect(PaginationState.initial, isNotNull);
      expect(PaginationState.loadingFirst, isNotNull);
      expect(PaginationState.loadingMore, isNotNull);
      expect(PaginationState.refreshing, isNotNull);
      expect(PaginationState.loaded, isNotNull);
      expect(PaginationState.loadedAll, isNotNull);
      expect(PaginationState.error, isNotNull);
    });
  });

  group('InfiniteScrollList widget', () {
    testWidgets('should show loading state', (tester) async {
      final completer = Completer<PaginationResult<int>>();
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) => completer.future,
      );

      // Start loading but don't await
      unawaited(paginated.loadFirst());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollList<int>(
              paginatedSignal: paginated,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text('$item')),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid timer issues
      completer.complete(PaginationResult(items: [], hasMore: false));
      await tester.pumpAndSettle();

      paginated.dispose();
    });

    testWidgets('should show empty state', (tester) async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(items: [], hasMore: false);
        },
      );

      await paginated.loadFirst();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollList<int>(
              paginatedSignal: paginated,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text('$item')),
              emptyBuilder: (context) => const Text('Empty'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Empty'), findsOneWidget);
      paginated.dispose();
    });

    testWidgets('should show error state', (tester) async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          throw Exception('Test error');
        },
      );

      await paginated.loadFirst();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollList<int>(
              paginatedSignal: paginated,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text('$item')),
              errorBuilder: (context, error, retry) =>
                  ElevatedButton(onPressed: retry, child: const Text('Retry')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      paginated.dispose();
    });

    testWidgets('should show items', (tester) async {
      final paginated = PaginatedSignal<String>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: ['Item 1', 'Item 2', 'Item 3'],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollList<String>(
              paginatedSignal: paginated,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      paginated.dispose();
    });

    testWidgets('should show header and footer', (tester) async {
      final paginated = PaginatedSignal<String>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: ['Item 1'],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollList<String>(
              paginatedSignal: paginated,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              header: const Text('Header'),
              footer: const Text('Footer'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      paginated.dispose();
    });

    testWidgets('should use separator builder', (tester) async {
      final paginated = PaginatedSignal<String>(
        loader: (page, pageSize) async {
          return PaginationResult(
            items: ['Item 1', 'Item 2'],
            hasMore: false,
          );
        },
      );

      await paginated.loadFirst();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteScrollList<String>(
              paginatedSignal: paginated,
              itemBuilder: (context, item, index) => Text(item),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsOneWidget);
      paginated.dispose();
    });
  });

  group('setupInfiniteScroll', () {
    test('should create effect for scroll controller', () {
      final scrollController = ScrollController();

      final eff = setupInfiniteScroll(
        scrollController: scrollController,
        onLoadMore: () async {},
        hasMore: () => true,
        isLoading: () => false,
      );

      expect(eff, isNotNull);
      eff.stop();
      scrollController.dispose();
    });
  });

  group('Edge cases', () {
    test('should handle empty loader result on first page', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return const PaginationResult.empty();
        },
      );

      await paginated.loadFirst();
      expect(paginated.items.value, isEmpty);
      expect(paginated.hasMore.value, isFalse);
      expect(paginated.state.value, equals(PaginationState.loadedAll));
      paginated.dispose();
    });

    test('should handle rapid loadFirst calls', () async {
      var loadCount = 0;
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          loadCount++;
          await Future.delayed(const Duration(milliseconds: 50));
          return PaginationResult(items: [loadCount], hasMore: false);
        },
      );

      // Start multiple loadFirst calls
      final future1 = paginated.loadFirst();
      final future2 = paginated.loadFirst();
      final future3 = paginated.loadFirst();

      await Future.wait([future1, future2, future3]);

      // Should have loaded at least once
      expect(loadCount, greaterThanOrEqualTo(1));
      paginated.dispose();
    });

    test('should not load more in initial state', () async {
      final paginated = PaginatedSignal<int>(
        loader: (page, pageSize) async {
          return PaginationResult(items: [1], hasMore: true);
        },
      );

      await paginated.loadMore();
      expect(paginated.state.value, equals(PaginationState.initial));
      expect(paginated.items.value, isEmpty);
      paginated.dispose();
    });

    test('should handle custom page size', () async {
      int? requestedPageSize;
      final paginated = PaginatedSignal<int>(
        config: const PaginationConfig(pageSize: 100),
        loader: (page, pageSize) async {
          requestedPageSize = pageSize;
          return PaginationResult(items: [1], hasMore: false);
        },
      );

      await paginated.loadFirst();
      expect(requestedPageSize, equals(100));
      paginated.dispose();
    });
  });
}
