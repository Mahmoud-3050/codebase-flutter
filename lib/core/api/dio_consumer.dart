import 'dart:io';

import 'package:app_language/app_language.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../injection_container.dart';
import '../error/exceptions.dart';
import '../utils/enums.dart';
import '../utils/extensions.dart';
import '../utils/log_utils.dart';
import '../utils/values/strings.dart';
import 'api_constants.dart';
import 'status_code.dart';

abstract class DioConsumer {
  Future<dynamic> get(String path, {
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

  Future<dynamic> delete(String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });


  void updateLanguageCodeHeader();
}

class DioConsumerImpl implements DioConsumer {
  final Dio client;

  DioConsumerImpl({required this.client}) {
    /// The code customizes the Dio HTTP client's behavior...
    /// by configuring its httpClientAdapter to use a custom HttpClient instance...
    /// that bypasses SSL certificate validation.
    /// This setup is useful when you need more control over how...
    /// HTTP requests are made, especially in scenarios where you need to...
    /// handle self-signed certificates or other special network configurations.
    (client.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      // client.findProxy = (uri) {
      // Proxy all request to localhost:8888.
      // Be aware, the proxy should went through you running device,
      // not the host platform.
      //   return 'PROXY https://doctor-app-production.up.railway.app';
      // };

      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    Map<String, String?> header = {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.acceptLanguageHeader: AppLanguage.currentCode,
    };

    client.options
      ..baseUrl = ApiConstants.baseUrl
      ..contentType = 'application/json'
      ..headers = header
      ..sendTimeout = const Duration(minutes: 30)
      ..receiveTimeout = const Duration(minutes: 30)
      ..connectTimeout = const Duration(seconds: 120);
    client.interceptors.add(appInterceptors);
    if (kDebugMode) {
      client.interceptors.add(prettyDioLogger);
      // client.interceptors.add(logInterceptor);
    }
  }

  Future<void> _handleAccessTokenHeader() async {
    String? accessToken;
    if(deviceType == DeviceType.ios){
      accessToken = await sharedPreferencesService.getAccessToken();
    } else {
      accessToken = await secureStorageService.getAccessToken();
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      client.options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    } else {
      client.options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  @override
  void updateLanguageCodeHeader() {
    client.options.headers[HttpHeaders.acceptLanguageHeader] =
        AppLanguage.currentCode;
  }

  @override
  Future get(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      Log.i('[GET][$path], params: ${queryParameters.toString()}, body: ${body.toString()}');
      await _handleAccessTokenHeader();
      final response = await client.get(path, queryParameters: queryParameters, data: body);
      // Log.i('[GET][$path], response: ${response.data.toString()}');
      return response.data;
    } on SocketException catch(e){
      Log.e('[GET][$path], SocketException ERROR: ${e.toString()}');
      throw InternetConnectionException(
          message: Strings.noInternetConnection);
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
      Log.i('[POST][$path], formData: ${formData?.toPrint}, body: ${body.toString()}, params: ${queryParameters.toString()}');
      await _handleAccessTokenHeader();
      final response = await client.post(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      );
      // Log.i('[POST][$path], response: ${response.data.toString()}');
      return response.data;
    } on SocketException{
      throw InternetConnectionException(
          message: Strings.noInternetConnection);
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
      Log.i('[PUT][$path], formData: ${formData?.toPrint}, body: ${body.toString()}, params: ${queryParameters.toString()}');
      await _handleAccessTokenHeader();
      final response = await client.put(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      );
      // Log.i('[PUT][$path], response: ${response.data.toString()}');
      return response.data;
    } on SocketException {
      throw InternetConnectionException(
          message: Strings.noInternetConnection);
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
      Log.i('[PATCH][$path], formData: ${formData?.toPrint}, body: ${body.toString()}, params: ${queryParameters.toString()}');
      await _handleAccessTokenHeader();
      final response = await client.patch(
        path,
        queryParameters: queryParameters,
        data: formData ?? body,
      );
      // Log.i('[PATCH][$path], response: ${response.data.toString()}');
      return response.data;
    } on SocketException {
      throw InternetConnectionException(
          message: Strings.noInternetConnection);
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
      Log.i('[DELETE][$path], formData: ${formData?.toPrint}, body: ${body.toString()}, params: ${queryParameters.toString()}');
      await _handleAccessTokenHeader();
      final response = await client.delete(
        path,
        queryParameters: queryParameters,
      );
      // Log.i('[DELETE][$path], response: ${response.data.toString()}');
      return response.data;
    } on SocketException {
      throw InternetConnectionException(
          message: Strings.noInternetConnection);
    } on DioException catch (error) {
      _handleDioError(error);
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  void _handleDioError(DioException error) {
    if (error.response?.statusCode == StatusCode.unauthorized) {
      throw UnauthorizedException(message: error.response?.data['message']?? error.response?.data.toString());
    }
    if (error.type == DioExceptionType.unknown) {
      throw InternetConnectionException(
          message: Strings.noInternetConnection);
    }
    if (error.response?.statusCode == StatusCode.movedPermanently) {
      throw ServerException(
        message: error.response?.data['data']?? error.response?.data.toString(),
        statusCode: error.response?.statusCode,
      );
    }
    throw ServerException(
      message: error.response?.data['message']?? error.response?.data.toString(),
      statusCode: error.response?.statusCode,
    );
  }
}
