/// The package reads/writes the JSON file stem (`ar`, `ar_EG`), not a Locale.
///
/// Host implements this (SharedPreferences, Hive, …) and passes it to
/// [Language.init]. Missing key must return `null`, never throw.
abstract interface class LanguageStorage {
  Future<String?> getLanguageCode();

  Future<void> saveLanguageCode(String code);
}

/// Null-object [LanguageStorage]: values do not survive process death.
class InMemoryLanguageStorage implements LanguageStorage {
  String? _languageCode;

  @override
  Future<String?> getLanguageCode() async => _languageCode;

  @override
  Future<void> saveLanguageCode(String code) async {
    _languageCode = code;
  }
}
