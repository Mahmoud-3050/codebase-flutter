import 'package:language/language.dart';
import 'package:flutter/material.dart' hide RouteFactory;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/enums.dart';
import 'features/profile/profile_injection.dart';
import 'features/theme/presentation/cubit/theme_cubit/theme_cubit.dart';
import 'features/theme/theme_injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ...themeBlocs,
        ...profileBlocs,
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (BuildContext context, ThemeState themState) {
          return LanguageBuilder(
            builder: (context, language, locale) {
              return ScreenUtilInit(
                designSize: const Size(393, 852),
                minTextAdapt: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    title: 'Base Project',
                    theme: getAppTheme(context: context, isLightTheme: true),
                    darkTheme:
                        getAppTheme(context: context, isLightTheme: false),
                    themeMode: themState.theme == Themes.light
                        ? ThemeMode.light
                        : ThemeMode.dark,
                    locale: locale,
                    supportedLocales: LanguageLocalizationsSetup.supportedLocales,
                    localeResolutionCallback:
                        LanguageLocalizationsSetup.localeResolutionCallback,
                    localizationsDelegates:
                        LanguageLocalizationsSetup.localizationsDelegates,
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
