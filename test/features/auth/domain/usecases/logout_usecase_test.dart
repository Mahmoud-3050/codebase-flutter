import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/features/auth/domain/entities/logout_response.dart';
import 'package:codebase/features/auth/domain/usecases/logout_usecase.dart';

import '../../dummy_eithers.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test('FR-043 LogoutUseCase delegates', () async {
    final MockAuthRepository repository = MockAuthRepository();
    when(repository.logout(params: anyNamed('params'))).thenAnswer(
      (_) async => const Right<Failure, LogoutResponse>(
        LogoutResponse(status: 'success', message: ''),
      ),
    );
    expect(
      (await LogoutUseCase(repository: repository)(const NoParams())).isRight,
      isTrue,
    );
  });
}
