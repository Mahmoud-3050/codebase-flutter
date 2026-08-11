import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/theme/presentation/cubit/theme_cubit/theme_cubit.dart';
import '../../injection_container.dart';

class AnimatedShadowedProgressIndicator extends StatefulWidget {
  final double targetValue; // Between 0.0 and 1.0
  final Duration duration;
  final Duration delay;

  const AnimatedShadowedProgressIndicator({
    required this.targetValue, super.key,
    this.duration = const Duration(milliseconds: 750),
    this.delay = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedShadowedProgressIndicator> createState() =>
      _AnimatedShadowedProgressIndicatorState();
}

class _AnimatedShadowedProgressIndicatorState extends State<AnimatedShadowedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () => _controller.forward());
  }

  @override
  void didUpdateWidget(covariant AnimatedShadowedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetValue != oldWidget.targetValue) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.targetValue,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final progressWidth = constraints.maxWidth * _progressAnimation.value;

            return Stack(
              children: [
                // Background
                Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: colors.progressBarBackground,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                // Animated foreground with shadow
                Container(
                  width: progressWidth,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: colors.secondary,
                        blurRadius: context.read<ThemeCubit>().isDarkMode ? 16.r : 4.r,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
