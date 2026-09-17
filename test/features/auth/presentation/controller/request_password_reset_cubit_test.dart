import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_password_reset_response.dart';
import 'package:codebase/features/auth/presentation/controller/request_password_reset/request_password_reset_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RequestPasswordResetResponse>>(
      const Left<Failure, RequestPasswordResetResponse>(ServerFailure()),
    );
  });

  blocTest<RequestPasswordResetCubit, RequestPasswordResetState>(
    'FR-046 emits challenge',
    build: () {
      final MockRequestPasswordResetUseCase useCase =
          MockRequestPasswordResetUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, RequestPasswordResetResponse>(
          RequestPasswordResetResponse(
            status: 'success',
            message: 'ok',
            data: kEmailChallenge,
          ),
        ),
      );
      return RequestPasswordResetCubit(useCase);
    },
    act: (RequestPasswordResetCubit cubit) =>
        cubit.fRequestPasswordReset(email: 'a@b.c'),
    expect: () => <RequestPasswordResetState>[
      const ApiCallLoading<OtpChallenge>(),
      const ApiCallSuccess<OtpChallenge>(data: kEmailChallenge),
    ],
  );
}
