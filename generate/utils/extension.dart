import 'enums.dart';

extension RequestTypeExtension on RequestType {
  static RequestType? fromString(String value) => RequestType.fromString(value);
}

extension DartTypeExtension on DartType {
  static DartType fromType({required dynamic value}) =>
      DartType.fromType(value: value);

  String typeName({String modelClass = 'Data'}) =>
      this.typeName(modelClass: modelClass);

  bool get isList => this.isList;
}

extension LineContains on List<String> {
  bool lineContains(String value) {
    for (final String line in this) {
      if (line.contains(value)) {
        return true;
      }
    }
    return false;
  }
}