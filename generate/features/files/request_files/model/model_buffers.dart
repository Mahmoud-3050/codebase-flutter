import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/json_meta.dart';
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
    buffer.writeln("import '../../../../core/utils/extensions.dart';");
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
    final String responseClassName = request.names.classCase;
    final String modelName = request.modelClassNames.classCase;
    final DartType? dataType = request.dartType;

    buffer.writeln(
      _generateResponseModel(
        response: request.response,
        responseClassName: responseClassName,
        modelName: modelName,
        dataType: dataType,
      ).toString(),
    );

    if (dataType != null && (dataType == .model || dataType == .listModel)) {
      Map<String, dynamic> dataMap = <String, dynamic>{};
      if (dataType == .model) {
        dataMap = JsonMeta.asStringKeyedMap(request.response['data']);
      }
      if (dataType == .listModel) {
        dataMap = JsonMeta.asStringKeyedMap(
          (request.response['data'] as List).first,
        );
      }
      final List<GenerateModel> models = GenerateModel.collectModels(
        rootName: modelName,
        dataMap: dataMap,
      );
      for (int i = models.length - 1; i >= 0; i--) {
        buffer.writeln(models[i].modelBuffer.toString());
      }
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
    final Map<String, String> attributes = <String, String>{};
    for (final MapEntry<String, dynamic> entry in JsonMeta.strip(
      response,
    ).entries) {
      if (entry.key == 'data') {
        continue;
      }
      final Names keyNames = Names.fromString(entry.key);
      final String valueInStr = getDartType(entry.value);
      buffer.writeln('    required super.${keyNames.camelCase},');
      attributes.putIfAbsent(keyNames.camelCase, () => valueInStr);
    }

    if (dataType != null) {
      buffer.writeln('    required super.data,');
    }
    buffer.writeln('  });');
    buffer.writeln();

    buffer.writeln(
      '  factory ${responseClassName}Model.fromJson(Map<String, dynamic> json) =>',
    );
    buffer.writeln('      ${responseClassName}Model(');
    for (final MapEntry<String, dynamic> attribute in attributes.entries) {
      final Names keyNames = Names.fromString(attribute.key);
      buffer.writeln(
        "        ${attribute.key}: (json['${keyNames.snakeCase}'] as Object?).toStringOrEmpty(),",
      );
    }
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
}
