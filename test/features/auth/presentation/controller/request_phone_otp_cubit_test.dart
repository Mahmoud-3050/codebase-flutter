import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/presentation/controller/request_phone_otp/request_phone_otp_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RequestOtpResponse>>(
      const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
  });

  blocTest<RequestPhoneOtpCubit, RequestPhoneOtpState>(
    'FR-019 emits challenge',
    build: () {
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
      return RequestPhoneOtpCubit(useCase);
    },
    act: (RequestPhoneOtpCubit cubit) => cubit.fRequestPhoneOtp(
      dialingCode: '+966',
      phone: '500000000',
      purpose: OtpPurpose.verifyPhone,
    ),
    expect: () => <RequestPhoneOtpState>[
      const ApiCallLoading<OtpChallenge>(),
      const ApiCallSuccess<OtpChallenge>(data: kPhoneChallenge),
    ],
  );
}
