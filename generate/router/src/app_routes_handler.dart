import 'dart:io';
import '../../utils/constants.dart';

class AppRoutesHandler {
  static Future<bool> updateAppRoutes(
      String camelName, String snakeName) async {
    final File file = File('lib/config/routes/app_routes.dart');
    if (!file.existsSync()) return false;

    String content = await file.readAsString();
    if (content.contains('static const String $camelName')) return false;

    final String routePath = '/${snakeName.replaceAll('_', '-')}';
    final String newRoute =
        "  static const String $camelName = '$routePath';\n";

    int lastBrace = content.lastIndexOf('}');
    if (lastBrace != -1) {
      content = content.substring(0, lastBrace) +
          newRoute +
          content.substring(lastBrace);
      await file.writeAsString(content);
      print(
          '${GenerateConstants.greenColorCode}Added AppRoutes.$camelName${GenerateConstants.resetColorCode}');
      return true;
    }
    return false;
  }
}
