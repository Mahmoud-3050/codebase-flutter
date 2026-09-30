import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/reset_password_response.dart';
import 'package:codebase/features/auth/presentation/controller/reset_password/reset_password_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, ResetPasswordResponse>>(
      const Left<Failure, ResetPasswordResponse>(ServerFailure()),
    );
  });

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'FR-046c emits success',
    build: () {
      final MockResetPasswordUseCase useCase = MockResetPasswordUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, ResetPasswordResponse>(
          ResetPasswordResponse(
            status: 'success',
            message: 'ok',
            data: kSession,
          ),
        ),
      );
      return ResetPasswordCubit(useCase);
    },
    act: (ResetPasswordCubit cubit) => cubit.fResetPassword(
      email: 'a@b.c',
      code: kValidOtpCode,
      password: 'secret12',
    ),
    expect: () => <ResetPasswordState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallSuccess<AuthSession>(data: kSession),
    ],
  );

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'FR-046c FR-007 password field 422 is not invalid_code',
    build: () {
      final MockResetPasswordUseCase useCase = MockResetPasswordUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, ResetPasswordResponse>(
          ValidationFailure(
            fieldErrors: <String, List<String>>{
              'password': <String>['weak'],
            },
          ),
        ),
      );
      return ResetPasswordCubit(useCase);
    },
    act: (ResetPasswordCubit cubit) => cubit.fResetPassword(
      email: 'a@b.c',
      code: kValidOtpCode,
      password: 'secret12',
    ),
    expect: () => <ResetPasswordState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallError<AuthSession>(
        message: Strings.pleaseTryAgainLater,
        fieldErrors: const <String, List<String>>{
          'password': <String>['weak'],
        },
      ),
    ],
  );
}
