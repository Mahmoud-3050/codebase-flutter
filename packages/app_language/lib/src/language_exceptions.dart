/// Exception thrown when a language JSON asset file name fails strict format rules.
/// Expected format: 'ar.json' or 'ar_EG.json' (e.g. 2-3 lowercase language code + optional 2 uppercase country code).
class InvalidLanguageFileNameException implements Exception {
  final String fileName;
  final String message;

  const InvalidLanguageFileNameException(
    this.fileName, [
    this.message = 'Invalid language JSON file name format. Expected format: "ar.json" or "ar_EG.json"',
  ]);

  @override
  String toString() => 'InvalidLanguageFileNameException: "$fileName" — $message';
}
