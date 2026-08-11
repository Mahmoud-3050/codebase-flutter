import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_language_model.dart';
import '../language_cubit.dart';

typedef LanguageWidgetBuilder = Widget Function(
  BuildContext context,
  AppLanguageModel language,
  Locale locale,
);

typedef LanguageStateListener = void Function(
  BuildContext context,
  LanguageState state,
);

/// A widget that subscribes to [LanguageCubit] state changes
/// and rebuilds its child (and triggers optional listener) when language changes.
class LanguageBuilder extends StatelessWidget {
  final LanguageWidgetBuilder builder;
  final LanguageStateListener? listener;

  const LanguageBuilder({
    required this.builder,
    this.listener,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (listener != null) {
      return BlocConsumer<LanguageCubit, LanguageState>(
        listener: listener!,
        builder: (context, state) {
          return builder(
            context,
            state.language,
            state.language.locale,
          );
        },
      );
    }

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return builder(
          context,
          state.language,
          state.language.locale,
        );
      },
    );
  }
}
