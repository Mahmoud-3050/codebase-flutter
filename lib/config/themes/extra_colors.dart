import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

/// Current palette. Widgets that lack a [BuildContext] (e.g. [TextStyles])
/// use this; prefer `context.colors` in the tree.
ThemeColors get colors => Themes.instance.colors;

/// Host extras and gradients. Light/dark values live on the two palettes.
extension ExtraColors on ThemeColors {
  Color get grey100 => extra('grey100');
  Color get grey200 => extra('grey200');
  Color get grey300 => extra('grey300');
  Color get grey400 => extra('grey400');
  Color get grey500 => extra('grey500');
  Color get grey600 => extra('grey600');
  Color get grey700 => extra('grey700');
  Color get yellow => extra('yellow');
  Color get orange => extra('orange');
  Color get green => extra('green');
  Color get red => extra('red');
  Color get greyBackground => extra('greyBackground');
  Color get greyForeground => extra('greyForeground');
  Color get progressBarBackground => extra('progressBarBackground');
  Color get baseColorShimmer => extra('baseColorShimmer');
  Color get highlightColorShimmer => extra('highlightColorShimmer');

  LinearGradient get primaryGradient => LinearGradient(
        colors: [secondary, primary],
        begin: AlignmentDirectional.topCenter,
        end: AlignmentDirectional.bottomCenter,
        stops: const [0.0, 1.0],
      );
}
