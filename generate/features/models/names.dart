import '../../utils/exceptions.dart';
import '../../utils/names_helper.dart';

class Names {
  final String original;
  final String camelCase;
  final String snakeCase;
  final String classCase;
  final String dashedCase;

  const Names({
    required this.original,
    required this.snakeCase,
    required this.camelCase,
    required this.classCase,
    required this.dashedCase,
  });

  factory Names.fromString(String input) {
    if (input.trim().isEmpty) {
      throw NamesException('Input name cannot be empty (input: "$input")');
    }

    try {
      final String snake = NamesHelper.toSnakeCase(input);
      if (snake.isEmpty) {
        throw NamesException('Input "$input" resulted in an empty name');
      }
      return Names(
        original: input,
        snakeCase: snake,
        camelCase: NamesHelper.snakeToCamelCase(snake),
        classCase: NamesHelper.snakeToClassCase(snake),
        dashedCase: NamesHelper.toDashedCase(snake),
      );
    } on NamesException {
      rethrow;
    } catch (e) {
      throw NamesException('Error processing name "$input": $e');
    }
  }

  factory Names.fromSnakeCase(String snake) {
    return Names(
      original: snake,
      snakeCase: snake,
      camelCase: NamesHelper.snakeToCamelCase(snake),
      classCase: NamesHelper.snakeToClassCase(snake),
      dashedCase: snake.replaceAll('_', '-'),
    );
  }

  Names copyWith({
    String? original,
    String? snakeCase,
    String? camelCase,
    String? classCase,
    String? dashedCase,
  }) {
    return Names(
      original: original ?? this.original,
      snakeCase: snakeCase ?? this.snakeCase,
      camelCase: camelCase ?? this.camelCase,
      classCase: classCase ?? this.classCase,
      dashedCase: dashedCase ?? this.dashedCase,
    );
  }
}
