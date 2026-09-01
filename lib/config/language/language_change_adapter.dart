import 'package:language/language.dart';
import 'package:field_validator/field_validator.dart';

/// Syncs host services when [Language] changes the active locale.
///
/// HTTP `Accept-Language` is applied per request in `ApiInterceptors`
/// from [Language.instance.currentCode], so Dio headers are not mutated here.
class LanguageChangeAdapter implements LanguageChangeListener {
  const LanguageChangeAdapter();

  @override
  void onLanguageChanged(LanguageModel language) {
    FieldValidator.instance.setLocale(
      ValidatorLocale.fromCode(language.code),
    );
  }
}
