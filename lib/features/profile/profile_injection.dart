import 'package:get_it/get_it.dart';

import 'data/datasources/profile_remote_datasource.dart';
import 'data/datasources/profile_remote_datasource_impl.dart';
import 'data/repositories/profile_repo_impl.dart';
import 'domain/repositories/profile_repo.dart';
import 'domain/usecases/change_company_password_usecase.dart';
import 'domain/usecases/change_student_password_usecase.dart';
import 'domain/usecases/get_company_profile_usecase.dart';
import 'domain/usecases/get_student_profile_usecase.dart';
import 'domain/usecases/update_company_profile_usecase.dart';
import 'domain/usecases/update_company_user_profile_usecase.dart';
import 'domain/usecases/update_student_profile_usecase.dart';
import 'presentation/controller/change_company_password/change_company_password_cubit.dart';
import 'presentation/controller/change_student_password/change_student_password_cubit.dart';
import 'presentation/controller/get_company_profile/get_company_profile_cubit.dart';
import 'presentation/controller/get_student_profile/get_student_profile_cubit.dart';
import 'presentation/controller/update_company_profile/update_company_profile_cubit.dart';
import 'presentation/controller/update_company_user_profile/update_company_user_profile_cubit.dart';
import 'presentation/controller/update_student_profile/update_student_profile_cubit.dart';

void registerProfileDataLayer(GetIt sl) {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remote: sl()),
  );
}

void registerChangeCompanyPassword(GetIt sl) {
  sl.registerFactory<ChangeCompanyPasswordCubit>(
    () => ChangeCompanyPasswordCubit(sl()),
  );
  sl.registerLazySingleton<ChangeCompanyPasswordUseCase>(
    () => ChangeCompanyPasswordUseCase(repository: sl()),
  );
}

void registerUpdateCompanyUserProfile(GetIt sl) {
  sl.registerFactory<UpdateCompanyUserProfileCubit>(
    () => UpdateCompanyUserProfileCubit(sl()),
  );
  sl.registerLazySingleton<UpdateCompanyUserProfileUseCase>(
    () => UpdateCompanyUserProfileUseCase(repository: sl()),
  );
}

void registerChangeStudentPassword(GetIt sl) {
  sl.registerFactory<ChangeStudentPasswordCubit>(
    () => ChangeStudentPasswordCubit(sl()),
  );
  sl.registerLazySingleton<ChangeStudentPasswordUseCase>(
    () => ChangeStudentPasswordUseCase(repository: sl()),
  );
}

void registerGetCompanyProfile(GetIt sl) {
  sl.registerFactory<GetCompanyProfileCubit>(
    () => GetCompanyProfileCubit(sl()),
  );
  sl.registerLazySingleton<GetCompanyProfileUseCase>(
    () => GetCompanyProfileUseCase(repository: sl()),
  );
}

void registerGetStudentProfile(GetIt sl) {
  sl.registerFactory<GetStudentProfileCubit>(
    () => GetStudentProfileCubit(sl()),
  );
  sl.registerLazySingleton<GetStudentProfileUseCase>(
    () => GetStudentProfileUseCase(repository: sl()),
  );
}

void registerUpdateCompanyProfile(GetIt sl) {
  sl.registerFactory<UpdateCompanyProfileCubit>(
    () => UpdateCompanyProfileCubit(sl()),
  );
  sl.registerLazySingleton<UpdateCompanyProfileUseCase>(
    () => UpdateCompanyProfileUseCase(repository: sl()),
  );
}

void registerUpdateStudentProfile(GetIt sl) {
  sl.registerFactory<UpdateStudentProfileCubit>(
    () => UpdateStudentProfileCubit(sl()),
  );
  sl.registerLazySingleton<UpdateStudentProfileUseCase>(
    () => UpdateStudentProfileUseCase(repository: sl()),
  );
}
