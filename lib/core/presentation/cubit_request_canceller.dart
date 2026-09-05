import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failures.dart';

/// Owns a [CancelToken] for the cubit's in-flight API call.
///
/// Cancel on [close] and when starting a replacement request so leaving a
/// screen does not wait for [ApiTimeouts.receive].
mixin CubitRequestCanceller<S> on Cubit<S> {
  CancelToken? _requestCancelToken;

  CancelToken nextRequestCancelToken() {
    _requestCancelToken?.cancel();
    return _requestCancelToken = CancelToken();
  }

  bool shouldIgnoreFailure(Failure failure) {
    return isClosed || failure is CancelledFailure;
  }

  @override
  Future<void> close() {
    _requestCancelToken?.cancel();
    return super.close();
  }
}
