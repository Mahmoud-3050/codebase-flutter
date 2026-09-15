import 'dart:async';

import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';

/// Linear bar that animates from empty to [targetValue] after [delay].
///
/// Open `animated_shadowed_linear_progress_indicator_example.dart` in the
/// Flutter Widget Preview to watch the fill.
class AnimatedShadowedLinearProgressIndicator extends StatefulWidget {
  /// Fill fraction. Values outside `0.0–1.0` are clamped.
  final double targetValue;
  final Duration duration;
  final Duration delay;
  final Color? fillColor;
  final Color? trackColor;
  final Color? glowColor;
  final String? semanticLabel;

  const AnimatedShadowedLinearProgressIndicator({
    required this.targetValue,
    super.key,
    this.duration = const Duration(milliseconds: 750),
    this.delay = const Duration(milliseconds: 500),
    this.fillColor,
    this.trackColor,
    this.glowColor,
    this.semanticLabel,
  });

  @override
  State<AnimatedShadowedLinearProgressIndicator> createState() =>
      _AnimatedShadowedLinearProgressIndicatorState();
}

typedef AnimatedShadowedProgressIndicator =
    AnimatedShadowedLinearProgressIndicator;

class _AnimatedShadowedLinearProgressIndicatorState
    extends State<AnimatedShadowedLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  static const double _trackHeight = 8;
  static const double _cornerRadius = 8;
  static const double _glowBlurLight = 4;
  static const double _glowBlurDark = 16;

  late final AnimationController _controller;
  Timer? _startTimer;

  double get _progress => widget.targetValue.clamp(0.0, 1.0).toDouble();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);
  }

  void _onFirstFrame(Duration _) {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _progress;
      return;
    }
    if (widget.delay <= Duration.zero) {
      _goToTarget();
      return;
    }
    _startTimer = Timer(widget.delay, _goToTarget);
  }

  void _goToTarget() {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = _progress;
      return;
    }
    _controller.animateTo(
      _progress,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(
    covariant AnimatedShadowedLinearProgressIndicator oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.targetValue != oldWidget.targetValue) {
      _startTimer?.cancel();
      _startTimer = null;
      _goToTarget();
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trackColor = widget.trackColor ?? colors.progressBarBackground;
    final fillColor = widget.fillColor ?? colors.primary;
    final glowColor = widget.glowColor ?? colors.secondary;
    final radius = _cornerRadius.r;
    final height = _trackHeight.h;
    final glowBlur = Theme.brightnessOf(context) == .dark
        ? _glowBlurDark.r
        : _glowBlurLight.r;

    final track = DecoratedBox(
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: .circular(radius),
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 0.0;
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Semantics(
              label: widget.semanticLabel,
              value: '${(_controller.value * 100).round()}%',
              child: SizedBox(
                width: maxWidth,
                height: height,
                child: Stack(
                  children: [
                    if (child != null) Positioned.fill(child: child),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: _controller.value,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: .circular(radius),
                            boxShadow: [
                              BoxShadow(color: glowColor, blurRadius: glowBlur),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: track,
        );
      },
    );
  }
}
