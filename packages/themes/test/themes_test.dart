import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);
const _yellowLight = Color(0xFFECC826);
const _yellowDark = Color(0xFFD4B020);
const _primaryOverride = Color(0xFF123456);

ThemeColors _swatch(Color color, {Map<String, Color> extra = const {}}) {
  return ThemeColors(
    white: color,
    black: color,
    background: color,
    foreground: color,
    primary: color,
    onPrimary: color,
    secondary: color,
    onSecondary: color,
    textPrimary: color,
    textSecondary: color,
    unselected: color,
    divider: color,
    hint: color,
    border: color,
    error: color,
    success: color,
    extra: extra,
  );
}

class FakeThemeStorage implements ThemeStorage {
  String? themeMode;
  int saveCount = 0;

  @override
  Future<String?> getThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(String mode) async {
    saveCount++;
    themeMode = mode;
  }
}

class RecordingThemeChangeListener implements ThemeChangeListener {
  final List<ThemeMode> calls = [];

  @override
  void onThemeChanged(ThemeMode mode) {
    calls.add(mode);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final light = _swatch(_white, extra: {'yellow': _yellowLight});
  final dark = _swatch(_black, extra: {'yellow': _yellowDark});

  ThemeConfig config({ThemeMode defaultMode = .light}) {
    return ThemeConfig(light: light, dark: dark, defaultMode: defaultMode);
  }

  setUp(resetThemes);
  tearDown(resetThemes);

  group('ThemeConfig', () {
    test('defaultMode is light when omitted', () {
      final themeConfig = ThemeConfig(light: light, dark: dark);
      expect(themeConfig.defaultMode, ThemeMode.light);
      expect(() => themeConfig.validate(), returnsNormally);
    });

    test('validate accepts light and dark', () {
      expect(() => config().validate(), returnsNormally);
      expect(() => config(defaultMode: .dark).validate(), returnsNormally);
    });

    test('rejects ThemeMode.system as defaultMode', () {
      expect(
        () => ThemeConfig(
          light: light,
          dark: dark,
          defaultMode: .system,
        ).validate(),
        throwsA(isA<InvalidThemeConfigException>()),
      );
    });
  });

  group('Themes singleton', () {
    test('factory returns the same instance', () {
      expect(Themes(), same(Themes.instance));
    });

    test('is uninitialized before init', () {
      expect(Themes.instance.isInitialized, isFalse);
      expect(Themes.instance.mode, ThemeMode.light);
      expect(Themes.instance.config, isNull);
    });
  });

  group('Themes.init', () {
    test('accessors and changeTheme throw before init', () {
      expect(
        () => Themes.instance.colors,
        throwsA(isA<ThemeNotInitializedException>()),
      );
      expect(
        () => Themes.instance.lightColors,
        throwsA(isA<ThemeNotInitializedException>()),
      );
      expect(
        () => Themes.instance.darkColors,
        throwsA(isA<ThemeNotInitializedException>()),
      );
      expect(
        () => Themes.instance.lightTheme,
        throwsA(isA<ThemeNotInitializedException>()),
      );
      expect(
        () => Themes.instance.darkTheme,
        throwsA(isA<ThemeNotInitializedException>()),
      );
      expect(
        () => Themes.instance.changeTheme(.dark),
        throwsA(isA<ThemeNotInitializedException>()),
      );
    });

    test('system defaultMode throws and does not initialize', () async {
      expect(
        () => Themes.instance.init(
          config: ThemeConfig(light: light, dark: dark, defaultMode: .system),
        ),
        throwsA(isA<InvalidThemeConfigException>()),
      );
      expect(Themes.instance.isInitialized, isFalse);
    });

    test('uses defaultMode when storage is empty', () async {
      await Themes.instance.init(config: config(defaultMode: .dark));
      expect(Themes.instance.isInitialized, isTrue);
      expect(Themes.instance.mode, ThemeMode.dark);
      expect(Themes.instance.defaultMode, ThemeMode.dark);
      expect(Themes.instance.isDark, isTrue);
      expect(Themes.instance.isLight, isFalse);
      expect(Themes.instance.colors.primary, dark.primary);
    });

    test('uses defaultMode when stored value is null', () async {
      await Themes.instance.init(
        config: config(defaultMode: .light),
        storage: FakeThemeStorage(),
      );
      expect(Themes.instance.mode, ThemeMode.light);
      expect(Themes.instance.isLight, isTrue);
    });

    test('restores stored light', () async {
      final storage = FakeThemeStorage()..themeMode = 'light';
      await Themes.instance.init(
        config: config(defaultMode: .dark),
        storage: storage,
      );
      expect(Themes.instance.mode, ThemeMode.light);
    });

    test('restores stored dark', () async {
      final storage = FakeThemeStorage()..themeMode = 'dark';
      await Themes.instance.init(config: config(), storage: storage);
      expect(Themes.instance.mode, ThemeMode.dark);
    });

    test('invalid stored values fall back to defaultMode', () async {
      for (final stored in ['system', 'LIGHT', 'Dark', '', '  ', 'foo']) {
        resetThemes();
        final storage = FakeThemeStorage()..themeMode = stored;
        await Themes.instance.init(
          config: config(defaultMode: .dark),
          storage: storage,
        );
        expect(Themes.instance.mode, ThemeMode.dark, reason: 'stored: $stored');
      }
    });

    test('notifies listener at end of init', () async {
      final listener = RecordingThemeChangeListener();
      await Themes.instance.init(config: config(), listener: listener);
      expect(listener.calls, [ThemeMode.light]);
    });

    test('omits listener without throwing', () async {
      await Themes.instance.init(config: config());
      expect(Themes.instance.isInitialized, isTrue);
    });

    test('omitted storage uses InMemoryThemeStorage', () async {
      await Themes.instance.init(config: config());
      await Themes.instance.changeTheme(.dark);
      expect(Themes.instance.mode, ThemeMode.dark);
    });
  });

  group('Themes.changeTheme', () {
    test('persists, notifies, and switches palette', () async {
      final storage = FakeThemeStorage();
      final listener = RecordingThemeChangeListener();
      await Themes.instance.init(
        config: config(),
        storage: storage,
        listener: listener,
      );

      await Themes.instance.changeTheme(.dark);

      expect(Themes.instance.mode, ThemeMode.dark);
      expect(storage.themeMode, 'dark');
      expect(storage.saveCount, 1);
      expect(listener.calls, [ThemeMode.light, ThemeMode.dark]);
      expect(Themes.instance.colors.primary, dark.primary);
      expect(Themes.instance.isDark, isTrue);
    });

    test('can switch back to light', () async {
      final storage = FakeThemeStorage()..themeMode = 'dark';
      await Themes.instance.init(config: config(), storage: storage);

      await Themes.instance.changeTheme(.light);

      expect(Themes.instance.mode, ThemeMode.light);
      expect(storage.themeMode, 'light');
      expect(Themes.instance.colors.primary, light.primary);
    });

    test('no-op when mode is unchanged', () async {
      final storage = FakeThemeStorage();
      final listener = RecordingThemeChangeListener();
      await Themes.instance.init(
        config: config(),
        storage: storage,
        listener: listener,
      );

      await Themes.instance.changeTheme(.light);

      expect(storage.themeMode, isNull);
      expect(storage.saveCount, 0);
      expect(listener.calls, [ThemeMode.light]);
    });

    test('rejects ThemeMode.system and keeps current mode', () async {
      await Themes.instance.init(config: config());
      expect(
        () => Themes.instance.changeTheme(.system),
        throwsA(
          isA<UnsupportedThemeException>().having(
            (e) => e.themeMode,
            'themeMode',
            'system',
          ),
        ),
      );
      expect(Themes.instance.mode, ThemeMode.light);
    });
  });

  group('Themes palettes', () {
    test('lightColors and darkColors ignore current mode', () async {
      await Themes.instance.init(config: config());
      await Themes.instance.changeTheme(.dark);

      expect(Themes.instance.lightColors.primary, light.primary);
      expect(Themes.instance.darkColors.primary, dark.primary);
      expect(Themes.instance.colors.primary, dark.primary);
    });

    test('lightTheme and darkTheme attach the matching extension', () async {
      await Themes.instance.init(config: config());

      expect(
        Themes.instance.lightTheme.extension<ThemeColors>()?.primary,
        light.primary,
      );
      expect(Themes.instance.lightTheme.brightness, Brightness.light);
      expect(
        Themes.instance.darkTheme.extension<ThemeColors>()?.primary,
        dark.primary,
      );
      expect(Themes.instance.darkTheme.brightness, Brightness.dark);
    });
  });

  group('ThemeColors', () {
    test('extra returns per-palette values', () async {
      await Themes.instance.init(config: config());
      expect(Themes.instance.colors.extra('yellow'), _yellowLight);

      await Themes.instance.changeTheme(.dark);
      expect(Themes.instance.colors.extra('yellow'), _yellowDark);
    });

    test('missing extra throws with the key', () async {
      await Themes.instance.init(config: config());
      expect(
        () => Themes.instance.colors.extra('missing'),
        throwsA(
          isA<MissingThemeExtraException>().having(
            (e) => e.key,
            'key',
            'missing',
          ),
        ),
      );
    });

    test('extras is unmodifiable', () {
      expect(() => light.extras['yellow'] = _black, throwsUnsupportedError);
    });

    test('copyWith overrides only provided fields', () {
      final next = light.copyWith(primary: _primaryOverride);
      expect(next.primary, _primaryOverride);
      expect(next.background, light.background);
      expect(next.success, light.success);
      expect(next.extra('yellow'), _yellowLight);
    });

    test('copyWith replaces extra map', () {
      final next = light.copyWith(extra: {'accent': _primaryOverride});
      expect(next.extra('accent'), _primaryOverride);
      expect(
        () => next.extra('yellow'),
        throwsA(isA<MissingThemeExtraException>()),
      );
    });

    test('lerp with null returns this', () {
      expect(light.lerp(null, 0.5), same(light));
    });

    test('lerp t=0 keeps the start palette', () {
      final lerped = light.lerp(dark, 0);
      expect(lerped.primary, light.primary);
    });

    test('lerp t=1 reaches the end palette', () {
      final lerped = light.lerp(dark, 1);
      expect(lerped.primary, dark.primary);
      expect(lerped.extra('yellow'), _yellowDark);
    });

    test('lerp t=0.5 mixes typed colors', () {
      final lerped = light.lerp(dark, 0.5);
      expect(lerped.primary, Color.lerp(_white, _black, 0.5));
    });

    test('lerp extras unions keys from both palettes', () {
      final a = _swatch(_white, extra: {'onlyA': _white, 'both': _white});
      final b = _swatch(_black, extra: {'onlyB': _black, 'both': _black});
      final lerped = a.lerp(b, 1);
      expect(lerped.extra('onlyA'), _white);
      expect(lerped.extra('onlyB'), _black);
      expect(lerped.extra('both'), _black);
    });
  });

  group('ThemeData factory', () {
    test('maps tokens onto ThemeData and ColorScheme', () {
      final theme = Themes.buildThemeData(light, .light);
      expect(theme.extension<ThemeColors>(), light);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, light.background);
      expect(theme.primaryColor, light.primary);
      expect(theme.colorScheme.primary, light.primary);
      expect(theme.colorScheme.onPrimary, light.onPrimary);
      expect(theme.colorScheme.secondary, light.secondary);
      expect(theme.colorScheme.onSecondary, light.onSecondary);
      expect(theme.colorScheme.error, light.error);
      expect(theme.colorScheme.surface, light.foreground);
      expect(theme.colorScheme.onSurface, light.textPrimary);
      expect(theme.appBarTheme.backgroundColor, light.background);
      expect(theme.bottomNavigationBarTheme.selectedItemColor, light.primary);
    });

    test('dark brightness uses dark tokens', () {
      final theme = Themes.buildThemeData(dark, .dark);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, dark.background);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });
  });

  group('InMemoryThemeStorage', () {
    test('returns null then persists a mode', () async {
      final storage = InMemoryThemeStorage();
      expect(await storage.getThemeMode(), isNull);
      await storage.saveThemeMode('dark');
      expect(await storage.getThemeMode(), 'dark');
    });
  });

  group('exceptions', () {
    test('toString includes useful detail', () {
      expect(
        const InvalidThemeConfigException('bad').toString(),
        contains('bad'),
      );
      expect(
        const UnsupportedThemeException('system').toString(),
        contains('system'),
      );
      expect(const ThemeNotInitializedException().toString(), contains('init'));
      expect(
        const MissingThemeExtraException('yellow').toString(),
        contains('yellow'),
      );
    });
  });

  group('ThemeBuilder', () {
    testWidgets('rebuilds when theme changes', (tester) async {
      await Themes.instance.init(config: config());
      var builds = 0;

      await tester.pumpWidget(
        ThemeBuilder(
          builder: (context, themes) {
            builds++;
            return Directionality(
              textDirection: .ltr,
              child: Text(themes.mode.name),
            );
          },
        ),
      );
      expect(find.text('light'), findsOneWidget);
      expect(builds, 1);

      await Themes.instance.changeTheme(.dark);
      await tester.pump();
      expect(find.text('dark'), findsOneWidget);
      expect(builds, 2);
    });

    testWidgets('does not rebuild on no-op changeTheme', (tester) async {
      await Themes.instance.init(config: config());
      var builds = 0;

      await tester.pumpWidget(
        ThemeBuilder(
          builder: (context, themes) {
            builds++;
            return const SizedBox();
          },
        ),
      );
      expect(builds, 1);

      await Themes.instance.changeTheme(.light);
      await tester.pump();
      expect(builds, 1);
    });
  });

  group('ThemesContext', () {
    testWidgets('reads ThemeExtension when present', (tester) async {
      await Themes.instance.init(config: config());

      await tester.pumpWidget(
        ThemeBuilder(
          builder: (context, themes) {
            return MaterialApp(
              theme: themes.lightTheme,
              darkTheme: themes.darkTheme,
              themeMode: themes.mode,
              home: Builder(
                builder: (context) {
                  return Text(
                    '${context.isLightTheme}|${context.currentThemeMode.name}',
                  );
                },
              ),
            );
          },
        ),
      );
      expect(find.text('true|light'), findsOneWidget);

      await Themes.instance.changeTheme(.dark);
      await tester.pump();
      expect(find.text('false|dark'), findsOneWidget);
    });

    testWidgets('falls back to singleton when Theme has no extension', (
      tester,
    ) async {
      await Themes.instance.init(config: config());

      late ThemeColors fromContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(),
          home: Builder(
            builder: (context) {
              fromContext = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(fromContext.primary, Themes.instance.colors.primary);
    });
  });

  group('resetThemes', () {
    test('returns uninitialized state without dispose', () async {
      await Themes.instance.init(config: config());
      await Themes.instance.changeTheme(.dark);
      resetThemes();

      expect(Themes.instance.isInitialized, isFalse);
      expect(Themes.instance.config, isNull);
      expect(Themes.instance.mode, ThemeMode.light);
      expect(
        () => Themes.instance.colors,
        throwsA(isA<ThemeNotInitializedException>()),
      );
    });

    test('allows init again after reset', () async {
      await Themes.instance.init(config: config());
      resetThemes();
      await Themes.instance.init(config: config(defaultMode: .dark));
      expect(Themes.instance.mode, ThemeMode.dark);
      await Themes.instance.changeTheme(.light);
      expect(Themes.instance.mode, ThemeMode.light);
    });
  });
}
