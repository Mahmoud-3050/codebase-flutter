import '../../../../utils/enums.dart';
import '../../../../utils/extension.dart';
import '../../../models/generate_model.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class EntityRequestBuffers extends BaseRequestBuffers{
  
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:equatable/equatable.dart';");
    return buffer;
  }
  
  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    String modelName = request.modelClassNames.classCase;
    DartType? dataType = request.dartType;

    ///-> Response Model
    buffer.writeln(_generateResponseModel(
      response: request.response,
      responseClassName: responseClassName,
      modelName: modelName,
      dataType: dataType,
    ).toString());

    ///-> Data Model
    if(dataType != null && (dataType == DartType.model || dataType == DartType.listModel)){
      Map<String, dynamic> dataMap = <String, dynamic>{};
      if(dataType == DartType.model){
        dataMap = request.response['data'];
      }
      if(dataType == DartType.listModel){
        dataMap = request.response['data'][0];
      }
      fetchJsonKeys(modelName, dataMap);
      for(int i=models.length-1; i>=0; i--){
        buffer.writeln(models[i].entityBuffer.toString());
      }

      // buffer.writeln(_generateDataModel(
      //   dataMap: dataMap,
      //   modelName: modelName,
      // ).toString());
    }

    return buffer;
  }



  StringBuffer _generateResponseModel({
    required String responseClassName,
    required Map<String, dynamic> response,
    required String modelName,
    DartType? dataType,
  }){
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('class ${responseClassName}Response extends Equatable{');
    Map<String, String> attributes = <String, String>{};
    for(MapEntry<String, dynamic> entry in response.entries){
      if(entry.key == 'data'){
        continue;
      }
      final Names keyNames = Names.fromString(entry.key);
      DartType type = DartTypeExtension.fromType(value: entry.value);
      String typeStr = type.typeName(modelClass: keyNames.classCase);
      buffer.writeln('  final $typeStr ${keyNames.camelCase};');
      attributes.putIfAbsent(keyNames.camelCase, () => typeStr);
    }

    // if(isDataModel){
    //   if(isDataList){
    //     buffer.writeln('  final List<$modelName> data;');
    //   }else if(dataType == 'Map'){
    //     buffer.writeln('  final $modelName data;');
    //   }else {
    //     buffer.writeln('  final $dataType data;');
    //   }
    // }
    if(dataType != null){
      buffer.writeln('  final ${dataType.typeName(modelClass: modelName)} data;');
    }


    buffer.writeln();
    buffer.writeln('  const ${responseClassName}Response({');
    for(MapEntry<String, dynamic> attribute in attributes.entries){
      buffer.writeln('    required this.${attribute.key},');
    }
    if(dataType != null){
      buffer.writeln('    required this.data,');
    }
    buffer.writeln('  });\n');
    ///Equatable props
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[');
    for(MapEntry<String, dynamic> attribute in attributes.entries){
      buffer.writeln('    ${attribute.key},');
    }
    if(dataType != null){
      buffer.writeln('    data,');
    }
    buffer.writeln('  ];');
    buffer.writeln('}\n');
    return buffer;
  }


  List<GenerateModel> models = <GenerateModel>[];
  void fetchJsonKeys(String key, Map<String, dynamic> dataMap){
    for(MapEntry<String, dynamic> entry in dataMap.entries){
      if(entry.value is Map){
        fetchJsonKeys(entry.key, entry.value);
      }
      if(entry.value is List && entry.value.isNotEmpty && entry.value[0] is Map){
        String key = entry.key;
        if(entry.key.endsWith('s')){
          String classNameWithoutSInLastChar = entry.key
              .substring(0, entry.key.length - 1);
          key = classNameWithoutSInLastChar;
        }
        fetchJsonKeys(key, entry.value[0]);
      }
    }
    models.add(GenerateModel.generate(
      name: key,
      map: dataMap,
      parent: key,
    ));
  }

}