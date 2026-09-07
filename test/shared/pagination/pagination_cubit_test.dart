import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/shared/pagination/pagination_cubit.dart';
import 'package:codebase/shared/pagination/pagination_entity.dart';

void main() {
  PaginationPage<int> pageOf({
    required List<int> items,
    int currentPage = 1,
    int totalPages = 1,
  }) {
    return PaginationPage<int>(
      items: items,
      meta: PaginationMeta(
        total: items.length,
        count: items.length,
        perPage: 10,
        currentPage: currentPage,
        totalPages: totalPages,
      ),
    );
  }

  group('PaginationCubit', () {
    test('initial state is holding with no items', () {
      final _FakePaginationCubit cubit = _FakePaginationCubit();
      expect(cubit.state, isA<ApiCallHolding<List<int>>>());
      expect(cubit.items, isEmpty);
      expect(cubit.hasMore, isFalse);
      cubit.close();
    });

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'emits [Loading, Success] on first page and keeps items',
      build: () => _FakePaginationCubit(
        onFetch:
            ({
              required int page,
              required int perPage,
              required CancelToken cancellation,
            }) async {
              return Right<Failure, PaginationPage<int>>(
                pageOf(items: const <int>[1, 2], currentPage: 1, totalPages: 3),
              );
            },
      ),
      act: (_FakePaginationCubit cubit) => cubit.fLoadFirstPage(),
      expect: () => <Matcher>[
        isA<ApiCallLoading<List<int>>>(),
        isA<ApiCallSuccess<List<int>>>(),
      ],
      verify: (_FakePaginationCubit cubit) {
        expect(cubit.items, const <int>[1, 2]);
        expect(cubit.hasMore, isTrue);
        expect(cubit.meta.currentPage, 1);
      },
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'emits [Loading, Empty] when the first page has no items',
      build: () => _FakePaginationCubit(
        onFetch:
            ({
              required int page,
              required int perPage,
              required CancelToken cancellation,
            }) async {
              return Right<Failure, PaginationPage<int>>(
                pageOf(items: const <int>[]),
              );
            },
      ),
      act: (_FakePaginationCubit cubit) => cubit.fLoadFirstPage(),
      expect: () => <Matcher>[
        isA<ApiCallLoading<List<int>>>(),
        isA<ApiCallEmpty<List<int>>>(),
      ],
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'emits [Loading, Error] when the first page fails',
      build: () => _FakePaginationCubit(
        onFetch:
            ({
              required int page,
              required int perPage,
              required CancelToken cancellation,
            }) async {
              return const Left<Failure, PaginationPage<int>>(
                ServerFailure(message: 'Server error'),
              );
            },
      ),
      act: (_FakePaginationCubit cubit) => cubit.fLoadFirstPage(),
      expect: () => <ApiCallState<List<int>>>[
        ApiCallLoading<List<int>>(),
        const ApiCallError<List<int>>(message: 'Server error'),
      ],
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'uses fallback message when first page failure has no message',
      build: () => _FakePaginationCubit(
        onFetch:
            ({
              required int page,
              required int perPage,
              required CancelToken cancellation,
            }) async {
              return const Left<Failure, PaginationPage<int>>(ServerFailure());
            },
      ),
      act: (_FakePaginationCubit cubit) => cubit.fLoadFirstPage(),
      expect: () => <ApiCallState<List<int>>>[
        ApiCallLoading<List<int>>(),
        ApiCallError<List<int>>(message: Strings.pleaseTryAgainLater),
      ],
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'does not emit error when the first page is cancelled',
      build: () => _FakePaginationCubit(
        onFetch:
            ({
              required int page,
              required int perPage,
              required CancelToken cancellation,
            }) async {
              return const Left<Failure, PaginationPage<int>>(
                CancelledFailure(),
              );
            },
      ),
      act: (_FakePaginationCubit cubit) => cubit.fLoadFirstPage(),
      expect: () => <Matcher>[isA<ApiCallLoading<List<int>>>()],
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'appends the next page after success',
      build: () {
        return _FakePaginationCubit(
          onFetch:
              ({
                required int page,
                required int perPage,
                required CancelToken cancellation,
              }) async {
                if (page == 1) {
                  return Right<Failure, PaginationPage<int>>(
                    pageOf(
                      items: const <int>[1, 2],
                      currentPage: 1,
                      totalPages: 2,
                    ),
                  );
                }
                return Right<Failure, PaginationPage<int>>(
                  pageOf(
                    items: const <int>[3, 4],
                    currentPage: 2,
                    totalPages: 2,
                  ),
                );
              },
        );
      },
      act: (_FakePaginationCubit cubit) async {
        await cubit.fLoadFirstPage();
        await cubit.fLoadNextPage();
      },
      expect: () => <Matcher>[
        isA<ApiCallLoading<List<int>>>(),
        isA<ApiCallSuccess<List<int>>>(),
        isA<ApiCallPagination<List<int>>>(),
        isA<ApiCallSuccess<List<int>>>(),
      ],
      verify: (_FakePaginationCubit cubit) {
        expect(cubit.items, const <int>[1, 2, 3, 4]);
        expect(cubit.hasMore, isFalse);
        expect(cubit.meta.currentPage, 2);
      },
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'does not request the next page when hasMore is false',
      build: () {
        int fetchCount = 0;
        return _FakePaginationCubit(
          onFetch:
              ({
                required int page,
                required int perPage,
                required CancelToken cancellation,
              }) async {
                fetchCount++;
                expect(fetchCount, 1);
                return Right<Failure, PaginationPage<int>>(
                  pageOf(items: const <int>[1], currentPage: 1, totalPages: 1),
                );
              },
        );
      },
      act: (_FakePaginationCubit cubit) async {
        await cubit.fLoadFirstPage();
        await cubit.fLoadNextPage();
      },
      expect: () => <Matcher>[
        isA<ApiCallLoading<List<int>>>(),
        isA<ApiCallSuccess<List<int>>>(),
      ],
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'keeps existing items and page when load-more fails',
      build: () {
        return _FakePaginationCubit(
          onFetch:
              ({
                required int page,
                required int perPage,
                required CancelToken cancellation,
              }) async {
                if (page == 1) {
                  return Right<Failure, PaginationPage<int>>(
                    pageOf(
                      items: const <int>[1, 2],
                      currentPage: 1,
                      totalPages: 3,
                    ),
                  );
                }
                return const Left<Failure, PaginationPage<int>>(
                  ServerFailure(message: 'Server error'),
                );
              },
        );
      },
      act: (_FakePaginationCubit cubit) async {
        await cubit.fLoadFirstPage();
        await cubit.fLoadNextPage();
      },
      verify: (_FakePaginationCubit cubit) {
        expect(cubit.items, const <int>[1, 2]);
        expect(cubit.meta.currentPage, 1);
        expect(cubit.hasMore, isTrue);
        expect(cubit.state, isA<ApiCallSuccess<List<int>>>());
      },
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'retries the same next page after a load-more failure',
      build: () {
        final List<int> requestedPages = <int>[];
        return _FakePaginationCubit(
          onFetch:
              ({
                required int page,
                required int perPage,
                required CancelToken cancellation,
              }) async {
                requestedPages.add(page);
                if (page == 1) {
                  return Right<Failure, PaginationPage<int>>(
                    pageOf(
                      items: const <int>[1],
                      currentPage: 1,
                      totalPages: 2,
                    ),
                  );
                }
                if (requestedPages.where((int p) => p == 2).length == 1) {
                  return const Left<Failure, PaginationPage<int>>(
                    ServerFailure(message: 'Server error'),
                  );
                }
                return Right<Failure, PaginationPage<int>>(
                  pageOf(items: const <int>[2], currentPage: 2, totalPages: 2),
                );
              },
        );
      },
      act: (_FakePaginationCubit cubit) async {
        await cubit.fLoadFirstPage();
        await cubit.fLoadNextPage();
        await cubit.fLoadNextPage();
      },
      verify: (_FakePaginationCubit cubit) {
        expect(cubit.items, const <int>[1, 2]);
        expect(cubit.meta.currentPage, 2);
      },
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'stops paging when the next page returns no items',
      build: () {
        return _FakePaginationCubit(
          onFetch:
              ({
                required int page,
                required int perPage,
                required CancelToken cancellation,
              }) async {
                if (page == 1) {
                  return Right<Failure, PaginationPage<int>>(
                    pageOf(
                      items: const <int>[1],
                      currentPage: 1,
                      totalPages: 5,
                    ),
                  );
                }
                return Right<Failure, PaginationPage<int>>(
                  pageOf(items: const <int>[], currentPage: 2, totalPages: 5),
                );
              },
        );
      },
      act: (_FakePaginationCubit cubit) async {
        await cubit.fLoadFirstPage();
        await cubit.fLoadNextPage();
      },
      verify: (_FakePaginationCubit cubit) {
        expect(cubit.items, const <int>[1]);
        expect(cubit.hasMore, isFalse);
      },
    );

    blocTest<_FakePaginationCubit, ApiCallState<List<int>>>(
      'emits [Refresh, Success] on pull-to-refresh and replaces items',
      build: () {
        int fetchCount = 0;
        return _FakePaginationCubit(
          onFetch:
              ({
                required int page,
                required int perPage,
                required CancelToken cancellation,
              }) async {
                fetchCount++;
                if (fetchCount == 1) {
                  return Right<Failure, PaginationPage<int>>(
                    pageOf(
                      items: const <int>[1],
                      currentPage: 1,
                      totalPages: 2,
                    ),
                  );
                }
                return Right<Failure, PaginationPage<int>>(
                  pageOf(items: const <int>[9], currentPage: 1, totalPages: 1),
                );
              },
        );
      },
      act: (_FakePaginationCubit cubit) async {
        await cubit.fLoadFirstPage();
        await cubit.fRefresh();
      },
      expect: () => <Matcher>[
        isA<ApiCallLoading<List<int>>>(),
        isA<ApiCallSuccess<List<int>>>(),
        isA<ApiCallRefresh<List<int>>>(),
        isA<ApiCallSuccess<List<int>>>(),
      ],
      verify: (_FakePaginationCubit cubit) {
        expect(cubit.items, const <int>[9]);
        expect(cubit.hasMore, isFalse);
      },
    );

    test('cancels the in-flight token when a newer request starts', () async {
      final Completer<Either<Failure, PaginationPage<int>>> pending =
          Completer<Either<Failure, PaginationPage<int>>>();
      CancelToken? firstToken;
      int fetchCount = 0;

      final _FakePaginationCubit cubit = _FakePaginationCubit(
        onFetch:
            ({
              required int page,
              required int perPage,
              required CancelToken cancellation,
            }) async {
              fetchCount++;
              if (fetchCount == 1) {
                firstToken = cancellation;
                return pending.future;
              }
              return Right<Failure, PaginationPage<int>>(
                pageOf(items: const <int>[1], currentPage: 1, totalPages: 1),
              );
            },
      );

      final Future<void> first = cubit.fLoadFirstPage();
      await Future<void>.delayed(Duration.zero);
      await cubit.fLoadFirstPage();

      expect(firstToken, isNotNull);
      expect(firstToken!.isCancelled, isTrue);

      pending.complete(
        const Left<Failure, PaginationPage<int>>(CancelledFailure()),
      );
      await first;
      await cubit.close();
    });
  });
}

class _FakePaginationCubit extends PaginationCubit<int> {
  _FakePaginationCubit({this.onFetch, super.perPage});

  final Future<Either<Failure, PaginationPage<int>>> Function({
    required int page,
    required int perPage,
    required CancelToken cancellation,
  })?
  onFetch;

  @override
  Future<Either<Failure, PaginationPage<int>>> fetchPage({
    required int page,
    required int perPage,
    required CancelToken cancellation,
  }) {
    return onFetch!(page: page, perPage: perPage, cancellation: cancellation);
  }
}
