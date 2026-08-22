/// Thrown when [Themes.init] is given a [ThemeConfig] that cannot be used.
class InvalidThemeConfigException implements Exception {
  final String message;

  const InvalidThemeConfigException(this.message);

  @override
  String toString() => 'InvalidThemeConfigException: $message';
}

/// Thrown when [Themes.changeTheme] is given a mode the package does not support.
class UnsupportedThemeException implements Exception {
  final String themeMode;

  const UnsupportedThemeException(this.themeMode);

  @override
  String toString() =>
      'UnsupportedThemeException: "$themeMode" is not supported. Use ThemeMode.light or ThemeMode.dark.';
}

/// Thrown when theme state is accessed before [Themes.init] has run.
class ThemeNotInitializedException implements Exception {
  const ThemeNotInitializedException();

  @override
  String toString() =>
      'ThemeNotInitializedException: call Themes.instance.init() before runApp().';
}

/// Thrown when [ThemeColors.extra] is asked for a key that is not on the palette.
class MissingThemeExtraException implements Exception {
  final String key;

  const MissingThemeExtraException(this.key);

  @override
  String toString() =>
      'MissingThemeExtraException: extra color "$key" is not on this palette.';
}
