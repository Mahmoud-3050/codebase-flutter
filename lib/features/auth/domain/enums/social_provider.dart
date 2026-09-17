enum SocialProvider {
  google(wireName: 'google'),
  apple(wireName: 'apple');

  const SocialProvider({required this.wireName});

  final String wireName;

  static SocialProvider fromWireName(String value) =>
      SocialProvider.values.firstWhere(
        (SocialProvider provider) => provider.wireName == value,
        orElse: () => SocialProvider.google,
      );
}
