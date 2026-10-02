import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../../../core/utils/values/text_styles.dart';

/// Shared width for auth entry and form columns on large windows.
abstract final class AuthLayout {
  static const double maxContentWidth = 480;

  /// Body copy leading, within the 1.4–1.6 range.
  static const double bodyLineHeight = 1.5;
}

/// Auth screen chrome. Colors and the title scale come from the theme
/// tokens and [TextStyles], then the body is centered up to
/// [AuthLayout.maxContentWidth].
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.title, required this.body, super.key});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyles.of(size: 18, weight: FontWeight.w600),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AuthLayout.maxContentWidth,
                minHeight: constraints.maxHeight,
              ),
              child: body,
            ),
          );
        },
      ),
    );
  }
}
