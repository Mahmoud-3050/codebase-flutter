# themes

Host how-to. Package design lives in `RULES.md`.

Flutter SDK only — no Bloc, GetIt, YAML, or prefs. You pass Dart palettes,
storage, and optional side effects. Modes are `ThemeMode.light` / `dark`
only (`system` is rejected).

Import `package:themes/themes.dart`.

| API | Use |
|---|---|
| `Themes.instance` | `init`, `changeTheme`, `mode`, `colors` |
| `ThemeColors` | typed tokens + `extra` |
| `ThemeConfig` | light + dark palettes, `defaultMode` |
| `ThemeStorage` | persist `'light'` / `'dark'` |
| `ThemeChangeListener` | host side effects (optional) |
| `ThemeBuilder` | rebuild `MaterialApp` |
| `Themes.buildThemeData` | color `ThemeData`; host `copyWith` fonts / `.sp` |
| `context.colors` | current palette |

Tests: `package:themes/testing.dart` (`resetThemes`). Do not `dispose()` the singleton.

---

## Setup

### 1. Dependency

```yaml
dependencies:
  themes:
    path: ./packages/themes
```

### 2. Palettes (host Dart)

Put hex in the host. Typed defaults: `white`, `black`, `background`,
`foreground`, `primary`, `onPrimary`, `secondary`, `onSecondary`,
`textPrimary`, `textSecondary`, `unselected`, `divider`, `hint`, `border`,
`error`, `success`. Anything else → `extra` + `ExtraColors`.

```dart
abstract final class ColorsPalettes {
  static const light = ThemeColors(
    primary: Color(0xFF5F17ED),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF00B507),
    // …other typed tokens
    extra: {
      'yellow': Color(0xFFECC826),
    },
  );

  static const dark = ThemeColors(
    primary: Color(0xFF5F17ED),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF00D60A),
    extra: {
      'yellow': Color(0xFFD4B020),
    },
  );

  static const config = ThemeConfig(
    defaultMode: ThemeMode.dark,
    light: light,
    dark: dark,
  );
}

extension ExtraColors on ThemeColors {
  Color get yellow => extra('yellow');
}
```

Same extra **key**, two values. Widgets use one getter: `context.colors.yellow`.

### 3. Persist mode (optional)

Store `'light'` or `'dark'`. Missing / invalid → `defaultMode`. First launch returns `null`, never throws. Omit `storage` to use in-memory (lost on process death).

```dart
class SharedPreferencesThemeStorage implements ThemeStorage {
  const SharedPreferencesThemeStorage(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'appTheme';

  @override
  Future<String?> getThemeMode() async => _prefs.getString(_key);

  @override
  Future<void> saveThemeMode(String mode) async =>
      _prefs.setString(_key, mode);
}
```

### 4. Side effects (optional)

Status bar, analytics — not in `main()` or widgets.

```dart
class ThemeChangeAdapter implements ThemeChangeListener {
  @override
  void onThemeChanged(ThemeMode mode) { /* … */ }
}
```

Runs at the end of `init`, and after a successful `changeTheme` (not no-ops).

### 5. `init` before `runApp`

```dart
await Themes.instance.init(
  config: ColorsPalettes.config,
  storage: SharedPreferencesThemeStorage(prefs),
  listener: ThemeChangeAdapter(), // optional
);
```

### 6. Wrap `MaterialApp`

Build fonts / ScreenUtil **inside** `ScreenUtilInit` (not in `init`).

```dart
ThemeBuilder(
  builder: (context, themes) {
    return MaterialApp.router(
      theme: hostTheme(themes.lightColors, Brightness.light),
      darkTheme: hostTheme(themes.darkColors, Brightness.dark),
      themeMode: themes.mode,
    );
  },
);

ThemeData hostTheme(ThemeColors colors, Brightness brightness) {
  final theme = Themes.buildThemeData(colors, brightness);
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: Fonts.poppins),
  );
}
```

---

## Use

```dart
context.colors.primary;
context.colors.success;      // typed default
context.colors.yellow;       // ExtraColors
context.isDarkTheme;

await Themes.instance.changeTheme(ThemeMode.dark);
```

| | |
|---|---|
| `Themes.instance.mode` / `.colors` | current mode / palette |
| `isDark` / `isLight` | from `mode` |
| `context.colors` | `ThemeExtension`, else singleton |

---

## `init` arguments

| | Default | |
|---|---|---|
| `config` | required | palettes + default mode |
| `storage` | in-memory | persist mode |
| `listener` | `null` | side effects |

## Exceptions

| | |
|---|---|
| `defaultMode` is `system` | `InvalidThemeConfigException` |
| `changeTheme` before `init` | `ThemeNotInitializedException` |
| `changeTheme(system)` | `UnsupportedThemeException` |
| missing `extra` key | `MissingThemeExtraException` |
