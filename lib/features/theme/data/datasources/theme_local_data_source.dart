import '../../../../core/utils/enums.dart';
import '../../../../injection_container.dart';

abstract class ThemeLocalDataSource {
  Future<void> changeTheme({required Themes theme});
  Future<Themes> getSavedTheme();
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {

  ThemeLocalDataSourceImpl();

  @override
  Future<void> changeTheme({required Themes theme}) async =>
      await sharedPreferencesService.saveAppTheme(theme);

  @override
  Future<Themes> getSavedTheme() async =>
      sharedPreferencesService.getAppTheme();
}
