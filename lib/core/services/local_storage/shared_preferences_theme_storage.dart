import 'package:shared_preferences/shared_preferences.dart';
import 'package:themes/themes.dart';

/// Host [ThemeStorage] backed by [SharedPreferences].
///
/// Key and values (`light` / `dark`) match the previous `Themes` enum so
/// existing installs keep their saved mode.
class SharedPreferencesThemeStorage implements ThemeStorage {
  const SharedPreferencesThemeStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'appTheme';

  @override
  Future<String?> getThemeMode() async => _prefs.getString(_key);

  @override
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_key, mode);
  }
}
