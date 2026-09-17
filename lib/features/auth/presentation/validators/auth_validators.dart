import 'package:field_validator/field_validator.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/services/phone_number/phone_validation_service.dart';

abstract final class AuthValidators {
  static BaseValidator get password => FieldValidator.combine(<BaseValidator>[
    FieldValidator.password(requireNumbers: true),
    FieldValidator.pattern(
      pattern: r'[A-Za-z]',
      errorMessage: Strings.passwordLetterRequirement,
    ),
  ]);

  static BaseValidator get email => FieldValidator.email();

  static BaseValidator get fullName => FieldValidator.required();

  static String? phone({required String phone, required String dialingCode}) {
    final PhoneValidationResult result = PhoneValidationService()
        .validatePhoneNumber(phoneNumber: phone, phoneCode: dialingCode);
    if (result.isValidPhone) {
      return null;
    }
    return Strings.errorValidPhoneNumber;
  }
}
