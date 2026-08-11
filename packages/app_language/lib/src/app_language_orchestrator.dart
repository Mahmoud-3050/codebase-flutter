import 'package:flutter/material.dart';

import 'app_language_model.dart';

/// Main orchestrator and static state holder for the app_language package.
abstract final class AppLanguage {
  const AppLanguage._();

  /// Well-known static language model instances.
  static const en = AppLanguageModel.en;
  static const ar = AppLanguageModel.ar;

  /// The configured default language for the application.
  static AppLanguageModel defaultLanguage = en;

  /// Configurable dynamic supported languages list.
  static List<AppLanguageModel> supportedLanguages = const [en, ar];

  // Single Source of Truth for Current Active Language State
  static AppLanguageModel _current = en;

  /// Returns the current active [AppLanguageModel].
  // ignore: unnecessary_getters_setters — backing field powers derived accessors below
  static AppLanguageModel get current => _current;

  /// Sets the current active language state.
  static set current(AppLanguageModel language) => _current = language;

  /// Returns the current active [Locale].
  static Locale get currentLocale => _current.locale;

  /// Returns the current active language code string (e.g. 'en' or 'ar_EG').
  static String get currentCode => _current.fullCode;

  /// Returns true if current active language is Arabic.
  static bool get isArabic => _current.isArabic;

  /// Returns true if current active language is English.
  static bool get isEnglish => _current.isEnglish;

  /// Looks up [AppLanguageModel] from a language code string.
  /// Falls back to [defaultLanguage] when no match is found.
  static AppLanguageModel fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return defaultLanguage;

    final normalized = code.trim();
    final primaryCode = normalized.split('_')[0];

    return supportedLanguages.firstWhere(
      (lang) =>
          lang.fullCode == normalized ||
          lang.code == normalized ||
          lang.code == primaryCode,
      orElse: () => defaultLanguage,
    );
  }

  /// Converts a Flutter [Locale] into the matching [AppLanguageModel].
  static AppLanguageModel fromLocale(Locale locale) {
    final codeStr = (locale.countryCode != null && locale.countryCode!.isNotEmpty)
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    return fromCode(codeStr);
  }
}

/// Convenience extension on [BuildContext] for clean UI access to current language state.
extension AppLanguageContextExtension on BuildContext {
  AppLanguageModel get currentLanguage => AppLanguage.current;
  Locale get currentLocale => AppLanguage.currentLocale;
  String get currentLanguageCode => AppLanguage.currentCode;
  bool get isArabic => AppLanguage.isArabic;
  bool get isEnglish => AppLanguage.isEnglish;
}
