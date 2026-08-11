class NamesException implements Exception {
  final String message;
  const NamesException(this.message);

  @override
  String toString() => 'NamesException: $message';
}

class DartTypeException implements Exception {
  final String message;
  const DartTypeException(this.message);

  @override
  String toString() => 'DartTypeException: $message';
}