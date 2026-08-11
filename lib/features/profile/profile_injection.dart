import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import 'data/datasources/profile_remote_datasource.dart';
import 'data/repositories/profile_repo_impl.dart';
import 'domain/repositories/profile_repo.dart';
import 'domain/usecases/change_company_password_usecase.dart';
import 'presentation/controller/change_company_password/change_company_password_cubit.dart';
import 'domain/usecases/update_company_user_profile_usecase.dart';
import 'presentation/controller/update_company_user_profile/update_company_user_profile_cubit.dart';
import 'domain/usecases/change_student_password_usecase.dart';
import 'presentation/controller/change_student_password/change_student_password_cubit.dart';
import 'domain/usecases/get_company_profile_usecase.dart';
import 'presentation/controller/get_company_profile/get_company_profile_cubit.dart';
import 'domain/usecases/get_student_profile_usecase.dart';
import 'presentation/controller/get_student_profile/get_student_profile_cubit.dart';
import 'domain/usecases/update_company_profile_usecase.dart';
import 'presentation/controller/update_company_profile/update_company_profile_cubit.dart';
import 'domain/usecases/update_student_profile_usecase.dart';
import 'presentation/controller/update_student_profile/update_student_profile_cubit.dart';

final _sl = ServiceLocator.instance;

Future<void> initProfileFeatureInjection() async {
  ///-> Cubits
  _sl.registerFactory<ChangeCompanyPasswordCubit>(() => ChangeCompanyPasswordCubit(_sl()));
  _sl.registerFactory<UpdateCompanyUserProfileCubit>(() => UpdateCompanyUserProfileCubit(_sl()));
  _sl.registerFactory<ChangeStudentPasswordCubit>(() => ChangeStudentPasswordCubit(_sl()));
  _sl.registerFactory<GetCompanyProfileCubit>(() => GetCompanyProfileCubit(_sl()));
  _sl.registerFactory<GetStudentProfileCubit>(() => GetStudentProfileCubit(_sl()));
  _sl.registerFactory<UpdateCompanyProfileCubit>(() => UpdateCompanyProfileCubit(_sl()));
  _sl.registerFactory<UpdateStudentProfileCubit>(() => UpdateStudentProfileCubit(_sl()));

  ///-> UseCases
  _sl.registerLazySingleton<ChangeCompanyPasswordUseCase>(() => ChangeCompanyPasswordUseCase(repository: _sl()));
  _sl.registerLazySingleton<UpdateCompanyUserProfileUseCase>(() => UpdateCompanyUserProfileUseCase(repository: _sl()));
  _sl.registerLazySingleton<ChangeStudentPasswordUseCase>(() => ChangeStudentPasswordUseCase(repository: _sl()));
  _sl.registerLazySingleton<GetCompanyProfileUseCase>(() => GetCompanyProfileUseCase(repository: _sl()));
  _sl.registerLazySingleton<GetStudentProfileUseCase>(() => GetStudentProfileUseCase(repository: _sl()));
  _sl.registerLazySingleton<UpdateCompanyProfileUseCase>(() => UpdateCompanyProfileUseCase(repository: _sl()));
  _sl.registerLazySingleton<UpdateStudentProfileUseCase>(() => UpdateStudentProfileUseCase(repository: _sl()));

  ///-> Repository
  _sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remote: _sl()));

  ///-> DataSource
  _sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl());
}

  ///-> BlocProvider
List<BlocProvider> get profileBlocs => <BlocProvider>[
  BlocProvider<ChangeCompanyPasswordCubit>(
    create: (BuildContext context) => _sl<ChangeCompanyPasswordCubit>(),
  ),

  BlocProvider<UpdateCompanyUserProfileCubit>(
    create: (BuildContext context) => _sl<UpdateCompanyUserProfileCubit>(),
  ),

  BlocProvider<ChangeStudentPasswordCubit>(
    create: (BuildContext context) => _sl<ChangeStudentPasswordCubit>(),
  ),

  BlocProvider<GetCompanyProfileCubit>(
    create: (BuildContext context) => _sl<GetCompanyProfileCubit>(),
  ),

  BlocProvider<GetStudentProfileCubit>(
    create: (BuildContext context) => _sl<GetStudentProfileCubit>(),
  ),

  BlocProvider<UpdateCompanyProfileCubit>(
    create: (BuildContext context) => _sl<UpdateCompanyProfileCubit>(),
  ),

  BlocProvider<UpdateStudentProfileCubit>(
    create: (BuildContext context) => _sl<UpdateStudentProfileCubit>(),
  ),
];
