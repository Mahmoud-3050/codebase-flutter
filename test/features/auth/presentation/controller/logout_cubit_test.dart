import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/logout_response.dart';
import 'package:codebase/features/auth/presentation/controller/logout/logout_cubit.dart';

import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, LogoutResponse>>(
      const Left<Failure, LogoutResponse>(ServerFailure()),
    );
  });

  blocTest<LogoutCubit, LogoutState>(
    'FR-043 emits success',
    build: () {
      final MockLogoutUseCase useCase = MockLogoutUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, LogoutResponse>(
          LogoutResponse(status: 'success', message: ''),
        ),
      );
      return LogoutCubit(useCase);
    },
    act: (LogoutCubit cubit) => cubit.fLogout(),
    expect: () => <LogoutState>[
      const ApiCallLoading<bool>(),
      const ApiCallSuccess<bool>(data: true),
    ],
  );

  blocTest<LogoutCubit, LogoutState>(
    'FR-043 cancel is ignored',
    build: () {
      final MockLogoutUseCase useCase = MockLogoutUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, LogoutResponse>(CancelledFailure()),
      );
      return LogoutCubit(useCase);
    },
    act: (LogoutCubit cubit) => cubit.fLogout(),
    expect: () => <LogoutState>[const ApiCallLoading<bool>()],
  );

  test('FR-043 closed logout cubit does not emit success', () async {
    final MockLogoutUseCase useCase = MockLogoutUseCase();
    when(useCase.call(any)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return const Right<Failure, LogoutResponse>(
        LogoutResponse(status: 'success', message: ''),
      );
    });
    final LogoutCubit cubit = LogoutCubit(useCase);
    final Future<void> pending = cubit.fLogout();
    await cubit.close();
    await pending;
  });
}
