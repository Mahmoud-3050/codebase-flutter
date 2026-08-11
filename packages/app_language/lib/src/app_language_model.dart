import 'package:flutter/material.dart';

/// Immutable data model representing a single language instance.
class AppLanguageModel {
  final String code;
  final String? countryCode;
  final String nativeName;

  const AppLanguageModel({
    required this.code,
    required this.nativeName,
    this.countryCode,
  });

  /// Standard Flutter [Locale] representation.
  Locale get locale => Locale(code, countryCode);

  /// Full code string representation (e.g. 'ar' or 'ar_EG').
  String get fullCode =>
      (countryCode != null && countryCode!.isNotEmpty) ? '${code}_$countryCode' : code;

  /// Returns true if language code belongs to Arabic language family.
  bool get isArabic => code.toLowerCase().startsWith('ar');

  /// Returns true if language code belongs to English language family.
  bool get isEnglish => code.toLowerCase().startsWith('en');

  // Well-known language model instances
  static const en = AppLanguageModel(code: 'en', nativeName: 'English');
  static const ar = AppLanguageModel(code: 'ar', nativeName: 'العربية');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguageModel &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          countryCode == other.countryCode;

  @override
  int get hashCode => code.hashCode ^ countryCode.hashCode;

  @override
  String toString() => 'AppLanguageModel($fullCode, nativeName: $nativeName)';
}
