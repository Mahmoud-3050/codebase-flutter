import 'asset_loader.dart';
import 'base_validator.dart';
import 'validator_locale.dart';
import 'validator_messages.dart';

/// Singleton manager for field validation configuration and factory methods.
class FieldValidator {
  FieldValidator._internal();
  static final FieldValidator _instance = ._internal();
  static FieldValidator get instance => _instance;
  factory FieldValidator() => _instance;

  ValidatorLocale _locale = .en;
  ValidatorLocale get locale => _locale;

  ValidatorMessages _messages = ValidatorMessages.en();
  ValidatorMessages get messages => _messages;

  /// Initialize default locale ([ValidatorLocale.en] by default) and optional custom messages override
  void init({ValidatorLocale locale = .en, ValidatorMessages? messages}) {
    _locale = locale;
    _messages = messages ?? ValidatorMessages.fromLocale(locale);
  }

  /// Initialize messages directly from a JSON map (e.g. loaded from assets)
  void initFromJson(Map<String, dynamic> json, {ValidatorLocale locale = .en}) {
    _locale = locale;
    _messages = ValidatorMessages.fromJson(json, locale: locale);
  }

  /// Load localized messages directly from asset JSON path
  Future<void> loadFromAsset(
    ValidatorLocale locale, {
    AssetLoader assetLoader = const RootBundleAssetLoader(),
    String? pathPrefix,
  }) async {
    _locale = locale;
    _messages = await ValidatorMessages.loadFromAsset(
      locale,
      assetLoader: assetLoader,
      pathPrefix: pathPrefix,
    );
  }

  /// Change current locale dynamically
  void setLocale(ValidatorLocale locale) {
    _locale = locale;
    _messages = ValidatorMessages.fromLocale(locale);
  }

  // Factory helper methods
  static BaseValidator required({String? customError}) =>
      EmptyValidator(customErrorMessage: customError);

  static BaseValidator email({bool required = true, String? customError}) =>
      EmailValidator(required: required, customErrorMessage: customError);

  static BaseValidator phone({
    bool required = true,
    String? phoneCode,
    String? customError,
    bool Function(String phone, String code)? phoneValidationHandler,
  }) => PhoneValidator(
    required: required,
    phoneCode: phoneCode,
    customErrorMessage: customError,
    phoneValidationHandler: phoneValidationHandler,
  );

  static BaseValidator textOnly({bool required = true, String? customError}) =>
      TextOnlyValidator(required: required, customErrorMessage: customError);

  static BaseValidator numbers({
    bool required = true,
    int? requiredDigitLength,
    int? maxDigitLength,
    int? maxDecimalPlaces,
    bool allowZero = false,
    String? customError,
  }) => NumbersValidator(
    required: required,
    requiredDigitLength: requiredDigitLength,
    maxDigitLength: maxDigitLength,
    maxDecimalPlaces: maxDecimalPlaces,
    allowZero: allowZero,
    customErrorMessage: customError,
  );

  static BaseValidator password({
    bool required = true,
    int minLength = 8,
    String? password,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
    String? customError,
  }) => PasswordValidator(
    required: required,
    minLength: minLength,
    password: password,
    requireUppercase: requireUppercase,
    requireLowercase: requireLowercase,
    requireNumbers: requireNumbers,
    requireSpecialChars: requireSpecialChars,
    customErrorMessage: customError,
  );

  static BaseValidator pattern({
    required String pattern,
    required String errorMessage,
    bool required = true,
    String? customError,
  }) => PatternValidator(
    pattern: pattern,
    errorMessage: errorMessage,
    required: required,
    customErrorMessage: customError,
  );

  static BaseValidator combine(List<BaseValidator> validators) =>
      CompositeValidator(validators: validators);
}
