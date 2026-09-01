import 'package:themes/themes.dart';

import 'shared_preferences_service.dart';

/// Host [ThemeStorage] backed by [SharedPreferencesService].
///
/// Key and values (`light` / `dark`) match the previous `Themes` enum so
/// existing installs keep their saved mode.
class SharedPreferencesThemeStorage implements ThemeStorage {
  const SharedPreferencesThemeStorage(this._preferences);

  final SharedPreferencesService _preferences;

  static const String _key = 'appTheme';

  @override
  Future<String?> getThemeMode() async => _preferences.getString(_key);

  @override
  Future<void> saveThemeMode(String mode) async {
    await _preferences.setString(_key, mode);
  }
}
