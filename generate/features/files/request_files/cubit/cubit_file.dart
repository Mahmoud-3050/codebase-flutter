import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';

class CubitFile extends RequestFile {
  CubitFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required Request request,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln(
      request.buffers.cubit
          .generateImports(
            requestNameSnakeCase: request.names.snakeCase,
            hasParams: request.params != null,
          )
          .toString(),
    );

    ///-> Class UseCase
    buffer.writeln(
      request.buffers.cubit
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

// void generateCubitFile({
//   required String name,
//   required String feature,
//   required String type,
//   String? dataType,
//   bool hasDirectory = true,
//   required Map<String, dynamic> params,
// }) {
//
//   String camelCase = name;
//   if(isSnakeCase(camelCase)){
//     camelCase = snakeToCamelCase(camelCase);
//   }
//   String className = capitalizeFirstChar(camelCase);
//   String snakeName = upperToSnakeCase(className);
//
//
//   final StringBuffer buffer = StringBuffer();
//   buffer.writeln("import 'package:easy_localization/easy_localization.dart';");
//   buffer.writeln("import 'package:dartz/dartz.dart';");
//   buffer.writeln("import 'package:equatable/equatable.dart';");
//   buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
//   buffer.writeln();
//   buffer.writeln("import '../../../../../core/error/failures.dart';");
//   if(params.isEmpty){
//     buffer.writeln("import '../../../../../core/usecases/usecase.dart';");
//   }
//   if(hasDirectory){
//     buffer.writeln("import '../../../domain/usecases/${snakeName}_usecase.dart';");
//     buffer.writeln("import '../../../domain/entities/${snakeName}_response.dart';");
//   }else{
//     buffer.writeln("import '../../domain/usecases/${snakeName}_usecase.dart';");
//     buffer.writeln("import '../../domain/entities/${snakeName}_response.dart';");
//   }
//
//   buffer.writeln();
//   buffer.writeln("part '${snakeName}_state.dart';");
//   buffer.writeln();
//   buffer.writeln("class ${className}Cubit extends Cubit<${className}State> {");
//   buffer.writeln("  final ${className}UseCase ${camelCase}UseCase;");
//   buffer.writeln();
//   buffer.writeln("  ${className}Cubit(this.${camelCase}UseCase) : super(const ${className}InitialState());");
//   buffer.writeln();
//   if(dataType != null){
//     buffer.writeln("  $dataType? data;");
//   }
//   buffer.writeln();
//   if(params.isEmpty){
//     buffer.writeln("  Future<void> f${className}() async {");
//   }else{
//     buffer.writeln("  Future<void> f${className}({");
//     params.forEach((key, value) {
//       buffer.writeln("   required ${getDartType(value)} ${snakeToCamelCase(key)},");
//     });
//     buffer.writeln("  }) async {");
//   }
//
//   buffer.writeln("    emit(const ${className}LoadingState());");
//   if(params.isEmpty){
//     buffer.writeln("    final Either<Failure, ${className}Response> eitherResult = await ${camelCase}UseCase.call(NoParams());");
//   }else {
//     buffer.writeln("    final Either<Failure, ${className}Response> eitherResult = await ${camelCase}UseCase.call(${className}Params(");
//     params.forEach((key, value) {
//       buffer.writeln("      ${snakeToCamelCase(key)}: ${snakeToCamelCase(key)},");
//     });
//     buffer.writeln("    ));");
//   }
//   buffer.writeln("    eitherResult.fold((Failure fail) {");
//   buffer.writeln("      String message = 'please try again later'.tr();");
//   buffer.writeln("      if (fail is ServerFailure) {");
//   buffer.writeln("        message = fail.message;");
//   buffer.writeln("      }");
//   buffer.writeln("      emit(${className}ErrorState(message: message));");
//   buffer.writeln("    }, (${className}Response response) {");
//   if(dataType != null){
//     if(dataType.startsWith('List')){
//       buffer.writeln("      data = [];");
//     }
//     buffer.writeln("      data = response.data;");
//     buffer.writeln("      emit(${className}SuccessState(value: response.data));");
//   }else{
//     buffer.writeln("      emit(const ${className}SuccessState());");
//   }
//   buffer.writeln("    });");
//   buffer.writeln("  }");
//   buffer.writeln("}");
//
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/presentation/controller/${snakeName}_cubit.dart';
//   if(hasDirectory){
//     filePath = '$featurePath/presentation/controller/$snakeName/${snakeName}_cubit.dart';
//   }
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print('File generated: ${file.path}');
// }
