import 'app_language_model.dart';

/// Configuration options for the app_language package.
class LanguageConfig {
  /// The asset path prefix where language JSON files are located (e.g. 'assets/lang/' or 'assets/lang').
  final String assetPathPrefix;

  /// Optional default language override.
  final AppLanguageModel? defaultLanguage;

  const LanguageConfig({
    required this.assetPathPrefix,
    this.defaultLanguage,
  });

  /// Returns normalized asset path prefix with a trailing slash.
  String get normalizedPathPrefix {
    final trimmed = assetPathPrefix.trim();
    if (trimmed.endsWith('/')) return trimmed;
    return '$trimmed/';
  }
}
