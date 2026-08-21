import 'package:flutter/material.dart';

import '../../domain/language.dart';
import '../../domain/language_model.dart';

typedef LanguageWidgetBuilder = Widget Function(
  BuildContext context,
  LanguageModel language,
  Locale locale,
);

/// Rebuilds when [Language.instance] notifies after a language change.
class LanguageBuilder extends StatelessWidget {
  final LanguageWidgetBuilder builder;

  const LanguageBuilder({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Language.instance,
      builder: (context, _) {
        final language = Language.instance;
        return builder(
          context,
          language.current,
          language.currentLocale,
        );
      },
    );
  }
}
