import '../../utils/functions.dart';
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

  factory GenerateModel.generate({
    required String name,
    required Map<String, dynamic> map,
    required String parent,
  }) {
    ///-> Names
    final Names names = Names.fromString(name);

    ///-> Attributes
    Map<Names, String> attributes = <Names, String>{};
    for (MapEntry<String, dynamic> entry in map.entries) {
      Names keyNames = Names.fromString(entry.key);
      String dartType = getDartType(entry.value);
      if (dartType.startsWith('Map')) {
        dartType = keyNames.classCase;
      } else if (dartType.startsWith('List')) {
        final List<dynamic> list = entry.value as List<dynamic>;
        if (list.isNotEmpty) {
          if (list[0] is Map) {
            keyNames = keyNames.copyWith(
              classCase: keyNames.classCase.substring(
                0,
                keyNames.classCase.length - 1,
              ),
            );
            dartType = 'List<${keyNames.classCase}>';
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
      }
      attributes.putIfAbsent(keyNames, () => dartType);
    }

    ///-> Buffers
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

  static StringBuffer _generateEntity({
    required Names names,
    required Map<Names, String> attributes,
  }) {
    final StringBuffer buffer = StringBuffer();

    ///-> Entity Class
    buffer.writeln('class ${names.classCase} extends Equatable {');

    ///-> Attributes
    for (MapEntry<Names, String> entry in attributes.entries) {
      if (entry.value == entry.key.classCase) {
        buffer.writeln('  final ${entry.value}? ${entry.key.camelCase};');
      } else {
        buffer.writeln('  final ${entry.value} ${entry.key.camelCase};');
      }
    }

    ///-> Named Argument Constructor
    buffer.writeln();
    buffer.writeln('  const ${names.classCase}({');
    attributes.forEach((Names keyNames, String value) {
      buffer.writeln('    required this.${keyNames.camelCase},');
    });
    buffer.writeln('  });\n');

    ///CopyWith
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

    ///Equatable props
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => <Object?>[');
    attributes.forEach((Names keyNames, String value) {
      buffer.writeln('    ${keyNames.camelCase},');
    });
    buffer.writeln('  ];');
    buffer.writeln();

    ///End of Data Class
    buffer.writeln('}');

    return buffer;
  }

  static StringBuffer _generateModel({
    required Names names,
    required Map<Names, String> attributes,
  }) {
    final StringBuffer buffer = StringBuffer();

    ///-> Entity Class
    buffer.writeln(
      'class ${names.classCase}Model extends ${names.classCase} {',
    );
    buffer.writeln('  const ${names.classCase}Model({');

    ///-> Attributes
    for (MapEntry<Names, dynamic> entry in attributes.entries) {
      buffer.writeln('    required super.${entry.key.camelCase},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    ///-> FromJson
    buffer.writeln(
      '  factory ${names.classCase}Model.fromJson(Map<String, dynamic> json) => ${names.classCase}Model(',
    );
    attributes.forEach((Names key, String value) {
      String jsonKeyName = 'json[\'${key.snakeCase}\']';
      if (value == 'int') {
        buffer.writeln(
          '    ${key.camelCase}: $jsonKeyName != null? num.tryParse($jsonKeyName.toString())?.toInt()?? 0: 0,',
        );
      } else if (value == 'double') {
        buffer.writeln(
          '    ${key.camelCase}: $jsonKeyName != null? num.tryParse($jsonKeyName.toString())?.toDouble()?? 0.0: 0.0,',
        );
      } else if (value.contains('List')) {
        String fromJsonStr = '';
        String modelName = '';
        if (value == 'List<dynamic>') {
          buffer.writeln(
            '    ${key.camelCase}: $jsonKeyName != null? $jsonKeyName as List<dynamic> : <dynamic>[]',
          );
        } else if (value == 'List<String>') {
          modelName = 'String';
          fromJsonStr = "e?.toString()?? ''";
        } else if (value == 'List<int>') {
          modelName = 'int';
          fromJsonStr = 'num.tryParse(e.toString())?.toInt()?? 0';
        } else if (value == 'List<double>') {
          modelName = 'double';
          fromJsonStr = 'num.tryParse(e.toString())?.toDouble()?? 0.0';
        } else if (value == 'List<bool>') {
          modelName = 'bool';
          fromJsonStr = "e?.toString() == 'true' ? true : false";
        } else {
          modelName = key.classCase;
          fromJsonStr = '${modelName}Model.fromJson(e)';
        }

        buffer.writeln(
          '    ${key.camelCase}: $jsonKeyName != null? ($jsonKeyName as List<dynamic>)'
          '.map((dynamic e) => $fromJsonStr).toList() : '
          'const <$modelName>[],',
        );
      } else if (value == key.classCase) {
        buffer.writeln(
          '    ${key.camelCase}: $jsonKeyName != null? ${key.classCase}Model.fromJson($jsonKeyName) : null,',
        );
      } else if (value == 'bool') {
        buffer.writeln(
          "    ${key.camelCase}: $jsonKeyName != null? $jsonKeyName.toString() == 'true' ? true : false : false,",
        );
      } else {
        buffer.writeln("    ${key.camelCase}: $jsonKeyName ?? '',");
      }
    });
    buffer.writeln('  );\n');

    // ///-> ToJson
    // buffer.writeln('  static Map<String, dynamic> toJson(${names.classCase}? value) => <String, dynamic>{');
    // attributes.forEach((Names key, String value){
    //   if(value.startsWith('Map')){
    //     buffer.writeln("    '${key.snakeCase}': ${key.classCase}Model.toJson(value?.${key.camelCase}),");
    //   }else{
    //     buffer.writeln("    '${key.snakeCase}': value?.${key.camelCase},");
    //   }
    // });
    // buffer.writeln('  };\n');

    ///-> End of Data Class
    buffer.writeln('}\n');

    return buffer;
  }
}
