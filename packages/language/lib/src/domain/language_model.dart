import 'dart:ui' show Locale;

/// Immutable value object for a single language.
class LanguageModel {
  final String code;
  final String? countryCode;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.nativeName,
    this.countryCode,
  });

  Locale get locale => Locale(code, countryCode);

  String get fullCode => hasCountry ? '${code}_$countryCode' : code;

  bool get hasCountry => countryCode != null && countryCode!.isNotEmpty;

  bool get isArabic => code.toLowerCase().startsWith('ar');

  bool get isEnglish => code.toLowerCase().startsWith('en');

  /// Exact file-name stem match (`ar.json` → `ar`, `ar_EG.json` → `ar_EG`).
  /// Used for persisted storage values. Returns `null` when the string is not
  /// a declared file stem.
  static LanguageModel? byStoredCode(
    List<LanguageModel> languages,
    String? code,
  ) {
    if (languages.isEmpty) return null;
    if (code == null || code.trim().isEmpty) return null;

    final normalized = code.trim();
    for (final language in languages) {
      if (language.fullCode == normalized) return language;
    }
    return null;
  }

  /// Resolves a YAML / UI code against [languages].
  ///
  /// Order: exact `fullCode` (`ar_EG`), then language-only (`ar.json`),
  /// then the first country variant of that language. Returns `null` when
  /// no language code matches.
  static LanguageModel? lookup(
    List<LanguageModel> languages,
    String? code,
  ) {
    if (languages.isEmpty) return null;
    if (code == null || code.trim().isEmpty) return null;

    final normalized = code.trim();
    final languageCode = normalized.split('_').first;

    for (final language in languages) {
      if (language.fullCode == normalized) return language;
    }

    for (final language in languages) {
      if (language.code == languageCode && !language.hasCountry) {
        return language;
      }
    }

    for (final language in languages) {
      if (language.code == languageCode) return language;
    }

    return null;
  }

  static const en = LanguageModel(code: 'en', nativeName: 'English');
  static const ar = LanguageModel(code: 'ar', nativeName: 'العربية');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          countryCode == other.countryCode;

  @override
  int get hashCode => code.hashCode ^ countryCode.hashCode;

  @override
  String toString() => 'LanguageModel($fullCode, nativeName: $nativeName)';
}
