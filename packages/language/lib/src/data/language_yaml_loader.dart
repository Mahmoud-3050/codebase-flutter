import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../domain/language_model.dart';
import '../domain/language_config.dart';
import '../domain/language_exceptions.dart';
import '../domain/language_file_parser.dart';

abstract final class LanguageYamlKeys {
  static const defaultLanguage = 'default_language';
  static const files = 'files';
}

/// Loads [LanguageConfig] from the host `language.yaml` asset.
abstract final class LanguageYamlLoader {
  static const String defaultAssetName = 'language.yaml';

  static Future<LanguageConfig> load({
    String assetName = defaultAssetName,
    AssetBundle? bundle,
  }) async {
    final targetBundle = bundle ?? rootBundle;
    late final String yamlString;
    try {
      yamlString = await targetBundle.loadString(assetName);
    } catch (_) {
      throw MissingLanguageYamlException(assetName);
    }
    return parse(yamlString);
  }

  static LanguageConfig parse(String yamlString) {
    final document = loadYaml(yamlString);
    if (document is! YamlMap) {
      throw const InvalidLanguageYamlException(
        'language.yaml must be a YAML map with a "files" list.',
      );
    }

    final jsonAssetPaths = _parseFiles(document);
    final declaredLanguages = [
      for (final path in jsonAssetPaths)
        LanguageFileParser.parse(LanguageFileParser.fileNameFromPath(path)),
    ];
    final defaultLanguage = _parseDefaultLanguage(
      document[LanguageYamlKeys.defaultLanguage],
      declaredLanguages,
    );

    return LanguageConfig(
      jsonAssetPaths: .unmodifiable(jsonAssetPaths),
      defaultLanguage: defaultLanguage,
    );
  }

  static List<String> _parseFiles(YamlMap document) {
    final filesNode = document[LanguageYamlKeys.files];
    if (filesNode is! YamlList || filesNode.isEmpty) {
      throw const InvalidLanguageYamlException(
        'language.yaml must declare a non-empty "files" list of JSON asset paths.',
      );
    }

    final jsonAssetPaths = <String>[];
    for (final entry in filesNode) {
      final path = _asNonEmptyString(entry);
      if (path == null) {
        throw const InvalidLanguageYamlException(
          'Each entry in "files" must be a non-empty asset path string.',
        );
      }
      if (!path.toLowerCase().endsWith('.json')) {
        throw InvalidLanguageYamlException(
          'Language asset path must point to a .json file: "$path".',
        );
      }

      LanguageFileParser.parse(LanguageFileParser.fileNameFromPath(path));
      jsonAssetPaths.add(path);
    }
    return jsonAssetPaths;
  }

  static LanguageModel _parseDefaultLanguage(
    Object? defaultLanguageNode,
    List<LanguageModel> declaredLanguages,
  ) {
    if (declaredLanguages.isEmpty) {
      throw const InvalidLanguageYamlException(
        'language.yaml must declare a non-empty "files" list of JSON asset paths.',
      );
    }

    final requestedCode = _asNonEmptyString(defaultLanguageNode);
    if (requestedCode == null) {
      return declaredLanguages.first;
    }

    final matched = LanguageModel.lookup(declaredLanguages, requestedCode);
    if (matched != null) return matched;

    throw InvalidLanguageYamlException(
      '"default_language" "$requestedCode" does not match any declared JSON file.',
    );
  }

  static String? _asNonEmptyString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}
