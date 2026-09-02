import 'package:flutter/material.dart';

import 'app.dart';
import 'core/utils/enums.dart';
import 'init_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppFlavor.activate(.dev);
  await initApp();
  runApp(const App());
}
