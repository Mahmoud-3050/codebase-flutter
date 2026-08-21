import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/language_model.dart';
import '../domain/language_config.dart';
import '../domain/language_file_parser.dart';

/// JSON translation I/O from the asset bundle.
abstract final class AssetLanguageLoader {
  static List<LanguageModel> languagesFromConfig(LanguageConfig config) {
    final parsedLanguages = <LanguageModel>[];
    for (final assetPath in config.jsonAssetPaths) {
      final fileName = LanguageFileParser.fileNameFromPath(assetPath);
      if (fileName.isEmpty) continue;
      final parsedLanguage = LanguageFileParser.parse(fileName);
      if (!parsedLanguages.contains(parsedLanguage)) {
        parsedLanguages.add(parsedLanguage);
      }
    }
    return List.unmodifiable(parsedLanguages);
  }

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
}
