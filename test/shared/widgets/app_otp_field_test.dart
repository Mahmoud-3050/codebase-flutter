import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/shared/widgets/app_otp_field.dart';

void main() {
  setUp(() async {
    await Themes.instance.init(config: ColorsPalettes.config);
  });
  tearDown(resetThemes);

  testWidgets('FR-012 AppOtpField is 6 digits and digit-only', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    await tester.pumpWidget(_harness(AppOtpField(controller: controller)));
    await tester.enterText(find.byType(TextFormField), '12ab34567');
    expect(controller.text, '123456');
  });

  testWidgets('FR-050 AppOtpField lays out under RTL', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    await tester.pumpWidget(
      _harness(
        AppOtpField(controller: controller),
        textDirection: TextDirection.rtl,
      ),
    );
    expect(find.byType(AppOtpField), findsOneWidget);
  });
}

Widget _harness(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    minTextAdapt: true,
    builder: (BuildContext context, Widget? _) {
      return MaterialApp(
        theme: appTheme(ColorsPalettes.config.light, Brightness.light),
        home: Scaffold(
          body: Directionality(textDirection: textDirection, child: child),
        ),
      );
    },
  );
}
