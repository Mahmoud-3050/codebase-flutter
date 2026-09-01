import 'dart:core';
import 'dart:core' as core;

enum ModeType {
  protected(0),
  generate(1),
  modify(2),
  delete(3);

  final int code;
  const ModeType(this.code);

  static ModeType fromCode(int code) => switch (code) {
    1 => .generate,
    2 => .modify,
    3 => .delete,
    _ => .protected,
  };
}

enum RequestType {
  get,
  post,
  put,
  patch,
  delete;

  static RequestType? fromString(String value) {
    final String normalized = value.trim().toLowerCase();
    for (final RequestType type in RequestType.values) {
      if (type.name == normalized) {
        return type;
      }
    }
    return null;
  }
}

enum DartType {
  int,
  double,
  bool,
  string,
  list,
  listString,
  listInt,
  listDouble,
  listBool,
  listModel,
  model,
  dynamicType;

  static DartType fromType({required dynamic value}) {
    if (value is core.int) {
      return DartType.int;
    }
    if (value is core.double) {
      return DartType.double;
    }
    if (value is core.bool) {
      return DartType.bool;
    }
    if (value is String) {
      return DartType.string;
    }
    if (value is List) {
      if (value.isNotEmpty) {
        final dynamic first = value.first;
        if (first is String) return DartType.listString;
        if (first is core.double) return DartType.listDouble;
        if (first is core.int) return DartType.listInt;
        if (first is core.bool) return DartType.listBool;
        if (first is Map) return DartType.listModel;
      }
      return DartType.list;
    }
    if (value is Map) {
      return DartType.model;
    }
    return DartType.dynamicType;
  }

  String typeName({String modelClass = 'Data'}) => switch (this) {
    .int => 'int',
    .double => 'double',
    .bool => 'bool',
    .string => 'String',
    .list => 'List<dynamic>',
    .listString => 'List<String>',
    .listInt => 'List<int>',
    .listDouble => 'List<double>',
    .listBool => 'List<bool>',
    .listModel => 'List<$modelClass>',
    .model => modelClass,
    .dynamicType => 'dynamic',
  };

  core.bool get isList => switch (this) {
    DartType.list ||
    DartType.listString ||
    DartType.listInt ||
    DartType.listDouble ||
    DartType.listBool ||
    .listModel => true,
    _ => false,
  };
}
