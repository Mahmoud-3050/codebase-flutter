import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class DatasourceFile extends ProjectFile {
  bool isNoParamsImports = false;

  DatasourceFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required List<Request> requests,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln("import '../../../../core/error/exceptions.dart';");
    buffer.writeln("import '../../../../injection_container.dart';");

    ///-> Func imports
    for (Request request in requests) {
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

    ///-> Class Datasource
    buffer.writeln();
    buffer.writeln(
      'abstract class ${featureNames.classCase}RemoteDataSource {',
    );

    ///-> Func
    for (Request request in requests) {
      String func = request.buffers.datasource
          .generateBody(featureNames: featureNames, request: request)
          .toString()
          .split('***')
          .first;
      buffer.write(func);
    }
    buffer.writeln('}');
    buffer.writeln();

    ///-> Class Datasource impl
    buffer.writeln(
      'class ${featureNames.classCase}RemoteDataSourceImpl implements ${featureNames.classCase}RemoteDataSource {',
    );

    ///-> Func impl
    for (Request request in requests) {
      String funcImpl = request.buffers.datasource
          .generateBody(featureNames: featureNames, request: request)
          .toString()
          .split('***')
          .last;
      buffer.write(funcImpl);
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
      ///-> Func imports
      if (line.contains('abstract class')) {
        for (Request request in requests) {
          List<String> importsLines = request.buffers.datasource
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

      buffer.writeln(line);

      ///-> Func
      if (line.contains('abstract class')) {
        for (Request request in requests) {
          String func = request.buffers.datasource
              .generateBody(featureNames: featureNames, request: request)
              .toString()
              .split('***')
              .first;
          buffer.write(func);
        }
      }

      ///-> Func impl
      if (line.contains('implements')) {
        for (Request request in requests) {
          String funcImpl = request.buffers.datasource
              .generateBody(featureNames: featureNames, request: request)
              .toString()
              .split('***')
              .last;
          buffer.write(funcImpl);
        }
      }
    }

    ///-> Rewrite file
    await file.writeAsString(buffer.toString());
  }
}

// void generateRemoteDatasourceFile({
//   required String feature,
//   required List<Map<String, StringBuffer>> functions,
//   required List<Map<String, String?>> filesImport,
// }) {
//   bool isCoreUseCaseImports = false;
//   String className = capitalizeFirstChar(feature);
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln('import \'dart:developer\';');
//   buffer.writeln();
//   buffer.writeln('import \'package:easy_localization/easy_localization.dart\';');
//   buffer.writeln();
//   buffer.writeln('import \'../../../../../injection_container.dart\';');
//   buffer.writeln('import \'../../../../core/error/exceptions.dart\';');
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
//
//   buffer.writeln();
//   buffer.writeln('abstract class ${className}RemoteDataSource {');
//   for(final Map<String, StringBuffer> item in functions){
//     buffer.write(item['datasourceFunc']);
//   }
//   buffer.writeln('}');
//   buffer.writeln();
//   buffer.writeln('class ${className}RemoteDataSourceImpl implements ${className}RemoteDataSource {');
//   for(final Map<String, StringBuffer> item in functions){
//     buffer.write(item['datasourceImplFunc']);
//   }
//   buffer.writeln('}');
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/data/datasources/${feature}_remote_datasource.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print('File generated: ${file.path}');
// }

void modifyRemoteDatasourceFile({
  required File file,
  required String feature,
  required List<Map<String, StringBuffer>> functions,
  required List<Map<String, String?>> filesImport,
}) {
  bool isCoreUseCaseImports = false;
  String className = capitalizeFirstChar(feature);
  List<String> lines = file.readAsLinesSync();
  int importsIndex = -1, functionsIndex = -1, functionsImplIndex = -1;
  int index = -1;
  for (String line in lines) {
    index++;
    if (line == 'import \'../../../../core/error/exceptions.dart\';') {
      importsIndex = index + 1;
    }
    if (line == 'abstract class ${className}RemoteDataSource {') {
      functionsIndex = index + 1;
    }

    if (line ==
        'class ${className}RemoteDataSourceImpl implements ${className}RemoteDataSource {') {
      functionsImplIndex = index + 1;
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
    functionsBuffer.write(item['datasourceFunc']);
  }

  ///FunctionsImpl StringBuffer
  final StringBuffer functionsImplBuffer = StringBuffer();
  for (final Map<String, StringBuffer> item in functions) {
    functionsImplBuffer.write(item['datasourceImplFunc']);
  }

  final StringBuffer contentsBuffer = StringBuffer();
  int i = -1;
  for (String line in lines) {
    i++;
    if (i == importsIndex) {
      contentsBuffer.write(importsBuffer.toString());
    } else if (i == functionsIndex) {
      contentsBuffer.write(functionsBuffer.toString());
    } else if (i == functionsImplIndex) {
      contentsBuffer.write(functionsImplBuffer.toString());
    }
    contentsBuffer.writeln(line);
  }

  // Write the content to a Dart file
  file.writeAsStringSync(contentsBuffer.toString());
}
