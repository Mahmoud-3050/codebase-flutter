import 'package:either/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_password_reset_response.dart';
import 'package:codebase/features/auth/presentation/controller/request_password_reset/request_password_reset_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/forgot_password_screen.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RequestPasswordResetResponse>>(
      const Left<Failure, RequestPasswordResetResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-046a forgot password email field', (
    WidgetTester tester,
  ) async {
    final MockRequestPasswordResetUseCase useCase =
        MockRequestPasswordResetUseCase();
    when(useCase.call(any)).thenAnswer(
      (_) async =>
          const Left<Failure, RequestPasswordResetResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPasswordResetCubit>(
          create: (_) => RequestPasswordResetCubit(useCase),
        ),
      ],
      child: const ForgotPasswordScreen(),
    );
    expect(find.text(Strings.forgotPassword), findsWidgets);
    expect(find.text(Strings.email), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'ada@example.com');
    await tester.tap(find.text(Strings.send));
    await tester.pump();
  });

  testWidgets('FR-046 forgot error and success navigate to reset', (
    WidgetTester tester,
  ) async {
    final RequestPasswordResetCubit cubit = RequestPasswordResetCubit(
      MockRequestPasswordResetUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPasswordResetCubit>.value(value: cubit),
      ],
      child: const ForgotPasswordScreen(),
    );
    cubit.emit(const ApiCallError<OtpChallenge>(message: 'reset failed'));
    await tester.pump();
    cubit.emit(const ApiCallSuccess<OtpChallenge>(data: kEmailChallenge));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('routed:${AppRoutes.resetPassword}'),
      findsOneWidget,
    );
    await cubit.close();
  });
}
