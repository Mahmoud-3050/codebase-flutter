import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../domain/language.dart';
import 'language_localizations.dart';

class LanguageLocalizationsSetup {
  static List<Locale> get supportedLocales =>
      Language.instance.supportedLanguages.map((lang) => lang.locale).toList();

  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      [
    LanguageLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];

  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale>? supportedLocales,
  ) {
    if (locale == null ||
        supportedLocales == null ||
        supportedLocales.isEmpty) {
      return Language.instance.currentLocale;
    }

    final locales = supportedLocales.toList();
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      for (final supportedLocale in locales) {
        if (supportedLocale.languageCode == locale.languageCode &&
            supportedLocale.countryCode == countryCode) {
          return supportedLocale;
        }
      }
    }

    for (final supportedLocale in locales) {
      final supportedCountry = supportedLocale.countryCode;
      if (supportedLocale.languageCode == locale.languageCode &&
          (supportedCountry == null || supportedCountry.isEmpty)) {
        return supportedLocale;
      }
    }

    for (final supportedLocale in locales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return Language.instance.defaultLanguage.locale;
  }
}
