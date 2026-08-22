import 'dart:io';

import 'package:language/language.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../injection_container.dart';
import '../error/exceptions.dart';
import '../utils/extensions.dart';
import '../utils/log_utils.dart';
import '../../config/language/strings.dart';
import 'api_constants.dart';
import 'status_code.dart';

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

  void updateLanguageCodeHeader();
}

const Set<String> _sensitiveBodyKeys = <String>{
  'password',
  'password_confirmation',
  'old_password',
  'new_password',
  'access_token',
  'token',
  'device_token',
};

String _sanitizeBodyForLog(Map<String, dynamic>? body) {
  if (body == null) {
    return 'null';
  }

  final Map<String, dynamic> sanitized = <String, dynamic>{};
  for (final MapEntry<String, dynamic> entry in body.entries) {
    final String normalizedKey = entry.key.toLowerCase();
    final bool isSensitive = _sensitiveBodyKeys.contains(normalizedKey) ||
        normalizedKey.contains('password') ||
        normalizedKey.contains('token');
    sanitized[entry.key] = isSensitive ? '***' : entry.value;
  }
  return sanitized.toString();
}

class DioConsumerImpl implements DioConsumer {
  final Dio client;

  DioConsumerImpl({required this.client}) {
    (client.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return httpClient;
    };

    final Map<String, String?> header = <String, String?>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.acceptLanguageHeader: Language.instance.currentCode,
    };

    client.options
      ..baseUrl = ApiConstants.baseUrl
      ..contentType = 'application/json'
      ..headers = header
      ..sendTimeout = const Duration(seconds: 120)
      ..receiveTimeout = const Duration(seconds: 120)
      ..connectTimeout = const Duration(seconds: 30);
    client.interceptors.add(appInterceptors);
    if (kDebugMode) {
      client.interceptors.add(prettyDioLogger);
    }
  }

  Future<void> _handleAccessTokenHeader() async {
    final String? accessToken = await secureStorageService.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      client.options.headers[HttpHeaders.authorizationHeader] =
          'Bearer $accessToken';
    } else {
      client.options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  @override
  void updateLanguageCodeHeader() {
    client.options.headers[HttpHeaders.acceptLanguageHeader] =
        Language.instance.currentCode;
  }

  @override
  Future get(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Log.i(
        '[GET][$path], params: ${queryParameters.toString()}, '
        'body: ${_sanitizeBodyForLog(body)}',
      );
      await _handleAccessTokenHeader();
      final response = await client.get(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      return response.data;
    } on SocketException catch (e) {
      Log.e('[GET][$path], SocketException ERROR: ${e.toString()}');
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Log.i(
        '[POST][$path], formData: ${formData?.toPrint}, '
        'body: ${_sanitizeBodyForLog(body)}, '
        'params: ${queryParameters.toString()}',
      );
      await _handleAccessTokenHeader();
      final response = await client.post(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      );
      return response.data;
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Log.i(
        '[PUT][$path], formData: ${formData?.toPrint}, '
        'body: ${_sanitizeBodyForLog(body)}, '
        'params: ${queryParameters.toString()}',
      );
      await _handleAccessTokenHeader();
      final response = await client.put(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      );
      return response.data;
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Log.i(
        '[PATCH][$path], formData: ${formData?.toPrint}, '
        'body: ${_sanitizeBodyForLog(body)}, '
        'params: ${queryParameters.toString()}',
      );
      await _handleAccessTokenHeader();
      final response = await client.patch(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      );
      return response.data;
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future delete(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Log.i(
        '[DELETE][$path], formData: ${formData?.toPrint}, '
        'body: ${_sanitizeBodyForLog(body)}, '
        'params: ${queryParameters.toString()}',
      );
      await _handleAccessTokenHeader();
      final response = await client.delete(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on SocketException {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  Never _handleDioError(DioException error) {
    if (error.response?.statusCode == StatusCode.unauthorized) {
      throw UnauthorizedException(
        message:
            error.response?.data['message'] ?? error.response?.data.toString(),
      );
    }
    if (error.type == DioExceptionType.unknown) {
      throw InternetConnectionException(message: Strings.noInternetConnection);
    }
    if (error.response?.statusCode == StatusCode.movedPermanently) {
      throw ServerException(
        message:
            error.response?.data['data'] ?? error.response?.data.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    throw ServerException(
      message:
          error.response?.data['message'] ?? error.response?.data.toString(),
      statusCode: error.response?.statusCode,
    );
  }
}
