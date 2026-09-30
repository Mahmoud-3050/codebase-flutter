import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/login_outcome.dart';
import 'package:codebase/features/auth/domain/entities/login_response.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';

import '../../dummy_eithers.dart';
import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test('FR-015 LoginParams.toJson', () {
    const LoginParams params = LoginParams(
      email: 'ada@example.com',
      password: 'secret12',
    );
    expect(params.toJson(), <String, dynamic>{
      'email': 'ada@example.com',
      'password': 'secret12',
    });
  });

  test('FR-015 LoginUseCase pass-through', () async {
    final MockAuthRepository repository = MockAuthRepository();
    when(repository.login(params: anyNamed('params'))).thenAnswer(
      (_) async => Right<Failure, LoginResponse>(
        LoginResponse(
          status: 'success',
          message: 'ok',
          data: LoginSucceeded(kSession),
        ),
      ),
    );
    final Either<Failure, LoginResponse> result = await LoginUseCase(
      repository: repository,
    )(const LoginParams(email: 'ada@example.com', password: 'secret12'));
    expect(result.isRight, isTrue);
  });
}
