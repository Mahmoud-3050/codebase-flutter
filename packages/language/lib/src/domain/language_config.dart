import 'language_model.dart';
import 'language_file_parser.dart';

/// Immutable configuration from host `language.yaml`.
class LanguageConfig {
  final List<String> jsonAssetPaths;
  final LanguageModel? defaultLanguage;

  const LanguageConfig({
    required this.jsonAssetPaths,
    this.defaultLanguage,
  });

  List<LanguageModel> get declaredLanguages {
    final parsedLanguages = <LanguageModel>[];
    for (final path in jsonAssetPaths) {
      final fileName = LanguageFileParser.fileNameFromPath(path);
      if (fileName.isEmpty) continue;
      final parsedLanguage = LanguageFileParser.parse(fileName);
      if (!parsedLanguages.contains(parsedLanguage)) {
        parsedLanguages.add(parsedLanguage);
      }
    }
    return List.unmodifiable(parsedLanguages);
  }

  String? assetPathFor(LanguageModel language) {
    String? codeMatch;
    for (final path in jsonAssetPaths) {
      final parsed = LanguageFileParser.parse(
        LanguageFileParser.fileNameFromPath(path),
      );
      if (parsed.fullCode == language.fullCode) return path;
      if (parsed.code == language.code) {
        codeMatch ??= path;
      }
    }
    return codeMatch;
  }
}
