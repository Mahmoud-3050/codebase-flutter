import 'package:either/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/domain/entities/verify_email_response.dart';
import 'package:codebase/features/auth/presentation/controller/otp_cooldown/otp_cooldown_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_email_otp/request_email_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/verify_email/verify_email_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/verify_email_screen.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, VerifyEmailResponse>>(
      const Left<Failure, VerifyEmailResponse>(ServerFailure()),
    );
    provideDummy<Either<Failure, RequestOtpResponse>>(
      const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-012 FR-013 verify email shows OTP and resend', (
    WidgetTester tester,
  ) async {
    final MockVerifyEmailUseCase verify = MockVerifyEmailUseCase();
    final MockRequestEmailOtpUseCase request = MockRequestEmailOtpUseCase();
    final VerifyEmailCubit verifyCubit = VerifyEmailCubit(verify);
    final RequestEmailOtpCubit requestCubit = RequestEmailOtpCubit(request);
    final OtpCooldownCubit cooldown = OtpCooldownCubit(
      tick: (int ticks) => const Stream<int>.empty(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyEmailCubit>.value(value: verifyCubit),
        BlocProvider<RequestEmailOtpCubit>.value(value: requestCubit),
        BlocProvider<OtpCooldownCubit>.value(value: cooldown),
      ],
      child: const VerifyEmailScreen(email: 'ada@example.com'),
    );
    expect(find.text(Strings.verifyCode), findsWidgets);
    expect(find.text(Strings.resend), findsOneWidget);
    await verifyCubit.close();
    await requestCubit.close();
    await cooldown.close();
  });

  testWidgets('FR-050 verify email RTL', (WidgetTester tester) async {
    final MockVerifyEmailUseCase verify = MockVerifyEmailUseCase();
    final MockRequestEmailOtpUseCase request = MockRequestEmailOtpUseCase();
    await pumpAuthWidget(
      tester,
      textDirection: TextDirection.rtl,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyEmailCubit>(create: (_) => VerifyEmailCubit(verify)),
        BlocProvider<RequestEmailOtpCubit>(
          create: (_) => RequestEmailOtpCubit(request),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const VerifyEmailScreen(email: 'ada@example.com'),
    );
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
  });

  testWidgets('FR-011 FR-012 verify and resend dispatch', (
    WidgetTester tester,
  ) async {
    final MockVerifyEmailUseCase verifyUseCase = MockVerifyEmailUseCase();
    final MockRequestEmailOtpUseCase request = MockRequestEmailOtpUseCase();
    when(verifyUseCase.call(any)).thenAnswer(
      (_) async => const Left<Failure, VerifyEmailResponse>(ServerFailure()),
    );
    when(request.call(any)).thenAnswer(
      (_) async => const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyEmailCubit>(
          create: (_) => VerifyEmailCubit(verifyUseCase),
        ),
        BlocProvider<RequestEmailOtpCubit>(
          create: (_) => RequestEmailOtpCubit(request),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const VerifyEmailScreen(email: 'ada@example.com'),
    );
    await tester.tap(find.text(Strings.verifyCode).last);
    await tester.pump();
    await tester.tap(find.text(Strings.resend));
    await tester.pump();
  });

  testWidgets('FR-011 verify email error and success', (
    WidgetTester tester,
  ) async {
    final VerifyEmailCubit cubit = VerifyEmailCubit(MockVerifyEmailUseCase());
    final RequestEmailOtpCubit requestCubit = RequestEmailOtpCubit(
      MockRequestEmailOtpUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyEmailCubit>.value(value: cubit),
        BlocProvider<RequestEmailOtpCubit>.value(value: requestCubit),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const VerifyEmailScreen(email: 'ada@example.com'),
    );
    cubit.emit(const ApiCallError<AuthSession>(message: 'bad otp'));
    await tester.pump();
    requestCubit.emit(
      const ApiCallSuccess<OtpChallenge>(data: kEmailChallenge),
    );
    await tester.pump();
    cubit.emit(ApiCallSuccess<AuthSession>(data: kSession));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await cubit.close();
    await requestCubit.close();
  });
}
