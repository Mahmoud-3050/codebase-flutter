class NamesException implements Exception {
  final String message;
  const NamesException(this.message);

  @override
  String toString() => 'NamesException: $message';
}

class ColorException implements Exception {
  final String message;
  const ColorException(this.message);

  @override
  String toString() => 'ColorException: $message';
}