import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../models/generate_model.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class ModelRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      "import '../../domain/entities/${requestNameSnakeCase}_response.dart';",
    );
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
    buffer.writeln(
      _generateResponseModel(
        response: request.response,
        responseClassName: responseClassName,
        modelName: modelName,
        dataType: dataType,
      ).toString(),
    );

    ///-> Data Model
    if (dataType != null && (dataType == .model || dataType == .listModel)) {
      Map<String, dynamic> dataMap = <String, dynamic>{};
      if (dataType == .model) {
        dataMap = request.response['data'];
      }
      if (dataType == .listModel) {
        dataMap = request.response['data'][0];
      }
      fetchJsonKeys(modelName, dataMap);
      for (int i = models.length - 1; i >= 0; i--) {
        buffer.writeln(models[i].modelBuffer.toString());
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
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
      'class ${responseClassName}Model extends ${responseClassName}Response {',
    );
    buffer.writeln('  const ${responseClassName}Model({');
    Map<String, String> attributes = <String, String>{};
    for (MapEntry<String, dynamic> entry in response.entries) {
      if (entry.key == 'data') {
        continue;
      }
      final Names keyNames = Names.fromString(entry.key);
      String valueInStr = getDartType(entry.value);
      buffer.writeln('    required super.${keyNames.camelCase},');
      attributes.putIfAbsent(keyNames.camelCase, () => valueInStr);
    }

    // if(isDataModel){
    //   buffer.writeln('    required super.data,');
    // }
    if (dataType != null) {
      buffer.writeln('    required super.data,');
    }
    buffer.writeln('  });');
    buffer.writeln();

    ///-> fromJson
    buffer.writeln(
      '  factory ${responseClassName}Model.fromJson(Map<String, dynamic> json) =>',
    );
    buffer.writeln('      ${responseClassName}Model(');
    for (MapEntry<String, dynamic> attribute in attributes.entries) {
      final Names keyNames = Names.fromString(attribute.key);
      String stringTermNull = "?? ''";
      if (attribute.value == 'bool') {
        stringTermNull = '?? true';
      }
      buffer.writeln(
        "        ${attribute.key}: json['${keyNames.snakeCase}'] $stringTermNull,",
      );
    }
    // if(isDataModel){
    //   if(isDataList){
    //     buffer.writeln("        data: (json['data'] as List<dynamic>)");
    //     buffer.writeln('            .map((dynamic e) => ${modelName}Model.fromJson(e))');
    //     buffer.writeln('            .toList(),');
    //   }else if(dataType == 'Map'){
    //     buffer.writeln("        data: ${modelName}Model.fromJson(json['data']),");
    //   } else {
    //     buffer.writeln("        data: json['data'],");
    //   }
    // }
    if (dataType != null && dataType == .listModel) {
      buffer.writeln("        data: (json['data'] as List<dynamic>)");
      buffer.writeln(
        '            .map((dynamic e) => ${modelName}Model.fromJson(e))',
      );
      buffer.writeln('            .toList(),');
    } else if (dataType != null && dataType == .model) {
      buffer.writeln("        data: ${modelName}Model.fromJson(json['data']),");
    } else if (dataType != null) {
      buffer.writeln("        data: json['data'] as ${dataType.typeName()},");
    }

    buffer.writeln('      );');
    buffer.writeln('}');
    buffer.writeln();
    return buffer;
  }

  List<GenerateModel> models = <GenerateModel>[];
  void fetchJsonKeys(String key, Map<String, dynamic> dataMap) {
    for (MapEntry<String, dynamic> entry in dataMap.entries) {
      if (entry.value is Map) {
        fetchJsonKeys(entry.key, entry.value);
      }
      if (entry.value is List &&
          entry.value.isNotEmpty &&
          entry.value[0] is Map) {
        String key = entry.key;
        if (entry.key.endsWith('s')) {
          String classNameWithoutSInLastChar = entry.key.substring(
            0,
            entry.key.length - 1,
          );
          key = classNameWithoutSInLastChar;
        }
        fetchJsonKeys(key, entry.value[0]);
      }
    }
    models.add(GenerateModel.generate(name: key, map: dataMap, parent: key));
  }
}
