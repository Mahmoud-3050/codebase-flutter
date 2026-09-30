import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/registration_draft.dart';
import 'package:codebase/features/auth/presentation/controller/read_registration_draft/read_registration_draft_cubit.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RegistrationDraft?>>(
      const Right<Failure, RegistrationDraft?>(null),
    );
  });

  blocTest<ReadRegistrationDraftCubit, ReadRegistrationDraftState>(
    'FR-026 emits stored draft',
    build: () {
      final MockReadRegistrationDraftUseCase useCase =
          MockReadRegistrationDraftUseCase();
      when(useCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, RegistrationDraft?>(kPhoneDraft),
      );
      return ReadRegistrationDraftCubit(useCase);
    },
    act: (ReadRegistrationDraftCubit cubit) => cubit.fReadRegistrationDraft(),
    expect: () => <ReadRegistrationDraftState>[
      const ApiCallLoading<RegistrationDraft?>(),
      const ApiCallSuccess<RegistrationDraft?>(data: kPhoneDraft),
    ],
  );

  blocTest<ReadRegistrationDraftCubit, ReadRegistrationDraftState>(
    'FR-026 emits null when no draft is stored',
    build: () {
      final MockReadRegistrationDraftUseCase useCase =
          MockReadRegistrationDraftUseCase();
      when(
        useCase.call(any),
      ).thenAnswer((_) async => const Right<Failure, RegistrationDraft?>(null));
      return ReadRegistrationDraftCubit(useCase);
    },
    act: (ReadRegistrationDraftCubit cubit) => cubit.fReadRegistrationDraft(),
    expect: () => <ReadRegistrationDraftState>[
      const ApiCallLoading<RegistrationDraft?>(),
      const ApiCallSuccess<RegistrationDraft?>(data: null),
    ],
  );
}
