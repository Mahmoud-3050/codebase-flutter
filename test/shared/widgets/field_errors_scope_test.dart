import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/shared/widgets/field_errors_scope.dart';

void main() {
  group('ApiCallError.fromFailure', () {
    test('keeps ValidationFailure field errors', () {
      final ApiCallError<void> error = ApiCallError<void>.fromFailure(
        const ValidationFailure(
          message: 'invalid',
          fieldErrors: <String, List<String>>{
            'email': <String>['taken'],
          },
        ),
        fallbackMessage: 'try later',
      );

      expect(error.message, 'invalid');
      expect(error.hasFieldErrors, isTrue);
      expect(error.fieldErrors['email'], <String>['taken']);
    });

    test('uses fallback message and empty field errors for ServerFailure', () {
      final ApiCallError<void> error = ApiCallError<void>.fromFailure(
        const ServerFailure(),
        fallbackMessage: 'try later',
      );

      expect(error.message, 'try later');
      expect(error.hasFieldErrors, isFalse);
      expect(error.fieldErrors, isEmpty);
    });
  });

  group('FieldErrorsLookup', () {
    test('reads snake_case and camelCase keys', () {
      const Map<String, List<String>> errors = <String, List<String>>{
        'first_name': <String>['required'],
        'email': <String>['taken'],
      };

      expect(errors.messageFor('first_name'), 'required');
      expect(errors.messageFor('firstName'), 'required');
      expect(errors.messageFor('email'), 'taken');
      expect(errors.messageFor('phone'), isNull);
    });
  });
}
