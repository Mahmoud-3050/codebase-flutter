import '../../features/models/names.dart';
import '../../utils/exceptions.dart';
import '../../utils/names_helper.dart';
import 'color_helper.dart';

enum PaletteKind { light, dark }

/// One validated colors.json entry after camelCase + hex normalize.
class ColorEntry {
  const ColorEntry({
    required this.camelCase,
    required this.lightHex,
    required this.darkHex,
  });

  final String camelCase;
  final String lightHex;
  final String darkHex;

  bool get isShared => lightHex == darkHex;
}

/// Result of applying a colors.json map onto palette / ExtraColors sources.
class ColorApplyResult {
  const ColorApplyResult({
    required this.palettes,
    required this.extras,
    required this.applied,
  });

  final String palettes;
  final String extras;
  final int applied;
}

final RegExp _sharedExtraMap = RegExp(
  r'(static const Map<String, Color> _sharedExtra = \{)([\s\S]*?)(\n  \};)',
);

/// Validates key → camelCase identifier and value → AARRGGBB hex.
///
/// Value is one hex (both modes) or `"light;dark"`.
/// Returns null when the entry should be skipped.
ColorEntry? parseColorEntry(String rawKey, dynamic rawValue) {
  if (rawValue is! String) return null;

  late final Names names;
  try {
    names = Names.fromString(rawKey.trim());
  } on NamesException {
    return null;
  }

  if (!NamesHelper.isValidDartVariableName(names.camelCase)) {
    return null;
  }

  final List<String> parts =
      rawValue.split(';').map((String part) => part.trim()).toList();
  if (parts.length != 1 && parts.length != 2) return null;
  if (parts.any((String part) => part.isEmpty)) return null;

  try {
    final String lightHex = ColorHelper.normalizeHex(parts[0]);
    final String darkHex = ColorHelper.normalizeHex(
      parts.length == 2 ? parts[1] : parts[0],
    );
    return ColorEntry(
      camelCase: names.camelCase,
      lightHex: lightHex,
      darkHex: darkHex,
    );
  } on ColorException {
    return null;
  }
}

bool hasTypedField(String source, String camelCase) {
  return RegExp(
    '^\\s+$camelCase: Color\\(0x[0-9A-Fa-f]+\\),',
    multiLine: true,
  ).hasMatch(source);
}

bool hasExtraKey(String source, String camelCase) {
  return RegExp(
    "'$camelCase': Color\\(0x[0-9A-Fa-f]+\\),",
  ).hasMatch(source);
}

bool hasSharedExtraKey(String source, String camelCase) {
  final Match? match = _sharedExtraMap.firstMatch(source);
  if (match == null) return false;
  return RegExp(
    "'$camelCase': Color\\(0x[0-9A-Fa-f]+\\),",
  ).hasMatch(match[2]!);
}

String replaceTypedField(String source, String camelCase, String hex) {
  return source.replaceAllMapped(
    RegExp(
      '^(\\s+)$camelCase: Color\\(0x[0-9A-Fa-f]+\\),',
      multiLine: true,
    ),
    (Match match) => '${match[1]}$camelCase: Color(0x$hex),',
  );
}

String replaceTypedFieldInPalette(
  String source,
  String camelCase,
  String hex,
  PaletteKind kind,
) {
  return _rewritePaletteBlock(source, kind, (String block) {
    return replaceTypedField(block, camelCase, hex);
  });
}

String replaceExtraKey(String source, String camelCase, String hex) {
  return source.replaceAllMapped(
    RegExp("'$camelCase': Color\\(0x[0-9A-Fa-f]+\\),"),
    (Match match) => "'$camelCase': Color(0x$hex),",
  );
}

/// Creates `_sharedExtra` (and `..._sharedExtra` spreads) when missing.
String ensureSharedExtraMap(String source) {
  if (!_sharedExtraMap.hasMatch(source)) {
    final int lightAt = source.indexOf(
      'static const ThemeColors _light = ThemeColors(',
    );
    if (lightAt == -1) {
      throw const ColorException(
        '_light palette not found; cannot create _sharedExtra',
      );
    }
    const String map = '''
  static const Map<String, Color> _sharedExtra = {
  };

''';
    source = source.replaceRange(lightAt, lightAt, map);
  }
  source = _ensureSharedExtraSpread(source, PaletteKind.light);
  source = _ensureSharedExtraSpread(source, PaletteKind.dark);
  return source;
}

String addSharedExtra(String source, String camelCase, String hex) {
  source = ensureSharedExtraMap(source);
  final Match? match = _sharedExtraMap.firstMatch(source);
  if (match == null) {
    throw const ColorException('_sharedExtra map not found in palettes file');
  }

  var body = match[2]!.trimRight();
  if (body.isNotEmpty && !body.endsWith(',')) {
    body = '$body,';
  }
  body = "$body\n    '$camelCase': Color(0x$hex),";
  return source.replaceRange(
    match.start,
    match.end,
    '${match[1]}$body${match[3]}',
  );
}

String removeSharedExtra(String source, String camelCase) {
  final Match? match = _sharedExtraMap.firstMatch(source);
  if (match == null) {
    throw const ColorException('_sharedExtra map not found in palettes file');
  }

  final String body = match[2]!.replaceFirst(
    RegExp("\\n\\s*'$camelCase': Color\\(0x[0-9A-Fa-f]+\\),?"),
    '',
  );
  return source.replaceRange(
    match.start,
    match.end,
    '${match[1]}$body${match[3]}',
  );
}

String removePaletteExtra(
  String source,
  String camelCase,
  PaletteKind kind,
) {
  return _rewritePaletteBlock(source, kind, (String block) {
    final _ExtraMapRange? extra = _extraMapRange(block);
    if (extra == null) return block;
    final String body = extra.body.replaceFirst(
      RegExp("\\n\\s*'$camelCase': Color\\(0x[0-9A-Fa-f]+\\),?"),
      '',
    );
    return extra.replaceBody(block, body);
  });
}

String upsertPaletteExtra(
  String source,
  String camelCase,
  String hex,
  PaletteKind kind,
) {
  return _rewritePaletteBlock(source, kind, (String block) {
    final _ExtraMapRange? extra = _extraMapRange(block);
    if (extra == null) {
      return _insertExtraMap(block, "\n      '$camelCase': Color(0x$hex),");
    }

    var body = extra.body;
    final RegExp key = RegExp("'$camelCase': Color\\(0x[0-9A-Fa-f]+\\),");
    if (key.hasMatch(body)) {
      body = body.replaceAllMapped(
        key,
        (Match match) => "'$camelCase': Color(0x$hex),",
      );
    } else {
      body = body.trimRight();
      if (body.isNotEmpty && !body.endsWith(',')) {
        body = '$body,';
      }
      body = "$body\n      '$camelCase': Color(0x$hex),";
    }
    return extra.replaceBody(block, body);
  });
}

String ensureExtraGetter(String source, String camelCase) {
  if (RegExp('Color get $camelCase =>').hasMatch(source)) {
    return source;
  }

  final String getter = "  Color get $camelCase => extra('$camelCase');\n";
  final Match? gradient = RegExp(
    r'^(\s*)LinearGradient get primaryGradient',
    multiLine: true,
  ).firstMatch(source);
  if (gradient != null) {
    return source.replaceRange(
      gradient.start,
      gradient.end,
      '$getter\n${gradient[1]}LinearGradient get primaryGradient',
    );
  }

  final int closeAt = source.lastIndexOf('}');
  if (closeAt == -1) {
    throw const ColorException('ExtraColors extension not found');
  }
  return '${source.substring(0, closeAt)}$getter${source.substring(closeAt)}';
}

/// Updates typed fields, extra map values, or inserts new extras.
ColorApplyResult applyColors({
  required String palettes,
  required String extras,
  required Map<String, dynamic> json,
}) {
  var nextPalettes = palettes;
  var nextExtras = extras;
  var applied = 0;

  for (final MapEntry<String, dynamic> entry in json.entries) {
    final ColorEntry? color = parseColorEntry(entry.key, entry.value);
    if (color == null) continue;

    if (hasTypedField(nextPalettes, color.camelCase)) {
      nextPalettes = replaceTypedFieldInPalette(
        nextPalettes,
        color.camelCase,
        color.lightHex,
        PaletteKind.light,
      );
      nextPalettes = replaceTypedFieldInPalette(
        nextPalettes,
        color.camelCase,
        color.darkHex,
        PaletteKind.dark,
      );
    } else if (color.isShared) {
      if (hasExtraKey(nextPalettes, color.camelCase) &&
          !hasSharedExtraKey(nextPalettes, color.camelCase)) {
        nextPalettes = removePaletteExtra(
          nextPalettes,
          color.camelCase,
          PaletteKind.light,
        );
        nextPalettes = removePaletteExtra(
          nextPalettes,
          color.camelCase,
          PaletteKind.dark,
        );
      }
      if (hasSharedExtraKey(nextPalettes, color.camelCase)) {
        nextPalettes = replaceExtraKey(
          nextPalettes,
          color.camelCase,
          color.lightHex,
        );
      } else {
        nextPalettes = addSharedExtra(
          nextPalettes,
          color.camelCase,
          color.lightHex,
        );
      }
      nextExtras = ensureExtraGetter(nextExtras, color.camelCase);
    } else {
      if (hasSharedExtraKey(nextPalettes, color.camelCase)) {
        nextPalettes = removeSharedExtra(nextPalettes, color.camelCase);
      }
      nextPalettes = upsertPaletteExtra(
        nextPalettes,
        color.camelCase,
        color.lightHex,
        PaletteKind.light,
      );
      nextPalettes = upsertPaletteExtra(
        nextPalettes,
        color.camelCase,
        color.darkHex,
        PaletteKind.dark,
      );
      nextExtras = ensureExtraGetter(nextExtras, color.camelCase);
    }
    applied++;
  }

  return ColorApplyResult(
    palettes: nextPalettes,
    extras: nextExtras,
    applied: applied,
  );
}

String _rewritePaletteBlock(
  String source,
  PaletteKind kind,
  String Function(String block) rewrite,
) {
  final String marker = kind == PaletteKind.light
      ? 'static const ThemeColors _light = ThemeColors('
      : 'static const ThemeColors _dark = ThemeColors(';
  final int start = source.indexOf(marker);
  if (start == -1) {
    throw ColorException('_${kind.name} palette not found');
  }

  final int openParen = start + marker.length - 1;
  final int end = _findDelimiterBlockEnd(source, openParen, '(', ')');
  if (end == -1) {
    throw ColorException('_${kind.name} palette is not closed');
  }

  final String updated = rewrite(source.substring(start, end));
  return source.replaceRange(start, end, updated);
}

int _findDelimiterBlockEnd(
  String source,
  int openIndex,
  String open,
  String close,
) {
  var depth = 1;
  for (var i = openIndex + 1; i < source.length; i++) {
    final String char = source[i];
    if (char == open) depth++;
    if (char == close) depth--;
    if (depth == 0) return i + 1;
  }
  return -1;
}

class _ExtraMapRange {
  const _ExtraMapRange({
    required this.bodyStart,
    required this.bodyEnd,
    required this.body,
  });

  final int bodyStart;
  final int bodyEnd;
  final String body;

  String replaceBody(String block, String nextBody) {
    return block.replaceRange(bodyStart, bodyEnd, nextBody);
  }
}

_ExtraMapRange? _extraMapRange(String block) {
  final Match? extra = RegExp(r'extra:\s*\{').firstMatch(block);
  if (extra == null) return null;
  final int openBrace = extra.end - 1;
  final int closeEnd = _findDelimiterBlockEnd(block, openBrace, '{', '}');
  if (closeEnd == -1) {
    throw const ColorException('extra map is not closed');
  }
  return _ExtraMapRange(
    bodyStart: openBrace + 1,
    bodyEnd: closeEnd - 1,
    body: block.substring(openBrace + 1, closeEnd - 1),
  );
}

String _insertExtraMap(String block, String extraBody) {
  final int close = block.length - 1;
  var before = block.substring(0, close).trimRight();
  if (!before.endsWith(',')) {
    before = '$before,';
  }
  return '$before\n    extra: {$extraBody\n    },\n  )';
}

String _ensureSharedExtraSpread(String source, PaletteKind kind) {
  final String marker = kind == PaletteKind.light
      ? 'static const ThemeColors _light = ThemeColors('
      : 'static const ThemeColors _dark = ThemeColors(';
  if (!source.contains(marker)) return source;
  return _rewritePaletteBlock(source, kind, (String block) {
    final _ExtraMapRange? extra = _extraMapRange(block);
    if (extra == null) {
      return _insertExtraMap(block, '\n      ..._sharedExtra,');
    }
    if (extra.body.contains('..._sharedExtra')) {
      return block;
    }
    return extra.replaceBody(block, '\n      ..._sharedExtra,${extra.body}');
  });
}
