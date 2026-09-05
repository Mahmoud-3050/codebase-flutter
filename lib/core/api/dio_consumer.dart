import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/language/strings.dart';
import '../error/exceptions.dart';
import 'api_constants.dart';
import 'api_interceptors.dart';
import 'debug_api_logger.dart';
import 'dio_exception_mapper.dart';
import 'dio_http_adapter.dart';
import 'redirect_interceptor.dart';

abstract interface class DioConsumer {
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
  });

  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });

  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });

  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });

  Future<dynamic> delete(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });
}

class DioConsumerImpl implements DioConsumer {
  DioConsumerImpl({
    required this.client,
    @visibleForTesting Interceptor? apiInterceptor,
  }) {
    applyHttpAdapter(client);
    applyRedirectPolicy(client);
    client.options
      ..baseUrl = ApiConstants.baseUrl
      ..contentType = Headers.jsonContentType
      ..headers = <String, String?>{ApiHeaders.accept: 'application/json'}
      ..connectTimeout = ApiTimeouts.connect
      ..sendTimeout = ApiTimeouts.send
      ..receiveTimeout = ApiTimeouts.receive
      ..followRedirects = false;
    // Dio 5 runs error interceptors in add-order. Redirect must see 3xx
    // before [ApiInterceptor] rejects them as failed responses.
    addRedirectInterceptor(client);
    _addInterceptorOnce(apiInterceptor ?? ApiInterceptor.instance);
    if (kDebugMode) {
      _addDebugLogger();
    }
  }

  final Dio client;

  void _addInterceptorOnce(Interceptor interceptor) {
    if (client.interceptors.contains(interceptor)) {
      return;
    }
    client.interceptors.add(interceptor);
  }

  void _addDebugLogger() {
    if (client.interceptors.whereType<DebugApiLogger>().isNotEmpty) {
      return;
    }
    client.interceptors.add(DebugApiLogger());
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => client.get<dynamic>(
        path,
        queryParameters: queryParameters,
        data: body,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => client.post<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
        cancelToken: cancelToken,
        options: _optionsFor(formData),
      ),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => client.put<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
        cancelToken: cancelToken,
        options: _optionsFor(formData),
      ),
    );
  }

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => client.patch<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
        cancelToken: cancelToken,
        options: _optionsFor(formData),
      ),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => client.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
        cancelToken: cancelToken,
        options: _optionsFor(formData),
      ),
    );
  }

  Options? _optionsFor(FormData? formData) {
    if (formData == null) {
      return null;
    }
    return Options(contentType: Headers.multipartFormDataContentType);
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final Response<dynamic> response = await request();
      return response.data;
    } on DioException catch (error) {
      final Object? cause = error.error;
      if (cause is AppException) {
        throw cause;
      }
      if (cause is SocketException) {
        throw InternetConnectionException(
          message: Strings.noInternetConnection,
        );
      }
      throw DioExceptionMapper.instance.map(error);
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }
}
