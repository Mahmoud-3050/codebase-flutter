import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';
import '../../config/language/strings.dart';
import 'status_code.dart';

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
    final String? message = extractErrorMessage(error.response?.data);

    return switch (statusCode) {
      StatusCode.unauthorized => UnauthorizedException(message: message),
      StatusCode.forbidden => ForbiddenException(message: message),
      StatusCode.conflict => ConflictException(message: message),
      StatusCode.unProcessableContent => ValidationException(
        message: message,
        fieldErrors: extractFieldErrors(error.response?.data),
      ),
      StatusCode.tooManyRequests => TooManyRequestsException(message: message),
      StatusCode.movedPermanently => ServerException(
        message:
            extractErrorMessage(error.response?.data, preferDataField: true) ??
            message,
        statusCode: statusCode,
      ),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }
}

String? extractErrorMessage(dynamic data, {bool preferDataField = false}) {
  if (data is String) {
    return _messageFromStringBody(data);
  }
  if (data is! Map) {
    return null;
  }
  if (preferDataField) {
    final Object? field = data['data'];
    if (field is String && field.isNotEmpty) {
      return field;
    }
    if (field != null) {
      return field.toString();
    }
  }
  final Object? message = data['message'];
  if (message is String && message.isNotEmpty) {
    return message;
  }
  return _firstValidationMessage(data['errors']);
}

Map<String, List<String>> extractFieldErrors(dynamic data) {
  if (data is! Map) {
    return const <String, List<String>>{};
  }
  final Object? errors = data['errors'];
  if (errors is! Map) {
    return const <String, List<String>>{};
  }

  final Map<String, List<String>> fieldErrors = <String, List<String>>{};
  errors.forEach((Object? key, Object? value) {
    if (key is! String || key.isEmpty) {
      return;
    }
    if (value is List && value.isNotEmpty) {
      fieldErrors[key] = value.map((Object? item) => item.toString()).toList();
    } else if (value is String && value.isNotEmpty) {
      fieldErrors[key] = <String>[value];
    }
  });
  return fieldErrors;
}

String? _messageFromStringBody(String data) {
  final String trimmed = data.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
    try {
      return extractErrorMessage(jsonDecode(trimmed));
    } on FormatException {
      return null;
    }
  }
  return null;
}

String? _firstValidationMessage(dynamic errors) {
  if (errors is Map && errors.isNotEmpty) {
    final Object? first = errors.values.first;
    if (first is List && first.isNotEmpty) {
      return first.first.toString();
    }
    if (first is String && first.isNotEmpty) {
      return first;
    }
  }
  if (errors is List && errors.isNotEmpty) {
    return errors.first.toString();
  }
  return null;
}
