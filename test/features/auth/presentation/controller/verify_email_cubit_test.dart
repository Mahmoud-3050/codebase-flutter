import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/verify_email_response.dart';
import 'package:codebase/features/auth/presentation/controller/verify_email/verify_email_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, VerifyEmailResponse>>(
      const Left<Failure, VerifyEmailResponse>(ServerFailure()),
    );
  });

  blocTest<VerifyEmailCubit, VerifyEmailState>(
    'FR-011 emits success session',
    build: () {
      final MockVerifyEmailUseCase useCase = MockVerifyEmailUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => Right<Failure, VerifyEmailResponse>(
          VerifyEmailResponse(status: 'success', message: 'ok', data: kSession),
        ),
      );
      return VerifyEmailCubit(useCase);
    },
    act: (VerifyEmailCubit cubit) =>
        cubit.fVerifyEmail(email: 'a@b.c', code: kValidOtpCode),
    expect: () => <VerifyEmailState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallSuccess<AuthSession>(data: kSession),
    ],
  );

  blocTest<VerifyEmailCubit, VerifyEmailState>(
    'FR-013 emits error',
    build: () {
      final MockVerifyEmailUseCase useCase = MockVerifyEmailUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, VerifyEmailResponse>(
          ServerFailure(message: 'bad'),
        ),
      );
      return VerifyEmailCubit(useCase);
    },
    act: (VerifyEmailCubit cubit) =>
        cubit.fVerifyEmail(email: 'a@b.c', code: '000000'),
    expect: () => <VerifyEmailState>[
      const ApiCallLoading<AuthSession>(),
      ApiCallError<AuthSession>(
        message: Strings.invalidCode,
        fieldErrors: <String, List<String>>{
          'code': <String>[Strings.invalidCode],
        },
      ),
    ],
  );
}
