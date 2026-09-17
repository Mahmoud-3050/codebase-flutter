import 'package:either/either.dart';
import 'package:field_validator/field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/presentation/controller/request_phone_otp/request_phone_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/phone_sign_in_screen.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RequestOtpResponse>>(
      const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-019 phone sign-in shows phone field', (
    WidgetTester tester,
  ) async {
    final MockRequestPhoneOtpUseCase useCase = MockRequestPhoneOtpUseCase();
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(useCase),
        ),
      ],
      child: const PhoneSignInScreen(),
    );
    expect(find.text(Strings.signInWithPhone), findsWidgets);
    expect(find.text(Strings.send), findsOneWidget);
    await tester.tap(find.text(Strings.send));
    await tester.pump();
  });

  testWidgets('FR-019 valid phone requests OTP and navigates', (
    WidgetTester tester,
  ) async {
    FieldValidator.instance.init();
    final MockRequestPhoneOtpUseCase useCase = MockRequestPhoneOtpUseCase();
    when(useCase.call(any)).thenAnswer(
      (_) async => const Right<Failure, RequestOtpResponse>(
        RequestOtpResponse(
          status: 'success',
          message: 'ok',
          data: kPhoneChallenge,
        ),
      ),
    );
    final RequestPhoneOtpCubit cubit = RequestPhoneOtpCubit(useCase);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPhoneOtpCubit>.value(value: cubit),
      ],
      child: const PhoneSignInScreen(),
    );
    await tester.enterText(find.byType(TextField).first, '500000000');
    await tester.tap(find.text(Strings.send));
    await tester.pump();
    cubit.emit(const ApiCallError<OtpChallenge>(message: 'send failed'));
    await tester.pump();
    cubit.emit(const ApiCallSuccess<OtpChallenge>(data: kPhoneChallenge));
    await tester.pumpAndSettle();
    expect(find.textContaining('routed:${AppRoutes.phoneOtp}'), findsOneWidget);
    await cubit.close();
  });
}
