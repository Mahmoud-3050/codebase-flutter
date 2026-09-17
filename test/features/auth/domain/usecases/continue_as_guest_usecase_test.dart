import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/features/auth/domain/usecases/continue_as_guest_usecase.dart';

import '../../dummy_eithers.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test('FR-037 ContinueAsGuestUseCase delegates', () async {
    final MockAuthRepository repository = MockAuthRepository();
    when(
      repository.continueAsGuest(params: anyNamed('params')),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
    final Either<Failure, void> result = await ContinueAsGuestUseCase(
      repository: repository,
    )(const NoParams());
    expect(result.isRight, isTrue);
  });
}
