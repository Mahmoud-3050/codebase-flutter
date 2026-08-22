import 'dart:convert';

import '../../features/models/names.dart';
import '../../utils/exceptions.dart';
import '../../utils/names_helper.dart';

const String stringsClassImport = "import 'package:language/language.dart';";

/// File stem (`ar`, `ar_EG`) — same grammar as `language.yaml` JSON names.
final RegExp langFileNamePattern = RegExp(r'^[a-z]{2,3}(_[A-Z]{2})?\.json$');
final RegExp localeCodePattern = RegExp(r'^[a-z]{2,3}(_[A-Z]{2})?$');
final RegExp placeholderPattern = RegExp(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}');

enum StringsGenerateMode { append, delete }

class ResolvedLangKey {
  const ResolvedLangKey({
    required this.jsonKey,
    required this.lookupKey,
    required this.original,
  });

  /// Key written to locale JSON (`status` or `status_`).
  final String jsonKey;

  /// snake_case without a trailing `_` — same key add-mode uses for "already exists".
  final String lookupKey;

  /// Outer `lang.json` key, used as English fallback when no `en` / `en_*` is given.
  final String original;
}

/// `ar.json` → `ar`, `ar_EG.json` → `ar_EG`. Invalid names return `null`.
String? langStemFromFileName(String fileName) {
  final String base = fileName.trim().replaceAll('\\', '/').split('/').last;
  if (!langFileNamePattern.hasMatch(base)) {
    return null;
  }
  return base.substring(0, base.length - 5);
}

/// Valid locale stems from file names (`en.json`, `assets/lang/ar_EG.json`).
List<String> langStemsFromFileNames(Iterable<String> fileNames) {
  final List<String> stems = <String>[];
  for (final String name in fileNames) {
    final String? stem = langStemFromFileName(name);
    if (stem != null) {
      stems.add(stem);
    }
  }
  return stems;
}

/// Locale used to generate `Strings` getters: `en`, else first `en_*`, else first stem.
String? stringsSourceStem(Iterable<String> stems) {
  final List<String> list = stems.toList();
  if (list.contains('en')) {
    return 'en';
  }
  for (final String stem in list) {
    if (stem.startsWith('en_')) {
      return stem;
    }
  }
  return list.isEmpty ? null : list.first;
}

String languageCodeFromStem(String stem) {
  final int underscore = stem.indexOf('_');
  return underscore == -1 ? stem : stem.substring(0, underscore);
}

/// Parses a `lang.json` value object: `{ "en": "...", "ar_EG": "..." }`.
Map<String, String> localeValuesFrom(Object? value) {
  if (value is! Map) {
    throw const FormatException(
      'lang.json values must be objects mapping locale codes to strings',
    );
  }
  final Map<String, String> result = <String, String>{};
  value.forEach((dynamic rawKey, dynamic rawValue) {
    final String code = rawKey.toString().trim();
    if (!localeCodePattern.hasMatch(code) || rawValue == null) {
      return;
    }
    result[code] = rawValue.toString();
  });
  return result;
}

/// Unique `{identifier}` names in first-seen order.
List<String> extractPlaceholders(String template) {
  final List<String> names = <String>[];
  final Set<String> seen = <String>{};
  for (final Match match in placeholderPattern.allMatches(template)) {
    final String name = match.group(1)!;
    if (seen.add(name)) {
      names.add(name);
    }
  }
  return names;
}

/// Placeholder names from the English template (`en`, else first `en_*`, else
/// first locale value).
List<String> placeholdersForEntry(Map<String, String> locales) {
  if (locales.containsKey('en')) {
    return extractPlaceholders(locales['en']!);
  }
  for (final MapEntry<String, String> entry in locales.entries) {
    if (entry.key.startsWith('en_')) {
      return extractPlaceholders(entry.value);
    }
  }
  if (locales.isEmpty) {
    return <String>[];
  }
  return extractPlaceholders(locales.values.first);
}

/// Resolves a `lang.json` key to JSON file stems. Returns `null` for Dart
/// keywords and names that cannot be converted.
ResolvedLangKey? resolveLangJsonKey(String rawKey) {
  final String usingKey = rawKey.trim();
  if (usingKey.isEmpty || NamesHelper.dartKeywords.contains(usingKey)) {
    return null;
  }
  try {
    final Names keyNames = usingKey.endsWith('_')
        ? Names.fromString(usingKey.substring(0, usingKey.length - 1))
        : Names.fromString(usingKey);
    return ResolvedLangKey(
      jsonKey: '${keyNames.snakeCase}${usingKey.endsWith('_') ? '_' : ''}',
      lookupKey: keyNames.snakeCase,
      original: keyNames.original,
    );
  } on NamesException {
    return null;
  }
}

/// Picks the string to write for a locale file stem (`en`, `ar_EG`, …).
///
/// Order: exact locale → language-only (`en` / `ar`) → first same-language
/// entry in the object → outer key text.
String translationForLang({
  required ResolvedLangKey key,
  required Object? value,
  required String lang,
}) {
  final Map<String, String> locales = localeValuesFrom(value);
  final String? exact = locales[lang];
  if (exact != null) {
    return exact;
  }
  final String languageCode = languageCodeFromStem(lang);
  final String? languageLevel = locales[languageCode];
  if (languageLevel != null) {
    return languageLevel;
  }
  for (final MapEntry<String, String> entry in locales.entries) {
    if (languageCodeFromStem(entry.key) == languageCode) {
      return entry.value;
    }
  }
  return key.original;
}

/// Applies [incoming] `lang.json` entries onto an existing lang JSON object.
///
/// Append mode adds missing keys. Delete mode removes matching keys.
/// [lang] is the target file stem (`en`, `ar`, `ar_EG`, …) and is ignored
/// in delete mode.
String applyLangJsonEntries({
  required String existingJson,
  required Map<String, dynamic> incoming,
  required String lang,
  StringsGenerateMode mode = StringsGenerateMode.append,
}) {
  if (mode == StringsGenerateMode.delete) {
    return _removeLangJsonEntries(
      existingJson: existingJson,
      incoming: incoming,
    );
  }
  return _appendLangJsonEntries(
    existingJson: existingJson,
    incoming: incoming,
    lang: lang,
  );
}

String _removeLangJsonEntries({
  required String existingJson,
  required Map<String, dynamic> incoming,
}) {
  final Map<String, dynamic> fileMap = _decodeLangObject(existingJson);
  for (final String rawKey in incoming.keys) {
    final ResolvedLangKey? resolved = resolveLangJsonKey(rawKey);
    if (resolved == null) continue;
    fileMap.remove(resolved.jsonKey);
    fileMap.remove(resolved.lookupKey);
  }
  return '${const JsonEncoder.withIndent('  ').convert(fileMap)}\n';
}

String _appendLangJsonEntries({
  required String existingJson,
  required Map<String, dynamic> incoming,
  required String lang,
}) {
  final StringBuffer buffer = StringBuffer();
  final String content = existingJson.trim();
  final Map<String, dynamic> fileMap = _decodeLangObject(content);
  final List<String> lines = content.split('\n');
  final List<String> linesWithoutLastCurlBrace =
      lines.sublist(0, lines.length - 1);
  buffer.writeAll(linesWithoutLastCurlBrace, '\n');
  String bufferStringTrim = buffer.toString().trim();
  if (fileMap.isNotEmpty) {
    bufferStringTrim = '$bufferStringTrim,';
  }
  buffer.clear();
  buffer.writeln(bufferStringTrim);
  int counter = 0;
  incoming.forEach((String key, dynamic value) {
    final ResolvedLangKey? resolved = resolveLangJsonKey(key);
    if (resolved != null && !fileMap.containsKey(resolved.lookupKey)) {
      final String translation = translationForLang(
        key: resolved,
        value: value,
        lang: lang,
      );
      buffer.write(
        '  ${json.encode(resolved.jsonKey)}: ${json.encode(translation)}',
      );
      if (counter < incoming.length - 1) {
        buffer.write(',');
      }
      buffer.writeln();
    }
    counter++;
  });
  final List<String> linesAfterWrite = buffer.toString().trim().split('\n');
  String lastLineOfLinesAfterWrite = linesAfterWrite.last.trimRight();
  if (lastLineOfLinesAfterWrite.isNotEmpty &&
      lastLineOfLinesAfterWrite[lastLineOfLinesAfterWrite.length - 1] == ',') {
    lastLineOfLinesAfterWrite = lastLineOfLinesAfterWrite.substring(
      0,
      lastLineOfLinesAfterWrite.length - 1,
    );
    linesAfterWrite[linesAfterWrite.length - 1] = lastLineOfLinesAfterWrite;
    buffer.clear();
    buffer.writeAll(linesAfterWrite, '\n');
  }
  buffer.writeln();
  buffer.writeln('}');
  return buffer.toString();
}

Map<String, dynamic> _decodeLangObject(String source) {
  final Object? decoded = json.decode(source.trim());
  if (decoded is! Map) {
    throw const FormatException('lang JSON must be a JSON object');
  }
  return Map<String, dynamic>.from(decoded);
}

/// Builds `lib/config/language/strings.dart` from a translation map
/// (typically the merged `en.json`).
String buildStringsClassSource(Map<String, dynamic> jsonMap) {
  final StringBuffer buffer = StringBuffer();
  buffer.writeln(stringsClassImport);
  buffer.writeln();
  buffer.writeln('abstract class Strings {');
  jsonMap.forEach((String key, dynamic value) {
    try {
      String keyStr = key;
      if (key.endsWith('_')) {
        keyStr = key.replaceAll('_', '');
      }
      final Names keyNames = Names.fromString(keyStr);
      final String suffix = key.endsWith('_') ? '_' : '';
      final String trKey = '${keyNames.original}$suffix';
      final String dartName = '${keyNames.camelCase}$suffix';
      final List<({String placeholder, String dartName})> params =
          _namedStringParams(extractPlaceholders(value?.toString() ?? ''));
      if (params.isEmpty) {
        buffer.writeln("  static String get $dartName => '$trKey'.tr;");
      } else {
        final String signature =
            params.map((p) => 'required String ${p.dartName}').join(', ');
        final String mapEntries =
            params.map((p) => "'${p.placeholder}': ${p.dartName}").join(', ');
        buffer.writeln(
          "  static String $dartName({$signature}) => '$trKey'.trParams({$mapEntries});",
        );
      }
      buffer.writeln();
    } on NamesException {
      // Invalid identifier — skip.
    }
  });
  buffer.writeln('}');
  return buffer.toString();
}

List<({String placeholder, String dartName})> _namedStringParams(
  List<String> placeholders,
) {
  final List<({String placeholder, String dartName})> params =
      <({String placeholder, String dartName})>[];
  for (final String placeholder in placeholders) {
    try {
      final Names names = Names.fromString(placeholder);
      if (!NamesHelper.isValidDartVariableName(names.camelCase)) {
        continue;
      }
      params.add((placeholder: placeholder, dartName: names.camelCase));
    } on NamesException {
      continue;
    }
  }
  return params;
}
