import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';

class UseCaseFile extends RequestFile {
  UseCaseFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required Request request,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln(
      request.buffers.useCase
          .generateImports(
            featureNameSnakeCase: featureNames.snakeCase,
            requestNameSnakeCase: request.names.snakeCase,
            hasParams: request.params != null,
          )
          .toString(),
    );

    buffer.writeln();

    ///-> Class UseCase
    buffer.writeln(
      request.buffers.useCase
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

// String generateUseCaseFile({
//   required String name,
//   required String feature,
//   required Map<String, dynamic> params,
// }) {
//   final String className = capitalizeFirstChar(name);
//   String featureCapital = capitalizeFirstChar(feature);
//   if (isSnakeCase(feature)) {
//     featureCapital = capitalizeFirstChar(snakeToCamelCase(feature));
//   }
//   String nameSnakeCase = upperToSnakeCase(name);
//
//
//   final StringBuffer buffer = StringBuffer();
//   if(params.isNotEmpty){
//     buffer.writeln('import \'package:equatable/equatable.dart\';');
//   }
//   buffer.writeln('import \'package:dartz/dartz.dart\';');
//   buffer.writeln();
//   buffer.writeln('import \'../../../../core/error/failures.dart\';');
//   buffer.writeln('import \'../../../../core/usecases/usecase.dart\';');
//   buffer.writeln('import \'../entities/${nameSnakeCase}_response.dart\';');
//   buffer.writeln('import \'../repositories/${feature}_repo.dart\';');
//   buffer.writeln();
//   if (params.isNotEmpty) {
//     buffer.writeln(
//         'class ${className}UseCase extends UseCase<${className}Response, ${className}Params> {');
//   } else {
//     buffer.writeln(
//         'class ${className}UseCase extends UseCase<${className}Response, NoParams> {');
//   }
//
//   buffer.writeln('  final ${featureCapital}Repository repository;');
//   buffer.writeln();
//   buffer.writeln('  ${className}UseCase({required this.repository});');
//   buffer.writeln();
//   buffer.writeln('  @override');
//   if (params.isNotEmpty) {
//     buffer.writeln(
//         '  Future<Either<Failure, ${className}Response>> call(${className}Params params) async {');
//   } else {
//     buffer.writeln(
//         '  Future<Either<Failure, ${className}Response>> call(NoParams params) async {');
//   }
//   buffer.writeln('    return await repository.$name(params: params);');
//   buffer.writeln('  }');
//   buffer.writeln('}');
//   buffer.writeln();
//
//   if (params.isNotEmpty) {
//     ///Start Param Class
//     buffer.writeln('class ${className}Params extends Equatable {');
//
//     ///Attributes
//     Map<String, String> attributes = {}; // example: key = id, value = int
//     params.forEach((key, value) {
//       String variableName = key;
//       if (isSnakeCase(key)) {
//         variableName = snakeToCamelCase(key);
//       }
//       String valueInStr = getDartType(value);
//       buffer.writeln('  final $valueInStr $variableName;');
//       attributes.putIfAbsent(variableName, () => valueInStr);
//     });
//     buffer.writeln();
//
//     ///Named Argument Constructor
//     buffer.writeln('  const ${className}Params({');
//     attributes.forEach((key, value) {
//       buffer.writeln('    required this.$key,');
//     });
//     buffer.writeln('  });\n');
//
//     ///ToJson
//     buffer.writeln('  Map<String, dynamic> toJson() => {');
//     attributes.forEach((key, value){
//       String snakeKey = camelToSnakeCase(key);
//       buffer.writeln('    \'$snakeKey\': $key,');
//     });
//     buffer.writeln('  };\n');
//
//     ///Equatable props
//     buffer.writeln('  @override');
//     buffer.writeln('  List<Object?> get props => <Object?>[');
//     attributes.forEach((key, value) {
//       buffer.writeln('    $key,');
//     });
//     buffer.writeln('  ];\n');
//
//     ///End of Param Class
//     buffer.writeln('}\n');
//   }
//
//   final String classContent = buffer.toString();
//
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$feature';
//   String filePath = '$featurePath/domain/usecases/${camelToSnakeCase(name)}_usecase.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(classContent);
//   //print('Dart file generated: $filePath');
//   return '../../domain/usecases/${camelToSnakeCase(name)}_usecase';
// }
//
