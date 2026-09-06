import 'dart:io';

extension StringCasingExtension on String {
  String toLowerCaseFirstChar() {
    if (isEmpty) return this;
    return this[0].toLowerCase() + substring(1);
  }

  String toCapitalizeFirstChar() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String get parentDirectoryPath {
    final List<String> segments = split('/');
    if (segments.length <= 1) return '';
    return segments.sublist(0, segments.length - 1).join('/');
  }
}

String lowerCaseFirstChar(String input) => input.toLowerCaseFirstChar();

String capitalizeFirstChar(String input) => input.toCapitalizeFirstChar();

File createFile(String path) {
  final File file = File(path);
  file.createSync(recursive: true);
  return file;
}

void createDirectory(String path) {
  final Directory directory = Directory(path);
  directory.createSync(recursive: true);
}

String getDartType(dynamic value) {
  if (value is int) {
    return 'int';
  } else if (value is double) {
    return 'double';
  } else if (value is String) {
    return 'String';
  } else if (value is bool) {
    return 'bool';
  } else if (value is List) {
    return 'List<dynamic>';
  } else if (value is Map) {
    return 'Map<String, dynamic>';
  } else {
    return 'dynamic';
  }
}

/// [typeOverride] wins when present. Otherwise keys ending in `_at` / `_date`
/// or containing `date` are treated as DateTime.
bool isDateTimeField(String jsonKey, {String? typeOverride}) {
  if (typeOverride != null && typeOverride.trim().isNotEmpty) {
    return typeOverride.trim().toLowerCase() == 'datetime';
  }
  final String lower = jsonKey.toLowerCase();
  return lower.endsWith('_at') ||
      lower.endsWith('_date') ||
      lower.contains('date');
}

bool isFileParamType(String? type) {
  final String normalized = type?.trim().toLowerCase() ?? '';
  return normalized == 'file' || normalized == 'image';
}

bool isPrimitiveDartType(String dartType) {
  return dartType == 'int' ||
      dartType == 'double' ||
      dartType == 'String' ||
      dartType == 'bool' ||
      dartType == 'dynamic' ||
      dartType == 'DateTime' ||
      dartType == 'File' ||
      dartType.startsWith('List');
}

String defaultValueForDartType(String dartType) {
  return switch (dartType) {
    'int' => '0',
    'double' => '0.0',
    'String' => "''",
    'bool' => 'false',
    'File' => "File('test')",
    _ => 'null',
  };
}

String fallbackValueForDartType(String dartType) {
  return switch (dartType) {
    'int' => '?? 0',
    'double' => '?? 0.0',
    'String' => "?? ''",
    'bool' => '?? false',
    _ => '!',
  };
}

String singularizeKey(String key) {
  if (key.endsWith('s') && key.length > 1) {
    return key.substring(0, key.length - 1);
  }
  return key;
}

Map<String, dynamic> getDataKeys(
  Map<String, dynamic> jsonMap,
  bool isDataList,
) {
  if (jsonMap['result'] == null || jsonMap['result']['data'] == null) {
    return <String, dynamic>{};
  }
  if (isDataList) {
    final List<dynamic> listData = jsonMap['result']['data'] as List<dynamic>;
    if (listData.isEmpty) {
      return <String, dynamic>{};
    } else {
      return listData[0] as Map<String, dynamic>;
    }
  } else {
    return jsonMap['result']['data'] as Map<String, dynamic>;
  }
}
