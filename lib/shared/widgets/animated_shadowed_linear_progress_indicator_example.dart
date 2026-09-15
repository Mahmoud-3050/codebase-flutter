import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/themes/colors_palettes.dart';
import 'animated_counter_text.dart';
import 'animated_shadowed_linear_progress_indicator.dart';

@Preview(
  name: '65% fill',
  group: 'AnimatedShadowedLinearProgressIndicator',
  size: Size(393, 96),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedShadowedProgress65Preview() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: AnimatedShadowedLinearProgressIndicator(targetValue: 0.65),
  );
}

@Preview(
  name: 'Reduced motion',
  group: 'AnimatedShadowedLinearProgressIndicator',
  size: Size(393, 96),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedShadowedProgressReducedMotionPreview() {
  return Builder(
    builder: (BuildContext context) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: AnimatedShadowedLinearProgressIndicator(targetValue: 0.65),
        ),
      );
    },
  );
}

@Preview(
  name: 'Interactive',
  group: 'AnimatedShadowedLinearProgressIndicator',
  size: Size(393, 720),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedShadowedProgressInteractivePreview() {
  return const AnimatedShadowedLinearProgressIndicatorExample();
}

@Preview(
  name: 'Count to 5',
  group: 'AnimatedCounterText',
  size: Size(393, 96),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedCounterTextCountTo5Preview() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: AnimatedCounterText(maxNumber: 5)),
  );
}

@Preview(
  name: 'Jump to 42',
  group: 'AnimatedCounterText',
  size: Size(393, 96),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedCounterTextJumpPreview() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: AnimatedCounterText(maxNumber: 42)),
  );
}

/// Previewer already provides [MaterialApp]. Do not nest another one, and do
/// not use [ScreenUtilInit] — it waits on [View] and stays empty in previews.
Widget wrapAnimatedShadowedProgressPreview(Widget child) {
  return Builder(
    builder: (BuildContext context) {
      final mediaQuery = MediaQuery.maybeOf(context);
      final size = mediaQuery?.size;
      ScreenUtil.configure(
        data: size == null || size == Size.zero
            ? const MediaQueryData(size: Size(393, 852))
            : mediaQuery,
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: false,
      );
      return child;
    },
  );
}

/// Minimal [ThemeData] so the previewer does not lerp [AppBarTheme] / button
/// styles (that interpolation throws `true is not a subtype of double?` on web).
PreviewThemeData animatedShadowedProgressPreviewTheme() {
  return PreviewThemeData(
    materialLight: _previewTheme(ColorsPalettes.config.light, .light),
    materialDark: _previewTheme(ColorsPalettes.config.dark, .dark),
  );
}

ThemeData _previewTheme(ThemeColors colors, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    extensions: <ThemeExtension<ThemeColors>>[colors],
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      error: colors.error,
      onError: colors.onPrimary,
      surface: colors.foreground,
      onSurface: colors.textPrimary,
    ),
    scaffoldBackgroundColor: colors.background,
  );
}

/// Interactive demo: static fills, then buttons that change [targetValue].
class AnimatedShadowedLinearProgressIndicatorExample extends StatefulWidget {
  const AnimatedShadowedLinearProgressIndicatorExample({super.key});

  @override
  State<AnimatedShadowedLinearProgressIndicatorExample> createState() =>
      _AnimatedShadowedLinearProgressIndicatorExampleState();
}

class _AnimatedShadowedLinearProgressIndicatorExampleState
    extends State<AnimatedShadowedLinearProgressIndicatorExample> {
  static const List<double> _presetTargets = [0, 0.25, 0.5, 0.75, 1];

  double _target = 0.65;
  int _replayToken = 0;

  void _setTarget(double value) {
    setState(() => _target = value);
  }

  void _replay() {
    setState(() => _replayToken++);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bodyStyle = TextStyle(
      inherit: false,
      fontSize: 14,
      color: colors.textPrimary,
    );
    final hintStyle = TextStyle(
      inherit: false,
      fontSize: 12,
      color: colors.textSecondary,
    );

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Progress example',
            style: bodyStyle.copyWith(fontSize: 18, fontWeight: .w600),
          ),
          const SizedBox(height: 12),
          Text(
            'After a 500ms delay the fill animates to the target. Percent buttons '
            'animate from the current fill. Replay remounts from empty.',
            style: bodyStyle,
          ),
          const SizedBox(height: 24),
          const _LabeledBar(label: '25%', targetValue: 0.25),
          const SizedBox(height: 16),
          const _LabeledBar(label: '50%', targetValue: 0.5),
          const SizedBox(height: 16),
          const _LabeledBar(label: '85%', targetValue: 0.85),
          const SizedBox(height: 32),
          _LabeledBar(
            key: ValueKey(_replayToken),
            label: 'Interactive (${(_target * 100).round()}%)',
            targetValue: _target,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in _presetTargets)
                _PercentButton(
                  label: '${(value * 100).round()}%',
                  selected: _target == value,
                  onTap: () => _setTarget(value),
                ),
              _PercentButton(label: 'Replay', selected: false, onTap: _replay),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Values above 100% are clamped. Reduced-motion preview jumps instantly.',
            style: hintStyle,
          ),
        ],
      ),
    );
  }
}

class _LabeledBar extends StatelessWidget {
  const _LabeledBar({
    required this.label,
    required this.targetValue,
    super.key,
  });

  final String label;
  final double targetValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: TextStyle(
            inherit: false,
            fontSize: 14,
            fontWeight: .w500,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedShadowedLinearProgressIndicator(
          targetValue: targetValue,
          semanticLabel: label,
        ),
      ],
    );
  }
}

class _PercentButton extends StatelessWidget {
  const _PercentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.16)
              : colors.foreground,
          borderRadius: .circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              inherit: false,
              fontSize: 14,
              fontWeight: .w500,
              color: selected ? colors.primary : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
