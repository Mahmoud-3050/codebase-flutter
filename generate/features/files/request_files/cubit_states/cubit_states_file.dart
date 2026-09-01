import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';

class CubitStatesFile extends RequestFile {
  CubitStatesFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required Request request,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln(
      request.buffers.cubitStates
          .generateImports(requestNameSnakeCase: request.names.snakeCase)
          .toString(),
    );

    buffer.writeln();

    ///-> Class CubitStates
    buffer.writeln(
      request.buffers.cubitStates
          .generateBody(featureNames: featureNames, request: request)
          .toString(),
    );

    ///-> Write file
    final File targetFile = createFile(file.path);
    await targetFile.writeAsString(buffer.toString());
  }

  @override
  Future<void> modify({required Names featureNames, required Request request}) {
    // TODO: implement modify
    throw UnimplementedError();
  }
}

// void generateCubitStateFile({
//   required String name,
//   required String feature,
//   String? dataType,
//   bool hasDirectory = true,
//
// }) {
//   String className = name;
//   if(isSnakeCase(className)){
//     className = snakeToCamelCase(className);
//   }
//   className = capitalizeFirstChar(className);
//   String snakeName = upperToSnakeCase(className);
//
//
//
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln("part of '${snakeName}_cubit.dart';");
//   buffer.writeln();
//   buffer.writeln("abstract class ${className}State extends Equatable {");
//   buffer.writeln();
//   buffer.writeln("  const ${className}State();");
//   buffer.writeln();
//   buffer.writeln("  @override");
//   buffer.writeln("  List<Object?> get props => [];");
//   buffer.writeln("}");
//   buffer.writeln();
//   buffer.writeln("class ${className}InitialState extends ${className}State {");
//   buffer.writeln("  const ${className}InitialState();");
//   buffer.writeln("}");
//   buffer.writeln();
//   buffer.writeln("class ${className}LoadingState extends ${className}State {");
//   buffer.writeln("  const ${className}LoadingState();");
//   buffer.writeln("}");
//   buffer.writeln();
//   buffer.writeln("class ${className}SuccessState extends ${className}State {");
//   if(dataType != null){
//     buffer.writeln("  final $dataType value;");
//   }
//   buffer.writeln();
//   if(dataType != null){
//     buffer.writeln("  const ${className}SuccessState({required this.value,});");
//   }else{
//     buffer.writeln("  const ${className}SuccessState();");
//   }
//   buffer.writeln();
//   if(dataType != null){
//     buffer.writeln("  @override");
//     buffer.writeln("  List<Object?> get props => [value,];");
//   }
//   buffer.writeln("}");
//   buffer.writeln();
//   buffer.writeln("class ${className}ErrorState extends ${className}State {");
//   buffer.writeln("  final String message;");
//   buffer.writeln();
//   buffer.writeln("  const ${className}ErrorState({required this.message,});");
//   buffer.writeln();
//   buffer.writeln("  @override");
//   buffer.writeln("  List<Object?> get props => [message,];");
//   buffer.writeln("}");
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/presentation/controller/${snakeName}_state.dart';
//   if(hasDirectory){
//     filePath = '$featurePath/presentation/controller/$snakeName/${snakeName}_state.dart';
//     String directoryPath = '$featurePath/presentation/controller/${snakeName}';
//     createDirectory(directoryPath);
//   }
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print('File generated: ${file.path}');
// }
