import 'dart:io';

import '../../utils/constants.dart';
import '../../utils/functions.dart';
import '../files/project_files/datasource/datasource_file.dart';
import '../files/project_files/datasource/datasource_impl_file.dart';
import '../files/project_files/injection/injection_file.dart';
import '../files/project_files/repository/repository_file.dart';
import '../files/project_files/repository_impl/repository_impl_file.dart';
import '../files/request_files/cubit/cubit_file.dart';
import '../files/request_files/cubit_test/cubit_test_file.dart';
import '../files/request_files/datasource_test/datasource_test_file.dart';
import '../files/request_files/entity/entity_file.dart';
import '../files/request_files/model/model_file.dart';
import '../files/request_files/repository_test/repository_test_file.dart';
import '../files/request_files/usecase/usecase_file.dart';
import '../files/request_files/usecase_test/usecase_test_file.dart';
import '../models/feature.dart';
import '../models/request.dart';

abstract class GenerateFeature {
  static Future<void> generateFeature({
    required Feature feature,
    bool generateTest = false,
  }) async {
    for (final Request request in feature.activeRequests) {
      generateSingleRequestFiles(
        feature: feature,
        request: request,
        generateTest: generateTest,
      );
    }

    await generateProjectFiles(
      feature: feature,
      requests: feature.activeRequests,
    );
  }

  static Future<void> generateProjectFiles({
    required Feature feature,
    required List<Request> requests,
  }) async {
    final Directory projectRoot = .current;
    final String featurePath =
        '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/${feature.names.snakeCase}';

    await DatasourceFile(
      file: File(
        '$featurePath/data/datasources/${feature.names.snakeCase}_remote_datasource.dart',
      ),
    ).generate(featureNames: feature.names, requests: requests);

    await DatasourceImplFile(
      file: File(
        '$featurePath/data/datasources/${feature.names.snakeCase}_remote_datasource_impl.dart',
      ),
    ).generate(featureNames: feature.names, requests: requests);

    await RepositoryFile(
      file: File(
        '$featurePath/domain/repositories/${feature.names.snakeCase}_repo.dart',
      ),
    ).generate(featureNames: feature.names, requests: requests);

    await RepositoryImplFile(
      file: File(
        '$featurePath/data/repositories/${feature.names.snakeCase}_repo_impl.dart',
      ),
    ).generate(featureNames: feature.names, requests: requests);

    await InjectionFile(
      file: File('$featurePath/${feature.names.snakeCase}_injection.dart'),
    ).generate(featureNames: feature.names, requests: requests);
  }

  static void generateSingleRequestFiles({
    required Feature feature,
    required Request request,
    bool generateTest = false,
  }) {
    EntityFile(
      file: request.files.entity,
    ).generate(featureNames: feature.names, request: request);

    ModelFile(
      file: request.files.model,
    ).generate(featureNames: feature.names, request: request);

    UseCaseFile(
      file: request.files.useCase,
    ).generate(featureNames: feature.names, request: request);

    createDirectory(request.files.cubit.path.parentDirectoryPath);
    CubitFile(
      file: request.files.cubit,
    ).generate(featureNames: feature.names, request: request);

    if (generateTest) {
      createDirectory(request.files.cubitTest.path.parentDirectoryPath);
      CubitTestFile(
        file: request.files.cubitTest,
      ).generate(featureNames: feature.names, request: request);

      createDirectory(request.files.useCaseTest.path.parentDirectoryPath);
      UseCaseTestFile(
        file: request.files.useCaseTest,
      ).generate(featureNames: feature.names, request: request);

      createDirectory(request.files.repositoryTest.path.parentDirectoryPath);
      RepositoryTestFile(
        file: request.files.repositoryTest,
      ).generate(featureNames: feature.names, request: request);

      createDirectory(request.files.datasourceTest.path.parentDirectoryPath);
      DatasourceTestFile(
        file: request.files.datasourceTest,
      ).generate(featureNames: feature.names, request: request);
    }

    request.markAsProtected();
  }
}
