import 'app_language_model.dart';
import 'language_exceptions.dart';

/// Validates and parses language JSON file names into [AppLanguageModel] instances.
///
/// Expected formats: `'ar.json'` or `'ar_EG.json'`
/// (2–3 lowercase language code + optional underscore + 2 uppercase country code).
class LanguageFileParser {
  const LanguageFileParser._();

  /// Strict regex for valid language asset JSON file names.
  static final RegExp _fileNameRegex = RegExp(r'^[a-z]{2,3}(_[A-Z]{2})?\.json$');

  /// Returns `true` if [fileName] matches the expected format.
  static bool isValidFileName(String fileName) {
    return _fileNameRegex.hasMatch(fileName.trim());
  }

  /// Parses [fileName] into an [AppLanguageModel] or throws [InvalidLanguageFileNameException].
  static AppLanguageModel parse(String fileName) {
    final cleanFileName = fileName.trim();
    if (!isValidFileName(cleanFileName)) {
      throw InvalidLanguageFileNameException(
        cleanFileName,
        'File name must strictly follow "ar.json" or "ar_EG.json" format.',
      );
    }

    final nameWithoutExtension = cleanFileName.substring(0, cleanFileName.length - 5);
    final parts = nameWithoutExtension.split('_');

    final languageCode = parts[0];
    final countryCode = parts.length > 1 ? parts[1] : null;

    return AppLanguageModel(
      code: languageCode,
      nativeName: _resolveNativeName(languageCode, countryCode),
      countryCode: countryCode,
    );
  }

  /// Resolves a human-readable native name for well-known language codes.
  static String _resolveNativeName(String code, String? countryCode) {
    final suffix = countryCode != null ? ' ($countryCode)' : '';

    return switch (code) {
      'ar' => 'العربية$suffix',
      'en' => 'English$suffix',
      _ => '$code$suffix',
    };
  }
}
