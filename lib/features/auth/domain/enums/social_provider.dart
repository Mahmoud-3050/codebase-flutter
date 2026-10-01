enum SocialProvider {
  google(wireName: 'google'),
  apple(wireName: 'apple');

  const SocialProvider({required this.wireName});

  final String wireName;

  static SocialProvider fromWireName(String value) {
    for (final SocialProvider provider in SocialProvider.values) {
      if (provider.wireName == value) {
        return provider;
      }
    }
    throw FormatException('Unknown social provider: $value');
  }
}
