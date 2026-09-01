import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({required this.child, super.key});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.baseColorShimmer,
      highlightColor: colors.highlightColorShimmer,
      child: widget.child,
    );
  }
}
