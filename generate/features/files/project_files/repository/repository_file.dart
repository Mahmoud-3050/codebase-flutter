import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class RepositoryFile extends ProjectFile {
  bool isNoParamsImports = false;

  RepositoryFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln("import 'package:either/either.dart';");
    buffer.writeln();
    buffer.writeln("import '../../../../core/error/failures.dart';");

    ///-> Func imports
    for (Request request in requests) {
      List<String> importsLines = request.buffers.repository
          .generateImports(
            featureNameSnakeCase: featureNames.snakeCase,
            requestNameSnakeCase: request.names.snakeCase,
            hasParams: request.params != null,
          )
          .toString()
          .split('\n');

      ///-> Filter duplicated imports
      for (String line in importsLines) {
        if (line.contains('core/usecases/usecase.dart')) {
          if (isNoParamsImports) {
            continue;
          }
          isNoParamsImports = true;
        }
        buffer.writeln(line);
      }
    }
    buffer.writeln();

    ///-> Class Datasource
    buffer.writeln('abstract class ${featureNames.classCase}Repository {');

    ///-> Func
    for (Request request in requests) {
      String func = request.buffers.repository
          .generateBody(featureNames: featureNames, request: request)
          .toString();
      buffer.writeln(func);
    }
    buffer.writeln('}');

    ///-> Write file
    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }

  @override
  Future<void> modify({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    List<String> lines = file.readAsLinesSync();
    final StringBuffer buffer = StringBuffer();
    if (requests.isEmpty) {
      return;
    }

    for (String line in lines) {
      buffer.writeln(line);

      ///-> Func imports
      if (line.contains('core/error/failures.dart')) {
        for (Request request in requests) {
          List<String> importsLines = request.buffers.repository
              .generateImports(
                featureNameSnakeCase: featureNames.snakeCase,
                requestNameSnakeCase: request.names.snakeCase,
                hasParams: request.params != null,
              )
              .toString()
              .split('\n');

          ///-> Filter duplicated imports
          for (String line in importsLines) {
            if (line.contains('core/usecases/usecases.dart')) {
              if (isNoParamsImports) {
                continue;
              }
              isNoParamsImports = true;
            }
            buffer.writeln(line);
          }
        }
      }

      ///-> Func
      if (line.contains('abstract class')) {
        for (Request request in requests) {
          String func = request.buffers.repository
              .generateBody(featureNames: featureNames, request: request)
              .toString();
          buffer.writeln(func);
        }
      }
    }

    ///-> Write file
    await file.writeAsString(buffer.toString());
  }
}

// void generateDomainRepositoryFile({
//   required String feature,
//   required List<Map<String, StringBuffer>> functions,
//   required List<Map<String, String?>> filesImport,
// }) {
//   String className = capitalizeFirstChar(feature);
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln("import 'package:dartz/dartz.dart';");
//   buffer.writeln();
//   buffer.writeln("import '../../../../../core/error/failures.dart';");
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
//   buffer.writeln('abstract class ${className}Repository {');
//
//   for(final Map<String, StringBuffer> item in functions){
//     buffer.write(item['repositoryFunc']);
//   }
//   buffer.writeln('}');
//   buffer.writeln();
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/domain/repositories/${feature}_repo.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print('File generated: ${file.path}');
// }

void modifyDomainRepositoryFile({
  required File file,
  required String feature,
  required List<Map<String, StringBuffer>> functions,
  required List<Map<String, String?>> filesImport,
}) {
  bool isCoreUseCaseImports = false;
  String className = capitalizeFirstChar(feature);
  List<String> lines = file.readAsLinesSync();
  int importsIndex = -1, functionsIndex = -1;
  int index = -1;
  for (String line in lines) {
    index++;
    if (line == "import '../../../../../core/error/failures.dart';") {
      importsIndex = index + 1;
    }
    if (line == 'abstract class ${className}Repository {') {
      functionsIndex = index + 1;
    }

    if (line == 'import \'../../../../core/usecases/usecase.dart\';') {
      isCoreUseCaseImports = true;
    }
  }

  ///Imports StringBuffer
  final StringBuffer importsBuffer = StringBuffer();
  for (Map<String, String?> item in filesImport) {
    if (item['entity'] != null) {
      importsBuffer.writeln(
        'import \'../../domain/entities/${item['entity']}.dart\';',
      );
    }
    if (item['usecase'] == '../../../../core/usecases/usecases' &&
        isCoreUseCaseImports) {
      continue;
    }
    importsBuffer.writeln('import \'${item['usecase']}.dart\';');
  }

  ///Functions StringBuffer
  final StringBuffer functionsBuffer = StringBuffer();
  for (final Map<String, StringBuffer> item in functions) {
    functionsBuffer.write(item['repositoryFunc']);
  }

  final StringBuffer contentsBuffer = StringBuffer();
  int i = -1;
  for (String line in lines) {
    i++;
    if (i == importsIndex) {
      contentsBuffer.write(importsBuffer.toString());
    } else if (i == functionsIndex) {
      contentsBuffer.write(functionsBuffer.toString());
    }
    contentsBuffer.writeln(line);
  }

  // Write the content to a Dart file
  file.writeAsStringSync(contentsBuffer.toString());
}
