import 'package:flutter/material.dart';

import 'app_language_orchestrator.dart';
import 'app_localizations_delegate.dart';
import 'asset_language_loader.dart';

/// Holds the loaded translation strings for the current [locale]
/// and provides key-based translation lookup.
class AppLocalizations {
  final Locale locale;
  final String assetPathPrefix;
  Map<String, String> _localizedStrings = const {};

  AppLocalizations(
    this.locale, {
    this.assetPathPrefix = 'assets/lang/',
  });

  static AppLocalizations? _instance;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  /// Global singleton instance for `.tr` extension access.
  static AppLocalizations get instance {
    return _instance ?? AppLocalizations(AppLanguage.currentLocale);
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Loads translation JSON file via [AssetLanguageLoader].
  Future<void> load({String? customPathPrefix}) async {
    final prefix = customPathPrefix ?? assetPathPrefix;
    final normalizedPrefix = prefix.endsWith('/') ? prefix : '$prefix/';
    final language = AppLanguage.fromLocale(locale);

    final fullPath = '$normalizedPrefix${language.fullCode}.json';
    final fallbackPath = '$normalizedPrefix${language.code}.json';

    _localizedStrings = await AssetLanguageLoader.loadJsonTranslation(fullPath) ??
        await AssetLanguageLoader.loadJsonTranslation(fallbackPath) ??
        const {};
    _instance = this;
  }

  /// Retrieves localized string for given [key].
  String text(String key) => _localizedStrings[key] ?? key;
}

/// Extension on [String] to provide easy `.tr` translation syntax.
extension AppLocalizationsExtension on String {
  String get tr => AppLocalizations.instance.text(this);
}
