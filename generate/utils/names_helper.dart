abstract class NamesHelper {
  static final RegExp validCharactersPattern = RegExp(r'^[A-Za-z0-9_\s]+$');

  static String toSnakeCase(String input) {
    // Replace all non-alphanumeric characters (including spaces) with underscores
    String snakeCase = input.replaceAll(RegExp(r'[^\w]'), '_');

    // Collapse multiple underscores into one
    snakeCase = snakeCase.replaceAll(RegExp(r'_+'), '_');

    // ... conversion logic ...
    if (!snakeCase.contains('_')) {
      String snakeWithoutUnderscore = snakeCase;
      if (isCamelCase(snakeWithoutUnderscore)) {
        snakeCase = camelToSnakeCase(snakeWithoutUnderscore);
      }
      if (isClassCase(snakeWithoutUnderscore)) {
        snakeCase = classToSnakeCase(snakeWithoutUnderscore);
      }
    }

    // Remove leading and trailing underscores and lowercase
    return snakeCase.trim().replaceAll(RegExp(r'^_+|_+$'), '').toLowerCase();
  }

  static bool isSnakeCase(String input) {
    return RegExp(r'^[a-z]+(?:_[a-z0-9]+)*$').hasMatch(input);
  }

  static bool isCamelCase(String input) {
    return RegExp(r'^[a-z]+(?:[A-Z][a-z0-9]*)*$').hasMatch(input);
  }

  static bool isClassCase(String input) {
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(input);
  }

  static String toDashedCase(String input) {
    if (input.isEmpty) return '';
    final String snake = toSnakeCase(input);
    return snake.replaceAll('_', '-');
  }

  static String snakeToCamelCase(String input) {
    List<String> parts = input
        .split('_')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    String camelCase = parts[0];
    for (int i = 1; i < parts.length; i++) {
      camelCase += parts[i][0].toUpperCase() + parts[i].substring(1);
    }
    return camelCase;
  }

  static String snakeToClassCase(String input) {
    return camelToClassCase(snakeToCamelCase(input));
  }

  static String camelToSnakeCase(String input) {
    String snakeCase = '';
    for (int i = 0; i < input.length; i++) {
      String currentChar = input[i];
      if (currentChar == currentChar.toUpperCase()) {
        if (i != 0) {
          snakeCase += '_';
        }
        snakeCase += currentChar.toLowerCase();
      } else {
        snakeCase += currentChar;
      }
    }
    return snakeCase;
  }

  static String camelToClassCase(String input) {
    return input[0].toUpperCase() + input.substring(1);
  }

  static String classToCamelCase(String input) {
    return input[0].toLowerCase() + input.substring(1);
  }

  static String classToSnakeCase(String input) {
    return camelToSnakeCase(classToCamelCase(input));
  }

  /// Dart reserved words that cannot be used as variable names.
  static const Set<String> dartKeywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'Function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  /// Lowercase-leading Dart identifier (not a reserved word).
  static bool isValidDartVariableName(String name) {
    if (name.isEmpty || dartKeywords.contains(name)) return false;
    return RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(name);
  }
}
