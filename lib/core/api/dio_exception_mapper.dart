import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../../config/language/strings.dart';
import 'status_code.dart';

final class DioExceptionMapper {
  const DioExceptionMapper({String Function()? noInternetMessage})
    : noInternetMessage = noInternetMessage ?? _defaultNoInternetMessage;

  static final DioExceptionMapper instance = const DioExceptionMapper();

  static String _defaultNoInternetMessage() => Strings.noInternetConnection;

  final String Function() noInternetMessage;

  AppException map(DioException error) {
    return switch (error.type) {
      .connectionTimeout ||
      .sendTimeout ||
      .receiveTimeout ||
      .transformTimeout ||
      .connectionError ||
      .unknown => InternetConnectionException(message: noInternetMessage()),
      .badResponse => _mapResponse(error),
      .badCertificate || .cancel => ServerException(message: error.message, statusCode: error.response?.statusCode),
    };
  }

  AppException _mapResponse(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final String? message = extractErrorMessage(error.response?.data);

    if (statusCode == StatusCode.unauthorized) {
      return UnauthorizedException(message: message);
    }
    if (statusCode == StatusCode.movedPermanently) {
      return ServerException(
        message: extractErrorMessage(error.response?.data, preferDataField: true) ?? message,
        statusCode: statusCode,
      );
    }
    return ServerException(message: message, statusCode: statusCode);
  }
}

String? extractErrorMessage(dynamic data, {bool preferDataField = false}) {
  if (data is Map) {
    if (preferDataField && data['data'] != null) {
      return data['data'].toString();
    }
    if (data['message'] != null) {
      return data['message'].toString();
    }
    return data.toString();
  }
  return data?.toString();
}
