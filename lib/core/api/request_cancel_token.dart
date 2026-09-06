import 'package:dio/dio.dart';

/// Narrows an opaque domain [cancellation] handle to a Dio [CancelToken].
CancelToken? requestCancelToken(Object? cancellation) {
  if (cancellation is CancelToken) {
    return cancellation;
  }
  return null;
}
