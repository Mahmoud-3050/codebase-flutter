import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/error/failures.dart';

void main() {
  test('ValidationException keeps field errors on ValidationFailure', () {
    const ValidationException exception = ValidationException(
      message: 'invalid',
      fieldErrors: <String, List<String>>{
        'email': <String>['taken'],
      },
    );

    final Failure failure = exception.toFailure();

    expect(
      failure,
      isA<ValidationFailure>()
          .having(
            (ValidationFailure item) => item.message,
            'message',
            'invalid',
          )
          .having(
            (ValidationFailure item) => item.fieldErrors['email'],
            'email errors',
            <String>['taken'],
          ),
    );
  });

  test('UnauthorizedException maps to UnauthorizedFailure', () {
    expect(
      const UnauthorizedException(message: 'expired').toFailure(),
      isA<UnauthorizedFailure>().having(
        (UnauthorizedFailure item) => item.message,
        'message',
        'expired',
      ),
    );
  });

  test('RequestCancelledException maps to CancelledFailure', () {
    expect(
      const RequestCancelledException(message: 'cancelled').toFailure(),
      isA<CancelledFailure>().having(
        (CancelledFailure item) => item.message,
        'message',
        'cancelled',
      ),
    );
  });

  test('ForbiddenException keeps status on ServerFailure', () {
    expect(
      const ForbiddenException(message: 'nope').toFailure(),
      isA<ServerFailure>().having(
        (ServerFailure item) => item.statusCode,
        'statusCode',
        StatusCode.forbidden,
      ),
    );
  });
}
