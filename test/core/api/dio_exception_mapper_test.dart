import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/dio_exception_mapper.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';

void main() {
  late DioExceptionMapper mapper;

  setUp(() {
    mapper = DioExceptionMapper.instance..init(noInternetMessage: _noInternet);
  });

  tearDown(DioExceptionMapper.instance.reset);

  DioException dioError({
    required DioExceptionType type,
    int? statusCode,
    dynamic data,
    String? message,
  }) {
    final RequestOptions requestOptions = RequestOptions(path: '/test');
    return DioException(
      requestOptions: requestOptions,
      type: type,
      message: message,
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
        .connectionTimeout,
        .sendTimeout,
        .receiveTimeout,
        .connectionError,
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

    test('maps transformTimeout to ServerException, not offline', () {
      expect(
        mapper.map(
          dioError(type: .transformTimeout, message: 'transform stalled'),
        ),
        isA<ServerException>().having(
          (ServerException e) => e.message,
          'message',
          'transform stalled',
        ),
      );
    });

    test('maps unknown and badCertificate to ServerException', () {
      expect(
        mapper.map(dioError(type: .unknown, message: 'parse failed')),
        isA<ServerException>().having(
          (ServerException e) => e.message,
          'message',
          'parse failed',
        ),
      );
      expect(
        mapper.map(dioError(type: .badCertificate)),
        isA<ServerException>(),
      );
    });

    test('maps cancel to RequestCancelledException', () {
      expect(
        mapper.map(dioError(type: .cancel)),
        isA<RequestCancelledException>(),
      );
    });

    test('maps 401 to UnauthorizedException using response message', () {
      final AppException exception = mapper.map(
        dioError(
          type: .badResponse,
          statusCode: StatusCode.unauthorized,
          data: <String, dynamic>{'message': 'Token expired'},
        ),
      );

      expect(exception, isA<UnauthorizedException>());
      expect(exception.message, 'Token expired');
    });

    test('maps 403, 409, 422, and 429 to distinct exceptions', () {
      expect(
        mapper.map(
          dioError(
            type: .badResponse,
            statusCode: StatusCode.forbidden,
            data: <String, dynamic>{'message': 'nope'},
          ),
        ),
        isA<ForbiddenException>().having(
          (ForbiddenException e) => e.message,
          'message',
          'nope',
        ),
      );
      expect(
        mapper.map(
          dioError(
            type: .badResponse,
            statusCode: StatusCode.conflict,
            data: <String, dynamic>{'message': 'exists'},
          ),
        ),
        isA<ConflictException>(),
      );
      expect(
        mapper.map(
          dioError(
            type: .badResponse,
            statusCode: StatusCode.tooManyRequests,
            data: <String, dynamic>{'message': 'Slow down'},
          ),
        ),
        isA<TooManyRequestsException>().having(
          (TooManyRequestsException e) => e.message,
          'message',
          'Slow down',
        ),
      );

      final AppException validation = mapper.map(
        dioError(
          type: .badResponse,
          statusCode: StatusCode.unProcessableContent,
          data: <String, dynamic>{
            'errors': <String, dynamic>{
              'email': <String>['invalid'],
            },
          },
        ),
      );
      expect(validation, isA<ValidationException>());
      expect(validation.message, 'invalid');
      expect((validation as ValidationException).fieldErrors['email'], <String>[
        'invalid',
      ]);
    });

    test('maps 301 using a non-string data field', () {
      final AppException exception = mapper.map(
        dioError(
          type: .badResponse,
          statusCode: StatusCode.movedPermanently,
          data: <String, dynamic>{'data': 301},
        ),
      );
      expect(exception.message, '301');
    });

    test('maps 301 using the data field', () {
      final AppException exception = mapper.map(
        dioError(
          type: .badResponse,
          statusCode: StatusCode.movedPermanently,
          data: <String, dynamic>{'data': 'moved', 'message': 'ignored'},
        ),
      );

      expect(
        exception,
        isA<ServerException>()
            .having((ServerException e) => e.message, 'message', 'moved')
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
          type: .badResponse,
          statusCode: StatusCode.internalServerError,
          data: <String, dynamic>{'message': 'Boom'},
        ),
      );

      expect(
        exception,
        isA<ServerException>()
            .having((ServerException e) => e.message, 'message', 'Boom')
            .having(
              (ServerException e) => e.statusCode,
              'statusCode',
              StatusCode.internalServerError,
            ),
      );
    });

    test('does not use HTML string bodies as the error message', () {
      final AppException exception = mapper.map(
        dioError(
          type: .badResponse,
          statusCode: StatusCode.badGateway,
          data: '<html><body>502 Bad Gateway</body></html>',
        ),
      );

      expect(
        exception,
        isA<ServerException>()
            .having((ServerException e) => e.message, 'message', isNull)
            .having(
              (ServerException e) => e.statusCode,
              'statusCode',
              StatusCode.badGateway,
            ),
      );
    });
  });

  group('extractErrorMessage', () {
    test('reads message from a map and ignores non-maps safely', () {
      expect(extractErrorMessage(<String, dynamic>{'message': 'oops'}), 'oops');
      expect(extractErrorMessage('plain'), isNull);
      expect(
        extractErrorMessage('<html><body>502 Bad Gateway</body></html>'),
        isNull,
      );
      expect(extractErrorMessage('{"message":"from json"}'), 'from json');
      expect(extractErrorMessage(''), isNull);
      expect(extractErrorMessage(null), isNull);
      expect(extractErrorMessage(42), isNull);
      expect(extractErrorMessage(<String, dynamic>{'status': 'error'}), isNull);
    });

    test('unwraps validation maps and string error values', () {
      expect(
        extractErrorMessage(<String, dynamic>{
          'errors': <String, dynamic>{
            'email': <String>['taken'],
          },
        }),
        'taken',
      );
      expect(
        extractErrorMessage(<String, dynamic>{
          'errors': <String, dynamic>{'phone': 'required'},
        }),
        'required',
      );
      expect(
        extractErrorMessage(<String, dynamic>{
          'errors': <String>['bad'],
        }),
        'bad',
      );
    });
  });

  group('extractFieldErrors', () {
    test('returns an empty map when errors are missing or invalid', () {
      expect(extractFieldErrors(null), isEmpty);
      expect(extractFieldErrors('nope'), isEmpty);
      expect(extractFieldErrors(<String, dynamic>{}), isEmpty);
      expect(extractFieldErrors(<String, dynamic>{'errors': 'x'}), isEmpty);
    });

    test('collects list and string field errors', () {
      expect(
        extractFieldErrors(<String, dynamic>{
          'errors': <dynamic, dynamic>{
            'email': <String>['invalid'],
            'name': 'required',
            1: 'ignored',
            'empty': <String>[],
          },
        }),
        <String, List<String>>{
          'email': <String>['invalid'],
          'name': <String>['required'],
        },
      );
    });
  });

  test('factory returns the singleton', () {
    expect(DioExceptionMapper(), same(DioExceptionMapper.instance));
  });
}

String _noInternet() => 'No internet';
