import 'dart:ui';

/// Supported locales for the field_validator package.
enum ValidatorLocale {
  en('en'),
  ar('ar');

  final String code;
  const ValidatorLocale(this.code);

  /// Parse locale code string to [ValidatorLocale] enum (defaults to [ValidatorLocale.en]).
  static ValidatorLocale fromCode(String code) {
    if (code.trim().toLowerCase().startsWith('ar')) {
      return .ar;
    }
    return .en;
  }

  // convert Locale dart:ui into ValidatorLocale
  static ValidatorLocale fromLocale(Locale locale) {
    return fromCode(locale.languageCode);
  }
}
