import 'package:language/language.dart';
import 'package:field_validator/field_validator.dart';

import '../../api/dio_consumer.dart';

/// Syncs host services when [Language] changes the active locale.
class LanguageChangeAdapter implements LanguageChangeListener {
  const LanguageChangeAdapter({required this.dioConsumer});

  final DioConsumer dioConsumer;

  @override
  void onLanguageChanged(LanguageModel language) {
    FieldValidator.instance.setLocale(
      ValidatorLocale.fromCode(language.code),
    );
    dioConsumer.updateLanguageCodeHeader();
  }
}
