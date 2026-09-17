import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/complete_registration_response.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';
import 'package:codebase/features/auth/presentation/controller/complete_registration/complete_registration_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, CompleteRegistrationResponse>>(
      const Left<Failure, CompleteRegistrationResponse>(ServerFailure()),
    );
  });

  blocTest<CompleteRegistrationCubit, CompleteRegistrationState>(
    'FR-025 emits success',
    build: () {
      final MockCompleteRegistrationUseCase useCase =
          MockCompleteRegistrationUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, CompleteRegistrationResponse>(
          CompleteRegistrationResponse(
            status: 'success',
            message: 'ok',
            data: kSession,
          ),
        ),
      );
      return CompleteRegistrationCubit(useCase);
    },
    act: (CompleteRegistrationCubit cubit) => cubit.fCompleteRegistration(
      registrationToken: 'tok',
      source: RegistrationSource.phone,
      fullName: 'Ada',
      password: 'secret12',
      email: 'ada@example.com',
    ),
    expect: () => <CompleteRegistrationState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallSuccess<AuthSession>(data: kSession),
    ],
  );

  blocTest<CompleteRegistrationCubit, CompleteRegistrationState>(
    'FR-026a conflict maps to draft_expired',
    build: () {
      final MockCompleteRegistrationUseCase useCase =
          MockCompleteRegistrationUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, CompleteRegistrationResponse>(
          ServerFailure(statusCode: StatusCode.conflict),
        ),
      );
      return CompleteRegistrationCubit(useCase);
    },
    act: (CompleteRegistrationCubit cubit) => cubit.fCompleteRegistration(
      registrationToken: 'tok',
      source: RegistrationSource.phone,
      fullName: 'Ada',
      password: 'secret12',
    ),
    expect: () => <CompleteRegistrationState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallError<AuthSession>(message: Strings.draftExpired),
    ],
  );

  blocTest<CompleteRegistrationCubit, CompleteRegistrationState>(
    'FR-026a 422 maps to draft_expired',
    build: () {
      final MockCompleteRegistrationUseCase useCase =
          MockCompleteRegistrationUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, CompleteRegistrationResponse>(
          ValidationFailure(message: 'token expired'),
        ),
      );
      return CompleteRegistrationCubit(useCase);
    },
    act: (CompleteRegistrationCubit cubit) => cubit.fCompleteRegistration(
      registrationToken: 'tok',
      source: RegistrationSource.phone,
      fullName: 'Ada',
      password: 'secret12',
    ),
    expect: () => <CompleteRegistrationState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallError<AuthSession>(message: Strings.draftExpired),
    ],
  );
}
