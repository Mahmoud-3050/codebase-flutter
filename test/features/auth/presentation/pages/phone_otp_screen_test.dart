import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/domain/entities/verify_phone_otp_response.dart';
import 'package:codebase/features/auth/presentation/controller/otp_cooldown/otp_cooldown_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_phone_otp/request_phone_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/verify_phone_otp/verify_phone_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/phone_otp_screen.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, VerifyPhoneOtpResponse>>(
      const Left<Failure, VerifyPhoneOtpResponse>(ServerFailure()),
    );
    provideDummy<Either<Failure, RequestOtpResponse>>(
      const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-021 phone OTP screen shows code field', (
    WidgetTester tester,
  ) async {
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyPhoneOtpCubit>(
          create: (_) => VerifyPhoneOtpCubit(MockVerifyPhoneOtpUseCase()),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const PhoneOtpScreen(dialingCode: '+966', phone: '500000000'),
    );
    expect(find.text(Strings.verifyCode), findsWidgets);
  });

  testWidgets('FR-021 FR-022 verify phone otp dispatches', (
    WidgetTester tester,
  ) async {
    final MockVerifyPhoneOtpUseCase verifyUseCase = MockVerifyPhoneOtpUseCase();
    final MockRequestPhoneOtpUseCase request = MockRequestPhoneOtpUseCase();
    when(verifyUseCase.call(any)).thenAnswer(
      (_) async => const Left<Failure, VerifyPhoneOtpResponse>(ServerFailure()),
    );
    when(request.call(any)).thenAnswer(
      (_) async => const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyPhoneOtpCubit>(
          create: (_) => VerifyPhoneOtpCubit(verifyUseCase),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(request),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const PhoneOtpScreen(dialingCode: '+966', phone: '500000000'),
    );
    await tester.tap(find.text(Strings.verifyCode).last);
    await tester.pump();
    await tester.tap(find.text(Strings.resend));
    await tester.pump();
  });

  testWidgets('FR-021 FR-022 phone OTP error session and draft outcomes', (
    WidgetTester tester,
  ) async {
    final VerifyPhoneOtpCubit cubit = VerifyPhoneOtpCubit(
      MockVerifyPhoneOtpUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyPhoneOtpCubit>.value(value: cubit),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const PhoneOtpScreen(dialingCode: '+966', phone: '500000000'),
    );
    cubit.emit(const ApiCallError<AuthOutcome?>(message: 'bad code'));
    await tester.pump();
    cubit.emit(
      ApiCallSuccess<AuthOutcome?>(data: AuthSessionEstablished(kSession)),
    );
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-022 phone OTP registration_required routes complete', (
    WidgetTester tester,
  ) async {
    final VerifyPhoneOtpCubit cubit = VerifyPhoneOtpCubit(
      MockVerifyPhoneOtpUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyPhoneOtpCubit>.value(value: cubit),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const PhoneOtpScreen(dialingCode: '+966', phone: '500000000'),
    );
    cubit.emit(
      const ApiCallSuccess<AuthOutcome?>(
        data: AuthRegistrationRequired(kPhoneDraft),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('routed:${AppRoutes.completeRegistration}'),
      findsOneWidget,
    );
    await cubit.close();
  });
}
