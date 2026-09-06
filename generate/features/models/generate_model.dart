import '../../utils/functions.dart';
import '../../utils/json_meta.dart';
import 'names.dart';

class GenerateModel {
  final Names names;
  final Map<String, dynamic> map;
  final Map<Names, String> attributes;
  final String parent;
  final StringBuffer entityBuffer;
  final StringBuffer modelBuffer;

  GenerateModel({
    required this.names,
    required this.map,
    required this.attributes,
    required this.parent,
    required this.entityBuffer,
    required this.modelBuffer,
  });

  static List<GenerateModel> collectModels({
    required String rootName,
    required Map<String, dynamic> dataMap,
  }) {
    final List<GenerateModel> models = <GenerateModel>[];

    void fetchJsonKeys(String key, Map<String, dynamic> currentMap) {
      final Map<String, String> classNameOverrides =
          JsonMeta.classNameOverrides(currentMap);
      final Map<String, dynamic> fields = JsonMeta.strip(currentMap);

      for (final MapEntry<String, dynamic> entry in fields.entries) {
        if (entry.value is Map) {
          final String nestedName = classNameOverrides[entry.key] ?? entry.key;
          fetchJsonKeys(nestedName, JsonMeta.asStringKeyedMap(entry.value));
        }
        if (entry.value is List &&
            (entry.value as List).isNotEmpty &&
            (entry.value as List).first is Map) {
          final String nestedName =
              classNameOverrides[entry.key] ?? singularizeKey(entry.key);
          fetchJsonKeys(
            nestedName,
            JsonMeta.asStringKeyedMap((entry.value as List).first),
          );
        }
      }
      models.add(
        GenerateModel.generate(name: key, map: currentMap, parent: key),
      );
    }

    fetchJsonKeys(rootName, dataMap);
    return models;
  }

  factory GenerateModel.generate({
    required String name,
    required Map<String, dynamic> map,
    required String parent,
  }) {
    final Names names = Names.fromString(name);
    final Map<String, String> classNameOverrides = JsonMeta.classNameOverrides(
      map,
    );
    final Map<String, String> typeOverrides = JsonMeta.typeOverrides(map);
    final Map<String, dynamic> fields = JsonMeta.strip(map);

    final Map<Names, String> attributes = <Names, String>{};
    for (final MapEntry<String, dynamic> entry in fields.entries) {
      Names keyNames = Names.fromString(entry.key);
      String dartType = getDartType(entry.value);
      if (dartType.startsWith('Map')) {
        dartType = classNameOverrides[entry.key] ?? keyNames.classCase;
        if (classNameOverrides[entry.key] != null) {
          keyNames = keyNames.copyWith(classCase: dartType);
        }
      } else if (dartType.startsWith('List')) {
        final List<dynamic> list = entry.value as List<dynamic>;
        if (list.isNotEmpty) {
          if (list[0] is Map) {
            final String itemClass =
                classNameOverrides[entry.key] ??
                Names.fromString(singularizeKey(entry.key)).classCase;
            keyNames = keyNames.copyWith(classCase: itemClass);
            dartType = 'List<$itemClass>';
          }
          if (list[0] is String) {
            dartType = 'List<String>';
          }
          if (list[0] is int) {
            dartType = 'List<int>';
          }
          if (list[0] is double) {
            dartType = 'List<double>';
          }
          if (list[0] is bool) {
            dartType = 'List<bool>';
          }
        }
      } else if (isDateTimeField(
        entry.key,
        typeOverride: typeOverrides[entry.key],
      )) {
        dartType = 'DateTime';
      }
      attributes.putIfAbsent(keyNames, () => dartType);
    }

    final StringBuffer entityBuffer = _generateEntity(
      names: names,
      attributes: attributes,
    );
    final StringBuffer modelBuffer = _generateModel(
      names: names,
      attributes: attributes,
    );

    return GenerateModel(
      names: names,
      map: map,
      attributes: attributes,
      parent: parent,
      entityBuffer: entityBuffer,
      modelBuffer: modelBuffer,
    );
  }

  static bool _isNullableField(Names keyNames, String dartType) {
    if (dartType == 'DateTime') {
      return true;
    }
    if (dartType.startsWith('List') || isPrimitiveDartType(dartType)) {
      return false;
    }
    return true;
  }

  static StringBuffer _generateEntity({
    required Names names,
    required Map<Names, String> attributes,
  }) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('class ${names.classCase} extends Equatable {');

    for (final MapEntry<Names, String> entry in attributes.entries) {
      if (_isNullableField(entry.key, entry.value)) {
        buffer.writeln('  final ${entry.value}? ${entry.key.camelCase};');
      } else {
        buffer.writeln('  final ${entry.value} ${entry.key.camelCase};');
      }
    }

    buffer.writeln();
    buffer.writeln('  const ${names.classCase}({');
    attributes.forEach((Names keyNames, String value) {
      buffer.writeln('    required this.${keyNames.camelCase},');
    });
    buffer.writeln('  });\n');

    buffer.writeln('  ${names.classCase} copyWith({');
    attributes.forEach((Names keyNames, String value) {
      buffer.writeln('    $value? ${keyNames.camelCase},');
    });
    buffer.writeln('  }) {');
    buffer.writeln('    return ${names.classCase}(');
    attributes.forEach((Names keyNames, String value) {
      buffer.writeln(
        '      ${keyNames.camelCase}: ${keyNames.camelCase} ?? this.${keyNames.camelCase},',
      );
    });
    buffer.writeln('    );');
    buffer.writeln('  }\n');

    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[');
    attributes.forEach((Names keyNames, String value) {
      buffer.writeln('    ${keyNames.camelCase},');
    });
    buffer.writeln('  ];');
    buffer.writeln();

    buffer.writeln('}');

    return buffer;
  }

  static StringBuffer _generateModel({
    required Names names,
    required Map<Names, String> attributes,
  }) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln(
      'class ${names.classCase}Model extends ${names.classCase} {',
    );
    buffer.writeln('  const ${names.classCase}Model({');

    for (final MapEntry<Names, dynamic> entry in attributes.entries) {
      buffer.writeln('    required super.${entry.key.camelCase},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    buffer.writeln(
      '  factory ${names.classCase}Model.fromJson(Map<String, dynamic> json) => ${names.classCase}Model(',
    );
    attributes.forEach((Names key, String value) {
      final String jsonKeyName = 'json[\'${key.snakeCase}\']';
      if (value == 'int') {
        buffer.writeln(
          '    ${key.camelCase}: ($jsonKeyName as Object?).toIntOrZero(),',
        );
      } else if (value == 'double') {
        buffer.writeln(
          '    ${key.camelCase}: ($jsonKeyName as Object?).toDoubleOrZero(),',
        );
      } else if (value == 'DateTime') {
        buffer.writeln(
          '    ${key.camelCase}: ($jsonKeyName as Object?).toDateTimeOrNull(),',
        );
      } else if (value.contains('List')) {
        String fromJsonStr = '';
        String modelName = '';
        if (value == 'List<dynamic>') {
          buffer.writeln(
            '    ${key.camelCase}: $jsonKeyName != null? $jsonKeyName as List<dynamic> : <dynamic>[],',
          );
        } else if (value == 'List<String>') {
          modelName = 'String';
          fromJsonStr = '(e as Object?).toStringOrEmpty()';
        } else if (value == 'List<int>') {
          modelName = 'int';
          fromJsonStr = '(e as Object?).toIntOrZero()';
        } else if (value == 'List<double>') {
          modelName = 'double';
          fromJsonStr = '(e as Object?).toDoubleOrZero()';
        } else if (value == 'List<bool>') {
          modelName = 'bool';
          fromJsonStr = '(e as Object?).toBoolOrFalse()';
        } else {
          final Match? match = RegExp(r'List<(.+)>').firstMatch(value);
          modelName = match?.group(1) ?? key.classCase;
          fromJsonStr = '${modelName}Model.fromJson(e)';
        }

        if (value != 'List<dynamic>') {
          buffer.writeln(
            '    ${key.camelCase}: $jsonKeyName != null? ($jsonKeyName as List<dynamic>)'
            '.map((dynamic e) => $fromJsonStr).toList() : '
            'const <$modelName>[],',
          );
        }
      } else if (value == 'bool') {
        buffer.writeln(
          '    ${key.camelCase}: ($jsonKeyName as Object?).toBoolOrFalse(),',
        );
      } else if (!isPrimitiveDartType(value)) {
        buffer.writeln(
          '    ${key.camelCase}: $jsonKeyName != null? ${value}Model.fromJson($jsonKeyName) : null,',
        );
      } else {
        buffer.writeln(
          '    ${key.camelCase}: ($jsonKeyName as Object?).toStringOrEmpty(),',
        );
      }
    });
    buffer.writeln('  );\n');

    buffer.writeln('}\n');

    return buffer;
  }
}
