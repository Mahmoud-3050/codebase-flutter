import 'language_model.dart';
import 'language_exceptions.dart';

/// Pure file-name grammar for language JSON assets (`ar.json`, `ar_EG.json`).
abstract final class LanguageFileParser {
  static final RegExp _fileNameRegex =
      RegExp(r'^[a-z]{2,3}(_[A-Z]{2})?\.json$');

  static String fileNameFromPath(String assetPath) {
    final normalized = assetPath.trim().replaceAll('\\', '/');
    final separatorIndex = normalized.lastIndexOf('/');
    if (separatorIndex == -1) return normalized;
    return normalized.substring(separatorIndex + 1);
  }

  static bool isValidFileName(String fileName) {
    return _fileNameRegex.hasMatch(fileName.trim());
  }

  /// File-name stem stored by [LanguageStorage]: `ar` or `ar_EG`.
  static bool isValidLanguageCode(String code) {
    return isValidFileName('${code.trim()}.json');
  }

  static LanguageModel parse(String fileName) {
    final cleanFileName = fileName.trim();
    if (!isValidFileName(cleanFileName)) {
      throw InvalidLanguageFileNameException(
        cleanFileName,
        'File name must strictly follow "ar.json" or "ar_EG.json" format.',
      );
    }

    final nameWithoutExtension =
        cleanFileName.substring(0, cleanFileName.length - 5);
    final parts = nameWithoutExtension.split('_');
    final languageCode = parts[0];
    final countryCode = parts.length > 1 ? parts[1] : null;

    return LanguageModel(
      code: languageCode,
      nativeName: _resolveNativeName(languageCode, countryCode),
      countryCode: countryCode,
    );
  }

  static String _resolveNativeName(String code, String? countryCode) {
    final suffix = countryCode != null ? ' ($countryCode)' : '';
    return switch (code) {
      'ar' => 'العربية$suffix',
      'en' => 'English$suffix',
      _ => '$code$suffix',
    };
  }
}
