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
    List<String> parts =
        input.split('_').where((part) => part.isNotEmpty).toList();
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
}
