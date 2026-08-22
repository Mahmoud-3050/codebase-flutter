import 'package:flutter/material.dart';

import '../../domain/themes.dart';

typedef ThemeWidgetBuilder = Widget Function(
  BuildContext context,
  Themes themes,
);

/// Rebuilds when [Themes.instance] notifies after a theme change.
class ThemeBuilder extends StatelessWidget {
  final ThemeWidgetBuilder builder;

  const ThemeBuilder({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Themes.instance,
      builder: (context, _) => builder(context, Themes.instance),
    );
  }
}
