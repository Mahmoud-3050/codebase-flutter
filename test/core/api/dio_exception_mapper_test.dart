import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/dio_exception_mapper.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';

void main() {
  const DioExceptionMapper mapper = DioExceptionMapper(
    noInternetMessage: _noInternet,
  );

  DioException dioError({
    required DioExceptionType type,
    int? statusCode,
    dynamic data,
  }) {
    final RequestOptions requestOptions = RequestOptions(path: '/test');
    return DioException(
      requestOptions: requestOptions,
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: requestOptions,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('DioExceptionMapper', () {
    test('maps connection failures to InternetConnectionException', () {
      for (final DioExceptionType type in <DioExceptionType>[
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.unknown,
      ]) {
        expect(
          mapper.map(dioError(type: type)),
          isA<InternetConnectionException>().having(
            (InternetConnectionException e) => e.message,
            'message',
            'No internet',
          ),
        );
      }
    });

    test('maps 401 to UnauthorizedException using response message', () {
      final AppException exception = mapper.map(
        dioError(
          type: DioExceptionType.badResponse,
          statusCode: StatusCode.unauthorized,
          data: <String, dynamic>{'message': 'Token expired'},
        ),
      );

      expect(exception, isA<UnauthorizedException>());
      expect(exception.message, 'Token expired');
    });

    test('maps 301 using the data field', () {
      final AppException exception = mapper.map(
        dioError(
          type: DioExceptionType.badResponse,
          statusCode: StatusCode.movedPermanently,
          data: <String, dynamic>{'data': 'moved', 'message': 'ignored'},
        ),
      );

      expect(
        exception,
        isA<ServerException>()
            .having(
              (ServerException e) => e.message,
              'message',
              'moved',
            )
            .having(
              (ServerException e) => e.statusCode,
              'statusCode',
              StatusCode.movedPermanently,
            ),
      );
    });

    test('maps other HTTP failures to ServerException with status', () {
      final AppException exception = mapper.map(
        dioError(
          type: DioExceptionType.badResponse,
          statusCode: StatusCode.tooManyRequests,
          data: <String, dynamic>{'message': 'Slow down'},
        ),
      );

      expect(
        exception,
        isA<ServerException>()
            .having(
              (ServerException e) => e.message,
              'message',
              'Slow down',
            )
            .having(
              (ServerException e) => e.statusCode,
              'statusCode',
              StatusCode.tooManyRequests,
            ),
      );
    });
  });

  group('extractErrorMessage', () {
    test('reads message from a map and ignores non-maps safely', () {
      expect(
        extractErrorMessage(<String, dynamic>{'message': 'oops'}),
        'oops',
      );
      expect(extractErrorMessage('plain'), 'plain');
      expect(extractErrorMessage(null), isNull);
    });
  });
}

String _noInternet() => 'No internet';
