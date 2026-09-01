import 'package:language/language.dart';

import '../../core/services/local_storage/shared_preferences_service.dart';

/// Host [LanguageStorage] backed by [SharedPreferencesService].
class SharedPreferencesLanguageStorage implements LanguageStorage {
  const SharedPreferencesLanguageStorage(this._preferences);

  final SharedPreferencesService _preferences;

  static const String _key = 'languageCode';

  @override
  Future<String?> getLanguageCode() async => _preferences.getString(_key);

  @override
  Future<void> saveLanguageCode(String code) async {
    await _preferences.setString(_key, code);
  }
}
