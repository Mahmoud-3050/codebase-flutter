/// Exception thrown when a language JSON asset file name fails strict format rules.
class InvalidLanguageFileNameException implements Exception {
  final String fileName;
  final String message;

  const InvalidLanguageFileNameException(
    this.fileName, [
    this.message =
        'Invalid language JSON file name format. Expected format: "ar.json" or "ar_EG.json"',
  ]);

  @override
  String toString() =>
      'InvalidLanguageFileNameException: "$fileName" — $message';
}

/// Thrown when the host project's language YAML asset cannot be loaded.
class MissingLanguageYamlException implements Exception {
  final String assetName;

  const MissingLanguageYamlException(this.assetName);

  @override
  String toString() =>
      'MissingLanguageYamlException: expected language YAML asset "$assetName" '
      'in the host project (declare it under flutter.assets in pubspec.yaml).';
}

/// Thrown when the language YAML is present but malformed.
class InvalidLanguageYamlException implements Exception {
  final String message;

  const InvalidLanguageYamlException(this.message);

  @override
  String toString() => 'InvalidLanguageYamlException: $message';
}

/// Thrown when [Language.changeLanguage] is given a model not declared in YAML `files`.
class UnsupportedLanguageException implements Exception {
  final String languageCode;

  const UnsupportedLanguageException(this.languageCode);

  @override
  String toString() =>
      'UnsupportedLanguageException: "$languageCode" is not in language.yaml files.';
}

/// Thrown when language state is accessed before [Language.init] has run.
class LanguageNotInitializedException implements Exception {
  const LanguageNotInitializedException();

  @override
  String toString() =>
      'LanguageNotInitializedException: call Language.instance.init() before runApp().';
}
