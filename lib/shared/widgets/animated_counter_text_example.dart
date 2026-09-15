import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:themes/themes.dart';

import 'animated_counter_text.dart';
import 'animated_shadowed_linear_progress_indicator_example.dart';

@Preview(
  name: 'Count to 5',
  group: 'AnimatedCounterText',
  size: Size(393, 96),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedCounterTextExampleCountTo5Preview() {
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
Widget animatedCounterTextExampleJumpPreview() {
  return const Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: AnimatedCounterText(maxNumber: 42)),
  );
}

@Preview(
  name: 'Interactive',
  group: 'AnimatedCounterText',
  size: Size(393, 720),
  theme: animatedShadowedProgressPreviewTheme,
  wrapper: wrapAnimatedShadowedProgressPreview,
)
Widget animatedCounterTextExampleInteractivePreview() {
  return const AnimatedCounterTextExample();
}

/// Interactive demo: sequential counts, a jump past 10, then replay.
class AnimatedCounterTextExample extends StatefulWidget {
  const AnimatedCounterTextExample({super.key});

  @override
  State<AnimatedCounterTextExample> createState() =>
      _AnimatedCounterTextExampleState();
}

class _AnimatedCounterTextExampleState
    extends State<AnimatedCounterTextExample> {
  static const List<int> _presetMax = [0, 5, 10, 42];

  int _maxNumber = 5;
  int _replayToken = 0;

  void _setMax(int value) {
    setState(() {
      _maxNumber = value;
      _replayToken++;
    });
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
            'Counter example',
            style: bodyStyle.copyWith(fontSize: 18, fontWeight: .w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Ticks 1–10, then jumps to the target when it is larger. Replay '
            'remounts from empty.',
            style: bodyStyle,
          ),
          const SizedBox(height: 24),
          const _LabeledCounter(label: 'Count to 5', maxNumber: 5),
          const SizedBox(height: 16),
          const _LabeledCounter(label: 'Jump to 42', maxNumber: 42),
          const SizedBox(height: 32),
          _LabeledCounter(
            key: ValueKey(_replayToken),
            label: 'Interactive (max $_maxNumber)',
            maxNumber: _maxNumber,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in _presetMax)
                _PresetButton(
                  label: '$value',
                  selected: _maxNumber == value,
                  onTap: () => _setMax(value),
                ),
              _PresetButton(label: 'Replay', selected: false, onTap: _replay),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Targets above 10 count to 10, pause, then jump to the final value.',
            style: hintStyle,
          ),
        ],
      ),
    );
  }
}

class _LabeledCounter extends StatelessWidget {
  const _LabeledCounter({
    required this.label,
    required this.maxNumber,
    super.key,
  });

  final String label;
  final int maxNumber;

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
        ClipRect(
          child: SizedBox(
            height: 40,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedCounterText(maxNumber: maxNumber),
            ),
          ),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
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
