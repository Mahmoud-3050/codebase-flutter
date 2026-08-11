enum DeviceType{
  android,
  ios,
}

enum Themes {
  light,
  dark,
}

enum UserType {
  firstOpen, //WelcomeScreen
  login, // LoginScreen
  company, // HomeScreen
  student, // HomeScreen
  guest, // HomeScreen
}

enum ProductBuyMethod{
  all('all'),
  withEdit('with_edit'),
  buy('buy');
  
  final String name;
  const ProductBuyMethod(this.name);
}

enum AppUpdateType{
  flexible,
  immediately,
}

enum JobLocationType{
  inPerson(title: 'In-Person', paramKey: 'in-person'),
  remote(title: 'Remote', paramKey: 'remote');

  final String title;
  final String paramKey;

  const JobLocationType({
    required this.title,
    required this.paramKey,
  });

  bool get isRemote => this == remote;
}

enum DegreeType {
  any(title: 'Any', paramKey: 'Any'),
  bachelor(title: 'Bachelor’s', paramKey: 'Bachelor'),
  associates(title: 'Associates', paramKey: 'Associates');

  final String title;
  final String paramKey;

  const DegreeType({
    required this.title,
    required this.paramKey,
  });


}