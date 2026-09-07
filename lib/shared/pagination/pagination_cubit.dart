import 'package:dio/dio.dart';
import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/language/strings.dart';
import '../../core/error/failures.dart';
import '../../core/presentation/api_call_state.dart';
import '../../core/presentation/cubit_request_canceller.dart';
import 'pagination_entity.dart';

enum _PaginationLoadMode { firstPage, refresh, nextPage }

/// Shared paged-list cubit. Subclasses only implement [fetchPage] (use case).
///
/// Emits [ApiCallState]: loading / refresh / pagination / success / empty / error.
/// Page index advances only after a successful response. Load-more and refresh
/// failures keep the current list visible.
abstract class PaginationCubit<T> extends Cubit<ApiCallState<List<T>>>
    with CubitRequestCanceller<ApiCallState<List<T>>> {
  PaginationCubit({this.perPage = PaginationMeta.defaultPerPage})
    : super(ApiCallHolding<List<T>>());

  final int perPage;

  PaginationMeta _meta = .initial;
  final List<T> _items = <T>[];
  int _requestId = 0;
  bool _isInFlight = false;

  PaginationMeta get meta => _meta;

  List<T> get items => .of(_items);

  bool get hasMore => _meta.hasMore;

  bool get isFetchingMore => state.isPagination;

  Future<Either<Failure, PaginationPage<T>>> fetchPage({
    required int page,
    required int perPage,
    required CancelToken cancellation,
  });

  Future<void> fLoadFirstPage() {
    return _load(page: PaginationMeta.defaultPage, mode: .firstPage);
  }

  Future<void> fRefresh() {
    return _load(page: PaginationMeta.defaultPage, mode: .refresh);
  }

  Future<void> fLoadNextPage() {
    if (!_canLoadNextPage) {
      return Future<void>.value();
    }
    return _load(page: _meta.currentPage + 1, mode: .nextPage);
  }

  bool get _canLoadNextPage =>
      !_isInFlight &&
      _meta.hasMore &&
      _items.isNotEmpty &&
      !state.isLoading &&
      !state.isPagination &&
      !state.isRefresh;

  Future<void> _load({
    required int page,
    required _PaginationLoadMode mode,
  }) async {
    if (isClosed) {
      return;
    }
    if (mode == .nextPage && !_canLoadNextPage) {
      return;
    }

    final int requestId = ++_requestId;
    _isInFlight = true;
    final CancelToken cancellation = nextRequestCancelToken();
    _emitInFlight(mode);

    final Either<Failure, PaginationPage<T>> result = await fetchPage(
      page: page,
      perPage: perPage,
      cancellation: cancellation,
    );

    if (!_isCurrentRequest(requestId)) {
      return;
    }

    result.fold(
      (Failure failure) => _onFailure(failure, mode: mode),
      (PaginationPage<T> pageResult) => _onSuccess(pageResult, mode: mode),
    );

    if (_isCurrentRequest(requestId)) {
      _isInFlight = false;
    }
  }

  void _emitInFlight(_PaginationLoadMode mode) {
    switch (mode) {
      case .firstPage:
        emit(ApiCallLoading<List<T>>());
      case .refresh:
        emit(ApiCallRefresh<List<T>>(data: List<T>.of(_items)));
      case .nextPage:
        emit(ApiCallPagination<List<T>>(data: List<T>.of(_items)));
    }
  }

  void _onFailure(Failure failure, {required _PaginationLoadMode mode}) {
    if (shouldIgnoreFailure(failure)) {
      return;
    }
    if (mode == .firstPage && _items.isEmpty) {
      emit(
        ApiCallError<List<T>>.fromFailure(
          failure,
          fallbackMessage: Strings.pleaseTryAgainLater,
        ),
      );
      return;
    }
    emit(_listState());
  }

  void _onSuccess(
    PaginationPage<T> pageResult, {
    required _PaginationLoadMode mode,
  }) {
    if (isClosed) {
      return;
    }

    final bool reset = mode != .nextPage;
    if (reset) {
      _items
        ..clear()
        ..addAll(pageResult.items);
      _meta = pageResult.meta;
    } else if (pageResult.items.isEmpty) {
      _meta = pageResult.meta.copyWith(totalPages: pageResult.meta.currentPage);
    } else {
      _items.addAll(pageResult.items);
      _meta = pageResult.meta;
    }

    emit(_listState());
  }

  ApiCallState<List<T>> _listState() {
    if (_items.isEmpty) {
      return ApiCallEmpty<List<T>>();
    }
    return ApiCallSuccess<List<T>>(data: List<T>.of(_items));
  }

  bool _isCurrentRequest(int requestId) => !isClosed && requestId == _requestId;
}
