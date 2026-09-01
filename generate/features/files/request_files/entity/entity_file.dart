import 'dart:io';

import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_file.dart';

class EntityFile extends RequestFile {
  EntityFile({required super.file});

  @override
  Future<void> generate({
    required Names featureNames,
    required Request request,
  }) async {
    final StringBuffer buffer = StringBuffer();

    ///-> File imports
    buffer.writeln(
      request.buffers.entity
          .generateImports(isDataModel: request.response['data'] != null)
          .toString(),
    );

    ///-> Class Response
    buffer.writeln(
      request.buffers.entity
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

//
// List<String?> generateEntityFile({
//   required String featureName,
//   required String responseClassName,
//   required String? modelName,
//   required Map<String, dynamic> jsonMap,
// }) {
//   bool isDataModel = true;
//   bool isDataList = false;
//   String? dataType;
//   if(modelName == null){
//     isDataModel = false;
//     dataType = null;
//   }else{
//     if(jsonMap['data'] != null && jsonMap['data'] is List<dynamic>){
//       isDataList = true;
//     }
//     dataType = isDataList? 'List<$modelName>' : modelName;
//   }
//
//   final StringBuffer buffer = StringBuffer();
//
//   ///ResponseModel
//   if(isDataModel){
//     buffer.writeln("import 'package:equatable/equatable.dart';");
//   }
//   buffer.writeln();
//   buffer.writeln('class ${responseClassName}Response {');
//   buffer.writeln('  final int status;');
//   buffer.writeln('  final String message;');
//   if(isDataModel){
//     buffer.writeln('  final $dataType data;\n');
//   }
//   buffer.writeln();
//   buffer.writeln('  const ${responseClassName}Response({');
//   buffer.writeln('    required this.status,');
//   buffer.writeln('    required this.message,');
//   if(isDataModel){
//     buffer.writeln('    required this.data,');
//   }
//   buffer.writeln('  });\n');
//   buffer.writeln('  factory ${responseClassName}Response.fromJson(Map<String, dynamic> json) =>');
//   buffer.writeln('      ${responseClassName}Response(');
//   buffer.writeln('        status: json[\'status\'],');
//   buffer.writeln('        message: json[\'message\'],');
//   if(isDataModel){
//     if(isDataList){
//       writeDataList(buffer, modelName!);
//     }else{
//       writeData(buffer, modelName!);
//     }
//   }
//   buffer.writeln('      );');
//   buffer.writeln('}\n');
//
//   ///DataModel
//   if(isDataModel){
//     writeDataModelClass(
//       buffer: buffer,
//       modelName: modelName!,
//       jsonMap: jsonMap,
//       isDataList: isDataList,
//     );
//   }
//   // Write the content to a Dart file
//   final Directory projectRoot = Directory.current;
//   final String featurePath = '${projectRoot.absolute.path}/${GenerateConstants.projectFeaturesPath}/$featureName';
//   String filePath = '$featurePath/domain/entities/${upperToSnakeCase(responseClassName)}_response.dart';
//   createFile(filePath);
//   final File file = File(filePath);
//   file.writeAsStringSync(buffer.toString());
//   //print('File generated: ${file.path}');
//   return <String?>['${upperToSnakeCase(responseClassName)}_response', dataType];
// }
//
// void writeDataList(StringBuffer buffer, String modelName){
//   buffer.writeln('        data: (json[\'data\'] as List<dynamic>)');
//   buffer.writeln('            .map((e) => $modelName.fromJson(e))');
//   buffer.writeln('            .toList(),');
// }
//
// void writeData(StringBuffer buffer, String modelName){
//   buffer.writeln('        data: $modelName.fromJson(json[\'data\']),');
// }
//
// void writeDataModelClass({
//   required StringBuffer buffer,
//   required String modelName,
//   required Map<String, dynamic> jsonMap,
//   required bool isDataList,
// }){
//   buffer.writeln('class $modelName extends Equatable {');
//
//   ///Attributes
//   Map<String, dynamic> keys = getDataKeys(jsonMap ,isDataList);
//   Map<String, String> attributes = <String, String>{}; // example: key = id, value = int
//   keys.forEach((String key, value) {
//     String variableName = key;
//     if(isSnakeCase(key)){
//       variableName = snakeToCamelCase(key);
//     }
//     String valueInStr = getDartType(value);
//     buffer.writeln('  final $valueInStr? $variableName;');
//     attributes.putIfAbsent(variableName, () => valueInStr);
//   });
//   buffer.writeln();
//
//   ///Named Argument Constructor
//   buffer.writeln('  const $modelName({');
//   attributes.forEach((String key, String value) {
//     buffer.writeln('    this.$key,');
//   });
//   buffer.writeln('  });\n');
//
//   ///FromJson
//   buffer.writeln('  factory $modelName.fromJson(Map<String, dynamic> json) => $modelName(');
//   attributes.forEach((String key, String value) {
//     String jsonKeyName = 'json[\'${camelToSnakeCase(key)}\']';
//     if(value == 'int'){
//       buffer.writeln('    $key: $jsonKeyName != null? int.tryParse($jsonKeyName.toString()): null,');
//     }
//     else if(value == 'double'){
//       buffer.writeln('    $key: $jsonKeyName != null? double.tryParse($jsonKeyName.toString()): null,');
//     }
//     else if(value == 'List<dynamic>'){
//       buffer.writeln('    $key: $jsonKeyName != null? $jsonKeyName as List<dynamic> : null,');
//
//     }
//     else if(value == 'Map<String, dynamic>'){
//       buffer.writeln('    $key: $jsonKeyName != null? $jsonKeyName as Map<String, dynamic> : null,');
//     }
//     else{
//       buffer.writeln('    $key: $jsonKeyName,');
//     }
//   });
//   buffer.writeln('  );\n');
//
//
//   ///ToJson
//   buffer.writeln('  Map<String, dynamic> toJson() => {');
//   attributes.forEach((String key, String value){
//     String snakeKey = camelToSnakeCase(key);
//     buffer.writeln('    \'$snakeKey\': $key,');
//   });
//   buffer.writeln('  };\n');
//
//   ///CopyWith
//   buffer.writeln('  $modelName copyWith({');
//   attributes.forEach((String key, String value){
//     buffer.writeln('    $value? $key,');
//   });
//   buffer.writeln('  }) {');
//   buffer.writeln('    return $modelName(');
//   attributes.forEach((String key, String value){
//     buffer.writeln('      $key: $key ?? this.$key,');
//   });
//   buffer.writeln('    );');
//   buffer.writeln('  }\n');
//
//
//   ///Equatable props
//   buffer.writeln('  @override');
//   buffer.writeln('  List<Object?> get props => <Object?>[');
//   attributes.forEach((String key, String value){
//     buffer.writeln('    $key,');
//   });
//   buffer.writeln('  ];\n');
//
//   ///End of Data Class
//   buffer.writeln('}\n');
// }
//
// {
//   bool isCoreUseCaseImports = false;
//   String className = capitalizeFirstChar(feature);
//   List<String> lines = file.readAsLinesSync();
//   int importsIndex = -1, functionsIndex = -1;
//   int index = -1;
//   for(String line in lines){
//     index++;
//     if(line == "import '../../../../../core/error/failures.dart';"){
//       importsIndex = index + 1;
//     }
//     if(line == 'abstract class ${className}Repository {'){
//       functionsIndex = index + 1;
//     }
//
//     if(line == 'import \'../../../../core/usecases/usecase.dart\';'){
//       isCoreUseCaseImports = true;
//     }
//
//   }
//
//   ///Imports StringBuffer
//   final StringBuffer importsBuffer = StringBuffer();
//   for(Map<String, String?> item in filesImport){
//     if(item['entity'] != null){
//       importsBuffer.writeln('import \'../../domain/entities/${item['entity']}.dart\';');
//     }
//     if(item['usecase'] == '../../../../core/usecases/usecases' && isCoreUseCaseImports){
//       continue;
//     }
//     importsBuffer.writeln('import \'${item['usecase']}.dart\';');
//   }
//
//   ///Functions StringBuffer
//   final StringBuffer functionsBuffer = StringBuffer();
//   for(final Map<String, StringBuffer> item in functions){
//     functionsBuffer.write(item['repositoryFunc']);
//   }
//
//
//   final StringBuffer contentsBuffer = StringBuffer();
//   int i = -1;
//   for(String line in lines){
//     i++;
//     if(i == importsIndex){
//       contentsBuffer.write(importsBuffer.toString());
//     } else if(i == functionsIndex){
//       contentsBuffer.write(functionsBuffer.toString());
//     }
//     contentsBuffer.writeln(line);
//   }
//
//   // Write the content to a Dart file
//   file.writeAsStringSync(contentsBuffer.toString());
// }
