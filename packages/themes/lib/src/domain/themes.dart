import 'package:flutter/material.dart';

import '../presentation/theme_colors.dart';
import '../presentation/theme_data_factory.dart';
import 'theme_change_listener.dart';
import 'theme_config.dart';
import 'theme_exceptions.dart';
import 'theme_storage.dart';

/// Process-wide theme orchestrator (singleton + [ChangeNotifier]).
final class Themes extends ChangeNotifier {
  Themes._();

  static final Themes instance = Themes._();

  factory Themes() => instance;

  bool _initialized = false;
  ThemeMode _mode = ThemeMode.light;
  ThemeMode _defaultMode = ThemeMode.light;
  ThemeConfig? _config;
  ThemeStorage _storage = InMemoryThemeStorage();
  ThemeChangeListener? _listener;

  bool get isInitialized => _initialized;
  ThemeMode get mode => _mode;
  ThemeMode get defaultMode => _defaultMode;
  ThemeConfig? get config => _config;
  bool get isLight => _mode == ThemeMode.light;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeColors get colors {
    _assertInitialized();
    return _mode == ThemeMode.dark ? _config!.dark : _config!.light;
  }

  ThemeColors get lightColors {
    _assertInitialized();
    return _config!.light;
  }

  ThemeColors get darkColors {
    _assertInitialized();
    return _config!.dark;
  }

  ThemeData get lightTheme {
    _assertInitialized();
    return ThemeDataFactory.build(_config!.light, Brightness.light);
  }

  ThemeData get darkTheme {
    _assertInitialized();
    return ThemeDataFactory.build(_config!.dark, Brightness.dark);
  }

  /// Must run after [WidgetsFlutterBinding.ensureInitialized] and before `runApp`.
  Future<void> init({
    required ThemeConfig config,
    ThemeStorage? storage,
    ThemeChangeListener? listener,
  }) async {
    config.validate();
    _config = config;
    _defaultMode = config.defaultMode;
    _storage = storage ?? InMemoryThemeStorage();
    _listener = listener;

    final savedMode = await _storage.getThemeMode();
    _mode = _modeFromStored(savedMode);
    _initialized = true;
    _listener?.onThemeChanged(_mode);
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode mode) async {
    _assertInitialized();
    if (mode == ThemeMode.system) {
      throw const UnsupportedThemeException('system');
    }
    if (mode == _mode) return;

    _mode = mode;
    await _storage.saveThemeMode(mode.name);
    notifyListeners();
    _listener?.onThemeChanged(mode);
  }

  /// Color-complete [ThemeData]. Hosts `copyWith` fonts and ScreenUtil sizes.
  static ThemeData buildThemeData(ThemeColors colors, Brightness brightness) {
    return ThemeDataFactory.build(colors, brightness);
  }

  ThemeMode _modeFromStored(String? value) {
    if (value == ThemeMode.light.name) return ThemeMode.light;
    if (value == ThemeMode.dark.name) return ThemeMode.dark;
    return _defaultMode;
  }

  /// Restores uninitialized defaults. Does not [dispose] this singleton.
  void _reset() {
    _initialized = false;
    _mode = ThemeMode.light;
    _defaultMode = ThemeMode.light;
    _config = null;
    _storage = InMemoryThemeStorage();
    _listener = null;
  }

  void _assertInitialized() {
    if (!_initialized) throw const ThemeNotInitializedException();
  }
}

/// Test-only. Host apps must not call this — import `package:themes/testing.dart`.
@visibleForTesting
void resetThemes() => Themes.instance._reset();
