import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/shared/widgets/app_dropdown.dart';
import 'package:codebase/shared/widgets/app_shimmer.dart';
import 'package:codebase/shared/widgets/field_errors_scope.dart';

void main() {
  setUp(() async {
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  testWidgets('selecting an item calls onChanged', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: null,
          values: const ['a', 'b'],
          names: const ['Alpha', 'Beta'],
          hintText: 'Pick',
          onChanged: (String? value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();

    expect(selected, 'b');
  });

  testWidgets('does not invoke onChanged when enabled is false', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: 'a',
          values: const ['a', 'b'],
          names: const ['Alpha', 'Beta'],
          hintText: 'Pick',
          enabled: false,
          onChanged: (String? value) => selected = value,
        ),
      ),
    );

    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .onChanged,
      isNull,
    );
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(selected, isNull);
  });

  testWidgets('shows error text and an error border', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: 'a',
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          errorText: 'Required',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Required'), findsOneWidget);
    final decoration =
        tester
                .widget<Container>(
                  find
                      .descendant(
                        of: find.byType(AppDropdown<String>),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(decoration.border?.top.color, ColorsPalettes.config.light.error);
  });

  testWidgets('reads field errors from FieldErrorsScope', (tester) async {
    await tester.pumpWidget(
      _harness(
        FieldErrorsScope(
          fieldErrors: const {
            'city_id': ['taken'],
          },
          child: AppDropdown<String>(
            value: 'a',
            values: const ['a'],
            names: const ['Alpha'],
            hintText: 'Pick',
            fieldName: 'city_id',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('taken'), findsOneWidget);
  });

  testWidgets('shows a required mark on the label', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: null,
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          labelText: 'City',
          showRequiredSymbol: true,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('City *', findRichText: true), findsOneWidget);
  });

  testWidgets('optional dropdown includes a none item', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: null,
          values: const ['a', 'b'],
          names: const ['Alpha', 'Beta'],
          hintText: 'Pick',
          isOptional: true,
          onChanged: (_) {},
        ),
      ),
    );

    final items = tester
        .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
        .items;
    expect(items, hasLength(3));
    expect(items!.first.value, isNull);
  });

  testWidgets('value missing from values does not throw', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: 'missing',
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          onChanged: (_) {},
        ),
      ),
    );

    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .value,
      isNull,
    );
    expect(find.text('Pick'), findsOneWidget);
  });

  testWidgets('uses per-item icons when provided', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: 'a',
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          itemIcons: const [Icon(Icons.place)],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.place), findsWidgets);
  });

  testWidgets('hides the arrow when showArrow is false', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdown<String>(
          value: 'a',
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          showArrow: false,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_drop_down_rounded), findsNothing);
  });

  testWidgets('shimmer renders without a selected value', (tester) async {
    await tester.pumpWidget(
      _harness(const AppDropdownShimmer(labelText: 'City')),
    );

    expect(find.text('City'), findsOneWidget);
    expect(find.byType(AppShimmer), findsOneWidget);
    expect(
      tester
          .widget<DropdownButton<int>>(find.byType(DropdownButton<int>))
          .value,
      isNull,
    );
  });

  testWidgets('error widget retry callback fires', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      _harness(
        AppDropdownErrorWidget(errorText: 'Failed', onRetry: () => retries++),
      ),
    );

    expect(find.text('Failed'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();
    expect(retries, 1);
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
