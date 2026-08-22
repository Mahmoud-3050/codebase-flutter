enum DeviceType {
  android,
  ios,
}

enum UserType {
  firstOpen, //WelcomeScreen
  login, // LoginScreen
  company, // HomeScreen
  student, // HomeScreen
  guest, // HomeScreen
}

enum AppUpdateType {
  flexible,
  immediately,
}

enum JobLocationType {
  inPerson(title: 'In-Person', paramKey: 'in-person'),
  remote(title: 'Remote', paramKey: 'remote');

  final String title;
  final String paramKey;

  const JobLocationType({
    required this.title,
    required this.paramKey,
  });

  bool get isRemote => this == remote;

  static JobLocationType fromString(String value) => JobLocationType.values
      .firstWhere((JobLocationType element) => element.paramKey == value,
          orElse: () => JobLocationType.inPerson);
}
