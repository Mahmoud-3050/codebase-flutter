import 'package:flutter_test/flutter_test.dart';

import '../../utils/exceptions.dart';
import '../../utils/names_helper.dart';
import '../src/color_helper.dart';
import '../src/colors_generator.dart';

const String _palettesFixture = '''
abstract final class ColorsPalettes {
  static const Map<String, Color> _sharedExtra = {
    'yellow': Color(0xFFECC826),
  };

  static const ThemeColors _light = ThemeColors(
    primary: Color(0xFF5F17ED),
    success: Color(0xFF00B507),
    extra: {
      ..._sharedExtra,
      'greyBackground': Color(0xFFEAEBED),
    },
  );

  static const ThemeColors _dark = ThemeColors(
    primary: Color(0xFF111111),
    success: Color(0xFF00B507),
    extra: {
      ..._sharedExtra,
      'greyBackground': Color(0xFF13151C),
    },
  );

  static const ThemeConfig config = ThemeConfig(
    defaultMode: ThemeMode.dark,
    light: _light,
    dark: _dark,
  );
}
''';

const String _extrasFixture = '''
extension ExtraColors on ThemeColors {
  Color get yellow => extra('yellow');
  Color get greyBackground => extra('greyBackground');

  LinearGradient get primaryGradient => LinearGradient(
        colors: [secondary, primary],
      );
}
''';

void main() {
  group('ColorHelper.normalizeHex', () {
    test('strips # from 6-digit hex and prepends FF', () {
      expect(ColorHelper.normalizeHex('#5F17ED'), 'FF5F17ED');
    });

    test('accepts 6-digit hex without #', () {
      expect(ColorHelper.normalizeHex('00B507'), 'FF00B507');
    });

    test('expands 3-digit #RGB', () {
      expect(ColorHelper.normalizeHex('#F0A'), 'FFFF00AA');
    });

    test('keeps 8-digit AARRGGBB', () {
      expect(ColorHelper.normalizeHex('#26738277'), '26738277');
    });

    test('strips 0x / 0X prefix', () {
      expect(ColorHelper.normalizeHex('0xFF5F17ED'), 'FF5F17ED');
      expect(ColorHelper.normalizeHex('0Xff00aa'), 'FFFF00AA');
    });

    test('uppercases hex digits', () {
      expect(ColorHelper.normalizeHex('#ecc826'), 'FFECC826');
    });

    test('trims whitespace', () {
      expect(ColorHelper.normalizeHex('  #5F17ED  '), 'FF5F17ED');
    });

    test('throws on empty value', () {
      expect(
        () => ColorHelper.normalizeHex(''),
        throwsA(isA<ColorException>()),
      );
      expect(
        () => ColorHelper.normalizeHex('   '),
        throwsA(isA<ColorException>()),
      );
    });

    test('throws on non-hex characters', () {
      expect(
        () => ColorHelper.normalizeHex('not-a-color'),
        throwsA(isA<ColorException>()),
      );
      expect(
        () => ColorHelper.normalizeHex('#GG0000'),
        throwsA(isA<ColorException>()),
      );
    });

    test('throws on unsupported length', () {
      expect(
        () => ColorHelper.normalizeHex('#FFFF'),
        throwsA(isA<ColorException>()),
      );
      expect(
        () => ColorHelper.normalizeHex('#12345'),
        throwsA(isA<ColorException>()),
      );
      expect(
        () => ColorHelper.normalizeHex('#123456789'),
        throwsA(isA<ColorException>()),
      );
    });
  });

  group('ColorHelper.isValidHex', () {
    test('returns true for supported formats', () {
      expect(ColorHelper.isValidHex('#F00'), isTrue);
      expect(ColorHelper.isValidHex('#5F17ED'), isTrue);
      expect(ColorHelper.isValidHex('0xFF5F17ED'), isTrue);
    });

    test('returns false for invalid values', () {
      expect(ColorHelper.isValidHex(''), isFalse);
      expect(ColorHelper.isValidHex('red'), isFalse);
      expect(ColorHelper.isValidHex('#12'), isFalse);
    });
  });

  group('ColorException', () {
    test('toString includes the message', () {
      expect(
        const ColorException('bad hex').toString(),
        contains('bad hex'),
      );
    });
  });

  group('NamesHelper.isValidDartVariableName', () {
    test('accepts camelCase identifiers', () {
      expect(NamesHelper.isValidDartVariableName('primary'), isTrue);
      expect(NamesHelper.isValidDartVariableName('onPrimary'), isTrue);
      expect(NamesHelper.isValidDartVariableName('brandAccent'), isTrue);
      expect(NamesHelper.isValidDartVariableName('grey100'), isTrue);
    });

    test('rejects reserved words, empty, and illegal starts', () {
      expect(NamesHelper.isValidDartVariableName('class'), isFalse);
      expect(NamesHelper.isValidDartVariableName('void'), isFalse);
      expect(NamesHelper.isValidDartVariableName(''), isFalse);
      expect(NamesHelper.isValidDartVariableName('123abc'), isFalse);
      expect(NamesHelper.isValidDartVariableName('Primary'), isFalse);
    });
  });

  group('parseColorEntry', () {
    test('converts snake_case key to camelCase and normalizes hex', () {
      final ColorEntry? entry = parseColorEntry('brand_accent', '#FF00AA');
      expect(entry, isNotNull);
      expect(entry!.camelCase, 'brandAccent');
      expect(entry.lightHex, 'FFFF00AA');
      expect(entry.darkHex, 'FFFF00AA');
      expect(entry.isShared, isTrue);
    });

    test('parses light;dark pair on the same key', () {
      final ColorEntry? entry = parseColorEntry(
        'testColor',
        '#5F17ED;#5F17FF',
      );
      expect(entry, isNotNull);
      expect(entry!.camelCase, 'testColor');
      expect(entry.lightHex, 'FF5F17ED');
      expect(entry.darkHex, 'FF5F17FF');
      expect(entry.isShared, isFalse);
    });

    test('trims whitespace around the light;dark separator', () {
      final ColorEntry? entry = parseColorEntry(
        'testColor',
        '#5F17ED ; #5F17FF',
      );
      expect(entry?.lightHex, 'FF5F17ED');
      expect(entry?.darkHex, 'FF5F17FF');
    });

    test('returns null for empty sides or more than two hexes', () {
      expect(parseColorEntry('testColor', '#5F17ED;'), isNull);
      expect(parseColorEntry('testColor', ';#5F17FF'), isNull);
      expect(parseColorEntry('testColor', '#5F17ED;#5F17FF;#000000'), isNull);
    });

    test('converts dashed and class-case keys', () {
      expect(parseColorEntry('grey-100', '#F1F1F1')?.camelCase, 'grey100');
      expect(parseColorEntry('OnPrimary', '#FFFFFF')?.camelCase, 'onPrimary');
    });

    test('keeps already-camelCase keys', () {
      expect(parseColorEntry('primary', '5F17ED')?.camelCase, 'primary');
    });

    test('returns null when one side of the pair is invalid hex', () {
      expect(parseColorEntry('testColor', '#5F17ED;#GG0000'), isNull);
      expect(parseColorEntry('testColor', 'zzzzzz;#5F17FF'), isNull);
    });

    test('returns null for reserved-word keys', () {
      expect(parseColorEntry('class', '#000000'), isNull);
    });

    test('returns null for keys that are not variable names', () {
      expect(parseColorEntry('123invalid', '#FFFFFF'), isNull);
      expect(parseColorEntry('', '#FFFFFF'), isNull);
      expect(parseColorEntry('   ', '#FFFFFF'), isNull);
    });

    test('returns null when value is not a string', () {
      expect(parseColorEntry('primary', 123), isNull);
      expect(parseColorEntry('primary', true), isNull);
      expect(parseColorEntry('primary', null), isNull);
    });

    test('returns null for invalid hex', () {
      expect(parseColorEntry('primary', 'not-a-color'), isNull);
      expect(parseColorEntry('primary', '#GG0000'), isNull);
    });
  });

  group('hasTypedField / hasExtraKey', () {
    test('detects typed ThemeColors fields', () {
      expect(hasTypedField(_palettesFixture, 'primary'), isTrue);
      expect(hasTypedField(_palettesFixture, 'success'), isTrue);
      expect(hasTypedField(_palettesFixture, 'yellow'), isFalse);
    });

    test('detects quoted extra map keys', () {
      expect(hasExtraKey(_palettesFixture, 'yellow'), isTrue);
      expect(hasExtraKey(_palettesFixture, 'greyBackground'), isTrue);
      expect(hasExtraKey(_palettesFixture, 'primary'), isFalse);
    });

    test('distinguishes shared extras from per-palette extras', () {
      expect(hasSharedExtraKey(_palettesFixture, 'yellow'), isTrue);
      expect(hasSharedExtraKey(_palettesFixture, 'greyBackground'), isFalse);
    });
  });

  group('replaceTypedField', () {
    test('updates every matching typed field (light and dark)', () {
      final String next =
          replaceTypedField(_palettesFixture, 'primary', 'FF6A20FF');
      expect('primary: Color(0xFF6A20FF),'.allMatches(next).length, 2);
      expect(next.contains('primary: Color(0xFF5F17ED)'), isFalse);
      expect(next.contains('primary: Color(0xFF111111)'), isFalse);
      expect(next.contains('success: Color(0xFF00B507)'), isTrue);
    });
  });

  group('replaceExtraKey', () {
    test('updates shared extra keys', () {
      final String next =
          replaceExtraKey(_palettesFixture, 'yellow', 'FFD4B020');
      expect(next.contains("'yellow': Color(0xFFD4B020),"), isTrue);
      expect(next.contains("'yellow': Color(0xFFECC826),"), isFalse);
    });

    test('updates per-palette extra keys independently', () {
      final String next =
          replaceExtraKey(_palettesFixture, 'greyBackground', 'FFFFFFFF');
      expect("'greyBackground': Color(0xFFFFFFFF),".allMatches(next).length, 2);
    });
  });

  group('addSharedExtra', () {
    test('appends a new extra to _sharedExtra', () {
      final String next =
          addSharedExtra(_palettesFixture, 'brandAccent', 'FFFF00AA');
      expect(next.contains("'brandAccent': Color(0xFFFF00AA),"), isTrue);
      expect(next.contains("'yellow': Color(0xFFECC826),"), isTrue);
    });

    test('adds a trailing comma when the last extra has none', () {
      const String noComma = '''
abstract final class ColorsPalettes {
  static const Map<String, Color> _sharedExtra = {
    'yellow': Color(0xFFECC826)
  };
}
''';
      final String next = addSharedExtra(noComma, 'brandAccent', 'FFFF00AA');
      expect(next.contains("'yellow': Color(0xFFECC826),"), isTrue);
      expect(next.contains("'brandAccent': Color(0xFFFF00AA),"), isTrue);
    });

    test('throws when _light palette is missing', () {
      expect(
        () => addSharedExtra('class Empty {}', 'brandAccent', 'FFFF00AA'),
        throwsA(isA<ColorException>()),
      );
    });

    test('creates _sharedExtra when the map is missing', () {
      const String noShared = '''
abstract final class ColorsPalettes {
  static const ThemeColors _light = ThemeColors(
    primary: Color(0xFF5F17ED),
    extra: {
      'greyBackground': Color(0xFFEAEBED),
    },
  );

  static const ThemeColors _dark = ThemeColors(
    primary: Color(0xFF111111),
    extra: {
      'greyBackground': Color(0xFF13151C),
    },
  );
}
''';
      final String next = addSharedExtra(noShared, 'testColor', 'FF5F17ED');
      expect(hasSharedExtraKey(next, 'testColor'), isTrue);
      expect(next.contains('..._sharedExtra'), isTrue);
      expect(
        next.contains("'testColor': Color(0xFF5F17ED),"),
        isTrue,
      );
    });
  });

  group('ensureExtraGetter', () {
    test('inserts a getter before primaryGradient', () {
      final String next = ensureExtraGetter(_extrasFixture, 'brandAccent');
      expect(
        next.contains("Color get brandAccent => extra('brandAccent');"),
        isTrue,
      );
      expect(
        next.contains('LinearGradient get primaryGradient'),
        isTrue,
      );
      expect(
        next.indexOf('brandAccent'),
        lessThan(next.indexOf('primaryGradient')),
      );
    });

    test('does not duplicate an existing getter', () {
      final String next = ensureExtraGetter(_extrasFixture, 'yellow');
      expect('Color get yellow =>'.allMatches(next).length, 1);
    });

    test('inserts before the last brace when there is no gradient', () {
      const String noGradient = '''
extension ExtraColors on ThemeColors {
  Color get yellow => extra('yellow');
}
''';
      final String next = ensureExtraGetter(noGradient, 'brandAccent');
      expect(
        next.contains("Color get brandAccent => extra('brandAccent');"),
        isTrue,
      );
      expect(next.trim().endsWith('}'), isTrue);
    });

    test('throws when the extra file has no closing brace', () {
      expect(
        () => ensureExtraGetter('extension ExtraColors on ThemeColors', 'x'),
        throwsA(isA<ColorException>()),
      );
    });
  });

  group('applyColors', () {
    test('updates an existing typed field in both palettes', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'primary': '#6A20FF'},
      );
      expect(result.applied, 1);
      expect(
        'primary: Color(0xFF6A20FF),'.allMatches(result.palettes).length,
        2,
      );
      expect(result.extras, _extrasFixture);
    });

    test('updates an existing extra value', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'yellow': '#D4B020'},
      );
      expect(result.applied, 1);
      expect(
        result.palettes.contains("'yellow': Color(0xFFD4B020),"),
        isTrue,
      );
      expect('Color get yellow =>'.allMatches(result.extras).length, 1);
    });

    test('adds a new extra key and ExtraColors getter', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'brand_accent': '#FF00AA'},
      );
      expect(result.applied, 1);
      expect(
        result.palettes.contains("'brandAccent': Color(0xFFFF00AA),"),
        isTrue,
      );
      expect(
        result.extras
            .contains("Color get brandAccent => extra('brandAccent');"),
        isTrue,
      );
    });

    test('applies mixed valid entries and skips invalid ones', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{
          'primary': '#6A20FF',
          'class': '#000000',
          '123invalid': '#FFFFFF',
          'badValue': 'not-a-color',
          'brand_accent': '#FF00AA',
          'count': 12,
        },
      );
      expect(result.applied, 2);
      expect(result.palettes.contains('primary: Color(0xFF6A20FF),'), isTrue);
      expect(
        result.palettes.contains("'brandAccent': Color(0xFFFF00AA),"),
        isTrue,
      );
      expect(hasTypedField(result.palettes, 'class'), isFalse);
    });

    test('returns originals when json is empty', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{},
      );
      expect(result.applied, 0);
      expect(result.palettes, _palettesFixture);
      expect(result.extras, _extrasFixture);
    });

    test('prefers typed field over extra when the name matches a typed token',
        () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'success': '#00D60A'},
      );
      expect(result.palettes.contains('success: Color(0xFF00D60A),'), isTrue);
      expect(
        result.extras.contains("Color get success => extra('success');"),
        isFalse,
      );
    });

    test('sets typed light and dark from a semicolon pair', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'primary': '#6A20FF;#00AA11'},
      );
      expect(result.applied, 1);
      final String light = _paletteSlice(result.palettes, '_light', '_dark');
      final String dark = _paletteSlice(result.palettes, '_dark', null);
      expect(light.contains('primary: Color(0xFF6A20FF),'), isTrue);
      expect(dark.contains('primary: Color(0xFF00AA11),'), isTrue);
      expect(light.contains('primary: Color(0xFF00AA11)'), isFalse);
      expect(dark.contains('primary: Color(0xFF6A20FF)'), isFalse);
    });

    test('moves a shared extra into per-palette extras for a pair', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'yellow': '#ECC826;#D4B020'},
      );
      expect(result.applied, 1);
      expect(hasSharedExtraKey(result.palettes, 'yellow'), isFalse);
      expect(
        result.palettes.contains("'yellow': Color(0xFFECC826),"),
        isTrue,
      );
      expect(
        result.palettes.contains("'yellow': Color(0xFFD4B020),"),
        isTrue,
      );
      expect('Color get yellow =>'.allMatches(result.extras).length, 1);
    });

    test('updates an existing per-palette extra with a light;dark pair', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'greyBackground': '#EAEBED;#13151C'},
      );
      expect(result.applied, 1);
      expect(
        result.palettes.contains("'greyBackground': Color(0xFFEAEBED),"),
        isTrue,
      );
      expect(
        result.palettes.contains("'greyBackground': Color(0xFF13151C),"),
        isTrue,
      );
    });

    test('adds a single hex to _sharedExtra', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'testColor': '#5F17ED'},
      );
      expect(result.applied, 1);
      expect(hasSharedExtraKey(result.palettes, 'testColor'), isTrue);
      final String light = _paletteSlice(result.palettes, '_light', '_dark');
      final String dark = _paletteSlice(result.palettes, '_dark', null);
      expect(light.contains("'testColor': Color(0xFF5F17ED),"), isFalse);
      expect(dark.contains("'testColor': Color(0xFF5F17ED),"), isFalse);
      expect(
        result.extras.contains("Color get testColor => extra('testColor');"),
        isTrue,
      );
    });

    test('adds a light;dark pair to per-palette extras, not _sharedExtra', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'testColor': '#5F17ED;#5F17FF'},
      );
      expect(result.applied, 1);
      expect(hasSharedExtraKey(result.palettes, 'testColor'), isFalse);
      final String light = _paletteSlice(result.palettes, '_light', '_dark');
      final String dark = _paletteSlice(result.palettes, '_dark', null);
      expect(light.contains("'testColor': Color(0xFF5F17ED),"), isTrue);
      expect(dark.contains("'testColor': Color(0xFF5F17FF),"), isTrue);
      expect(
        result.extras.contains("Color get testColor => extra('testColor');"),
        isTrue,
      );
    });

    test('preserves ThemeConfig around palette edits', () {
      final ColorApplyResult result = applyColors(
        palettes: _palettesFixture,
        extras: _extrasFixture,
        json: <String, dynamic>{'testColor': '#5F17ED;#5F17FF'},
      );
      expect(
        result.palettes.contains('defaultMode: ThemeMode.dark,'),
        isTrue,
      );
    });

    test('creates _sharedExtra when missing and json has a single hex', () {
      const String noShared = '''
abstract final class ColorsPalettes {
  static const ThemeColors _light = ThemeColors(
    primary: Color(0xFF5F17ED),
    extra: {
      'greyBackground': Color(0xFFEAEBED),
    },
  );

  static const ThemeColors _dark = ThemeColors(
    primary: Color(0xFF111111),
    extra: {
      'greyBackground': Color(0xFF13151C),
    },
  );
}
''';
      final ColorApplyResult result = applyColors(
        palettes: noShared,
        extras: _extrasFixture,
        json: <String, dynamic>{'testColor': '#5F17ED'},
      );
      expect(result.applied, 1);
      expect(
        result.palettes
            .contains('static const Map<String, Color> _sharedExtra'),
        isTrue,
      );
      expect(hasSharedExtraKey(result.palettes, 'testColor'), isTrue);
      expect(
        '..._sharedExtra,'.allMatches(result.palettes).length,
        2,
      );
      expect(
        result.extras.contains("Color get testColor => extra('testColor');"),
        isTrue,
      );
    });

    test('moves a per-palette extra into _sharedExtra for a single hex', () {
      const String splitExtra = '''
abstract final class ColorsPalettes {
  static const Map<String, Color> _sharedExtra = {
    'yellow': Color(0xFFECC826),
  };

  static const ThemeColors _light = ThemeColors(
    primary: Color(0xFF5F17ED),
    extra: {
      ..._sharedExtra,
      'testColor': Color(0xFF5F17ED),
    },
  );

  static const ThemeColors _dark = ThemeColors(
    primary: Color(0xFF111111),
    extra: {
      ..._sharedExtra,
      'testColor': Color(0xFF5F17FF),
    },
  );
}
''';
      final ColorApplyResult result = applyColors(
        palettes: splitExtra,
        extras: _extrasFixture,
        json: <String, dynamic>{'testColor': '#5F17ED'},
      );
      expect(hasSharedExtraKey(result.palettes, 'testColor'), isTrue);
      final String light = _paletteSlice(result.palettes, '_light', '_dark');
      final String dark = _paletteSlice(result.palettes, '_dark', null);
      expect(light.contains("'testColor': Color(0xFF5F17ED),"), isFalse);
      expect(dark.contains("'testColor': Color(0xFF5F17FF),"), isFalse);
    });
  });
}

String _paletteSlice(String source, String startMarker, String? endMarker) {
  final int start = source.indexOf(startMarker);
  final int end =
      endMarker == null ? source.length : source.indexOf(endMarker, start + 1);
  return source.substring(start, end);
}
