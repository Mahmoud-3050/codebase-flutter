// ignore_for_file: avoid_print
import 'dart:io';
import '../../utils/constants.dart';

class AppRouterHandler {
  static const String appRouterPath = 'lib/config/routes/app_router.dart';

  /// Register a feature in app_router.dart (export, import, routes spread).
  static Future<bool> registerFeatureInAppRouter(String feature) async {
    final File file = File(appRouterPath);
    if (!file.existsSync()) return false;

    String content = await file.readAsString();
    bool changed = false;

    final String exportLine =
        "export '../../features/$feature/presentation/navigation/router.dart' hide \$appRoutes;";
    final String importLine =
        "import '../../features/$feature/presentation/navigation/router.dart' as $feature;";
    final String routeSpread = '      ...$feature.\$appRoutes,';

    // 1. Add export if not present
    if (!content.contains(
      "features/$feature/presentation/navigation/router.dart' hide",
    )) {
      // Insert export after last existing export or after package imports
      int insertPos = _findExportInsertPosition(content);
      content =
          '${content.substring(0, insertPos)}$exportLine\n${content.substring(insertPos)}';
      changed = true;
    }

    // 2. Add import if not present
    if (!content.contains(
      "features/$feature/presentation/navigation/router.dart' as $feature",
    )) {
      int insertPos = _findImportInsertPosition(content);
      content =
          '${content.substring(0, insertPos)}$importLine\n${content.substring(insertPos)}';
      changed = true;
    }

    // 3. Add route spread in routes list if not present
    if (!content.contains('...$feature.\$appRoutes')) {
      int routesIndex = content.indexOf('routes: [');
      if (routesIndex != -1) {
        int bracketStart = content.indexOf('[', routesIndex);
        if (bracketStart != -1) {
          content =
              '${content.substring(0, bracketStart + 1)}\n$routeSpread${content.substring(bracketStart + 1)}';
          changed = true;
        }
      }
    }

    if (changed) {
      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      await file.writeAsString(content);
      print(
        '${GenerateConstants.greenColorCode}Registered feature $feature in app_router.dart${GenerateConstants.resetColorCode}',
      );
    }

    return changed;
  }

  /// Cleanup a feature from app_router.dart when it has no more routes.
  static Future<void> cleanupFeatureFromAppRouter(String feature) async {
    final File file = File(appRouterPath);
    if (!file.existsSync()) return;

    String content = await file.readAsString();
    bool changed = false;

    // Remove Export
    final RegExp exportRegex = RegExp(
      "export\\s+'.*?features\\/$feature\\/presentation\\/navigation\\/router\\.dart'\\s+hide\\s+\\\$appRoutes;\\s*\\n?",
      multiLine: true,
    );
    if (exportRegex.hasMatch(content)) {
      content = content.replaceFirst(exportRegex, '');
      changed = true;
    }

    // Remove Import
    final RegExp importRegex = RegExp(
      "import\\s+'.*?features\\/$feature\\/presentation\\/navigation\\/router\\.dart'\\s+as\\s+$feature;\\s*\\n?",
      multiLine: true,
    );
    if (importRegex.hasMatch(content)) {
      content = content.replaceFirst(importRegex, '');
      changed = true;
    }

    // Remove from Routes list
    final RegExp routeRegex = RegExp(
      '\\s*\\.\\.\\.$feature\\.\\s*\\\$appRoutes,?\\s*\\n?',
      multiLine: true,
    );
    if (routeRegex.hasMatch(content)) {
      content = content.replaceFirst(routeRegex, '\n');
      changed = true;
    }

    if (changed) {
      content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
      await file.writeAsString(content);
      print(
        '${GenerateConstants.greenColorCode}Cleaned up feature $feature from app_router.dart${GenerateConstants.resetColorCode}',
      );
    }
  }

  /// Find position to insert an export line (after last export, or after imports).
  static int _findExportInsertPosition(String content) {
    // After last export line
    int lastExport = content.lastIndexOf(
      RegExp(r"^export\s+'", multiLine: true),
    );
    if (lastExport != -1) {
      int endOfLine = content.indexOf('\n', lastExport);
      return endOfLine + 1;
    }
    // After last import line
    int lastImport = content.lastIndexOf(
      RegExp(r"^import\s+'", multiLine: true),
    );
    if (lastImport != -1) {
      int endOfLine = content.indexOf('\n', lastImport);
      return endOfLine + 1;
    }
    return 0;
  }

  /// Find position to insert an import line (after last import before class).
  static int _findImportInsertPosition(String content) {
    // Find the last import line before the class definition
    int classIndex = content.indexOf('class AppRouter');
    String beforeClass = classIndex != -1
        ? content.substring(0, classIndex)
        : content;

    int lastImport = beforeClass.lastIndexOf(
      RegExp(r"^import\s+'", multiLine: true),
    );
    if (lastImport != -1) {
      int endOfLine = beforeClass.indexOf('\n', lastImport);
      return endOfLine + 1;
    }
    return 0;
  }
}
