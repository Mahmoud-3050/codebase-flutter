enum DeviceType {
  android,
  ios;

  bool get isAndroid => this == android;
  bool get isIOS => this == ios;

  static DeviceType fromString(String value) =>
      DeviceType.values.firstWhere((DeviceType element) => element.name == value, orElse: () => .android);
}

enum UserType {
  firstOpen, //WelcomeScreen
  loggedIn, // HomeScreen
  guest; // HomeScreen

  bool get isFirstOpen => this == firstOpen;
  bool get isLoggedIn => this == loggedIn;
  bool get isGuest => this == guest;

  static UserType fromString(String value) =>
      UserType.values.firstWhere((UserType element) => element.name == value, orElse: () => .guest);
}

enum AppUpdateType {
  flexible,
  immediately;

  bool get isFlexible => this == flexible;
  bool get isImmediately => this == immediately;

  static AppUpdateType fromString(String value) =>
      AppUpdateType.values.firstWhere((AppUpdateType element) => element.name == value, orElse: () => .flexible);
}
