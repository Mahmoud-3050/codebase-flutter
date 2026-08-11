import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/values/strings.dart';
import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../../../injection_container.dart';
import '../../../domain/usecases/change_theme.dart';
import '../../../domain/usecases/get_saved_theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final GetSavedThemeUseCase getSavedThemeUseCase;
  final ChangeThemeUseCase changeThemeUseCase;

  ThemeCubit(
      {required this.getSavedThemeUseCase, required this.changeThemeUseCase})
      : super(ThemeState(theme: sharedPreferencesService.getAppTheme()));

  Themes currentTheme = sharedPreferencesService.getAppTheme();
  bool get isDarkMode => currentTheme == Themes.dark;

  Future<void> getSavedTheme() async {
    final response = await getSavedThemeUseCase(NoParams());
    response.fold(
      (failure) {
        emit(ThemeState(
          theme: currentTheme,
          errorMessage: failure.message ?? Strings.pleaseTryAgainLater,
        ));
      },
      (value) {
        currentTheme = value;
        ServiceLocator.injectAppTheme(currentTheme);
        emit(ThemeState(theme: currentTheme));
      },
    );
  }

  Future<void> changeTheme({
    required BuildContext context,
    required Themes theme,
  }) async {
    final response = await changeThemeUseCase(theme);
    response.fold(
      (failure) {
        showAppSnackBar(
            context: context,
            message: Strings.pleaseTryAgainLater,
            type: ToastType.error,
        );
      },
      (value) {
        currentTheme = theme;
        ServiceLocator.injectAppTheme(currentTheme);
        ServiceLocator.injectAppColors(context, theme: currentTheme);
        emit(ThemeState(theme: currentTheme));
      },
    );
  }
}
