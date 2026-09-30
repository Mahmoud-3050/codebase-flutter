import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/presentation/controller/request_email_otp/request_email_otp_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RequestOtpResponse>>(
      const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
  });

  blocTest<RequestEmailOtpCubit, RequestEmailOtpState>(
    'FR-012 resend emits success challenge',
    build: () {
      final MockRequestEmailOtpUseCase useCase = MockRequestEmailOtpUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, RequestOtpResponse>(
          RequestOtpResponse(
            status: 'success',
            message: 'ok',
            data: kEmailChallenge,
          ),
        ),
      );
      return RequestEmailOtpCubit(useCase);
    },
    act: (RequestEmailOtpCubit cubit) => cubit.fRequestEmailOtp(email: 'a@b.c'),
    expect: () => <RequestEmailOtpState>[
      const ApiCallLoading<OtpChallenge>(),
      const ApiCallSuccess<OtpChallenge>(data: kEmailChallenge),
    ],
  );
}
