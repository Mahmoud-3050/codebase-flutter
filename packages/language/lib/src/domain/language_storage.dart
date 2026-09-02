import 'dart:developer';

/// The package reads/writes the JSON file stem (`ar`, `ar_EG`), not a Locale.
///
/// Host implements this (SharedPreferences, Hive, …) and passes it to
/// [Language.init]. Missing key must return `null`, never throw.
abstract interface class LanguageStorage {

  Future<String?> getLanguageCode();

  Future<bool> saveLanguageCode(String code);
}

/// Null-object [LanguageStorage]: values do not survive process death.
class InMemoryLanguageStorage implements LanguageStorage {
  String? _languageCode;

  @override
  Future<String?> getLanguageCode() async {
    try {
      return _languageCode;
    } catch (e, stackTrace) {
      log('Error getting language code: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> saveLanguageCode(String code) async {
    try {
      _languageCode = code;
      return true;
    } catch (e, stackTrace) {
      log('Error saving language code: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }
}
