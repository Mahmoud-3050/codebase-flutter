import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_response.dart';
import 'package:codebase/core/error/exceptions.dart';

void main() {
  test('isSuccess reads status: success', () {
    expect(
      ApiResponse.isSuccess(<String, dynamic>{'status': 'success'}),
      isTrue,
    );
  });

  test('isSuccess reads success: true', () {
    expect(ApiResponse.isSuccess(<String, dynamic>{'success': true}), isTrue);
  });

  test('isSuccess rejects other payloads', () {
    expect(
      ApiResponse.isSuccess(<String, dynamic>{'status': 'error'}),
      isFalse,
    );
    expect(ApiResponse.isSuccess('ok'), isFalse);
    expect(ApiResponse.isSuccess(null), isFalse);
  });

  test('messageOf reads a string message', () {
    expect(
      ApiResponse.messageOf(<String, dynamic>{'message': 'failed'}),
      'failed',
    );
    expect(ApiResponse.messageOf(<String, dynamic>{}), '');
  });

  group('exceptionOf', () {
    test('returns ServerException when errors are absent', () {
      final exception = ApiResponse.exceptionOf(<String, dynamic>{
        'status': 'error',
        'message': 'Failed',
      });
      expect(exception, isA<ServerException>());
      expect(exception.message, 'Failed');
    });

    test('returns ValidationException for a field-error map', () {
      final exception = ApiResponse.exceptionOf(<String, dynamic>{
        'status': 'error',
        'errors': <String, dynamic>{
          'email': <String>['taken'],
          'name': <String>['required'],
        },
      });
      expect(exception, isA<ValidationException>());
      expect(exception.message, 'taken');
      expect(
        (exception as ValidationException).fieldErrors,
        <String, List<String>>{
          'email': <String>['taken'],
          'name': <String>['required'],
        },
      );
    });

    test('returns ValidationException for a list of field objects', () {
      final exception = ApiResponse.exceptionOf(<String, dynamic>{
        'status': 'error',
        'errors': <Map<String, dynamic>>[
          <String, dynamic>{'field': 'email', 'message': 'taken'},
          <String, dynamic>{'name': 'phone', 'error': 'required'},
        ],
      });
      expect(exception, isA<ValidationException>());
      expect(exception.message, 'taken');
      expect((exception as ValidationException).fieldErrors['email'], <String>[
        'taken',
      ]);
      expect((exception as ValidationException).fieldErrors['phone'], <String>[
        'required',
      ]);
    });

    test('returns ValidationException for a list of error strings', () {
      final exception = ApiResponse.exceptionOf(<String, dynamic>{
        'status': 'error',
        'errors': <String>['email is taken', 'phone is required'],
      });
      expect(exception, isA<ValidationException>());
      expect(exception.message, 'email is taken');
      expect((exception as ValidationException).fieldErrors, isEmpty);
    });
  });
}
