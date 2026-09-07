import '../../../../utils/enums.dart';
import '../../../../utils/extension.dart';
import '../../../../utils/json_meta.dart';
import '../../../models/generate_model.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class EntityRequestBuffers extends BaseRequestBuffers {
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

    if (request.usesSharedEntity) {
      return buffer;
    }

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
        buffer.writeln(models[i].entityBuffer.toString());
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
    buffer.writeln('class ${responseClassName}Response extends Equatable{');
    final Map<String, String> attributes = <String, String>{};
    for (final MapEntry<String, dynamic> entry in JsonMeta.strip(
      response,
    ).entries) {
      if (Request.isEnvelopeKey(entry.key)) {
        continue;
      }
      final Names keyNames = Names.fromString(entry.key);
      final DartType type = DartTypeExtension.fromType(value: entry.value);
      final String typeStr = type.typeName(modelClass: keyNames.classCase);
      buffer.writeln('  final $typeStr ${keyNames.camelCase};');
      attributes.putIfAbsent(keyNames.camelCase, () => typeStr);
    }

    if (dataType != null) {
      buffer.writeln(
        '  final ${dataType.typeName(modelClass: modelName)} data;',
      );
    }
    final bool hasPagination = response[Request.paginationKey] is Map;
    if (hasPagination) {
      buffer.writeln('  final PaginationMeta pagination;');
    }

    buffer.writeln();
    buffer.writeln('  const ${responseClassName}Response({');
    for (final MapEntry<String, dynamic> attribute in attributes.entries) {
      buffer.writeln('    required this.${attribute.key},');
    }
    if (dataType != null) {
      buffer.writeln('    required this.data,');
    }
    if (hasPagination) {
      buffer.writeln('    required this.pagination,');
    }
    buffer.writeln('  });\n');

    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[');
    for (final MapEntry<String, dynamic> attribute in attributes.entries) {
      buffer.writeln('    ${attribute.key},');
    }
    if (dataType != null) {
      buffer.writeln('    data,');
    }
    if (hasPagination) {
      buffer.writeln('    pagination,');
    }
    buffer.writeln('  ];');
    buffer.writeln('}\n');
    return buffer;
  }
}
