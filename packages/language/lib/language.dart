import 'package:flutter/widgets.dart';

import 'src/domain/language.dart';
import 'src/domain/language_model.dart';

export 'src/domain/language.dart' show Language;
export 'src/domain/language_model.dart';
export 'src/domain/language_change_listener.dart';
export 'src/domain/language_exceptions.dart';
export 'src/domain/language_storage.dart';
export 'src/presentation/language_localizations.dart';
export 'src/presentation/language_localizations_setup.dart';
export 'src/presentation/widgets/language_builder.dart';

/// Convenience accessors for the current [Language] singleton.
extension LanguageContextExtension on BuildContext {
  LanguageModel get currentLanguage => Language.instance.current;
  Locale get currentLocale => Language.instance.currentLocale;
  String get currentLanguageCode => Language.instance.currentCode;
  bool get isArabic => Language.instance.isArabic;
  bool get isEnglish => Language.instance.isEnglish;
}
