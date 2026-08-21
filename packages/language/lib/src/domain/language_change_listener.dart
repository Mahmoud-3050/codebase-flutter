import 'language_model.dart';

/// Host-side hook for locale side effects (headers, SDK locales, …).
abstract interface class LanguageChangeListener {
  void onLanguageChanged(LanguageModel language);
}
