import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class RepositoryImplFile extends ProjectFile {
  RepositoryImplFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln("import 'package:either/either.dart';");
    buffer.writeln();
    buffer.writeln("import '../../../../core/data/repository_guard.dart';");
    buffer.writeln("import '../../../../core/error/failures.dart';");
    buffer.writeln("import '../../../../core/usecases/usecase.dart';");
    buffer.writeln(
      "import '../../data/datasources/${featureNames.snakeCase}_remote_datasource.dart';",
    );
    buffer.writeln(
      "import '../../domain/repositories/${featureNames.snakeCase}_repo.dart';",
    );

    ///-> Func imports
    for (Request request in requests) {
      List<String> importsLines = request.buffers.repositoryImpl
          .generateImports(
            featureNameSnakeCase: featureNames.snakeCase,
            requestNameSnakeCase: request.names.snakeCase,
            hasParams: request.params != null,
          )
          .toString()
          .split('\n');

      ///-> Filter duplicated imports
      for (String line in importsLines) {
        buffer.writeln(line);
      }
    }
    buffer.writeln();

    ///-> Class RepositoryImpl
    buffer.writeln();
    buffer.writeln(
      'class ${featureNames.classCase}RepositoryImpl with RepositoryGuard implements ${featureNames.classCase}Repository {',
    );
    buffer.writeln('  final ${featureNames.classCase}RemoteDataSource remote;');
    buffer.writeln();
    buffer.writeln('  ${featureNames.classCase}RepositoryImpl({');
    buffer.writeln('    required this.remote,');
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln('  /// Impl');

    ///-> Func
    for (Request request in requests) {
      String func = request.buffers.repositoryImpl
          .generateBody(featureNames: featureNames, request: request)
          .toString();
      buffer.writeln(func);
    }
    buffer.writeln('}');
    buffer.writeln();

    ///-> Write file
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

// void generateRepositoryImplFile({
//   required String feature,
//   required List<Map<String, StringBuffer>> functions,
//   required List<Map<String, String?>> filesImport,
//   required bool isOneRequestHasToken,
// }) {
//   String className = capitalizeFirstChar(feature);
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln("import 'dart:developer';");
//   buffer.writeln();
//   buffer.writeln("import 'package:dartz/dartz.dart';");
//   buffer.writeln();
//   buffer.writeln("import '../../data/datasources/${feature}_remote_datasource.dart';");
//   buffer.writeln("import '../../../../../core/error/exceptions.dart';");
//   if(isOneRequestHasToken){
//     buffer.writeln("import '../../../../../core/local/auth_local_datasource.dart';");
//   }
//   buffer.writeln("import '../../../../core/error/failures.dart';");
//   buffer.writeln("import '../../domain/repositories/${feature}_repo.dart';");
//   bool isCoreUseCaseImports = false;
//   for(Map<String, String?> item in filesImport){
//     if(item['entity'] != null){
//       buffer.writeln('import \'../../domain/entities/${item['entity']}.dart\';');
//     }
//     if(item['usecase'] == '../../../../core/usecases/usecases'){
//       if(!isCoreUseCaseImports){
//         buffer.writeln('import \'${item['usecase']}.dart\';');
//         isCoreUseCaseImports = true;
//       }
//     }else{
//       buffer.writeln('import \'${item['usecase']}.dart\';');
//     }
//   }
//   buffer.writeln();
//   buffer.writeln('class ${className}RepositoryImpl implements ${className}Repository {');
//   if(isOneRequestHasToken){
//     buffer.writeln('  final AuthLocalDataSource local;');
//   }
//   buffer.writeln('  final ${className}RemoteDataSource remote;');
//   buffer.writeln();
//   buffer.writeln('  ${className}RepositoryImpl({');
//   if(isOneRequestHasToken){
//     buffer.writeln('    required this.local,');
//   }
//   buffer.writeln('    required this.remote,');
//   buffer.writeln('  });');
//   buffer.writeln();
//   buffer.writeln('  /// Impl');
//   for(final Map<String, StringBuffer> item in functions){
//     buffer.write(item['repositoryImplFunc']);
//   }
//   buffer.writeln('}');
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/data/repositories/${feature}_repo_impl.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print('File generated: ${file.path}');
// }

void modifyRepositoryImplFile({
  required File file,
  required String feature,
  required List<Map<String, StringBuffer>> functions,
  required List<Map<String, String?>> filesImport,
  required bool isOneRequestHasToken,
}) {
  String className = capitalizeFirstChar(feature);
  bool isCoreUseCaseImports = false;
  List<String> lines = file.readAsLinesSync();
  final StringBuffer contentsBuffer = StringBuffer();

  // Imports
  bool isLocalDatasourceWrote = false;
  int count = 0;
  for (String line in lines) {
    //Start looping
    if (line.contains(
      'class ${className}RepositoryImpl implements ${className}Repository {',
    )) {
      break; //end of imports
    }
    contentsBuffer.writeln(line);

    if (line.contains('auth_local_datasource.dart')) {
      isLocalDatasourceWrote = true;
    }
    if (line.contains("/domain/repositories/${feature}_repo.dart';")) {
      // write functions imports
      for (Map<String, String?> item in filesImport) {
        if (item['entity'] != null) {
          contentsBuffer.writeln(
            'import \'../../domain/entities/${item['entity']}.dart\';',
          );
        }
        if (item['usecase'] == '../../../../core/usecases/usecases') {
          if (!isCoreUseCaseImports) {
            contentsBuffer.writeln('import \'${item['usecase']}.dart\';');
            isCoreUseCaseImports = true;
          }
        } else {
          contentsBuffer.writeln('import \'${item['usecase']}.dart\';');
        }
      }
    }
    count++;
  }

  // Class
  for (int i = count; i < lines.length; i++) {
    contentsBuffer.writeln(lines[i]);
    if (lines[i].contains('final ${className}RemoteDataSource') &&
        !isLocalDatasourceWrote &&
        isOneRequestHasToken) {
      contentsBuffer.writeln('  final AuthLocalDataSource local;');
    }
    if (lines[i].contains('${className}RepositoryImpl({') &&
        !isLocalDatasourceWrote &&
        isOneRequestHasToken) {
      contentsBuffer.writeln('    required this.local,');
    }
    if (lines[i].contains('});')) {
      for (final Map<String, StringBuffer> item in functions) {
        contentsBuffer.write(item['repositoryImplFunc']);
      }
    }
  }

  // Write the content to a Dart file
  file.writeAsStringSync(contentsBuffer.toString());
}
