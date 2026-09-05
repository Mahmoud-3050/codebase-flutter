import 'package:flutter/material.dart' hide RouteFactory;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:language/language.dart';
import 'package:themes/themes.dart';

import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'features/profile/profile_injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [...profileBlocs],
      child: ThemeBuilder(
        builder: (context, themes) {
          return LanguageBuilder(
            builder: (context, language, locale) {
              return ScreenUtilInit(
                designSize: const Size(393, 852),
                minTextAdapt: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    title: 'Base Project',
                    theme: appTheme(themes.lightColors, .light),
                    darkTheme: appTheme(themes.darkColors, .dark),
                    themeMode: themes.mode,
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
