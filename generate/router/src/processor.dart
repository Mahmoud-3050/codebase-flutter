// ignore_for_file: avoid_print
import '../../features/models/names.dart';
import '../../utils/constants.dart';
import '../../utils/names_helper.dart';
import 'cleanup_handler.dart';
import 'app_routes_handler.dart';
import 'app_router_handler.dart';
import 'feature_router_handler.dart';
import 'screen_generator.dart';
import 'global_checker.dart';

class RouteProcessor {
  static Future<bool> processRoute(Map<String, dynamic> data) async {
    final Names featureNames;
    final Names screenNames;
    Names? oldFeatureNames;
    Names? oldScreenNames;

    try {
      featureNames = Names.fromString(data['feature']);
      screenNames = Names.fromString(data['screen']);
      if (data['old_feature'] != null) {
        oldFeatureNames = Names.fromString(data['old_feature']);
      }
      if (data['old_screen'] != null) {
        oldScreenNames = Names.fromString(data['old_screen']);
      }
    } catch (e) {
      print(
        '${GenerateConstants.redColorCode}Configuration Error: $e${GenerateConstants.resetColorCode}',
      );
      return false;
    }

    Map<String, dynamic> argsMap = {};
    if (data['args'] != null && data['args'] is Map) {
      argsMap = .from(data['args']);
    }

    final String featureName = featureNames.snakeCase;
    final String screenClass = screenNames.classCase;
    final String screenSnake = screenNames.snakeCase;

    Names? routeNames;
    if (data['route'] != null) {
      routeNames = Names.fromString(data['route']);
    }

    final String uniqueRouteClass =
        '${routeNames?.classCase ?? screenClass}Route';
    final String uniqueAppRouteConstant =
        routeNames?.camelCase ?? NamesHelper.classToCamelCase(screenClass);
    final String routePathValue =
        routeNames?.dashedCase ?? screenNames.dashedCase;

    print(
      '${GenerateConstants.blueColorCode}Processing route update for $screenClass in feature $featureName...${GenerateConstants.resetColorCode}',
    );

    bool changed = false;

    // 0. Handle Mode (6. Delete)
    if (data['delete'] == true) {
      print(
        '${GenerateConstants.redColorCode}Mode: Delete. Removing $screenClass from $featureName...${GenerateConstants.resetColorCode}',
      );
      changed = await CleanupHandler.cleanupOldRoute(
        featureName,
        screenClass,
        screenSnake,
      );
      if (await CleanupHandler.cleanupAppRouteConstant(
        uniqueAppRouteConstant,
      )) {
        changed = true;
      }
      return changed;
    }

    // 1. Handle "Old" Cleanup (Move or Rename)
    if (oldFeatureNames != null || oldScreenNames != null) {
      final String searchScreen = (oldScreenNames ?? screenNames).classCase;
      final String searchFeature = (oldFeatureNames ?? featureNames).snakeCase;

      print(
        '${GenerateConstants.blueColorCode}Cleaning up old definition of $searchScreen in $searchFeature...${GenerateConstants.resetColorCode}',
      );
      bool cleaned = await CleanupHandler.cleanupOldRoute(
        searchFeature,
        searchScreen,
        (oldScreenNames ?? screenNames).snakeCase,
      );
      if (cleaned) changed = true;
    }

    // 2. Global Check for existing
    final existingInfo = await GlobalChecker.findScreenDefinitionGlobally(
      screenClass,
    );
    if (existingInfo != null) {
      final String existingFeature = existingInfo['feature']!;
      if (existingFeature != featureName) {
        print(
          '${GenerateConstants.orangeColorCode}Screen $screenClass is already routed in feature $existingFeature. Use "old_feature" if you want to move it.${GenerateConstants.resetColorCode}',
        );
        return changed;
      }
    }

    // 3. Update AppRoutes
    if (await AppRoutesHandler.updateAppRoutes(
      uniqueAppRouteConstant,
      routePathValue,
    )) {
      changed = true;
    }

    // 4. Update/Create Feature Router
    if (await FeatureRouterHandler.updateFeatureRouter(
      featureName,
      screenClass,
      screenSnake,
      uniqueAppRouteConstant,
      uniqueRouteClass,
      argsMap,
    )) {
      changed = true;
    }

    // 5. Register feature in app_router.dart (export, import, routes)
    if (await AppRouterHandler.registerFeatureInAppRouter(featureName)) {
      changed = true;
    }

    // 6. Generate/Update Screen File
    if (await ScreenGenerator.generateScreenFile(
      featureName,
      screenClass,
      screenSnake,
      argsMap,
    )) {
      changed = true;
    }

    return changed;
  }
}
