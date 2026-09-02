import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:language/language.dart';

/// Host [LanguageStorage] backed by [SharedPreferencesService].
class LanguageCodeStorage implements LanguageStorage {
  const LanguageCodeStorage(this._preferences);

  final SharedPreferences _preferences;

  static const String _key = 'languageCode';

  @override
  Future<String?> getLanguageCode() async {
    try {
      return _preferences.getString(_key);
    } catch (e, stackTrace) {
      log('Error getting language code: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> saveLanguageCode(String code) async {
    try {
      await _preferences.setString(_key, code);
      return true;
    } catch (e, stackTrace) {
      log('Error saving language code: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }
}
