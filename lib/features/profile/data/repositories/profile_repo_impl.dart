import 'package:either/either.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../core/utils/log_utils.dart';
import '../../../../core/error/failures.dart';
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

  ProfileRepositoryImpl({
    required this.remote,
  });

  /// Impl
  @override
  Future<Either<Failure, ChangeCompanyPasswordResponse>> changeCompanyPassword({required ChangeCompanyPasswordParams params}) async {
    try {
      final ChangeCompanyPasswordResponse response = await remote.changeCompanyPassword(params: params);
        return Right<Failure, ChangeCompanyPasswordResponse>(response);
      } on AppException catch (error) {
        Log.e('[changeCompanyPassword] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, ChangeCompanyPasswordResponse>(error.toFailure());
      }
  }


  @override
  Future<Either<Failure, UpdateCompanyUserProfileResponse>> updateCompanyUserProfile({required UpdateCompanyUserProfileParams params}) async {
    try {
      final UpdateCompanyUserProfileResponse response = await remote.updateCompanyUserProfile(params: params);
        return Right<Failure, UpdateCompanyUserProfileResponse>(response);
      } on AppException catch (error) {
        Log.e('[updateCompanyUserProfile] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, UpdateCompanyUserProfileResponse>(error.toFailure());
      }
  }


  @override
  Future<Either<Failure, ChangeStudentPasswordResponse>> changeStudentPassword({required ChangeStudentPasswordParams params}) async {
    try {
      final ChangeStudentPasswordResponse response = await remote.changeStudentPassword(params: params);
        return Right<Failure, ChangeStudentPasswordResponse>(response);
      } on AppException catch (error) {
        Log.e('[changeStudentPassword] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, ChangeStudentPasswordResponse>(error.toFailure());
      }
  }


  @override
  Future<Either<Failure, GetCompanyProfileResponse>> getCompanyProfile({required NoParams params}) async {
    try {
      final GetCompanyProfileResponse response = await remote.getCompanyProfile();
        return Right<Failure, GetCompanyProfileResponse>(response);
      } on AppException catch (error) {
        Log.e('[getCompanyProfile] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, GetCompanyProfileResponse>(error.toFailure());
      }
  }


  @override
  Future<Either<Failure, GetStudentProfileResponse>> getStudentProfile({required NoParams params}) async {
    try {
      final GetStudentProfileResponse response = await remote.getStudentProfile();
        return Right<Failure, GetStudentProfileResponse>(response);
      } on AppException catch (error) {
        Log.e('[getStudentProfile] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, GetStudentProfileResponse>(error.toFailure());
      }
  }


  @override
  Future<Either<Failure, UpdateCompanyProfileResponse>> updateCompanyProfile({required UpdateCompanyProfileParams params}) async {
    try {
      final UpdateCompanyProfileResponse response = await remote.updateCompanyProfile(params: params);
        return Right<Failure, UpdateCompanyProfileResponse>(response);
      } on AppException catch (error) {
        Log.e('[updateCompanyProfile] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, UpdateCompanyProfileResponse>(error.toFailure());
      }
  }


  @override
  Future<Either<Failure, UpdateStudentProfileResponse>> updateStudentProfile({required UpdateStudentProfileParams params}) async {
    try {
      final UpdateStudentProfileResponse response = await remote.updateStudentProfile(params: params);
        return Right<Failure, UpdateStudentProfileResponse>(response);
      } on AppException catch (error) {
        Log.e('[updateStudentProfile] [${error.runtimeType.toString()}] ---- ${error.message}');
        return Left<Failure, UpdateStudentProfileResponse>(error.toFailure());
      }
  }


}

