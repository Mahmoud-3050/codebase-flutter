import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class DatasourceFile extends ProjectFile {
  DatasourceFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln("import '../../../../core/usecases/usecase.dart';");
    for (final Request request in requests) {
      buffer.write(
        request.buffers.datasource
            .generateImports(
              featureNameSnakeCase: featureNames.snakeCase,
              requestNameSnakeCase: request.names.snakeCase,
              hasParams: request.params != null,
            )
            .toString(),
      );
    }

    buffer.writeln();
    buffer.writeln(
      'abstract class ${featureNames.classCase}RemoteDataSource {',
    );

    for (final Request request in requests) {
      final String func = request.buffers.datasource
          .generateBody(featureNames: featureNames, request: request)
          .toString()
          .split('***')
          .first;
      buffer.write(func);
    }
    buffer.writeln('}');

    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }

  @override
  Future<void> modify({
    required Names featureNames,
    required List<Request> requests,
  }) {
    return generate(featureNames: featureNames, requests: requests);
  }
}
