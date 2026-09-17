import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/presentation/controller/resolve_visitor_state/resolve_visitor_state_cubit.dart';

import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, UserType>>(
      const Left<Failure, UserType>(ServerFailure()),
    );
  });

  blocTest<ResolveVisitorStateCubit, ResolveVisitorStateState>(
    'FR-002 emits firstOpen',
    build: () {
      final MockResolveVisitorStateUseCase useCase =
          MockResolveVisitorStateUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, UserType>(UserType.firstOpen),
      );
      return ResolveVisitorStateCubit(useCase);
    },
    act: (ResolveVisitorStateCubit cubit) => cubit.fResolveVisitorState(),
    expect: () => <ResolveVisitorStateState>[
      const ApiCallLoading<UserType>(),
      const ApiCallSuccess<UserType>(data: UserType.firstOpen),
    ],
  );

  blocTest<ResolveVisitorStateCubit, ResolveVisitorStateState>(
    'FR-004 draft-only is not emitted as loggedIn',
    build: () {
      final MockResolveVisitorStateUseCase useCase =
          MockResolveVisitorStateUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, UserType>(UserType.firstOpen),
      );
      return ResolveVisitorStateCubit(useCase);
    },
    act: (ResolveVisitorStateCubit cubit) => cubit.fResolveVisitorState(),
    expect: () => <ResolveVisitorStateState>[
      const ApiCallLoading<UserType>(),
      const ApiCallSuccess<UserType>(data: UserType.firstOpen),
    ],
  );

  blocTest<ResolveVisitorStateCubit, ResolveVisitorStateState>(
    'FR-002 emits error',
    build: () {
      final MockResolveVisitorStateUseCase useCase =
          MockResolveVisitorStateUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async =>
            const Left<Failure, UserType>(CacheFailure(message: 'cache')),
      );
      return ResolveVisitorStateCubit(useCase);
    },
    act: (ResolveVisitorStateCubit cubit) => cubit.fResolveVisitorState(),
    expect: () => <ResolveVisitorStateState>[
      const ApiCallLoading<UserType>(),
      const ApiCallError<UserType>(message: 'cache'),
    ],
  );
}
