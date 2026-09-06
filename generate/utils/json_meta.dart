/// JSON metadata keys used by the feature generator.
///
/// Sibling keys next to a sample field:
/// - `class_name$<field>` — exact Dart class name for a nested object or list item
/// - `type$<field>` — Dart type override (e.g. `DateTime`, `String`)
abstract class JsonMeta {
  static const String classNamePrefix = 'class_name\$';
  static const String typePrefix = 'type\$';

  static bool isMetaKey(String key) =>
      key.startsWith(classNamePrefix) || key.startsWith(typePrefix);

  static Map<String, String> classNameOverrides(Map<String, dynamic> map) {
    final Map<String, String> overrides = <String, String>{};
    for (final MapEntry<String, dynamic> entry in map.entries) {
      if (!entry.key.startsWith(classNamePrefix)) {
        continue;
      }
      final String field = entry.key.substring(classNamePrefix.length);
      final String value = entry.value.toString().trim();
      if (field.isNotEmpty && value.isNotEmpty) {
        overrides[field] = value;
      }
    }
    return overrides;
  }

  static Map<String, String> typeOverrides(Map<String, dynamic> map) {
    final Map<String, String> overrides = <String, String>{};
    for (final MapEntry<String, dynamic> entry in map.entries) {
      if (!entry.key.startsWith(typePrefix)) {
        continue;
      }
      final String field = entry.key.substring(typePrefix.length);
      final String value = entry.value.toString().trim();
      if (field.isNotEmpty && value.isNotEmpty) {
        overrides[field] = value;
      }
    }
    return overrides;
  }

  static Map<String, dynamic> strip(Map<String, dynamic> map) {
    return Map<String, dynamic>.fromEntries(
      map.entries.where((MapEntry<String, dynamic> e) => !isMetaKey(e.key)),
    );
  }

  static Map<String, dynamic> asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic val) => MapEntry(key.toString(), val),
      );
    }
    return <String, dynamic>{};
  }
}
