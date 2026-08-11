import 'package:app_language/app_language.dart';
import 'package:field_validator/field_validator.dart';
import 'package:flutter/material.dart' hide RouteFactory;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/enums.dart';
import 'features/theme/presentation/cubit/theme_cubit/theme_cubit.dart';
import 'features/theme/theme_injection.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ...themeBlocs,
        BlocProvider<LanguageCubit>(
          create: (_) => ServiceLocator.instance<LanguageCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState themState) {
          return LanguageBuilder(
            listener: (context, state) {
              // Sync FieldValidator locale on language state change
              FieldValidator.instance.setLocale(
                ValidatorLocale.fromCode(state.language.code),
              );

              // Update Dio headers on language state change
              dioConsumer.updateLanguageCodeHeader();
            },
            builder: (context, language, locale) {
              return ScreenUtilInit(
                designSize: const Size(393, 852),
                minTextAdapt: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    title: 'Base Project',
                    theme: getAppTheme(context: context, isLightTheme: true),
                    darkTheme: getAppTheme(context: context, isLightTheme: false),
                    themeMode: themState.theme == Themes.light
                        ? ThemeMode.light
                        : ThemeMode.dark,
                    locale: locale,
                    supportedLocales: AppLocalizationsSetup.supportedLocales,
                    localeResolutionCallback:
                        AppLocalizationsSetup.localeResolutionCallback,
                    localizationsDelegates:
                        AppLocalizationsSetup.localizationsDelegates,
                    routerConfig: AppRouter.router,
                    debugShowCheckedModeBanner: false,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
