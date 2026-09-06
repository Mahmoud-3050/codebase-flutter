import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class InjectionFile extends ProjectFile {
  InjectionFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln("import 'package:get_it/get_it.dart';");
    buffer.writeln();
    buffer.writeln(
      "import 'data/datasources/${featureNames.snakeCase}_remote_datasource.dart';",
    );
    buffer.writeln(
      "import 'data/datasources/${featureNames.snakeCase}_remote_datasource_impl.dart';",
    );
    buffer.writeln(
      "import 'data/repositories/${featureNames.snakeCase}_repo_impl.dart';",
    );
    buffer.writeln(
      "import 'domain/repositories/${featureNames.snakeCase}_repo.dart';",
    );

    for (final Request request in requests) {
      buffer.write(
        request.buffers.injection
            .generateImports(requestNameSnakeCase: request.names.snakeCase)
            .toString(),
      );
    }

    buffer.writeln();
    buffer.writeln(
      'void register${featureNames.classCase}DataLayer(GetIt sl) {',
    );
    buffer.writeln(
      '  sl.registerLazySingleton<${featureNames.classCase}RemoteDataSource>(() => ${featureNames.classCase}RemoteDataSourceImpl());',
    );
    buffer.writeln(
      '  sl.registerLazySingleton<${featureNames.classCase}Repository>(() => ${featureNames.classCase}RepositoryImpl(remote: sl()));',
    );
    buffer.writeln('}');
    buffer.writeln();

    for (final Request request in requests) {
      buffer.writeln(
        request.buffers.injection
            .generateBody(featureNames: featureNames, request: request)
            .toString(),
      );
    }

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
