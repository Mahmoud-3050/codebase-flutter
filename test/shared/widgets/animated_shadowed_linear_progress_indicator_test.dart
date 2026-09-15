import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/shared/widgets/animated_shadowed_linear_progress_indicator.dart';

void main() {
  setUp(() async {
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  testWidgets('animates to the target after delay', (tester) async {
    await tester.pumpWidget(
      _harness(
        const AnimatedShadowedLinearProgressIndicator(
          targetValue: 0.65,
          semanticLabel: 'Progress',
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSemantics(find.bySemanticsLabel('Progress')).value, '0%');

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 750));

    expect(tester.getSemantics(find.bySemanticsLabel('Progress')).value, '65%');
  });

  testWidgets('clamps values above 1', (tester) async {
    await tester.pumpWidget(
      _harness(
        const AnimatedShadowedLinearProgressIndicator(
          targetValue: 1.4,
          delay: Duration.zero,
          semanticLabel: 'Progress',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Progress')).value,
      '100%',
    );
  });

  testWidgets('jumps when animations are disabled', (tester) async {
    await tester.pumpWidget(
      _harness(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true, size: Size(393, 852)),
          child: AnimatedShadowedLinearProgressIndicator(
            targetValue: 0.65,
            semanticLabel: 'Progress',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSemantics(find.bySemanticsLabel('Progress')).value, '65%');
  });

  testWidgets('animates from the current fill when the target changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const AnimatedShadowedLinearProgressIndicator(
          targetValue: 0.2,
          delay: Duration.zero,
          semanticLabel: 'Progress',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    await tester.pumpWidget(
      _harness(
        const AnimatedShadowedLinearProgressIndicator(
          targetValue: 0.8,
          delay: Duration.zero,
          semanticLabel: 'Progress',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(tester.getSemantics(find.bySemanticsLabel('Progress')).value, '80%');
  });

  testWidgets('disposing during delay does not throw', (tester) async {
    await tester.pumpWidget(
      _harness(
        const AnimatedShadowedLinearProgressIndicator(
          targetValue: 0.65,
          semanticLabel: 'Progress',
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
  });
}

Widget _harness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    minTextAdapt: true,
    builder: (context, _) {
      return MaterialApp(
        theme: appTheme(ColorsPalettes.config.light, .light),
        home: Scaffold(
          body: SizedBox(width: 200, child: Center(child: child)),
        ),
      );
    },
  );
}
