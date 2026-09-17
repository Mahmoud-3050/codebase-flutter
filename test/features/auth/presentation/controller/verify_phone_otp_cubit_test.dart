import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/verify_phone_otp_response.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/presentation/controller/verify_phone_otp/verify_phone_otp_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, VerifyPhoneOtpResponse>>(
      const Left<Failure, VerifyPhoneOtpResponse>(ServerFailure()),
    );
  });

  blocTest<VerifyPhoneOtpCubit, VerifyPhoneOtpState>(
    'FR-021 emits session',
    build: () {
      final MockVerifyPhoneOtpUseCase useCase = MockVerifyPhoneOtpUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, VerifyPhoneOtpResponse>(
          VerifyPhoneOtpResponse(
            status: 'success',
            message: 'ok',
            data: AuthSessionEstablished(kSession),
          ),
        ),
      );
      return VerifyPhoneOtpCubit(useCase);
    },
    act: (VerifyPhoneOtpCubit cubit) => cubit.fVerifyPhoneOtp(
      dialingCode: '+966',
      phone: '500000000',
      code: kValidOtpCode,
      purpose: OtpPurpose.phoneSignIn,
    ),
    expect: () => <VerifyPhoneOtpState>[
      const ApiCallLoading<AuthOutcome?>(),
      ApiCallSuccess<AuthOutcome?>(data: AuthSessionEstablished(kSession)),
    ],
  );

  blocTest<VerifyPhoneOtpCubit, VerifyPhoneOtpState>(
    'FR-023 emits registration required',
    build: () {
      final MockVerifyPhoneOtpUseCase useCase = MockVerifyPhoneOtpUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, VerifyPhoneOtpResponse>(
          VerifyPhoneOtpResponse(
            status: 'success',
            message: 'ok',
            data: AuthRegistrationRequired(kPhoneDraft),
          ),
        ),
      );
      return VerifyPhoneOtpCubit(useCase);
    },
    act: (VerifyPhoneOtpCubit cubit) => cubit.fVerifyPhoneOtp(
      dialingCode: '+966',
      phone: '500000000',
      code: kValidOtpCode,
      purpose: OtpPurpose.phoneSignIn,
    ),
    expect: () => <VerifyPhoneOtpState>[
      const ApiCallLoading<AuthOutcome?>(),
      const ApiCallSuccess<AuthOutcome?>(
        data: AuthRegistrationRequired(kPhoneDraft),
      ),
    ],
  );

  blocTest<VerifyPhoneOtpCubit, VerifyPhoneOtpState>(
    'FR-021 emits error',
    build: () {
      final MockVerifyPhoneOtpUseCase useCase = MockVerifyPhoneOtpUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, VerifyPhoneOtpResponse>(
          ServerFailure(message: 'nope'),
        ),
      );
      return VerifyPhoneOtpCubit(useCase);
    },
    act: (VerifyPhoneOtpCubit cubit) => cubit.fVerifyPhoneOtp(
      dialingCode: '+966',
      phone: '500000000',
      code: kValidOtpCode,
      purpose: OtpPurpose.phoneSignIn,
    ),
    expect: () => <VerifyPhoneOtpState>[
      const ApiCallLoading<AuthOutcome?>(),
      ApiCallError<AuthOutcome?>(
        message: Strings.invalidCode,
        fieldErrors: <String, List<String>>{
          'code': <String>[Strings.invalidCode],
        },
      ),
    ],
  );

  blocTest<VerifyPhoneOtpCubit, VerifyPhoneOtpState>(
    'FR-021 cancel does not emit error',
    build: () {
      final MockVerifyPhoneOtpUseCase useCase = MockVerifyPhoneOtpUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async =>
            const Left<Failure, VerifyPhoneOtpResponse>(CancelledFailure()),
      );
      return VerifyPhoneOtpCubit(useCase);
    },
    act: (VerifyPhoneOtpCubit cubit) => cubit.fVerifyPhoneOtp(
      dialingCode: '+966',
      phone: '500000000',
      code: kValidOtpCode,
      purpose: OtpPurpose.phoneSignIn,
    ),
    expect: () => <VerifyPhoneOtpState>[const ApiCallLoading<AuthOutcome?>()],
  );
}
