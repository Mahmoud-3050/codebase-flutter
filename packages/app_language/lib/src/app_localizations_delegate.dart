import 'package:flutter/material.dart';

import 'app_language_orchestrator.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguage.supportedLanguages.any(
      (lang) => lang.code == locale.languageCode ||
          lang.fullCode == '${locale.languageCode}_${locale.countryCode ?? ''}',
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final appLocalizations = AppLocalizations(locale);
    await appLocalizations.load();
    return appLocalizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
