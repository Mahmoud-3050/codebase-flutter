import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/shared/widgets/app_dropdown_multiselect.dart';
import 'package:codebase/shared/widgets/field_errors_scope.dart';

void main() {
  setUp(() async {
    await Themes.instance.init(config: ColorsPalettes.config);
  });

  tearDown(resetThemes);

  testWidgets('selecting an item calls onChanged with a copied list', (
    tester,
  ) async {
    List<String>? selected;
    await tester.pumpWidget(
      _harness(
        AppDropdownMultiSelect<String>(
          selectedItems: const [],
          values: const ['a', 'b'],
          names: const ['Alpha', 'Beta'],
          hintText: 'Pick',
          onChanged: (List<String> value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'Beta'));
    await tester.pump();

    expect(selected, ['b']);
    selected!.add('mutated');

    await tester.tap(find.widgetWithText(InkWell, 'Alpha'));
    await tester.pump();

    expect(selected, ['b', 'a']);
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });

  testWidgets('chip close removes the item', (tester) async {
    List<String>? selected;
    await tester.pumpWidget(
      _harness(
        AppDropdownMultiSelect<String>(
          selectedItems: const ['a'],
          values: const ['a', 'b'],
          names: const ['Alpha', 'Beta'],
          hintText: 'Pick',
          onChanged: (List<String> value) => selected = value,
        ),
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(selected, isEmpty);
    expect(find.text('Pick'), findsOneWidget);
  });

  testWidgets('does not open when enabled is false', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdownMultiSelect<String>(
          selectedItems: const [],
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          enabled: false,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pump();
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('does not open when values are empty', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdownMultiSelect<String>(
          selectedItems: const [],
          values: const [],
          names: const [],
          hintText: 'Pick',
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pump();
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('shows error text', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdownMultiSelect<String>(
          selectedItems: const [],
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          errorText: 'Required',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('reads field errors from FieldErrorsScope', (tester) async {
    await tester.pumpWidget(
      _harness(
        FieldErrorsScope(
          fieldErrors: const {
            'skills': ['taken'],
          },
          child: AppDropdownMultiSelect<String>(
            selectedItems: const [],
            values: const ['a'],
            names: const ['Alpha'],
            hintText: 'Pick',
            fieldName: 'skills',
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
        AppDropdownMultiSelect<String>(
          selectedItems: const [],
          values: const ['a'],
          names: const ['Alpha'],
          hintText: 'Pick',
          labelText: 'Skills',
          showRequiredSymbol: true,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Skills *', findRichText: true), findsOneWidget);
  });

  testWidgets('closeOnSelect dismisses the menu after a tap', (tester) async {
    await tester.pumpWidget(
      _harness(
        AppDropdownMultiSelect<String>(
          selectedItems: const [],
          values: const ['a', 'b'],
          names: const ['Alpha', 'Beta'],
          hintText: 'Pick',
          closeOnSelect: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.widgetWithText(InkWell, 'Alpha'));
    await tester.pump();

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
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
