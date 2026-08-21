import 'package:flutter/material.dart';

import '../domain/language.dart';
import 'language_localizations.dart';

class LanguageLocalizationsDelegate
    extends LocalizationsDelegate<LanguageLocalizations> {
  const LanguageLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return Language.instance.supportedLanguages.any(
      (lang) =>
          lang.code == locale.languageCode ||
          lang.fullCode == '${locale.languageCode}_${locale.countryCode ?? ''}',
    );
  }

  @override
  Future<LanguageLocalizations> load(Locale locale) async {
    final localizations = LanguageLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<LanguageLocalizations> old) => false;
}
