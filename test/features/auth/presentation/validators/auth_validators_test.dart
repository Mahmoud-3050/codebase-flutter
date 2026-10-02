import 'package:field_validator/field_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/features/auth/presentation/validators/auth_validators.dart';

void main() {
  setUp(() => FieldValidator.instance.init());

  test('FR-007a FR-007b password requires 8 chars, a letter, and a digit', () {
    expect(AuthValidators.password.validate('short'), isNotNull);
    expect(AuthValidators.password.validate('abcdefgh'), isNotNull);
    expect(
      AuthValidators.password.validate('12345678'),
      Strings.passwordLetterRequirement,
    );
    expect(AuthValidators.password.validate('abc12345'), isNull);
  });

  test('FR-007 email validator accepts a well-formed address', () {
    expect(AuthValidators.email.validate('not-an-email'), isNotNull);
    expect(AuthValidators.email.validate('ada@example.com'), isNull);
  });

  test('FR-007 phone validator uses PhoneValidationService', () {
    expect(AuthValidators.phone(phone: '12', dialingCode: '+966'), isNotNull);
    expect(
      AuthValidators.phone(phone: '500000000', dialingCode: '+966'),
      isNull,
    );
  });

  test('FR-007b AuthValidators.password is the shared password rule', () {
    expect(AuthValidators.password, isNotNull);
    expect(AuthValidators.password.validate('Abcdef12'), isNull);
  });

  test('FR-007 AuthValidators.phoneValidator validates phone with dynamic dialing code', () {
    String currentCode = '+966';
    final validator = AuthValidators.phoneValidator(() => currentCode);

    expect(validator.validate(''), Strings.errorValidPhoneNumber);
    expect(validator.validate(null), Strings.errorValidPhoneNumber);
    expect(validator.validate('12'), Strings.errorValidPhoneNumber);
    expect(validator.validate('500000000'), isNull);

    // Dynamic update of dialingCode
    currentCode = '+1';
    expect(validator.validate('2025550123'), isNull);
  });
}
