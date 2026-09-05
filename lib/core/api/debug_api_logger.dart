import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_constants.dart';

/// Debug logger that prints request/response bodies except on auth/refresh paths.
final class DebugApiLogger extends Interceptor {
  DebugApiLogger({
    PrettyDioLogger? prettyLogger,
    void Function(Object object)? logPrint,
  }) : _logPrint = logPrint ?? _log,
       _pretty =
           prettyLogger ??
           PrettyDioLogger(requestBody: true, logPrint: logPrint ?? _log);

  final PrettyDioLogger _pretty;
  final void Function(Object object) _logPrint;

  static void _log(Object object) {
    log(object.toString(), name: 'logger');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiConstants.shouldOmitLogBody(options.path)) {
      _logPrint('${options.method} ${options.path} (body omitted)');
      handler.next(options);
      return;
    }
    _pretty.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (ApiConstants.shouldOmitLogBody(response.requestOptions.path)) {
      _logPrint(
        '${response.statusCode} ${response.requestOptions.path} (body omitted)',
      );
      handler.next(response);
      return;
    }
    _pretty.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (ApiConstants.shouldOmitLogBody(err.requestOptions.path)) {
      _logPrint(
        '${err.response?.statusCode} ${err.requestOptions.path} (body omitted)',
      );
      handler.next(err);
      return;
    }
    _pretty.onError(err, handler);
  }
}
