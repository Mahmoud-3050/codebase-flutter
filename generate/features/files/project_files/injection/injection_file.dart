import 'dart:io';

import '../../../../utils/extension.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../project_file.dart';


class InjectionFile extends ProjectFile{
  bool isOneRequestHasToken = false;

  InjectionFile({required super.file});

  @override
  Future<void> generate({required Names featureNames, required List<Request> requests}) async{
    final StringBuffer buffer = StringBuffer();
    ///-> File imports
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    buffer.writeln();
    buffer.writeln("import '../../injection_container.dart';");
    buffer.writeln("import 'data/datasources/${featureNames.snakeCase}_remote_datasource.dart';");
    buffer.writeln("import 'data/repositories/${featureNames.snakeCase}_repo_impl.dart';");
    buffer.writeln("import 'domain/repositories/${featureNames.snakeCase}_repo.dart';");
    ///-> Func imports
    for(Request request in requests){
      String imports = request.buffers.injection
          .generateImports(requestNameSnakeCase: request.names.snakeCase)
          .toString();
      buffer.write(imports);
    }

    ///-> Class Injection
    buffer.writeln();
    buffer.writeln('final _sl = ServiceLocator.instance;');
    buffer.writeln();
    buffer.writeln('Future<void> init${featureNames.classCase}FeatureInjection() async {');
    buffer.writeln('  ///-> Cubits');
    for(Request request in requests){
      String cubit = request.buffers.injection
          .generateBody(featureNames: featureNames, request: request)
          .toString().split('***')
          .first;
      buffer.write(cubit);
    }
    buffer.writeln();
    buffer.write('  ///-> UseCases');
    for(Request request in requests){
      String useCase = request.buffers.injection
          .generateBody(featureNames: featureNames, request: request)
          .toString()
          .split('***')[1].toString();
      buffer.write(useCase);
    }
    buffer.writeln('\n');
    buffer.writeln('  ///-> Repository');
    buffer.writeln('  _sl.registerLazySingleton<${featureNames.classCase}Repository>(() => ${featureNames.classCase}RepositoryImpl(remote: _sl()));');
    buffer.writeln();
    buffer.writeln('  ///-> DataSource');
    buffer.writeln('  _sl.registerLazySingleton<${featureNames.classCase}RemoteDataSource>(() => ${featureNames.classCase}RemoteDataSourceImpl());');
    buffer.writeln('}');
    buffer.writeln();

    ///-> BlocProvider
    buffer.writeln('  ///-> BlocProvider');
    buffer.write('List<BlocProvider> get ${featureNames.camelCase}Blocs => <BlocProvider>[');
    for(Request request in requests){
      String blocProvider = request.buffers.injection
          .generateBody(featureNames: featureNames, request: request)
          .toString().split('***')
          .last;
      buffer.write(blocProvider);
    }
    buffer.writeln('];');

    ///-> Write file
    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }

  @override
  Future<void> modify(
      {required Names featureNames, required List<Request> requests}) async {
    final List<String> lines = file.readAsLinesSync();
    final StringBuffer buffer = StringBuffer();
    if (requests.isEmpty) {
      return;
    }

    bool isOneRequestHasToken = false;
    if (lines.lineContains('local: _sl()')) {
      isOneRequestHasToken = true;
    }

    for (String line in lines) {
      if (!line.contains('RepositoryImpl(')) {
        buffer.writeln(line);
      }

      if (line.contains('domain/repositories/')) {
        for (Request request in requests) {
          String imports = request.buffers.injection
              .generateImports(requestNameSnakeCase: request.names.snakeCase)
              .toString();
          buffer.writeln(imports);
        }
      }

      if (line.contains('///-> Cubits')) {
        for (Request request in requests) {
          String bloc = request.buffers.injection
              .generateBody(featureNames: featureNames, request: request)
              .toString()
              .split('***')
              .first;
          buffer.writeln(bloc);
        }
      }

      if (line.contains('///-> UseCases')) {
        for (Request request in requests) {
          String useCase = request.buffers.injection
              .generateBody(featureNames: featureNames, request: request)
              .toString()
              .split('***')[1];
          buffer.writeln(useCase);
        }
      }

      if (line.contains('///-> Repository')) {
        if (!isOneRequestHasToken) {
          for (Request request in requests) {
            if (request.hasToken) {
              isOneRequestHasToken = true;
              break;
            }
          }
        }
        if (isOneRequestHasToken) {
          buffer.writeln(
              '  _sl.registerLazySingleton<${featureNames.classCase}Repository>(() => ${featureNames.classCase}RepositoryImpl(remote: _sl(), local: _sl()));');
        } else {
          buffer.writeln(
              '  _sl.registerLazySingleton<${featureNames.classCase}Repository>(() => ${featureNames.classCase}RepositoryImpl(remote: _sl()));');
        }
      }

      if (line.contains('List<BlocProvider')) {
        for (Request request in requests) {
          String blocProvider = request.buffers.injection
              .generateBody(featureNames: featureNames, request: request)
              .toString()
              .split('***')
              .last;
          buffer.write(blocProvider);
        }
      }
    }

    await file.writeAsString(buffer.toString());
  }
}


// void generateFeatureInjectionFile({
//   required String feature,
//   required List<String> namesInSnakeCase,
//   bool hasCubitDirectory = true,
//   required bool isOneRequestHasToken,
// }){
//
//   String featureSnackCase = feature;
//   String featureCamelCase = feature;
//   String featureClassName = feature;
//   if(isSnakeCase(featureSnackCase)){
//     featureCamelCase = snakeToCamelCase(featureSnackCase);
//   }else{
//     featureSnackCase = camelToSnakeCase(feature);
//   }
//   featureClassName = capitalizeFirstChar(featureCamelCase);
//
//
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln("import 'package:flutter/material.dart';");
//   buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
//   buffer.writeln();
//   buffer.writeln("import '../../injection_container.dart';");
//   buffer.writeln("import 'data/datasources/${featureSnackCase}_remote_datasource.dart';");
//   buffer.writeln("import 'data/repositories/${featureSnackCase}_repo_impl.dart';");
//   buffer.writeln("import 'domain/repositories/${featureSnackCase}_repo.dart';");
//
//   for(String name in namesInSnakeCase){
//     buffer.writeln("import 'domain/usecases/${name}_usecase.dart';");
//     if(hasCubitDirectory){
//       buffer.writeln("import 'presentation/controller/$name/${name}_cubit.dart';");
//     }else{
//       buffer.writeln("import 'presentation/controller/${name}_cubit.dart';");
//     }
//   }
//
//   buffer.writeln();
//   buffer.writeln('Future<void> init${featureClassName}Injection() async {');
//   buffer.writeln('  /// Blocs');
//   for(String name in namesInSnakeCase){
//     String featureClassName = capitalizeFirstChar(snakeToCamelCase(name));
//     buffer.writeln('  sl.registerLazySingleton(() => ${featureClassName}Cubit(sl()));');
//   }
//   buffer.writeln();
//   buffer.writeln('  /// UseCases');
//   for(String name in namesInSnakeCase){
//     String featureClassName = capitalizeFirstChar(snakeToCamelCase(name));
//     buffer.writeln('  sl.registerLazySingleton(() => ${featureClassName}UseCase(repository: sl()));');
//   }
//   buffer.writeln();
//   buffer.writeln('  /// Repository');
//   if(isOneRequestHasToken){
//     buffer.writeln('  sl.registerLazySingleton<${featureClassName}Repository>(() => ${featureClassName}RepositoryImpl(remote: sl(), local: sl()));');
//   }else{
//     buffer.writeln('  sl.registerLazySingleton<${featureClassName}Repository>(() => ${featureClassName}RepositoryImpl(remote: sl()));');
//   }
//   buffer.writeln();
//   buffer.writeln('  /// DataSource');
//   buffer.writeln('  sl.registerLazySingleton<${featureClassName}RemoteDataSource>(() => ${featureClassName}RemoteDataSourceImpl(),);');
//   buffer.writeln('}');
//   buffer.writeln();
//   buffer.writeln('List<BlocProvider<StateStreamableSource<Object?>>> ${featureCamelCase}Blocs(BuildContext context) => <BlocProvider<StateStreamableSource<Object?>>>[');
//   for(String name in namesInSnakeCase){
//     String featureClassName = capitalizeFirstChar(snakeToCamelCase(name));
//     buffer.writeln('  BlocProvider<${featureClassName}Cubit>(');
//     buffer.writeln('    create: (BuildContext context) => sl<${featureClassName}Cubit>(),');
//     buffer.writeln('  ),');
//   }
//   buffer.writeln('];');
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/${featureSnackCase}_injection.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print(buffer.toString());
// }


// void modifyFeatureInjectionFile({
//   required File file,
//   required String feature,
//   required List<String> namesInSnakeCase,
//   bool hasCubitDirectory = true,
//   required bool isOneRequestHasToken,
// }) {
//   String featureSnackCase = feature;
//   String featureCamelCase = feature;
//   String featureClassName = feature;
//   if(isSnakeCase(featureSnackCase)){
//     featureCamelCase = snakeToCamelCase(featureSnackCase);
//   }else{
//     featureSnackCase = camelToSnakeCase(feature);
//   }
//   featureClassName = capitalizeFirstChar(featureCamelCase);
//   List<String> lines = file.readAsLinesSync();
//   int importsIndex = -1, blocsIndex = -1, useCaseIndex = -1, repositoryIndex = -1, blocProviderIndex = -1;
//   int index = -1;
//   for(String line in lines){
//     index++;
//     if(line == "import 'domain/repositories/${featureSnackCase}_repo.dart';"){
//       importsIndex = index;
//     }
//     if(line == '  /// Blocs'){
//       blocsIndex = index;
//     }
//
//     if(line == '  /// UseCases'){
//       useCaseIndex = index;
//     }
//
//     if(line == '  /// Repository'){
//       repositoryIndex = index;
//     }
//
//     if(line == 'List<BlocProvider<StateStreamableSource<Object?>>> ${featureCamelCase}Blocs(BuildContext context) => <BlocProvider<StateStreamableSource<Object?>>>['){
//       blocProviderIndex = index;
//     }
//
//   }
//
//   ///Imports StringBuffer
//   final StringBuffer importsBuffer = StringBuffer();
//   for(String name in namesInSnakeCase){
//     importsBuffer.writeln("import 'domain/usecases/${name}_usecase.dart';");
//     if(hasCubitDirectory){
//       importsBuffer.writeln("import 'presentation/controller/$name/${name}_cubit.dart';");
//     }else{
//       importsBuffer.writeln("import 'presentation/controller/${name}_cubit.dart';");
//     }
//   }
//
//   ///Blocs StringBuffer
//   final StringBuffer blocsBuffer = StringBuffer();
//   for(String name in namesInSnakeCase){
//     String featureClassName = capitalizeFirstChar(snakeToCamelCase(name));
//     blocsBuffer.writeln('  sl.registerLazySingleton(() => ${featureClassName}Cubit(sl()));');
//   }
//
//   ///UseCases StringBuffer
//   final StringBuffer useCasesBuffer = StringBuffer();
//   for(String name in namesInSnakeCase){
//     String featureClassName = capitalizeFirstChar(snakeToCamelCase(name));
//     useCasesBuffer.writeln('  sl.registerLazySingleton(() => ${featureClassName}UseCase(repository: sl()));');
//   }
//
//   ///Repository StringBuffer
//   final StringBuffer repositoryBuffer = StringBuffer();
//   if(isOneRequestHasToken){
//     repositoryBuffer.writeln('  sl.registerLazySingleton<${featureClassName}Repository>(() => ${featureClassName}RepositoryImpl(remote: sl(), local: sl()));');
//   }else{
//     repositoryBuffer.writeln('  sl.registerLazySingleton<${featureClassName}Repository>(() => ${featureClassName}RepositoryImpl(remote: sl()));');
//   }
//
//   ///BlocProvider StringBuffer
//   final StringBuffer blocProviderBuffer = StringBuffer();
//   for(String name in namesInSnakeCase){
//     String featureClassName = capitalizeFirstChar(snakeToCamelCase(name));
//     blocProviderBuffer.writeln('  BlocProvider<${featureClassName}Cubit>(');
//     blocProviderBuffer.writeln('    create: (BuildContext context) => sl<${featureClassName}Cubit>(),');
//     blocProviderBuffer.writeln('  ),');
//   }
//
//   final StringBuffer contentsBuffer = StringBuffer();
//   int i = -1;
//   for(String line in lines){
//     i++;
//
//     if(i != repositoryIndex + 1){
//       contentsBuffer.writeln(line);
//     }
//
//     if(i == importsIndex){
//       contentsBuffer.write(importsBuffer.toString());
//     } else if(i == blocsIndex){
//       contentsBuffer.write(blocsBuffer.toString());
//     } else if(i == useCaseIndex){
//       contentsBuffer.write(useCasesBuffer.toString());
//     } else if(i == blocProviderIndex){
//       contentsBuffer.write(blocProviderBuffer.toString());
//     } else if(i == repositoryIndex){
//       contentsBuffer.write(repositoryBuffer.toString());
//     }
//
//   }
//
//   // Write the content to a Dart file
//   file.writeAsStringSync(contentsBuffer.toString());
// }