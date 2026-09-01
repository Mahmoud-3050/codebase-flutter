import 'dart:io';

import '../../utils/constants.dart';
import '../files/project_files/datasource/datasource_file.dart';
import '../files/project_files/injection/injection_file.dart';
import '../files/project_files/repository/repository_file.dart';
import '../files/project_files/repository_impl/repository_impl_file.dart';
import '../models/feature.dart';
import '../models/request.dart';
import 'generate_feature_files.dart';

abstract class ModifyFeature {
  static Future<void> modifyFeature({
    required Feature feature,
    required List<Request> requests,
  }) async {
    final Directory projectRoot = Directory.current;
    final String featurePath =
        '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/${feature.names.snakeCase}';

    for (final Request request in requests) {
      GenerateFeature.generateSingleRequestFiles(
        feature: feature,
        request: request,
      );
    }

    DatasourceFile(
      file: File(
        '$featurePath/data/datasources/${feature.names.snakeCase}_remote_datasource.dart',
      ),
    ).modify(featureNames: feature.names, requests: requests);

    RepositoryFile(
      file: File(
        '$featurePath/domain/repositories/${feature.names.snakeCase}_repo.dart',
      ),
    ).modify(featureNames: feature.names, requests: requests);

    RepositoryImplFile(
      file: File(
        '$featurePath/data/repositories/${feature.names.snakeCase}_repo_impl.dart',
      ),
    ).modify(featureNames: feature.names, requests: requests);

    InjectionFile(
      file: File('$featurePath/${feature.names.snakeCase}_injection.dart'),
    ).modify(featureNames: feature.names, requests: requests);
  }
}
