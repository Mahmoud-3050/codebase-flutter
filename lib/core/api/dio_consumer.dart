import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../error/exceptions.dart';
import '../../config/language/strings.dart';
import 'api_constants.dart';
import 'api_interceptors.dart';
import 'dio_http_adapter.dart';


sealed class DioConsumer {
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  });

  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> delete(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });
}

class DioConsumerImpl implements DioConsumer {
  DioConsumerImpl({
    required this.client,
    @visibleForTesting Interceptor? apiInterceptor,
  }) {
    applyHttpAdapter(client);
    client.options
      ..baseUrl = ApiConstants.baseUrl
      ..contentType = 'application/json'
      ..headers = <String, String?>{
        HttpHeaders.acceptHeader: 'application/json',
      }
      ..sendTimeout = const Duration(seconds: 120)
      ..receiveTimeout = const Duration(seconds: 360)
      ..connectTimeout = const Duration(seconds: 30);
    client.interceptors.add(apiInterceptor ?? ApiInterceptor.instance);
    if (kDebugMode) {
      client.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          logPrint: (Object text) => log(text.toString(), name: 'logger'),
        ),
      );
    }
  }

  final Dio client;

  @override
  Future<dynamic> get(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => client.get<dynamic>(
        path,
        queryParameters: queryParameters,
        data: body,
      ),
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => client.post<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      ),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => client.put<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      ),
    );
  }

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => client.patch<dynamic>(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      ),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => client.delete<dynamic>(path, queryParameters: queryParameters),
    );
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
      throw ServerException(
        message: error.message,
        statusCode: error.response?.statusCode,
      );
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }
}
