import 'dart:io';

import '../../../../utils/extension.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';

class RepositoryImplFile extends ProjectFile {
  bool isNoParamsImports = false;
  bool isAuthLocalImports = false;

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
    buffer.writeln("import '../../../../../core/error/exceptions.dart';");
    buffer.writeln("import '../../../../core/utils/log_utils.dart';");
    buffer.writeln("import '../../../../core/error/failures.dart';");
    buffer.writeln("import '../../../../config/language/strings.dart';");
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

    ///-> Class RepositoryImpl
    buffer.writeln();
    buffer.writeln(
      'class ${featureNames.classCase}RepositoryImpl implements ${featureNames.classCase}Repository {',
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
  }) async {
    final List<String> lines = file.readAsLinesSync();
    if (requests.isEmpty) {
      return;
    }

    bool isOneRequestHasToken = false;
    for (Request request in requests) {
      if (request.hasToken) {
        isOneRequestHasToken = true;
        break;
      }
    }

    List<String> fileLines = List<String>.from(lines);
    List<String> importsLines = <String>[];
    List<String> constructorLines = <String>[];
    List<String> functionsLines = <String>[];

    int index = 0;
    int constructorIndex = 0;
    int functionsIndex = 0;
    int currentIndex = 0;
    bool isAuthLocalImports = false;
    bool isNoParamsImports = false;

    ///-> Detect isAuthLocalImports
    if (fileLines.lineContains('local_datasource')) {
      isAuthLocalImports = true;
    }

    ///-> Remove last curly brace of end of class
    final StringBuffer tempBuffer = StringBuffer();
    tempBuffer.writeAll(fileLines, '\n');
    final String tempContent = tempBuffer.toString().trim();
    fileLines = tempContent.substring(0, tempContent.length - 1).split('\n');

    ///-> Separator file lines and detect indexes
    for (String line in fileLines) {
      ///-> Detect constructorIndex
      if (line.contains('class') &&
          line.contains('implements') &&
          currentIndex == 0) {
        constructorIndex = index + 1;
        currentIndex = constructorIndex;
      }
      ///-> Detect functionsIndex
      else if (currentIndex == constructorIndex && line.contains('@override')) {
        functionsIndex = index - 1;
        currentIndex = functionsIndex;
      }

      ///-> Add imports lines
      if (currentIndex == 0) {
        importsLines.add(line);
      }
      ///-> Add constructor lines
      else if (currentIndex == constructorIndex) {
        constructorLines.add(line);
      }
      ///-> Add functions lines
      else if (currentIndex == functionsIndex) {
        functionsLines.add(line);
      }
      index++;
    }

    ///-> AuthLocalImports
    if (!isAuthLocalImports &&
        isOneRequestHasToken &&
        !importsLines.lineContains('local_datasource.dart')) {
      importsLines.add(
        "import '../../../../core/local/auth_local_datasource.dart';",
      );
      isAuthLocalImports = true;
    }

    ///-> Func imports
    for (Request request in requests) {
      List<String> funcImportsLines = request.buffers.repositoryImpl
          .generateImports(
            featureNameSnakeCase: featureNames.snakeCase,
            requestNameSnakeCase: request.names.snakeCase,
            hasParams: request.params != null,
          )
          .toString()
          .split('\n');

      ///-> Filter duplicated imports
      for (String line in funcImportsLines) {
        if (line.contains('core/usecases/usecases.dart')) {
          if (isNoParamsImports) {
            continue;
          }
          isNoParamsImports = true;
        }
        importsLines.add(line);
      }
    }

    ///-> Constructor
    if (isAuthLocalImports &&
        !constructorLines.lineContains('LocalDataSource')) {
      constructorLines.insert(1, '  final AuthLocalDataSource local;');
      constructorLines.insert(
        constructorLines.length - 2,
        '    required this.local,',
      );
    }

    ///-> Functions Impl
    for (Request request in requests) {
      String func = request.buffers.repositoryImpl
          .generateBody(featureNames: featureNames, request: request)
          .toString();
      functionsLines.add(func);
    }

    ///-> Write Buffer
    final StringBuffer fileBuffer = StringBuffer();
    for (String line in importsLines) {
      fileBuffer.writeln(line);
    }
    fileBuffer.writeln();
    for (String line in constructorLines) {
      fileBuffer.writeln(line);
    }
    fileBuffer.writeln();
    for (String line in functionsLines) {
      fileBuffer.writeln(line);
    }
    fileBuffer.writeln('}');

    ///-> Write file
    await file.writeAsString(fileBuffer.toString());
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
