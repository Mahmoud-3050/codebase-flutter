import 'dart:convert';

import 'package:flutter/services.dart';

import 'app_language_model.dart';
import 'app_language_orchestrator.dart';
import 'language_config.dart';
import 'language_file_parser.dart';

/// Handles loading language data from the asset bundle.
class AssetLanguageLoader {
  const AssetLanguageLoader._();

  /// Scans the asset bundle for translation JSON files under [config.normalizedPathPrefix].
  /// Validates each file name via [LanguageFileParser] and populates [AppLanguage.supportedLanguages].
  static Future<List<AppLanguageModel>> discoverSupportedLanguages(
    LanguageConfig config, {
    AssetBundle? bundle,
  }) async {
    final prefix = config.normalizedPathPrefix;
    final targetBundle = bundle ?? rootBundle;

    final assetKeys = await _loadAssetKeys(targetBundle);
    final languageAssets = assetKeys.where((key) => key.startsWith(prefix)).toList();

    if (languageAssets.isEmpty) return AppLanguage.supportedLanguages;

    final parsedLanguages = <AppLanguageModel>[];

    for (final assetPath in languageAssets) {
      final fileName = assetPath.substring(prefix.length);
      if (fileName.contains('/') || fileName.isEmpty) continue;

      final parsedLanguage = LanguageFileParser.parse(fileName);
      if (!parsedLanguages.contains(parsedLanguage)) {
        parsedLanguages.add(parsedLanguage);
      }
    }

    if (parsedLanguages.isNotEmpty) {
      AppLanguage.supportedLanguages = List.unmodifiable(parsedLanguages);
    }

    return AppLanguage.supportedLanguages;
  }

  /// Loads a JSON translation file at [assetPath] and returns parsed key-value pairs.
  static Future<Map<String, String>?> loadJsonTranslation(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
    try {
      final targetBundle = bundle ?? rootBundle;
      final jsonString = await targetBundle.loadString(assetPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap.map<String, String>(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<String>> _loadAssetKeys(AssetBundle bundle) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(bundle);
      return manifest.listAssets();
    } catch (_) {
      return [];
    }
  }
}
