import 'dart:developer';

/// The package reads/writes `'light'` or `'dark'`.
///
/// Host implements this (SharedPreferences, Hive, …) and passes it to
/// [Themes.init]. Missing key must return `null`, never throw.
abstract interface class ThemeStorage {
  Future<String?> getThemeMode();

  Future<bool> saveThemeMode(String mode);
}

/// Null-object [ThemeStorage]: values do not survive process death.
class InMemoryThemeStorage implements ThemeStorage {
  String? _themeMode;

  @override
  Future<String?> getThemeMode() async {
    try {
      return _themeMode;
    } catch (e, stackTrace) {
      log('Error getting theme mode: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> saveThemeMode(String mode) async {
    try {
      _themeMode = mode;
      return true;
    } catch (e, stackTrace) {
      log('Error saving theme mode: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }
}
