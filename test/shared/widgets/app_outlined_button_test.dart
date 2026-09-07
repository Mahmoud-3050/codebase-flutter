import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/shared/widgets/app_outlined_button.dart';

void main() {
  setUp(() async {
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  testWidgets('invokes onPressed on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _harness(AppOutlinedButton(text: 'Cancel', onPressed: () => taps++)),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('does not invoke onPressed when enabled is false', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _harness(
        AppOutlinedButton(
          text: 'Cancel',
          enabled: false,
          onPressed: () => taps++,
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();

    expect(taps, 0);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
  });

  testWidgets('does not invoke onPressed while loading and shows a spinner', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _harness(
        AppOutlinedButton(
          text: 'Cancel',
          isLoading: true,
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('ignores a second tap while an async onPressed is in flight', (
    tester,
  ) async {
    var taps = 0;
    final gate = Completer<void>();
    await tester.pumpWidget(
      _harness(
        AppOutlinedButton(
          text: 'Cancel',
          onPressed: () async {
            taps++;
            await gate.future;
          },
        ),
      ),
    );

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();

    expect(taps, 1);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    gate.complete();
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('renders icon beside the label', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppOutlinedButton(
          text: 'Cancel',
          icon: const Icon(Icons.close),
          onPressed: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}

Widget _harness(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    minTextAdapt: true,
    builder: (context, _) {
      return MaterialApp(
        theme: appTheme(ColorsPalettes.config.light, .light),
        home: Scaffold(body: Center(child: child)),
      );
    },
  );
}
