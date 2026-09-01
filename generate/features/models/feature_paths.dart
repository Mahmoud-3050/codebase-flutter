import 'dart:io';

import '../../utils/constants.dart';
import 'names.dart';

class FeaturePaths {
  final Directory projectRoot;
  final String featureProjectPath;
  final String featureJsonFilesPath;

  const FeaturePaths({
    required this.projectRoot,
    required this.featureProjectPath,
    required this.featureJsonFilesPath,
  });

  factory FeaturePaths.fromFeatureName(Names featureNames) {
    final Directory projectRoot = .current;
    final String featureProjectPath =
        '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/${featureNames.snakeCase}';
    final String featureJsonFilesPath =
        '${GenerateConstants.requestsAssetsPath}/${featureNames.snakeCase}';

    return FeaturePaths(
      projectRoot: projectRoot,
      featureProjectPath: featureProjectPath,
      featureJsonFilesPath: featureJsonFilesPath,
    );
  }
}
