import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/social_sign_in_response.dart';
import 'package:codebase/features/auth/domain/enums/social_provider.dart';
import 'package:codebase/features/auth/presentation/controller/social_sign_in/social_sign_in_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, SocialSignInResponse>>(
      const Left<Failure, SocialSignInResponse>(ServerFailure()),
    );
  });

  blocTest<SocialSignInCubit, SocialSignInState>(
    'FR-030 session success',
    build: () {
      final MockSocialSignInUseCase useCase = MockSocialSignInUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, SocialSignInResponse>(
          SocialSignInResponse(
            status: 'success',
            message: 'ok',
            data: AuthSessionEstablished(kSession),
          ),
        ),
      );
      return SocialSignInCubit(useCase);
    },
    act: (SocialSignInCubit cubit) =>
        cubit.fSocialSignIn(SocialProvider.google),
    expect: () => <SocialSignInState>[
      const ApiCallLoading<AuthOutcome>(),
      ApiCallSuccess<AuthOutcome>(data: AuthSessionEstablished(kSession)),
    ],
  );

  blocTest<SocialSignInCubit, SocialSignInState>(
    'FR-031 registration required',
    build: () {
      final MockSocialSignInUseCase useCase = MockSocialSignInUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, SocialSignInResponse>(
          SocialSignInResponse(
            status: 'success',
            message: 'ok',
            data: AuthRegistrationRequired(kGoogleDraft),
          ),
        ),
      );
      return SocialSignInCubit(useCase);
    },
    act: (SocialSignInCubit cubit) =>
        cubit.fSocialSignIn(SocialProvider.google),
    expect: () => <SocialSignInState>[
      const ApiCallLoading<AuthOutcome>(),
      const ApiCallSuccess<AuthOutcome>(
        data: AuthRegistrationRequired(kGoogleDraft),
      ),
    ],
  );

  blocTest<SocialSignInCubit, SocialSignInState>(
    'FR-035 silent cancel does not emit error',
    build: () {
      final MockSocialSignInUseCase useCase = MockSocialSignInUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, SocialSignInResponse>(
          SocialSignInCancelledFailure(),
        ),
      );
      return SocialSignInCubit(useCase);
    },
    act: (SocialSignInCubit cubit) =>
        cubit.fSocialSignIn(SocialProvider.google),
    expect: () => <SocialSignInState>[
      const ApiCallLoading<AuthOutcome>(),
      const ApiCallHolding<AuthOutcome>(),
    ],
  );

  blocTest<SocialSignInCubit, SocialSignInState>(
    'FR-035a surfaces social_failed',
    build: () {
      final MockSocialSignInUseCase useCase = MockSocialSignInUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, SocialSignInResponse>(
          ServerFailure(message: 'boom'),
        ),
      );
      return SocialSignInCubit(useCase);
    },
    act: (SocialSignInCubit cubit) =>
        cubit.fSocialSignIn(SocialProvider.google),
    expect: () => <SocialSignInState>[
      const ApiCallLoading<AuthOutcome>(),
      const ApiCallError<AuthOutcome>(message: 'boom'),
    ],
  );

  blocTest<SocialSignInCubit, SocialSignInState>(
    'FR-029 Apple session vs draft vs cancel',
    build: () {
      final MockSocialSignInUseCase useCase = MockSocialSignInUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, SocialSignInResponse>(
          SocialSignInResponse(
            status: 'success',
            message: 'ok',
            data: AuthSessionEstablished(kSession),
          ),
        ),
      );
      return SocialSignInCubit(useCase);
    },
    act: (SocialSignInCubit cubit) => cubit.fSocialSignIn(SocialProvider.apple),
    expect: () => <SocialSignInState>[
      const ApiCallLoading<AuthOutcome>(),
      ApiCallSuccess<AuthOutcome>(data: AuthSessionEstablished(kSession)),
    ],
  );
}
