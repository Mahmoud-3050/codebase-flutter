import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/presentation/controller/guest_mode/guest_mode_cubit.dart';

import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, void>>(
      const Left<Failure, void>(ServerFailure()),
    );
  });

  blocTest<GuestModeCubit, GuestModeState>(
    'FR-037 emits success',
    build: () {
      final MockContinueAsGuestUseCase useCase = MockContinueAsGuestUseCase();
      when(
        useCase.call(any),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return GuestModeCubit(useCase);
    },
    act: (GuestModeCubit cubit) => cubit.fContinueAsGuest(),
    expect: () => <GuestModeState>[
      const ApiCallLoading<bool>(),
      const ApiCallSuccess<bool>(data: true),
    ],
  );
}
