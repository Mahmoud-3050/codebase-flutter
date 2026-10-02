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

  /// Returns a [BaseValidator] suitable for [AppTextFormField.validatorType].
  ///
  /// [dialingCode] is read at validation time via the getter so callers
  /// pass a live reference (e.g. `() => _dialingCode`) rather than a
  /// captured snapshot.
  static BaseValidator phoneValidator(String Function() dialingCode) =>
      _PhoneBaseValidator(dialingCode);

  /// Imperative check — kept for call-sites that need a plain [String?].
  static String? phone({required String phone, required String dialingCode}) {
    final PhoneValidationResult result = PhoneValidationService()
        .validatePhoneNumber(phoneNumber: phone, phoneCode: dialingCode);
    if (result.isValidPhone) {
      return null;
    }
    return Strings.errorValidPhoneNumber;
  }
}

class _PhoneBaseValidator extends BaseValidator {
  const _PhoneBaseValidator(this._dialingCode);

  final String Function() _dialingCode;

  @override
  String? validate(String? value) {
    final String number = value?.trim() ?? '';
    if (number.isEmpty) {
      return Strings.errorValidPhoneNumber;
    }
    final PhoneValidationResult result = PhoneValidationService()
        .validatePhoneNumber(phoneNumber: number, phoneCode: _dialingCode());
    return result.isValidPhone ? null : Strings.errorValidPhoneNumber;
  }
}
