import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/core/utils/values/strings.dart';
import 'package:codebase/features/profile/data/repositories/profile_repo_impl.dart';
import 'package:codebase/features/profile/domain/entities/get_student_profile_response.dart';

import '../../mocks.mocks.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource remote;

  setUp(() {
    remote = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remote: remote);
  });

  group('getStudentProfile', () {
    test('returns Left when remote throws AppException', () async {
      when(remote.getStudentProfile()).thenThrow(
        const ServerException(message: 'Server error'),
      );

      final Either<Failure, GetStudentProfileResponse> result =
          await repository.getStudentProfile(params: NoParams());

      expect(result.isLeft, isTrue);
      result.fold(
        (Failure failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left when remote throws non-AppException', () async {
      when(remote.getStudentProfile()).thenThrow(TypeError());

      final Either<Failure, GetStudentProfileResponse> result =
          await repository.getStudentProfile(params: NoParams());

      expect(result.isLeft, isTrue);
      result.fold(
        (Failure failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, Strings.pleaseTryAgainLater);
        },
        (_) => fail('Expected Left'),
      );
    });
  });
}
