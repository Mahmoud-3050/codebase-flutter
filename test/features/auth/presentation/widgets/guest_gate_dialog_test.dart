import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/features/auth/presentation/widgets/guest_gate_dialog.dart';

import '../pages/auth_widget_harness.dart';

void main() {
  tearDown(resetAuthWidget);

  testWidgets('FR-039 guest gate offers sign-in and register', (
    WidgetTester tester,
  ) async {
    await pumpAuthWidget(
      tester,
      child: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () => showGuestGateDialog(context),
            child: const Text('open'),
          );
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(Strings.accountRequired), findsOneWidget);
    expect(find.text(Strings.signIn), findsOneWidget);
    expect(find.text(Strings.createAccount), findsOneWidget);
    await tester.tap(find.text(Strings.signIn));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.login}'), findsOneWidget);
  });

  testWidgets('FR-039 guest gate register navigates', (
    WidgetTester tester,
  ) async {
    await pumpAuthWidget(
      tester,
      child: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () => showGuestGateDialog(context),
            child: const Text('open'),
          );
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.createAccount));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.register}'), findsOneWidget);
  });
}
