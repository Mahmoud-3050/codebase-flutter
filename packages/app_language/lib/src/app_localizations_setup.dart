import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_language_orchestrator.dart';
import 'app_localizations.dart';

class AppLocalizationsSetup {
  static List<Locale> get supportedLocales =>
      AppLanguage.supportedLanguages.map((lang) => lang.locale).toList();

  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];

  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale>? supportedLocales,
  ) {
    if (locale == null || supportedLocales == null || supportedLocales.isEmpty) {
      return AppLanguage.currentLocale;
    }

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        if (locale.countryCode != null &&
            locale.countryCode!.isNotEmpty &&
            supportedLocale.countryCode == locale.countryCode) {
          return supportedLocale;
        }
        return supportedLocale;
      }
    }
    return supportedLocales.first;
  }
}
