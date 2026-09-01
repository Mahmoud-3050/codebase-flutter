import 'dart:convert';

import 'asset_loader.dart';
import 'validator_locale.dart';

/// Configuration class holding localized error messages for validators.
class ValidatorMessages {
  final String required;
  final String validEmail;
  final String validPhone;
  final String validText;
  final String validNumbers;
  final String validPassword;
  final String validPasswordConfirm;
  final String passwordUppercase;
  final String passwordLowercase;
  final String passwordNumber;
  final String passwordSpecialChar;
  final String zeroNotAllowed;
  final String maximumDecimalPlacesAllowed;
  final String mustBeDigitsCount;
  final String maximumDigitsAllowed;

  const ValidatorMessages({
    required this.required,
    required this.validEmail,
    required this.validPhone,
    required this.validText,
    required this.validNumbers,
    required this.validPassword,
    required this.validPasswordConfirm,
    required this.passwordUppercase,
    required this.passwordLowercase,
    required this.passwordNumber,
    required this.passwordSpecialChar,
    required this.zeroNotAllowed,
    required this.maximumDecimalPlacesAllowed,
    required this.mustBeDigitsCount,
    required this.maximumDigitsAllowed,
  });

  /// Factory constructor to create [ValidatorMessages] from a JSON map.
  factory ValidatorMessages.fromJson(
    Map<String, dynamic> json, {
    ValidatorLocale locale = .en,
  }) {
    final defaults = locale == .ar
        ? ValidatorMessages.ar()
        : ValidatorMessages.en();

    return ValidatorMessages(
      required:
          json['error_field_required']?.toString() ??
          json['required']?.toString() ??
          defaults.required,
      validEmail:
          json['error_valid_email']?.toString() ??
          json['valid_email']?.toString() ??
          defaults.validEmail,
      validPhone:
          json['error_valid_phone_number']?.toString() ??
          json['valid_phone']?.toString() ??
          defaults.validPhone,
      validText:
          json['error_valid_text']?.toString() ??
          json['valid_text']?.toString() ??
          defaults.validText,
      validNumbers:
          json['error_valid_numbers']?.toString() ??
          json['valid_numbers']?.toString() ??
          defaults.validNumbers,
      validPassword:
          json['error_valid_password']?.toString() ??
          json['valid_password']?.toString() ??
          defaults.validPassword,
      validPasswordConfirm:
          json['error_valid_password_confirm']?.toString() ??
          json['valid_password_confirm']?.toString() ??
          defaults.validPasswordConfirm,
      passwordUppercase:
          json['password_uppercase_requirement']?.toString() ??
          defaults.passwordUppercase,
      passwordLowercase:
          json['password_lowercase_requirement']?.toString() ??
          defaults.passwordLowercase,
      passwordNumber:
          json['password_number_requirement']?.toString() ??
          defaults.passwordNumber,
      passwordSpecialChar:
          json['password_special_character_requirement']?.toString() ??
          defaults.passwordSpecialChar,
      zeroNotAllowed:
          json['zero_not_allowed']?.toString() ?? defaults.zeroNotAllowed,
      maximumDecimalPlacesAllowed:
          json['maximum_decimal_places_allowed']?.toString() ??
          defaults.maximumDecimalPlacesAllowed,
      mustBeDigitsCount:
          json['must_be_digits_count']?.toString() ??
          defaults.mustBeDigitsCount,
      maximumDigitsAllowed:
          json['maximum_digits_allowed']?.toString() ??
          defaults.maximumDigitsAllowed,
    );
  }

  /// Load localized messages directly from asset JSON path
  static Future<ValidatorMessages> loadFromAsset(
    ValidatorLocale locale, {
    AssetLoader assetLoader = const RootBundleAssetLoader(),
    String? pathPrefix,
  }) async {
    final path = pathPrefix != null
        ? '$pathPrefix/${locale.code}.json'
        : 'packages/field_validator/assets/lang/${locale.code}.json';
    try {
      final jsonString = await assetLoader.loadString(path);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return ValidatorMessages.fromJson(jsonMap, locale: locale);
    } catch (_) {
      return ValidatorMessages.fromLocale(locale);
    }
  }

  /// English default error messages
  factory ValidatorMessages.en({
    String? required,
    String? validEmail,
    String? validPhone,
    String? validText,
    String? validNumbers,
    String? validPassword,
    String? validPasswordConfirm,
    String? passwordUppercase,
    String? passwordLowercase,
    String? passwordNumber,
    String? passwordSpecialChar,
    String? zeroNotAllowed,
    String? maximumDecimalPlacesAllowed,
    String? mustBeDigitsCount,
    String? maximumDigitsAllowed,
  }) {
    return ValidatorMessages(
      required: required ?? 'Field is required',
      validEmail: validEmail ?? 'Please enter a valid email address',
      validPhone: validPhone ?? 'Please enter a valid phone number',
      validText: validText ?? 'Please enter valid text only',
      validNumbers: validNumbers ?? 'Please enter valid numbers only',
      validPassword: validPassword ?? 'Password must be at least 8 characters',
      validPasswordConfirm: validPasswordConfirm ?? 'Passwords do not match',
      passwordUppercase:
          passwordUppercase ??
          'Password must contain at least one uppercase letter',
      passwordLowercase:
          passwordLowercase ??
          'Password must contain at least one lowercase letter',
      passwordNumber:
          passwordNumber ?? 'Password must contain at least one number',
      passwordSpecialChar:
          passwordSpecialChar ??
          'Password must contain at least one special character',
      zeroNotAllowed: zeroNotAllowed ?? 'Zero is not allowed',
      maximumDecimalPlacesAllowed:
          maximumDecimalPlacesAllowed ??
          'Maximum decimal places allowed exceeded',
      mustBeDigitsCount: mustBeDigitsCount ?? 'Digits count must be',
      maximumDigitsAllowed:
          maximumDigitsAllowed ?? 'Maximum digits allowed exceeded',
    );
  }

  /// Arabic default error messages
  factory ValidatorMessages.ar({
    String? required,
    String? validEmail,
    String? validPhone,
    String? validText,
    String? validNumbers,
    String? validPassword,
    String? validPasswordConfirm,
    String? passwordUppercase,
    String? passwordLowercase,
    String? passwordNumber,
    String? passwordSpecialChar,
    String? zeroNotAllowed,
    String? maximumDecimalPlacesAllowed,
    String? mustBeDigitsCount,
    String? maximumDigitsAllowed,
  }) {
    return ValidatorMessages(
      required: required ?? 'حقل مطلوب',
      validEmail: validEmail ?? 'يرجى إدخال عنوان بريد إلكتروني صحيح',
      validPhone: validPhone ?? 'يرجى إدخال رقم هاتف صحيح',
      validText: validText ?? 'يرجى إدخال نص صحيح',
      validNumbers: validNumbers ?? 'يرجى إدخال أرقام صحيحة',
      validPassword: validPassword ?? 'يرجى إدخال كلمة مرور صحيحة',
      validPasswordConfirm:
          validPasswordConfirm ?? 'يرجى تأكيد كلمة المرور بشكل صحيح',
      passwordUppercase:
          passwordUppercase ??
          'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل',
      passwordLowercase:
          passwordLowercase ??
          'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل',
      passwordNumber:
          passwordNumber ?? 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل',
      passwordSpecialChar:
          passwordSpecialChar ??
          'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل',
      zeroNotAllowed: zeroNotAllowed ?? 'الصفر غير مسموح به',
      maximumDecimalPlacesAllowed:
          maximumDecimalPlacesAllowed ?? 'تم تجاوز الحد الأقصى للمنازل العشرية',
      mustBeDigitsCount: mustBeDigitsCount ?? 'عدد الأرقام يجب أن يكون',
      maximumDigitsAllowed:
          maximumDigitsAllowed ?? 'تم تجاوز الحد الأقصى للأرقام',
    );
  }

  /// Get messages based on [ValidatorLocale]
  factory ValidatorMessages.fromLocale(ValidatorLocale locale) {
    switch (locale) {
      case .ar:
        return ValidatorMessages.ar();
      case .en:
        return ValidatorMessages.en();
    }
  }
}
