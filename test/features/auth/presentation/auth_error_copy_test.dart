import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/presentation/auth_error_copy.dart';

void main() {
  test('FR-049 expired OTP is the gone status, not the message text', () {
    expect(
      AuthErrorCopy.of(
        const ServerFailure(statusCode: StatusCode.gone, message: 'nope'),
        otp: true,
      ),
      Strings.expiredCode,
    );
    expect(
      AuthErrorCopy.of(
        const ServerFailure(message: 'this code has expired'),
        otp: true,
      ),
      Strings.invalidCode,
    );
    expect(
      AuthErrorCopy.of(
        const ValidationFailure(
          statusCode: StatusCode.unProcessableContent,
          fieldErrors: <String, List<String>>{
            'code': <String>['That code has expired. Request a new one.'],
          },
        ),
        otp: true,
      ),
      Strings.expiredCode,
    );
    expect(
      AuthErrorCopy.of(
        const ValidationFailure(
          statusCode: StatusCode.unProcessableContent,
          fieldErrors: <String, List<String>>{
            'code': <String>['wrong'],
          },
        ),
        otp: true,
      ),
      Strings.invalidCode,
    );
  });

  test('FR-049 a code field error is invalid, and a used code is 409', () {
    expect(
      AuthErrorCopy.of(
        const ValidationFailure(
          fieldErrors: <String, List<String>>{
            'code': <String>['wrong'],
          },
        ),
        otp: true,
      ),
      Strings.invalidCode,
    );
    expect(
      AuthErrorCopy.of(
        const ServerFailure(statusCode: StatusCode.conflict),
        otp: true,
      ),
      Strings.codeAlreadyUsed,
    );
  });

  test('FR-026a draft expiry follows status and token fields', () {
    expect(
      AuthErrorCopy.of(const ValidationFailure(), draftConflict: true),
      Strings.draftExpired,
    );
    expect(
      AuthErrorCopy.of(
        const ValidationFailure(
          fieldErrors: <String, List<String>>{
            'phone': <String>['unverified'],
          },
        ),
        draftConflict: true,
      ),
      isNot(Strings.draftExpired),
    );
  });

  test('FR-018a 429 maps to too many attempts', () {
    expect(
      AuthErrorCopy.of(
        const ServerFailure(statusCode: StatusCode.tooManyRequests),
      ),
      Strings.tooManyAttempts,
    );
  });
}
