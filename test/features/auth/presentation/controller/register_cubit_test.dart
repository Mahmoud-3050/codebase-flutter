import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/register_response.dart';
import 'package:codebase/features/auth/presentation/controller/register/register_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RegisterResponse>>(
      const Left<Failure, RegisterResponse>(ServerFailure()),
    );
  });

  blocTest<RegisterCubit, RegisterState>(
    'FR-008 emits Loading then Success',
    build: () {
      final MockRegisterUseCase useCase = MockRegisterUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, RegisterResponse>(
          RegisterResponse(
            status: 'success',
            message: 'ok',
            data: kEmailChallenge,
          ),
        ),
      );
      return RegisterCubit(useCase);
    },
    act: (RegisterCubit cubit) => cubit.fRegister(
      fullName: 'Ada',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
      password: 'secret12',
    ),
    expect: () => <RegisterState>[
      const ApiCallLoading<OtpChallenge>(),
      const ApiCallSuccess<OtpChallenge>(data: kEmailChallenge),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'FR-010 emits fieldErrors',
    build: () {
      final MockRegisterUseCase useCase = MockRegisterUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, RegisterResponse>(
          ValidationFailure(
            message: 'invalid',
            fieldErrors: <String, List<String>>{
              'email': <String>['taken'],
            },
          ),
        ),
      );
      return RegisterCubit(useCase);
    },
    act: (RegisterCubit cubit) => cubit.fRegister(
      fullName: 'Ada',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
      password: 'secret12',
    ),
    expect: () => <RegisterState>[
      const ApiCallLoading<OtpChallenge>(),
      const ApiCallError<OtpChallenge>(
        message: 'invalid',
        fieldErrors: <String, List<String>>{
          'email': <String>['taken'],
        },
      ),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'FR-049 connectivity shows no_internet',
    build: () {
      final MockRegisterUseCase useCase = MockRegisterUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, RegisterResponse>(NetworkFailure()),
      );
      return RegisterCubit(useCase);
    },
    act: (RegisterCubit cubit) => cubit.fRegister(
      fullName: 'Ada',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
      password: 'secret12',
    ),
    expect: () => <RegisterState>[
      const ApiCallLoading<OtpChallenge>(),
      ApiCallError<OtpChallenge>(message: Strings.noInternet),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'FR-008 cancel does not emit error',
    build: () {
      final MockRegisterUseCase useCase = MockRegisterUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, RegisterResponse>(CancelledFailure()),
      );
      return RegisterCubit(useCase);
    },
    act: (RegisterCubit cubit) => cubit.fRegister(
      fullName: 'Ada',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
      password: 'secret12',
    ),
    expect: () => <RegisterState>[const ApiCallLoading<OtpChallenge>()],
  );
}
