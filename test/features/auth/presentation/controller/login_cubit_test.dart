import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/login_outcome.dart';
import 'package:codebase/features/auth/domain/entities/login_response.dart';
import 'package:codebase/features/auth/presentation/controller/login/login_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, LoginResponse>>(
      const Left<Failure, LoginResponse>(ServerFailure()),
    );
  });

  blocTest<LoginCubit, LoginState>(
    'FR-015 emits LoginSucceeded',
    build: () {
      final MockLoginUseCase useCase = MockLoginUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, LoginResponse>(
          LoginResponse(
            status: 'success',
            message: 'ok',
            data: LoginSucceeded(kSession),
          ),
        ),
      );
      return LoginCubit(useCase);
    },
    act: (LoginCubit cubit) =>
        cubit.fLogin(email: 'a@b.c', password: 'secret12'),
    expect: () => <LoginState>[
      const ApiCallLoading<LoginOutcome>(),
      ApiCallSuccess<LoginOutcome>(data: LoginSucceeded(kSession)),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'FR-017 emits LoginNeedsEmailVerification',
    build: () {
      final MockLoginUseCase useCase = MockLoginUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, LoginResponse>(
          LoginResponse(
            status: 'success',
            message: 'ok',
            data: LoginNeedsEmailVerification(kEmailChallenge),
          ),
        ),
      );
      return LoginCubit(useCase);
    },
    act: (LoginCubit cubit) =>
        cubit.fLogin(email: 'a@b.c', password: 'secret12'),
    expect: () => <LoginState>[
      const ApiCallLoading<LoginOutcome>(),
      const ApiCallSuccess<LoginOutcome>(
        data: LoginNeedsEmailVerification(kEmailChallenge),
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'FR-016 invalid_credentials for unauthorized',
    build: () {
      final MockLoginUseCase useCase = MockLoginUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, LoginResponse>(UnauthorizedFailure()),
      );
      return LoginCubit(useCase);
    },
    act: (LoginCubit cubit) => cubit.fLogin(email: 'a@b.c', password: 'wrong'),
    expect: () => <LoginState>[
      const ApiCallLoading<LoginOutcome>(),
      ApiCallError<LoginOutcome>(message: Strings.invalidCredentials),
    ],
  );
}
