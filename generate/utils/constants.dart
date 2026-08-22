abstract class GenerateConstants {
  //print_colors
  static const String blueColorCode = '\x1B[34m';
  static const String orangeColorCode = '\x1B[33m';
  static const String redColorCode = '\x1B[31m';
  static const String greenColorCode = '\x1B[32m';
  static const String resetColorCode = '\x1B[0m';
  //generate_strings
  static const String langJsonAssetFilePath = 'generate/strings/lang.json';
  static const String langAssetsDirectory = 'assets/lang';
  static const String langEnJsonAssetFilePath = '$langAssetsDirectory/en.json';
  static const String langArJsonAssetFilePath = '$langAssetsDirectory/ar.json';
  static const String outputStringsFilePath =
      'lib/config/language/strings.dart';
  //generate_colors
  static const String colorsJsonAssetFilePath = 'generate/colors/colors.json';
  static const String outputColorsPalettesFilePath =
      'lib/config/themes/colors_palettes.dart';
  static const String outputExtraColorsFilePath =
      'lib/config/themes/extra_colors.dart';
  //generate_features
  static const String projectFeaturesPath = 'lib/features';
  static const String requestsAssetsPath = 'generate/requests';
}
