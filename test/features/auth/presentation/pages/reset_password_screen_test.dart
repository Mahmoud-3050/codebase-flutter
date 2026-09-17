import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/request_password_reset_response.dart';
import 'package:codebase/features/auth/domain/entities/reset_password_response.dart';
import 'package:codebase/features/auth/presentation/controller/otp_cooldown/otp_cooldown_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_password_reset/request_password_reset_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/reset_password/reset_password_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:codebase/features/auth/presentation/validators/auth_validators.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, ResetPasswordResponse>>(
      const Left<Failure, ResetPasswordResponse>(ServerFailure()),
    );
    provideDummy<Either<Failure, RequestPasswordResetResponse>>(
      const Left<Failure, RequestPasswordResetResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-007b FR-046c reset uses password validator labels', (
    WidgetTester tester,
  ) async {
    expect(AuthValidators.password.validate('abc12345'), isNull);
    final MockResetPasswordUseCase useCase = MockResetPasswordUseCase();
    when(useCase.call(any)).thenAnswer(
      (_) async => const Left<Failure, ResetPasswordResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ResetPasswordCubit>(
          create: (_) => ResetPasswordCubit(useCase),
        ),
        BlocProvider<RequestPasswordResetCubit>(
          create: (_) =>
              RequestPasswordResetCubit(MockRequestPasswordResetUseCase()),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const ResetPasswordScreen(email: 'ada@example.com'),
    );
    expect(find.text(Strings.resetPassword), findsWidgets);
    expect(find.text(Strings.newPassword), findsWidgets);
    expect(find.text(Strings.resend), findsOneWidget);
    await tester.tap(find.text(Strings.confirm));
    await tester.pump();
  });

  testWidgets('FR-046c reset error and success route home', (
    WidgetTester tester,
  ) async {
    final ResetPasswordCubit cubit = ResetPasswordCubit(
      MockResetPasswordUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ResetPasswordCubit>.value(value: cubit),
        BlocProvider<RequestPasswordResetCubit>(
          create: (_) =>
              RequestPasswordResetCubit(MockRequestPasswordResetUseCase()),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) =>
              OtpCooldownCubit(tick: (int ticks) => const Stream<int>.empty()),
        ),
      ],
      child: const ResetPasswordScreen(email: 'ada@example.com'),
    );
    cubit.emit(const ApiCallError<AuthSession>(message: 'reset boom'));
    await tester.pump();
    cubit.emit(ApiCallSuccess<AuthSession>(data: kSession));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await cubit.close();
  });
}
