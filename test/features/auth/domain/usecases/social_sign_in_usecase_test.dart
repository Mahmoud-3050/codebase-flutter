import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/social_sign_in_response.dart';
import 'package:codebase/features/auth/domain/enums/social_provider.dart';
import 'package:codebase/features/auth/domain/usecases/social_sign_in_usecase.dart';

import '../../dummy_eithers.dart';
import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test('FR-030 SocialSignInUseCase passes SocialProvider.google', () async {
    final MockAuthRepository repository = MockAuthRepository();
    when(repository.socialSignIn(params: anyNamed('params'))).thenAnswer(
      (_) async => Right<Failure, SocialSignInResponse>(
        SocialSignInResponse(
          status: 'success',
          message: 'ok',
          data: AuthSessionEstablished(kSession),
        ),
      ),
    );
    await SocialSignInUseCase(repository: repository)(
      const SocialSignInParams(provider: SocialProvider.google),
    );
    final SocialSignInParams captured =
        verify(
              repository.socialSignIn(params: captureAnyNamed('params')),
            ).captured.single
            as SocialSignInParams;
    expect(captured.provider, SocialProvider.google);
  });
}
