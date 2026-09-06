import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class DatasourceImplFile extends ProjectFile {
  DatasourceImplFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln("import '../../../../core/api/api_response.dart';");
    buffer.writeln("import '../../../../core/api/request_cancel_token.dart';");
    buffer.writeln("import '../../../../core/error/exceptions.dart';");
    buffer.writeln("import '../../../../core/usecases/usecase.dart';");
    buffer.writeln("import '../../../../injection_container.dart';");
    buffer.writeln(
      "import '${featureNames.snakeCase}_remote_datasource.dart';",
    );
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
      'class ${featureNames.classCase}RemoteDataSourceImpl implements ${featureNames.classCase}RemoteDataSource {',
    );

    for (final Request request in requests) {
      final String funcImpl = request.buffers.datasource
          .generateBody(featureNames: featureNames, request: request)
          .toString()
          .split('***')
          .last;
      buffer.write(funcImpl);
    }
    buffer.writeln('}');

    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }

  @override
  Future<void> modify({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    if (requests.isEmpty) {
      return;
    }

    final List<String> lines = file.readAsLinesSync();
    final StringBuffer buffer = StringBuffer();

    for (final String line in lines) {
      if (line.contains('implements')) {
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
      }

      buffer.writeln(line);

      if (line.contains('implements')) {
        for (final Request request in requests) {
          final String funcImpl = request.buffers.datasource
              .generateBody(featureNames: featureNames, request: request)
              .toString()
              .split('***')
              .last;
          buffer.write(funcImpl);
        }
      }
    }

    await file.writeAsString(buffer.toString());
  }
}
