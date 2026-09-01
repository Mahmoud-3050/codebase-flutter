import 'dart:convert';
import 'dart:io';

import '../../utils/enums.dart';
import '../../utils/extension.dart';
import '../files/project_files/datasource/datasource_request_buffers.dart';
import '../files/project_files/injection/injection_request_buffers.dart';
import '../files/project_files/repository/repository_request_buffers.dart';
import '../files/project_files/repository_impl/repository_impl_request_buffers.dart';
import '../files/request_files/cubit_test/cubit_test_buffers.dart';
import '../files/request_files/datasource_test/datasource_test_buffers.dart';
import '../files/request_files/repository_test/repository_test_buffers.dart';
import '../files/request_files/usecase_test/usecase_test_buffers.dart';
import '../files/request_files/cubit/cubit_buffers.dart';
import '../files/request_files/cubit_states/cubit_states_buffers.dart';
import '../files/request_files/entity/entity_buffers.dart';
import '../files/request_files/model/model_buffers.dart';
import '../files/request_files/usecase/usecase_buffers.dart';
import 'endpoint.dart';
import 'names.dart';
import 'request_buffers.dart';
import 'request_files.dart';

class Request {
  final File file;
  final Names names;
  final Names modelClassNames;
  final DartType? dartType;
  final Endpoint endpoint;
  final RequestType type;
  final bool hasToken;
  final Map<String, dynamic>? params;
  final Map<String, dynamic> response;
  final RequestBuffers buffers;
  final RequestFiles files;
  final ModeType mode;

  const Request({
    required this.file,
    required this.names,
    required this.modelClassNames,
    required this.dartType,
    required this.endpoint,
    required this.type,
    required this.hasToken,
    required this.response,
    required this.buffers,
    required this.files,
    required this.mode,
    this.params,
  });

  factory Request.init({
    required File file,
    required String featureProjectPath,
    required Map<String, dynamic> json,
  }) {
    final Names names = Names.fromString(json['name']?.toString() ?? '');
    final Names modelClassNames = _resolveModelClassNames(
      names,
      json['model_class'],
    );

    DartType? dartType;
    if (json['response'] != null && json['response']['data'] != null) {
      dartType = DartTypeExtension.fromType(value: json['response']['data']);
    }

    final String originalEndpoint = json['endpoint']?.toString() ?? '';
    final Endpoint endpointModel = Endpoint(
      endpoint: originalEndpoint,
      hasParams: json['params'] != null,
      hasQueryParams: false,
      terms: const [],
    );

    final String testProjectPath = featureProjectPath.replaceAll(
      'lib/features',
      'test/features',
    );

    final RequestBuffers buffers = _buildRequestBuffers();
    final RequestFiles files = _buildRequestFiles(
      featureProjectPath: featureProjectPath,
      testProjectPath: testProjectPath,
      names: names,
    );

    final int modeInt = (json['mode'] as num?)?.toInt() ?? 1;
    final ModeType modeType = ModeType.fromCode(modeInt);

    return Request(
      file: file,
      names: names,
      modelClassNames: modelClassNames,
      dartType: dartType,
      endpoint: endpointModel,
      type:
          RequestTypeExtension.fromString(json['type']?.toString() ?? '') ??
          RequestType.get,
      hasToken: (json['token'] as bool?) ?? false,
      params: json['params'] as Map<String, dynamic>?,
      response:
          (json['response'] as Map<String, dynamic>?) ??
          <String, dynamic>{'status': true, 'message': '', 'data': null},
      buffers: buffers,
      files: files,
      mode: modeType,
    );
  }

  void markAsProtected() {
    final Map<String, dynamic> jsonMap =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    jsonMap['mode'] = 0;
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonMap));
  }

  static Names _resolveModelClassNames(
    Names requestNames,
    dynamic rawModelClass,
  ) {
    if (rawModelClass != null && rawModelClass.toString().trim().isNotEmpty) {
      return Names.fromString(rawModelClass.toString());
    }
    return Names.fromString('${requestNames.snakeCase}_data');
  }

  static RequestBuffers _buildRequestBuffers() {
    return RequestBuffers(
      datasource: DatasourceRequestBuffers(),
      repository: RepositoryRequestBuffers(),
      repositoryImpl: RepositoryImplRequestBuffers(),
      entity: EntityRequestBuffers(),
      model: ModelRequestBuffers(),
      useCase: UseCaseRequestBuffers(),
      cubit: CubitRequestBuffers(),
      cubitStates: CubitStatesRequestBuffers(),
      cubitTest: CubitTestRequestBuffers(),
      useCaseTest: UseCaseTestRequestBuffers(),
      repositoryTest: RepositoryTestRequestBuffers(),
      datasourceTest: DatasourceTestRequestBuffers(),
      injection: InjectionRequestBuffers(),
    );
  }

  static RequestFiles _buildRequestFiles({
    required String featureProjectPath,
    required String testProjectPath,
    required Names names,
  }) {
    final String snake = names.snakeCase;
    return RequestFiles(
      entity: File(
        '$featureProjectPath/domain/entities/${snake}_response.dart',
      ),
      model: File('$featureProjectPath/data/models/${snake}_model.dart'),
      useCase: File(
        '$featureProjectPath/domain/usecases/${snake}_usecase.dart',
      ),
      cubit: File(
        '$featureProjectPath/presentation/controller/$snake/${snake}_cubit.dart',
      ),
      cubitStates: File(
        '$featureProjectPath/presentation/controller/$snake/${snake}_states.dart',
      ),
      cubitTest: File(
        '$testProjectPath/presentation/controller/$snake/${snake}_cubit_test.dart',
      ),
      useCaseTest: File(
        '$testProjectPath/domain/usecases/${snake}_usecase_test.dart',
      ),
      repositoryTest: File(
        '$testProjectPath/data/repositories/${snake}_repository_test.dart',
      ),
      datasourceTest: File(
        '$testProjectPath/data/datasources/${snake}_datasource_test.dart',
      ),
    );
  }
}
