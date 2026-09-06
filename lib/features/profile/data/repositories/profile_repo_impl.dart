import 'package:either/either.dart';

import '../../../../core/data/repository_guard.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../domain/entities/change_company_password_response.dart';
import '../../domain/entities/change_student_password_response.dart';
import '../../domain/entities/get_company_profile_response.dart';
import '../../domain/entities/get_student_profile_response.dart';
import '../../domain/entities/update_company_profile_response.dart';
import '../../domain/entities/update_company_user_profile_response.dart';
import '../../domain/entities/update_student_profile_response.dart';
import '../../domain/repositories/profile_repo.dart';

class ProfileRepositoryImpl with RepositoryGuard implements ProfileRepository {
  ProfileRepositoryImpl({required this.remote});

  final ProfileRemoteDataSource remote;

  @override
  Future<Either<Failure, ChangeCompanyPasswordResponse>> changeCompanyPassword({
    required Params params,
  }) => guard(
    () => remote.changeCompanyPassword(params: params),
    'changeCompanyPassword',
  );

  @override
  Future<Either<Failure, UpdateCompanyUserProfileResponse>>
  updateCompanyUserProfile({required Params params}) => guard(
    () => remote.updateCompanyUserProfile(params: params),
    'updateCompanyUserProfile',
  );

  @override
  Future<Either<Failure, ChangeStudentPasswordResponse>> changeStudentPassword({
    required Params params,
  }) => guard(
    () => remote.changeStudentPassword(params: params),
    'changeStudentPassword',
  );

  @override
  Future<Either<Failure, GetCompanyProfileResponse>> getCompanyProfile({
    required Params params,
  }) => guard(
    () => remote.getCompanyProfile(params: params),
    'getCompanyProfile',
  );

  @override
  Future<Either<Failure, GetStudentProfileResponse>> getStudentProfile({
    required Params params,
  }) => guard(
    () => remote.getStudentProfile(params: params),
    'getStudentProfile',
  );

  @override
  Future<Either<Failure, UpdateCompanyProfileResponse>> updateCompanyProfile({
    required Params params,
  }) => guard(
    () => remote.updateCompanyProfile(params: params),
    'updateCompanyProfile',
  );

  @override
  Future<Either<Failure, UpdateStudentProfileResponse>> updateStudentProfile({
    required Params params,
  }) => guard(
    () => remote.updateStudentProfile(params: params),
    'updateStudentProfile',
  );
}
