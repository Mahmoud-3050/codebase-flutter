import 'package:language/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Host [LanguageStorage] backed by [SharedPreferences].
class SharedPreferencesLanguageStorage implements LanguageStorage {
  const SharedPreferencesLanguageStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'languageCode';

  @override
  Future<String?> getLanguageCode() async => _prefs.getString(_key);

  @override
  Future<void> saveLanguageCode(String code) async {
    await _prefs.setString(_key, code);
  }
}
