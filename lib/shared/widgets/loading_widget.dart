import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';

import '../../config/language/strings.dart';
import '../../core/utils/extensions.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  const LoadingWidget({this.size = 48, super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size.r,
          child: Center(child: const CircularProgressIndicator().appLoading),
        ),
      ),
    );
  }
}
