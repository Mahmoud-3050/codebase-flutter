import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:themes/themes.dart';

/// Host [ThemeStorage] backed by [SharedPreferences].
class ThemeModeStorage implements ThemeStorage {
  const ThemeModeStorage(this._preferences);

  final SharedPreferences _preferences;

  static const String _key = 'appTheme';

  @override
  Future<String?> getThemeMode() async {
    try {
      return _preferences.getString(_key);
    } catch (e, stackTrace) {
      log('Error getting theme mode: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> saveThemeMode(String mode) async {
    try {
      await _preferences.setString(_key, mode);
      return true;
    } catch (e, stackTrace) {
      log('Error saving theme mode: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }
}
