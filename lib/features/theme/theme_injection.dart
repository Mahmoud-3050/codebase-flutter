import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import 'data/datasources/theme_local_data_source.dart';
import 'data/repositories/theme_repository_impl.dart';
import 'domain/repositories/theme_repository.dart';
import 'domain/usecases/change_theme.dart';
import 'domain/usecases/get_saved_theme.dart';
import 'presentation/cubit/theme_cubit/theme_cubit.dart';

Future<void> initThemeFeatureInjection() async {
  /// Cubits
  ServiceLocator.instance.registerLazySingleton(() => 
      ThemeCubit(
        changeThemeUseCase: ServiceLocator.instance(), 
        getSavedThemeUseCase: ServiceLocator.instance(),
      )
  );

  /// UseCases
  ServiceLocator.instance.registerLazySingleton(
      () => GetSavedThemeUseCase(repository: ServiceLocator.instance()));
  ServiceLocator.instance.registerLazySingleton(
      () => ChangeThemeUseCase(repository: ServiceLocator.instance()));

  /// Repository
  ServiceLocator.instance.registerLazySingleton<ThemeRepository>(() =>
      ThemeRepositoryImpl(themeLocalDataSource: ServiceLocator.instance()));

  /// DataSource
  ServiceLocator.instance.registerLazySingleton<ThemeLocalDataSource>(
      () => ThemeLocalDataSourceImpl());
}

/// BlocProviders
List<BlocProvider> get themeBlocs => <BlocProvider>[
  BlocProvider<ThemeCubit>(
    create: (BuildContext context) => ServiceLocator.instance<ThemeCubit>(),
  ),
];
