import 'package:flutter/services.dart';
import 'field_validator_singleton.dart';
import 'formatters.dart';

abstract class BaseValidator {
  final bool required;
  final String? customErrorMessage;

  const BaseValidator({this.required = true, this.customErrorMessage});

  String? validate(String? value);

  List<TextInputFormatter> get inputFormatters => const [];

  String? validateRequired(String? value) {
    if (required && (value == null || value.trim().isEmpty)) {
      return customErrorMessage ?? FieldValidator.instance.messages.required;
    }
    return null;
  }

  bool shouldValidate(String? value) {
    return required || (value != null && value.trim().isNotEmpty);
  }
}

class EmptyValidator extends BaseValidator {
  const EmptyValidator({super.required = true, super.customErrorMessage});

  @override
  String? validate(String? value) => validateRequired(value);
}

class PatternValidator extends BaseValidator {
  final String pattern;
  final String? _errorMessage;

  const PatternValidator({
    required this.pattern,
    String? errorMessage,
    super.required = true,
    super.customErrorMessage,
  }) : _errorMessage = errorMessage;

  String get defaultErrorMessage =>
      _errorMessage ?? FieldValidator.instance.messages.required;

  @override
  String? validate(String? value) {
    final requiredError = validateRequired(value);
    if (requiredError != null) return requiredError;
    if (!shouldValidate(value)) return null;

    if (!RegExp(pattern).hasMatch(value!.trim())) {
      return customErrorMessage ?? defaultErrorMessage;
    }
    return null;
  }
}

class GenericPatternValidator extends PatternValidator {
  const GenericPatternValidator({
    required super.pattern,
    super.errorMessage,
    super.required = true,
    super.customErrorMessage,
  });
}

class EmailValidator extends PatternValidator {
  const EmailValidator({super.required = true, super.customErrorMessage})
    : super(
        pattern:
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
      );

  @override
  String get defaultErrorMessage => FieldValidator.instance.messages.validEmail;
}

class TextOnlyValidator extends PatternValidator {
  const TextOnlyValidator({super.required = true, super.customErrorMessage})
    : super(pattern: r'^[a-zA-Z\s]+$');

  @override
  String get defaultErrorMessage => FieldValidator.instance.messages.validText;
}

class PhoneValidator extends BaseValidator {
  final String? phoneCode;
  final bool Function(String phone, String code)? phoneValidationHandler;

  const PhoneValidator({
    super.required = true,
    super.customErrorMessage,
    this.phoneCode,
    this.phoneValidationHandler,
  });

  @override
  String? validate(String? value) {
    final requiredError = validateRequired(value);
    if (requiredError != null) return requiredError;
    if (!shouldValidate(value)) return null;

    final trimmed = value!.trim();
    final isValid = (phoneCode != null && phoneValidationHandler != null)
        ? phoneValidationHandler!(trimmed, phoneCode!)
        : RegExp(
            r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
          ).hasMatch(trimmed);

    if (!isValid) {
      return customErrorMessage ?? FieldValidator.instance.messages.validPhone;
    }
    return null;
  }
}

class NumbersValidator extends BaseValidator {
  final int? requiredDigitLength;
  final int? maxDigitLength;
  final int? maxDecimalPlaces;
  final bool allowZero;

  const NumbersValidator({
    super.required = true,
    super.customErrorMessage,
    this.requiredDigitLength,
    this.maxDigitLength,
    this.maxDecimalPlaces,
    this.allowZero = false,
  });

  @override
  List<TextInputFormatter> get inputFormatters {
    final formatters = <TextInputFormatter>[ArabicToEnglishNumberFormatter()];

    if (maxDecimalPlaces != null && maxDecimalPlaces! > 0) {
      formatters.add(
        DecimalTextInputFormatter(decimalRange: maxDecimalPlaces!),
      );
    } else {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    if (requiredDigitLength != null && requiredDigitLength! > 0) {
      formatters.add(LengthLimitingTextInputFormatter(requiredDigitLength));
    } else if (maxDigitLength != null && maxDigitLength! > 0) {
      formatters.add(LengthLimitingTextInputFormatter(maxDigitLength));
    }

    return formatters;
  }

  @override
  String? validate(String? value) {
    final requiredError = validateRequired(value);
    if (requiredError != null) return requiredError;
    if (!shouldValidate(value)) return null;

    final trimmed = value!.trim();
    final parsed = num.tryParse(trimmed);
    if (parsed == null) {
      return customErrorMessage ??
          FieldValidator.instance.messages.validNumbers;
    }

    if (!allowZero && parsed == 0) {
      return customErrorMessage ??
          FieldValidator.instance.messages.zeroNotAllowed;
    }

    if ((maxDecimalPlaces == null || maxDecimalPlaces == 0) &&
        !RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return customErrorMessage ??
          FieldValidator.instance.messages.validNumbers;
    }

    if (maxDecimalPlaces != null && maxDecimalPlaces! > 0) {
      final parts = trimmed.split('.');
      if (parts.length == 2 && parts[1].length > maxDecimalPlaces!) {
        return customErrorMessage ??
            '${FieldValidator.instance.messages.maximumDecimalPlacesAllowed} ($maxDecimalPlaces)';
      }
    }

    final digitsOnlyLength = trimmed.replaceAll('.', '').length;
    if (requiredDigitLength != null &&
        digitsOnlyLength != requiredDigitLength!) {
      return customErrorMessage ??
          '${FieldValidator.instance.messages.mustBeDigitsCount} ($requiredDigitLength)';
    }

    if (maxDigitLength != null && digitsOnlyLength > maxDigitLength!) {
      return customErrorMessage ??
          '${FieldValidator.instance.messages.maximumDigitsAllowed} ($maxDigitLength)';
    }

    return null;
  }
}

class PasswordValidator extends BaseValidator {
  final int minLength;
  final String? password;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;

  const PasswordValidator({
    super.required = true,
    super.customErrorMessage,
    this.minLength = 8,
    this.password,
    this.requireUppercase = false,
    this.requireLowercase = false,
    this.requireNumbers = false,
    this.requireSpecialChars = false,
  });

  @override
  String? validate(String? value) {
    final requiredError = validateRequired(value);
    if (requiredError != null) {
      return customErrorMessage ??
          FieldValidator.instance.messages.validPassword;
    }
    if (!shouldValidate(value)) return null;

    if (value!.length < minLength) {
      return customErrorMessage ??
          FieldValidator.instance.messages.validPassword;
    }

    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(value)) {
      return FieldValidator.instance.messages.passwordUppercase;
    }
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(value)) {
      return FieldValidator.instance.messages.passwordLowercase;
    }
    if (requireNumbers && !RegExp(r'[0-9]').hasMatch(value)) {
      return FieldValidator.instance.messages.passwordNumber;
    }
    if (requireSpecialChars && !RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return FieldValidator.instance.messages.passwordSpecialChar;
    }

    if (password != null && password!.isNotEmpty && password != value) {
      return FieldValidator.instance.messages.validPasswordConfirm;
    }

    return null;
  }
}

class CompositeValidator extends BaseValidator {
  final List<BaseValidator> validators;

  const CompositeValidator({required this.validators, super.required = true});

  @override
  String? validate(String? value) {
    for (final validator in validators) {
      final error = validator.validate(value);
      if (error != null) return error;
    }
    return null;
  }
}

extension ValidatorExtension on BaseValidator {
  String? call(String? value) => validate(value);
}
