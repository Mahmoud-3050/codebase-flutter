import 'package:flutter/material.dart';

import '../data/asset_language_loader.dart';
import '../domain/language.dart';
import 'language_localizations_delegate.dart';

class LanguageLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = const {};

  LanguageLocalizations(this.locale);

  static LanguageLocalizations? _instance;

  static const LocalizationsDelegate<LanguageLocalizations> delegate =
      LanguageLocalizationsDelegate();

  static LanguageLocalizations get instance {
    return _instance ?? LanguageLocalizations(Language.instance.currentLocale);
  }

  static LanguageLocalizations? of(BuildContext context) {
    return Localizations.of<LanguageLocalizations>(
      context,
      LanguageLocalizations,
    );
  }

  Future<void> load({AssetBundle? bundle}) async {
    final language = Language.instance.fromLocale(locale);
    final assetPath = Language.instance.config?.assetPathFor(language);

    if (assetPath == null) {
      _localizedStrings = const {};
      _instance = this;
      return;
    }

    _localizedStrings =
        await AssetLanguageLoader.loadJsonTranslation(
          assetPath,
          bundle: bundle,
        ) ??
        const {};
    _instance = this;
  }

  String text(String key) => _localizedStrings[key] ?? key;

  String textParams(String key, Map<String, String> params) {
    String result = text(key);
    params.forEach((String name, String value) {
      result = result.replaceAll('{$name}', value);
    });
    return result;
  }
}

extension LanguageLocalizationsExtension on String {
  String get tr => LanguageLocalizations.instance.text(this);

  String trParams([Map<String, String> params = const <String, String>{}]) =>
      LanguageLocalizations.instance.textParams(this, params);
}
