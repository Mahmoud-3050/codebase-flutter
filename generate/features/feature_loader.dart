import 'dart:convert';
import 'dart:io';

import '../utils/console_logger.dart';
import '../utils/constants.dart';
import 'models/feature.dart';
import 'models/feature_paths.dart';
import 'models/request.dart';

abstract class FeatureLoader {
  static Feature? load(String featureName) {
    try {
      Feature? feature = Feature.fromString(featureName);

      final FeaturePaths paths = FeaturePaths.fromFeatureName(feature.names);
      final Directory requestsDirectory = Directory(paths.featureJsonFilesPath);

      final List<File> jsonFiles = _getJsonFiles(requestsDirectory).toList();
      final List<Map<String, dynamic>> jsonFilesData =
          _getJsonFilesData(jsonFiles);

      final List<Request> requests = _getFeatureRequests(
        jsonFiles: jsonFiles,
        jsonFilesData: jsonFilesData,
        featureProjectPath: paths.featureProjectPath,
      );

      return feature.copyWith(
        jsonFiles: jsonFiles,
        jsonMaps: jsonFilesData,
        requests: requests,
      );
    } on PathNotFoundException {
      ConsoleLogger.error(
        'EXCEPTION: [Directory not found], path = ${GenerateConstants.requestsAssetsPath}/$featureName/',
      );
      return null;
    } catch (e) {
      ConsoleLogger.error('EXCEPTION loading feature: $e');
      return null;
    }
  }

  static Iterable<File> _getJsonFiles(Directory directory) {
    if (!directory.existsSync()) return const [];
    return directory.listSync().whereType<File>().where((File file) {
      final String fileName = file.path.split('/').last;
      return fileName.endsWith('.json') && fileName != 'settings.json';
    });
  }

  static List<Map<String, dynamic>> _getJsonFilesData(
      Iterable<File> jsonFiles) {
    final List<Map<String, dynamic>> jsonDataList = [];
    for (final File file in jsonFiles) {
      final String jsonContent = file.readAsStringSync();
      final Map<String, dynamic> jsonData =
          jsonDecode(jsonContent) as Map<String, dynamic>;
      jsonDataList.add(jsonData);
    }
    return jsonDataList;
  }

  static List<Request> _getFeatureRequests({
    required List<File> jsonFiles,
    required List<Map<String, dynamic>> jsonFilesData,
    required String featureProjectPath,
  }) {
    final List<Request> requests = <Request>[];
    for (int i = 0; i < jsonFilesData.length; i++) {
      requests.add(
        Request.init(
          file: jsonFiles[i],
          featureProjectPath: featureProjectPath,
          json: jsonFilesData[i],
        ),
      );
    }
    return requests;
  }
}
