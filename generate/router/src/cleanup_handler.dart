import 'dart:io';
import '../../utils/constants.dart';
import '../../utils/names_helper.dart';
import 'router_utils.dart';
import 'app_router_handler.dart';

class CleanupHandler {
  static Future<bool> cleanupOldRoute(
    String feature,
    String screenClass,
    String screenSnake,
  ) async {
    bool changed = false;
    final String routerPath =
        'lib/features/$feature/presentation/navigation/router.dart';
    final File routerFile = File(routerPath);

    if (routerFile.existsSync()) {
      String content = await routerFile.readAsString();
      int initialLen = content.length;

      final String screenBase = screenClass
          .replaceAll('Screen', '')
          .replaceAll('Page', '');

      // Try multiple class name patterns
      content = RouterUtils.removeBlock(
        content,
        'class ${NamesHelper.snakeToClassCase(feature)}${screenClass}Route',
      );
      content = RouterUtils.removeBlock(
        content,
        'class ${NamesHelper.snakeToClassCase(feature)}${screenBase}Route',
      );
      content = RouterUtils.removeBlock(content, 'class ${screenClass}Route');
      content = RouterUtils.removeBlock(content, 'class ${screenBase}Route');

      // Remove Import
      content = content.replaceFirst(
        "import '../pages/$screenSnake.dart';",
        '',
      );
      content = content.replaceFirst(
        "import '../pages/${screenSnake.replaceAll('_screen', '')}.dart';",
        '',
      );
      content = content.replaceFirst(
        "import '../pages/${screenSnake.replaceAll('_page', '')}.dart';",
        '',
      );

      // Remove old navigation methods (to, go, push)
      content = content.replaceAll(
        RegExp(
          'void (to|go|push)$screenBase\\s*\\(.*?\\)\\s*(=>|{).*?;',
          dotAll: true,
        ),
        '',
      );

      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

      if (content.length != initialLen) {
        await routerFile.writeAsString(content);
        print(
          '${GenerateConstants.greenColorCode}Removed $screenClass from $routerPath${GenerateConstants.resetColorCode}',
        );
        changed = true;
      }

      // Check if feature has no more routes (even if user manually cleaned)
      if (!content.contains('@TypedGoRoute')) {
        bool featureChanged = false;

        // Remove part directive
        String updatedContent = content.replaceAll(
          RegExp(r"part\s+'router\.g\.dart';\s*\n?"),
          '',
        );
        if (updatedContent.length != content.length) {
          featureChanged = true;
          content = updatedContent;
        }

        if (featureChanged) {
          content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
          await routerFile.writeAsString(content);
          changed = true;
        }

        // Delete the .g.dart file
        final File gFile = File(
          'lib/features/$feature/presentation/navigation/router.g.dart',
        );
        if (gFile.existsSync()) {
          gFile.deleteSync();
          print(
            '${GenerateConstants.greenColorCode}Deleted router.g.dart for $feature${GenerateConstants.resetColorCode}',
          );
          changed = true;
        }

        print(
          '${GenerateConstants.orangeColorCode}Feature $feature has no more routes. Cleaning up app_router.dart...${GenerateConstants.resetColorCode}',
        );
        await AppRouterHandler.cleanupFeatureFromAppRouter(feature);
      }
    }

    final String screenPath =
        'lib/features/$feature/presentation/pages/$screenSnake.dart';
    final File screenFile = File(screenPath);
    if (screenFile.existsSync()) {
      screenFile.deleteSync();
      print(
        '${GenerateConstants.greenColorCode}Deleted old screen file $screenPath${GenerateConstants.resetColorCode}',
      );
      changed = true;
    }

    return changed;
  }

  static Future<bool> cleanupAppRouteConstant(String camelName) async {
    final File file = File('lib/config/routes/app_routes.dart');
    if (!file.existsSync()) return false;

    String content = await file.readAsString();
    bool changed = false;

    final List<String> variations = [
      camelName,
      camelName.replaceAll('Screen', '').replaceAll('Page', ''),
    ];

    for (var v in variations) {
      final String pattern = 'static const String $v = \'.*?\';';
      final RegExp regex = RegExp(pattern);
      if (regex.hasMatch(content)) {
        content = content.replaceFirst(regex, '');
        changed = true;
      }
    }

    if (changed) {
      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      await file.writeAsString(content);
      print(
        '${GenerateConstants.greenColorCode}Removed AppRoutes constant(s)${GenerateConstants.resetColorCode}',
      );
      return true;
    }
    return false;
  }
}
