import 'dart:convert';
import 'dart:io';

import '../utils/constants.dart';
import 'src/processor.dart';
import 'src/build_executor.dart';

void main() async {
  final File jsonFile = File('generate/router/router.json');
  if (!jsonFile.existsSync()) {
    print(
      '${GenerateConstants.redColorCode}Error: router.json not found!${GenerateConstants.resetColorCode}',
    );
    return;
  }

  final dynamic jsonData;
  try {
    jsonData = jsonDecode(jsonFile.readAsStringSync());
  } catch (e) {
    print(
      '${GenerateConstants.redColorCode}Error: Invalid JSON in router.json - $e${GenerateConstants.resetColorCode}',
    );
    return;
  }

  List<Map<String, dynamic>> routeConfigs = [];

  if (jsonData is List) {
    routeConfigs = List<Map<String, dynamic>>.from(jsonData);
  } else if (jsonData is Map) {
    routeConfigs = [Map<String, dynamic>.from(jsonData)];
  } else {
    print(
      '${GenerateConstants.redColorCode}Error: Invalid JSON format. Expected Object or List.${GenerateConstants.resetColorCode}',
    );
    return;
  }

  bool globalChanged = false;

  for (var config in routeConfigs) {
    bool routeChanged = await RouteProcessor.processRoute(config);
    if (routeChanged) globalChanged = true;
  }

  if (!globalChanged) {
    print(
      '${GenerateConstants.orangeColorCode}No changes were made. Skipping build_runner.${GenerateConstants.resetColorCode}',
    );
    return;
  }

  await BuildExecutor.runBuildRunner();
}
