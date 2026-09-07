import 'dart:convert';

import '../error/exceptions.dart';

/// Single place to decide whether a JSON body is a successful API payload,
/// and to map failed bodies (including form `errors`) to [AppException].
///
/// Change [isSuccess] if the backend switches from `status: 'success'` to
/// `success: true` (or needs both).
abstract final class ApiResponse {
  static const String errorsKey = 'errors';

  static bool isSuccess(dynamic data) {
    if (data is! Map) {
      return false;
    }
    final Object? status = data['status'];
    if (status == 'success' || status == true) {
      return true;
    }
    return data['success'] == true;
  }

  static String messageOf(dynamic data) {
    if (data is! Map) {
      return '';
    }
    final Object? message = data['message'];
    if (message is String) {
      return message;
    }
    return '';
  }

  /// Maps a failed JSON body to [ValidationException] when `errors` is present,
  /// otherwise [ServerException].
  static AppException exceptionOf(dynamic data) {
    final String? parsed = extractErrorMessage(data);
    final String fallback = messageOf(data);
    final String? message = (parsed != null && parsed.isNotEmpty)
        ? parsed
        : (fallback.isEmpty ? null : fallback);

    if (hasFormErrors(data)) {
      return ValidationException(
        message: message,
        fieldErrors: extractFieldErrors(data),
      );
    }
    return ServerException(message: message);
  }
}

bool hasFormErrors(dynamic data) {
  if (data is! Map) {
    return false;
  }
  final Object? errors = data[ApiResponse.errorsKey];
  if (errors is Map) {
    return errors.isNotEmpty;
  }
  if (errors is List) {
    return errors.isNotEmpty;
  }
  return false;
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
  return _firstValidationMessage(data[ApiResponse.errorsKey]);
}

Map<String, List<String>> extractFieldErrors(dynamic data) {
  if (data is! Map) {
    return const <String, List<String>>{};
  }
  final Object? errors = data[ApiResponse.errorsKey];
  if (errors is Map) {
    return _fieldErrorsFromMap(errors);
  }
  if (errors is List) {
    return _fieldErrorsFromList(errors);
  }
  return const <String, List<String>>{};
}

Map<String, List<String>> _fieldErrorsFromMap(Map<dynamic, dynamic> errors) {
  final Map<String, List<String>> fieldErrors = <String, List<String>>{};
  errors.forEach((Object? key, Object? value) {
    _appendFieldError(fieldErrors, key, value);
  });
  return fieldErrors;
}

Map<String, List<String>> _fieldErrorsFromList(List<dynamic> errors) {
  final Map<String, List<String>> fieldErrors = <String, List<String>>{};
  for (final Object? item in errors) {
    if (item is! Map) {
      continue;
    }
    final Object? field =
        item['field'] ?? item['name'] ?? item['key'] ?? item['attribute'];
    final Object? message = item['message'] ?? item['error'] ?? item['msg'];
    if (field is String && field.isNotEmpty) {
      _appendFieldError(fieldErrors, field, message);
      continue;
    }
    item.forEach((Object? key, Object? value) {
      if (_isErrorObjectMetaKey(key)) {
        return;
      }
      _appendFieldError(fieldErrors, key, value);
    });
  }
  return fieldErrors;
}

bool _isErrorObjectMetaKey(Object? key) {
  return key == 'field' ||
      key == 'name' ||
      key == 'key' ||
      key == 'attribute' ||
      key == 'message' ||
      key == 'error' ||
      key == 'msg';
}

void _appendFieldError(
  Map<String, List<String>> fieldErrors,
  Object? key,
  Object? value,
) {
  if (key is! String || key.isEmpty) {
    return;
  }
  final List<String> messages = _messagesOf(value);
  if (messages.isEmpty) {
    return;
  }
  fieldErrors.putIfAbsent(key, () => <String>[]).addAll(messages);
}

List<String> _messagesOf(Object? value) {
  if (value is List && value.isNotEmpty) {
    return value
        .map((Object? item) => item?.toString() ?? '')
        .where((String item) => item.isNotEmpty)
        .toList();
  }
  if (value is String && value.isNotEmpty) {
    return <String>[value];
  }
  return const <String>[];
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
    final Object? named = errors['message'] ?? errors['error'] ?? errors['msg'];
    if (named is String && named.isNotEmpty) {
      if (errors.containsKey('field') ||
          errors.containsKey('name') ||
          errors.containsKey('attribute') ||
          errors.containsKey('key')) {
        return named;
      }
    }
    for (final Object? value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
    }
    for (final Object? value in errors.values) {
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
  }
  if (errors is List && errors.isNotEmpty) {
    final Object? first = errors.first;
    if (first is Map) {
      return _firstValidationMessage(first);
    }
    return first.toString();
  }
  return null;
}
