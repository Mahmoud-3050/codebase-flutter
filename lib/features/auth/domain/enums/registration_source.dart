enum RegistrationSource {
  phone(wireName: 'phone'),
  google(wireName: 'google'),
  apple(wireName: 'apple');

  const RegistrationSource({required this.wireName});

  final String wireName;

  bool get locksPhone => this == RegistrationSource.phone;

  bool get locksEmail =>
      this == RegistrationSource.google || this == RegistrationSource.apple;

  static RegistrationSource fromWireName(String value) {
    for (final RegistrationSource source in RegistrationSource.values) {
      if (source.wireName == value) {
        return source;
      }
    }
    throw FormatException('Unknown registration source: $value');
  }
}
