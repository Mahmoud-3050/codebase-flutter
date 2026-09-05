import 'package:either/either.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../core/utils/log_utils.dart';
import '../../../../core/error/failures.dart';
import '../../../../config/language/strings.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../domain/repositories/profile_repo.dart';
import '../../domain/entities/change_company_password_response.dart';
import '../../domain/usecases/change_company_password_usecase.dart';
import '../../domain/entities/update_company_user_profile_response.dart';
import '../../domain/usecases/update_company_user_profile_usecase.dart';
import '../../domain/entities/change_student_password_response.dart';
import '../../domain/usecases/change_student_password_usecase.dart';
import '../../domain/entities/get_company_profile_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/get_student_profile_response.dart';
import '../../domain/entities/update_company_profile_response.dart';
import '../../domain/usecases/update_company_profile_usecase.dart';
import '../../domain/entities/update_student_profile_response.dart';
import '../../domain/usecases/update_student_profile_usecase.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl({required this.remote});

  Future<Either<Failure, T>> _guard<T>(
    Future<T> Function() call,
    String operation,
  ) async {
    try {
      final T response = await call();
      return Right<Failure, T>(response);
    } on AppException catch (error) {
      Log.e('[$operation] [${error.runtimeType}] ---- ${error.message}');
      return Left<Failure, T>(error.toFailure());
    } on Object catch (error, stackTrace) {
      Log.e('[$operation] [${error.runtimeType}] ---- $error\n$stackTrace');
      return Left<Failure, T>(
        ServerFailure(message: Strings.pleaseTryAgainLater),
      );
    }
  }

  @override
  Future<Either<Failure, ChangeCompanyPasswordResponse>> changeCompanyPassword({
    required ChangeCompanyPasswordParams params,
  }) => _guard(
    () => remote.changeCompanyPassword(params: params),
    'changeCompanyPassword',
  );

  @override
  Future<Either<Failure, UpdateCompanyUserProfileResponse>>
  updateCompanyUserProfile({required UpdateCompanyUserProfileParams params}) =>
      _guard(
        () => remote.updateCompanyUserProfile(params: params),
        'updateCompanyUserProfile',
      );

  @override
  Future<Either<Failure, ChangeStudentPasswordResponse>> changeStudentPassword({
    required ChangeStudentPasswordParams params,
  }) => _guard(
    () => remote.changeStudentPassword(params: params),
    'changeStudentPassword',
  );

  @override
  Future<Either<Failure, GetCompanyProfileResponse>> getCompanyProfile({
    required CancellableParams params,
  }) => _guard(
    () => remote.getCompanyProfile(cancellation: params.cancellation),
    'getCompanyProfile',
  );

  @override
  Future<Either<Failure, GetStudentProfileResponse>> getStudentProfile({
    required CancellableParams params,
  }) => _guard(
    () => remote.getStudentProfile(cancellation: params.cancellation),
    'getStudentProfile',
  );

  @override
  Future<Either<Failure, UpdateCompanyProfileResponse>> updateCompanyProfile({
    required UpdateCompanyProfileParams params,
  }) => _guard(
    () => remote.updateCompanyProfile(params: params),
    'updateCompanyProfile',
  );

  @override
  Future<Either<Failure, UpdateStudentProfileResponse>> updateStudentProfile({
    required UpdateStudentProfileParams params,
  }) => _guard(
    () => remote.updateStudentProfile(params: params),
    'updateStudentProfile',
  );
}
