import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({
    required this.child,
    super.key,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colors.baseColorShimmer,
      highlightColor: context.colors.highlightColorShimmer,
      child: widget.child,
    );
  }
}

class AnimatedSwitcherShimmer extends StatelessWidget {
  final Widget shimmer;
  final Widget child;
  final bool showShimmer;
  final Duration? duration;

  const AnimatedSwitcherShimmer({
    required this.shimmer,
    required this.child,
    this.showShimmer = true,
    this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ??  const Duration(milliseconds: 500),
      child: showShimmer ? shimmer : child,
    );
  }
}

class TextShimmer extends StatelessWidget {
  final String text;
  final TextStyle style;
  final BorderRadiusGeometry? borderRadius;

  const TextShimmer(
    this.text, {
    required this.style,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.highlightColorShimmer,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: style.copyWith(color: Colors.transparent),
          overflow: .visible,
        ),
      ),
    );
  }
}

class ContainerShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const ContainerShimmer({
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: context.colors.highlightColorShimmer,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

class CircleShimmer extends StatelessWidget {
  final double size;

  const CircleShimmer({
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.colors.highlightColorShimmer,
          shape: .circle,
        ),
      ),
    );
  }
}

class StarShimmer extends StatelessWidget {
  final double size;

  const StarShimmer({
    this.size = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Icon(
        Icons.star,
        color: context.colors.highlightColorShimmer,
        size: size,
      ),
    );
  }
}
