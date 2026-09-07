import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';
import '../../config/language/strings.dart';
import 'api_response.dart';
import 'status_code.dart';

export 'api_response.dart'
    show extractErrorMessage, extractFieldErrors, hasFormErrors;

final class DioExceptionMapper {
  DioExceptionMapper._();

  static final DioExceptionMapper instance = ._();

  factory DioExceptionMapper() => instance;

  String Function()? _noInternetMessage;

  /// Optional override. Production uses [Strings.noInternetConnection].
  void init({String Function()? noInternetMessage}) {
    _noInternetMessage = noInternetMessage;
  }

  @visibleForTesting
  void reset() {
    _noInternetMessage = null;
  }

  String Function() get noInternetMessage =>
      _noInternetMessage ?? () => Strings.noInternetConnection;

  AppException map(DioException error) {
    return switch (error.type) {
      .connectionTimeout ||
      .sendTimeout ||
      .receiveTimeout ||
      .connectionError => InternetConnectionException(
        message: noInternetMessage(),
      ),
      .badResponse => _mapResponse(error),
      .cancel => const RequestCancelledException(),
      .badCertificate || .unknown || .transformTimeout => ServerException(
        message: error.message,
        statusCode: error.response?.statusCode,
      ),
    };
  }

  AppException _mapResponse(DioException error) {
    final int? statusCode = error.response?.statusCode;
    final dynamic data = error.response?.data;
    final String? message = extractErrorMessage(data);

    if (statusCode == StatusCode.unProcessableContent ||
        (statusCode == StatusCode.badRequest && hasFormErrors(data))) {
      return ValidationException(
        message: message,
        fieldErrors: extractFieldErrors(data),
      );
    }

    return switch (statusCode) {
      StatusCode.unauthorized => UnauthorizedException(message: message),
      StatusCode.forbidden => ForbiddenException(message: message),
      StatusCode.conflict => ConflictException(message: message),
      StatusCode.tooManyRequests => TooManyRequestsException(message: message),
      StatusCode.movedPermanently => ServerException(
        message: extractErrorMessage(data, preferDataField: true) ?? message,
        statusCode: statusCode,
      ),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }
}
