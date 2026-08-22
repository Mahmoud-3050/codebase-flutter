/// The package reads/writes `'light'` or `'dark'`.
///
/// Host implements this (SharedPreferences, Hive, …) and passes it to
/// [Themes.init]. Missing key must return `null`, never throw.
abstract interface class ThemeStorage {
  Future<String?> getThemeMode();

  Future<void> saveThemeMode(String mode);
}

/// Null-object [ThemeStorage]: values do not survive process death.
class InMemoryThemeStorage implements ThemeStorage {
  String? _themeMode;

  @override
  Future<String?> getThemeMode() async => _themeMode;

  @override
  Future<void> saveThemeMode(String mode) async {
    _themeMode = mode;
  }
}
