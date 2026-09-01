class Endpoint {
  final String endpoint;
  final bool hasParams;
  final bool hasQueryParams;
  final List<String> terms;

  const Endpoint({
    required this.endpoint,
    required this.hasParams,
    required this.hasQueryParams,
    required this.terms,
  });

  Endpoint copyWith({
    String? endpoint,
    bool? hasParams,
    bool? hasQueryParams,
    List<String>? terms,
  }) {
    return Endpoint(
      endpoint: endpoint ?? this.endpoint,
      hasParams: hasParams ?? this.hasParams,
      hasQueryParams: hasQueryParams ?? this.hasQueryParams,
      terms: terms ?? this.terms,
    );
  }
}
